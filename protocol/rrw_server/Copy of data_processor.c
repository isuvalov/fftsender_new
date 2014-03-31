#include<data_processor.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <debuglog.h>
#include <math.h>

int MAX_COUNT_FAIL_DETECT;
int do_restore;
int do_recalc_dist;
int do_check_accel;
int check_accel_fails = 0;
int v_avg_n = 0;

mvmt_t mvmt_locked;
rrw_point_t rrw_point_locked;
int harm_locked = 0;
double fharm_locked = 0.0;
int count_fail_detect = 0;

int calculate_sweeps (mvmt_t* mvmt, sweeps_data_t* sweeps_data, int i_start, int i_stop) {
  int i;
  int i_peak_fall = 0, i_peak_rise = 0;

  for (i = i_start; i < i_stop; i++) {
    if ( sweeps_data->rise[i] > sweeps_data->rise[i_peak_rise])
      i_peak_rise = i;
    if ( sweeps_data->fall[i] > sweeps_data->fall[i_peak_fall])
      i_peak_fall = i;
  }

  if (i_peak_fall == 0 || i_peak_rise == 0 || i_peak_fall == i_stop || i_peak_rise == i_stop)
    return 0;

  if (!calculate_target (mvmt, sweeps_data, i_peak_rise, i_peak_fall) )
    return 0;

  return 1;
}

int calculate_target (mvmt_t* mvmt,sweeps_data_t* sweeps_data, int x_peak_rise, int x_peak_fall) {
  double speed = 0.0;

  memset(mvmt,0,sizeof(mvmt_t));

  mvmt->peak_estim_rise = x_peak_rise + get_estim_peak_by_jacobson (sweeps_data->rise, x_peak_rise);
  mvmt->peak_estim_fall = x_peak_fall + get_estim_peak_by_jacobson (sweeps_data->fall, x_peak_fall);

  //last
  mvmt->sspeed = speed = ((mvmt->peak_estim_fall - mvmt->peak_estim_rise)/2.0) * 6.48; //  - это перевод в км/ч
  mvmt->speed = fabs(speed);
  mvmt->mv_to_radar = is_target_move_to_radar (speed);

  return 1;
}

int round_dist(double dist) {
  return dist+((dist-(long)dist) > 0.5);
}

double recalc_dist(int h, double spd, int per) {
  double recalc_dist = h*2.0;
  recalc_dist += ((spd*1000.0)/3600.0)*((double)per/1000.0);
  recalc_dist /= 2.0;
  return recalc_dist+((recalc_dist-(long)recalc_dist) > 0.5);
}

double avg_spd(double *spds, int n) {
  double spd = 0;
  int j;
  for(j=0; j<n; j+=1) {
    spd += spds[j];
  }
  spd/=n;
  return spd;
}

void clr_avg_spds(double *spds, int n) {
  memset(spds,0,sizeof(double)*n);
}

void avg_spd_add(double spd, double *spds, int n) {
  int i;
  for(i=0; i<n-1; i+=1) {
    spds[i] = spds[i+1];
  }
  spds[i] = spd;
}

void target_locked(int *lock) {
  *lock = 1;
}

void target_lost(int *lock) {
  *lock = 0;
}

int check_accel(double saved_spd, double cur_spd, int per) {
  return fabs(saved_spd - cur_spd) >= ACCEL_LIMIT*(per/RADAR_CLOCK);
}

void clr_rrw_points(rrw_point_t *pts, int win_min, int win_max) {
  int i;
  for(i=win_min; i<=win_max; i++) {
    init_rrw_point(pts+i);
  }
}

void find_maxs(sweeps_data_t *sweeps_data, int win_min, int win_max, threshold_t* th,
               int *i_peak_rise, int *i_peak_fall) {
  int i;
  unsigned short pow_cur_rise, pow_cur_fall;
  int _i_peak_rise = -1, _i_peak_fall = -1;

  for (i = win_min; i <= win_max; i++) {
    pow_cur_rise = sweeps_data->rise[i];
    pow_cur_fall = sweeps_data->fall[i];
    if (th != NULL) {
      if ( !is_upper_threshold (i, sweeps_data->rise, th))
        pow_cur_rise = 0;
      if ( !is_upper_threshold (i, sweeps_data->fall, th))
        pow_cur_fall = 0;
    }

    if (pow_cur_rise > sweeps_data->rise[_i_peak_rise])
      _i_peak_rise = i;
    if (pow_cur_fall > sweeps_data->fall[_i_peak_fall])
      _i_peak_fall = i;
  }

  *i_peak_rise = _i_peak_rise;
  *i_peak_fall = _i_peak_fall;
}

