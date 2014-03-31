#include<data_processor.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <debuglog.h>
#include <math.h>

int MAX_COUNT_FAIL_DETECT;
int do_restore;
int do_recalc_dist;
int check_accel;
int check_accel_fails = 0;
int v_avg_n = 0;

mv_params_t mv_params_saved;
rrw_point_t rrw_point_saved;
int harmonic_saved = 0;
int count_fail_detect = 0;


int calculate_sweeps (mv_params_t* mv_params, sweeps_data_t* sweeps_data, int i_start, int i_stop) {
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

  if (!calculate_target (mv_params, sweeps_data, i_peak_rise, i_peak_fall) )
    return 0;

  return 1;
}

int calculate_target (mv_params_t* mv_params,sweeps_data_t* sweeps_data, int x_peak_rise, int x_peak_fall) {
  double speed = 0.0;

  memset(mv_params,0,sizeof(mv_params_t));

  mv_params->peak_estim_rise = x_peak_rise + get_estim_peak_by_jacobson (sweeps_data->rise, x_peak_rise);
  mv_params->peak_estim_fall = x_peak_fall + get_estim_peak_by_jacobson (sweeps_data->fall, x_peak_fall);

  //last
  mv_params->sspeed = speed = ((mv_params->peak_estim_fall - mv_params->peak_estim_rise)/2.0) * 6.48; // 3.6 - это перевод в км/ч
  mv_params->speed = fabs(speed);
  mv_params->mv_to_radar = is_target_move_to_radar (speed);

  return 1;
}

int write_to_rrw_points(rrw_point_t* rrw_point, sweeps_data_t* sweeps_data, int sweep_size, int win_min, int win_max, threshold_t* threshold,
                        int cycle_per, double *v_avg) {
  static int lock = 0;
  int i,j;
  int i_peak_rise = 0, i_peak_fall = 0;
  unsigned short y_curr_rise = 0, y_curr_fall = 0;
  mv_params_t mv_params;
  unsigned char spd;
  int incorr = 0;
  static int v_avg_fill = 0;
  double recalc_dist;

  if (sweeps_data->rise == NULL || sweeps_data->fall == NULL || rrw_point == NULL)
    return 0;

  for (i = win_min; i <= win_max; i++) {
    init_rrw_point (rrw_point + i);
//		rrw_point[i].power = sweeps_data->rise[i];
    y_curr_rise = sweeps_data->rise[i];
    y_curr_fall = sweeps_data->fall[i];
    if (threshold != NULL) { // Обрезаем шум, если передали полилинию
      if ( !is_upper_threshold (i, sweeps_data->rise, threshold))
        y_curr_rise = 0;
      if ( !is_upper_threshold (i, sweeps_data->fall, threshold))
        y_curr_fall = 0;
    }

    if (y_curr_rise > sweeps_data->rise[i_peak_rise])
      i_peak_rise = i;
    if (y_curr_fall > sweeps_data->fall[i_peak_fall])
      i_peak_fall = i;
  }

  if (i_peak_rise == 0 || i_peak_fall == 0) {
    if ((count_fail_detect < MAX_COUNT_FAIL_DETECT) && do_restore && lock) {
      count_fail_detect++;
      mv_params = mv_params_saved;

      rrw_point[harmonic_saved] = rrw_point_saved;

      //додумываем скорость как усреднение накопленных скоростей
      if(v_avg_n>0 && v_avg_fill>0) {
        mv_params.sspeed = mv_params.speed = 0;

        for(j=0; j<v_avg_n; j+=1) {
          mv_params.sspeed = +=v_avg[j];
        }
        mv_params.speed/=v_avg_fill;
      }

      //додумываем расстояние на основе додуманной скорости
      if(do_recalc_dist) {
        recalc_dist = harmonic_saved*2;
        recalc_dist += ((mv_params.speed*1000.0)/3600.0)*((double)cycle_per/1000.0);
        recalc_dist /= 2;
        harmonic_saved = recalc_dist+((recalc_dist-(long)recalc_dist) > 0.5);
      }
      rrw_point[harmonic_saved].speed = mv_params.speed;

      flogprintf("%lf %d\n",(double)harmonic_saved*0.5,rrw_point[harmonic_saved].speed);
//      logprintf("RESTORING!\n");
    } else {
      if(v_avg_n>0) {
        memset(v_avg,0,sizeof(double)*v_avg_n);
        v_avg_fill = 0;
      }

      memset(&mv_params_saved, 0, sizeof(mv_params_t));
      memset(&rrw_point_saved, 0, sizeof(rrw_point_t));
      harmonic_saved = 0;
      count_fail_detect = 0;

      if(lock) {
        lock = 0; //lose target lock
//        logprintf("LOST!\n");
      }
      return 0;
    }
  } else {

    calculate_target (&mv_params, sweeps_data, i_peak_rise, i_peak_fall);

    harmonic_saved = (int)((mv_params.peak_estim_rise + mv_params.peak_estim_fall)/2.0);

    if(check_accel && lock) {
      incorr = (fabs(mv_params_saved.spd_sign*mv_params_saved.speed -
                     mv_params.spd_sign*mv_params.speed) >=
                ACCEL_LIMIT*(cycle_per/RADAR_CLOCK));
//      logprintf("SPEED CHECK: SAV %lf CUR %lf DIFF %lf LIM %lf FCORR %d!\n",mv_params_saved.speed, mv_params.speed,
//                fabs(mv_params_saved.speed - mv_params.speed),incorr);
      if(incorr) {
        logprintf("INCORRECT SPEED!\n");
        mv_params.speed = mv_params_saved.speed;
        check_accel_fails += 1;
      } else {
        check_accel_fails = 0;
        logprintf("CORRECT SPEED!\n");
      }
    }

    if(v_avg_n>0) {
//      printf("v_avg: ");
      for(i=0; i<v_avg_n-1; i+=1) {
        v_avg[i] = v_avg[i+1];
        printf("%lf ",v_avg[i]);
      }
      v_avg[i] = mv_params.speed;
//      printf("%lf\n",v_avg[i]);
      v_avg_fill += (v_avg_fill<v_avg_n);

      mv_params.speed = 0;
      for(j=0; j<v_avg_n; j+=1) {
        mv_params.speed+=v_avg[j];
      }
      mv_params.speed/=v_avg_fill;
    }

    spd = mv_params.speed;
    mv_params_saved = mv_params; //backup

    rrw_point[harmonic_saved].status_target = RRW_STATUS_TARGET_DETECT;
    rrw_point[harmonic_saved].status_direct = mv_params.mv_to_radar ? RRW_STATUS_DIRECT_TO_RADAR : RRW_STATUS_DIRECT_FROM_RADAR;
    rrw_point[harmonic_saved].speed = spd;
    rrw_point[harmonic_saved].status_speed = get_speed_status (mv_params.speed);
    rrw_point[harmonic_saved].power = sweeps_data->rise[i_peak_rise];

    rrw_point_saved = rrw_point[harmonic_saved];

    count_fail_detect = 0;

    if(!lock) {
      lock = 1;
//      logprintf("LOCKED!\n");
    }
    flogprintf("%lf %d\n",(double)harmonic_saved*0.5,rrw_point[harmonic_saved].speed);
  }

  return 1;
}

int is_upper_threshold (int harmonic, unsigned short* sweep, threshold_t* threshold) {
  int i;
  int x1 = 0, x2 = 0, y1 = 0, y2 = 0;
  double y_threshold = 0.0;
  if (threshold->points==NULL || sweep==NULL)
    return 0;

  for (i = 0; i + 1 < threshold->size ; i++) {
    if (harmonic == threshold->points[i].x)
      return sweep[harmonic] >= threshold->points[i].y;
    if (harmonic == threshold->points[i+1].x)
      return sweep[harmonic] >= threshold->points[i+1].y;

    if ( harmonic > threshold->points[i].x && harmonic < threshold->points[i+1].x) {
      x1 = threshold->points[i].x;
      x2 = threshold->points[i+1].x;
      y1 = threshold->points[i].y;
      y2 = threshold->points[i+1].y;

      y_threshold = threshold->points[i].y + (harmonic - x1) * (y2 - y1) / (x2 - x1);
      return sweep[harmonic] >= (int) y_threshold;
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

int is_correct_distance_range (int harmonic) {
   double dist = harmonic * RRW_DISTANCE_UNIT;
  return dist >= RRW_LIMIT_MIN_DISTANCE && dist <= RRW_LIMIT_MAX_DISTANCE;
}

double get_estim_peak_by_jacobson(unsigned short *spectr, int index_peak) {
  double peak = spectr [index_peak];
  double peak_after = spectr [index_peak + 1];
  double peak_before = spectr [index_peak - 1];

  return ( peak_after - peak_before) / (2.0 * peak - peak_before - peak_after);
}