void mvmt_set_spd(mvmt_t *mvmt, double sspeed) {
  mvmt->sspeed = sspeed;
  mvmt->speed = fabs(sspeed);
  mvmt->mv_to_radar = is_target_move_to_radar(mvmt->sspeed);
}
//
//void track_target(double *harm_locked, double *fharm_locked,
//                  mvmt_t *mvmt, mvmt_t *mvmt_locked, double *spds,
//                  int v_avg_n, int *v_avg_fill,int per) {
//  double _harm_locked = *harm_locked;
//  int _fharm_locked = *fharm_locked;
//  int _v_avg_fill = *v_avg_fill;
//
//  memcpy(mvmt,mvmt_locked,sizeof(mvmt_t));
//  mvmt = mvmt_locked;
//
//  //додумываем скорость
//  if(v_avg_n > 0) {
//    mvmt_set_spd(mvmt,avg_spd(v_avg,_v_avg_fill));
//    avg_spd_add(mvmt->sspeed, v_avg, v_avg_n);
//    _v_avg_fill += (_v_avg_fill < v_avg_n);
//    *v_avg_fill = _v_avg_fill;
//  }
//
//  //додумываем расстояние
//  if(do_recalc_dist) {
//    _fharm_locked = recalc_dist(harm_locked,mvmt.sspeed,per);
//    *fharm_locked = _fharm_locked;
//    _harm_locked = round_dist(fharm_locked);
//    *harm_locked = _harm_locked;
//  }
//}
int write_to_rrw_points(rrw_point_t* rrw_point, sweeps_data_t* sweeps_data, int sweep_size, int win_min, int win_max, threshold_t* threshold,
                        int cycle_per, double *v_avg) {
  static int lock = 0;
  int i_peak_rise, i_peak_fall;
  mvmt_t mvmt;
  static int v_avg_fill = 0;
  double harm_expected;

  if (sweeps_data->rise == NULL || sweeps_data->fall == NULL || rrw_point == NULL)
    return 0;

  //очищаем точки целей
  clr_rrw_points(rrw_point,win_min,win_max);

  //поиск глобального максимума
  find_maxs(sweeps_data,win_min,win_max,threshold,&i_peak_rise,&i_peak_fall);

  //Обнаружение цели:
  if (i_peak_rise < 0 || i_peak_fall < 0) { //цель потеряна?
    //ведение цели
    if ((count_fail_detect < MAX_COUNT_FAIL_DETECT) && do_restore && lock) {
      //наращиваем счётчик додумываний (допустимых потерь захвата)
      count_fail_detect++;

      //восстанавливаем движение цели по последнему состоянию захвата
      mvmt = mvmt_locked;

      //додумываем скорость
      if((v_avg_n > 0) && (v_avg_fill > 0)) {
        mvmt_set_spd(&mvmt,avg_spd(v_avg,v_avg_fill));
        avg_spd_add(mvmt.sspeed, v_avg, v_avg_n);
        v_avg_fill += (v_avg_fill<v_avg_n);
      }

      //додумываем расстояние
      if(do_recalc_dist) {
        fharm_locked = recalc_dist(harm_locked,mvmt.sspeed,cycle_per);
        harm_locked = round_dist(fharm_locked);
      }
      //заполняем додуманную точку цели
      rrw_point[harm_locked] = rrw_point_locked;
      rrw_point[harm_locked].speed = mvmt.speed;
      rrw_point[harm_locked].status_direct = mvmt.mv_to_radar ? RRW_STATUS_DIRECT_TO_RADAR : RRW_STATUS_DIRECT_FROM_RADAR;

    } else { //потеря захвата

      //очищаем массив скоростей для усреднения
      if(v_avg_n>0) {
        clr_avg_spds(v_avg,v_avg_n);
        v_avg_fill = 0;
      }

      //очищаем параметры цели при последнем захвате
      memset(&mvmt_locked, 0, sizeof(mvmt_t));
      memset(&rrw_point_locked, 0, sizeof(rrw_point_t));
      fharm_locked = harm_locked = 0;
      count_fail_detect = 0;

      //теряем захват
      if(lock)
        target_lost(&lock);

      return 0;
    }
  } else { //цель в захвате

    calculate_target (&mvmt, sweeps_data, i_peak_rise, i_peak_fall);

//    harm_expected = (mvmt.peak_estim_rise + mvmt.peak_estim_fall)/2.0;

    fharm_locked = (mvmt.peak_estim_rise + mvmt.peak_estim_fall)/2.0;
    harm_locked = round_dist(fharm_locked);

    if(v_avg_n>0) {
      //добавляем скорость в массив для усреднения
      avg_spd_add(mvmt.sspeed,v_avg,v_avg_n);
      v_avg_fill += (v_avg_fill<v_avg_n);

      //вычисляем текущую скорость как среднее и оцениваем
      mvmt_set_spd(&mvmt,avg_spd(v_avg,v_avg_fill));
    }

    //сохраняем параметры движения последнего захвата
    mvmt_locked = mvmt;

    //заполняем точку цели
    rrw_point[harm_locked].status_target = RRW_STATUS_TARGET_DETECT;
    rrw_point[harm_locked].status_direct = mvmt.mv_to_radar ? RRW_STATUS_DIRECT_TO_RADAR : RRW_STATUS_DIRECT_FROM_RADAR;
    rrw_point[harm_locked].speed = mvmt.speed;
    rrw_point[harm_locked].status_speed = get_speed_status (mvmt.speed);
    rrw_point[harm_locked].power = sweeps_data->rise[i_peak_rise];

    //сохраняем додуманную точку цели
    rrw_point_locked = rrw_point[harm_locked];

    //обнуляем счётчик додумываний (допустимых потерь захвата)
    count_fail_detect = 0;

    if(!lock)
      target_locked(&lock);
  }

  return 1;
}

int is_upper_threshold (int harm, unsigned short* sweep, threshold_t* threshold) {
  int i;
  int x1 = 0, x2 = 0, y1 = 0, y2 = 0;
  double y_threshold = 0.0;
  if (threshold->points==NULL || sweep==NULL)
    return 0;

  for (i = 0; i + 1 < threshold->size ; i++) {
    if (harm == threshold->points[i].x)
      return sweep[harm] >= threshold->points[i].y;
    if (harm == threshold->points[i+1].x)
      return sweep[harm] >= threshold->points[i+1].y;

    if ( harm > threshold->points[i].x && harm < threshold->points[i+1].x) {
      x1 = threshold->points[i].x;
      x2 = threshold->points[i+1].x;
      y1 = threshold->points[i].y;
      y2 = threshold->points[i+1].y;

      y_threshold = threshold->points[i].y + (harm - x1) * (y2 - y1) / (x2 - x1);
      return sweep[harm] >= (int) y_threshold;
    }
  }
  return 0;
}

void init_rrw_point (rrw_point_t* rrw_point) {
  rrw_point->power = 0;
  rrw_point->speed = 0;
  rrw_point->status_direct = RRW_STATUS_DIRECT_NO;
  rrw_point->status_power = RRW_STATUS_POWER_GOOD;
  rrw_point->status_speed = RRW_STATUS_SPEED_BAD;
  rrw_point->status_target = RRW_STATUS_TARGET_NO_DETECT;
}

unsigned char get_speed_status (double speed) {
  if (speed < RRW_LIMIT_MIN_SPEED)
    return RRW_STATUS_SPEED_LOWER_MIN_LIMIT;
  else {
    if (speed > RRW_LIMIT_MAX_SPEED)
      return RRW_STATUS_SPEED_UPPER_MAX_LIMIT;
    else
      return RRW_STATUS_SPEED_GOOD;
  }
}

int is_target_move_to_radar (double speed) {
  return speed >= 0;
}

int is_correct_distance_range (int harm) {
  double dist = harm * RRW_DISTANCE_UNIT;
  return dist >= RRW_LIMIT_MIN_DISTANCE && dist <= RRW_LIMIT_MAX_DISTANCE;
}

double get_estim_peak_by_jacobson(unsigned short *spectr, int index_peak) {
  double peak = spectr [index_peak];
  double peak_after = spectr [index_peak + 1];
  double peak_before = spectr [index_peak - 1];

  return ( peak_after - peak_before) / (2.0 * peak - peak_before - peak_after);
}
