#include<data_processor.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <debuglog.h>
#include <math.h>

void data_proc_init(proc_t *proc,
                    int do_restore_gaps, int do_recalc_dist,
                    int do_check_spd, int do_avg_spd,
                    int do_check_dist,
                    int max_fails_num, int avg_spds_num,
                    sweeps_data_t *data, int win_min, int win_max,
                    threshold_t *th,
                    target_pt_t *pts, int pts_num) {

  proc->do_restore_gaps = do_restore_gaps;
  proc->do_recalc_dist = do_recalc_dist;
  proc->do_check_spd = do_check_spd;
  proc->do_avg_spd = do_avg_spd;
  proc->do_check_dist = do_check_dist;
  proc->max_fails_num = max_fails_num;
  proc->fails_counter = 0;
  proc->avg_spds_num = avg_spds_num;
  proc->avg_spds = malloc(sizeof(double)*avg_spds_num);
  proc->avg_spds_filled = 1;
  memset(&proc->locked_mvmt,0,sizeof(mvmt_t));
  memset(&proc->lock_pt,0,sizeof(target_pt_t));
  memset(&proc->cur_mvmt,0,sizeof(mvmt_t));

  proc->data = data;
  proc->win_min = win_min;
  proc->win_max = win_max;
  proc->th = th;

  proc->pts = pts;
  proc->pts_num = pts_num;
}

void data_proc_deinit(proc_t *proc) {
  free(proc->avg_spds);
  free(proc->th->points);
}

void data_proc_set_th_pts(proc_t *proc, ipt_t *pts, int n) {
  free(proc->th->points);
  proc->th->points = pts;
  proc->th->size = n;
  proc->win_min = proc->th->points[0].x;
  proc->win_max = proc->th->points[proc->th->size-1].x;
}

void inc_fails(proc_t *proc) {
  proc->fails_counter++;
}

void clr_fails(proc_t *proc) {
  proc->fails_counter = 0;
}

int need_restore_gaps(proc_t *proc) {
  return proc->do_restore_gaps;
}

int need_recalc_dist(proc_t *proc) {
  return proc->do_recalc_dist;
}

int need_check_spd(proc_t *proc) {
  return proc->do_check_spd;
}

int need_check_dist(proc_t *proc) {
  return proc->do_check_dist;
}

int need_avg_spd(proc_t *proc) {
  return proc->do_avg_spd;
}

void lock_target(proc_t *proc) {
  proc->locked = 1;
}

void lose_target(proc_t *proc) {
  proc->locked = 0;
}

int have_target(proc_t *proc) {
  return proc->locked;
}

void set_locked_mvmt(proc_t *proc, mvmt_t *mvmt) {
  mvmt_copy(&(proc->locked_mvmt),mvmt);
}

mvmt_t *get_locked_mvmt(proc_t *proc) {
  if(proc->locked)
    return &(proc->locked_mvmt);
  return NULL;
}

double dbm(double val, int harm) {
  return 20.0 * log10(val/1300.0) - 40.0 + 3.2175 * log10(harm / 0.5) - 3.6;
}

void target_pt_init(target_pt_t* pt, int i, double pow_val) {
  double v;

  pt->det = NOT_DETECTED;
  pt->dir = DIR_NO;

//  pt->pow_val = (short)(dbm((double)pow_val, i));
  v = dbm((double)pow_val, i);

  pt->pow_val = (v >= POW_LIM_MIN && v < POW_LIM_MAX) ? v : POW_LIM_MIN;
  pt->pow_status = pow_status(v);

  pt->spd_status = SPD_GOOD;
  pt->spd_val = 0;
}

void clear_target_pts(proc_t *proc) {
  int win_min = proc->win_min;
  int win_max = proc->win_max;
  int i;

  for(i=win_min; i<=win_max; i++) {
    target_pt_init(proc->pts+i,i,proc->data->rise[i]);
//    proc->pts[i].pow_val = proc->data->rise[i];
  }
}

int is_above_threshold (int harm, unsigned short lev, threshold_t* threshold) {
  int i;
  int x1 = 0, x2 = 0, y1 = 0, y2 = 0;

  double y_threshold = 0.0;

  for (i = 0; i + 1 < threshold->size ; i++) {
    if (harm == threshold->points[i].x)
      return lev >= threshold->points[i].y;
    if (harm == threshold->points[i+1].x)
      return lev >= threshold->points[i+1].y;

    if ( harm > threshold->points[i].x && harm < threshold->points[i+1].x) {
      x1 = threshold->points[i].x;
      x2 = threshold->points[i+1].x;
      y1 = threshold->points[i].y;
      y2 = threshold->points[i+1].y;

      y_threshold = threshold->points[i].y + (harm - x1) * (y2 - y1) / (x2 - x1);
      return lev >= (int)y_threshold;
    }
  }
  return 0;
}

#define FOUND_RISE 1
#define FOUND_FALL 2
#define FOUND_BOTH 3

int find_target(proc_t *proc, mvmt_t *mvmt) {
  sweeps_data_t *sweeps_data = proc->data;
  threshold_t *th = proc->th;
  int win_min = proc->win_min,
      win_max = proc->win_max;
  unsigned short pow_rise, pow_fall;
  int peak_rise = 0, peak_fall = 0;
  int found = 0;
  int i;

  for (i = win_min; i <= win_max; i++) {
    pow_rise = sweeps_data->rise[i];
    pow_fall = sweeps_data->fall[i];
    if (th != NULL) {
      if (!is_above_threshold(i, pow_rise, th))
        pow_rise = 0;
      if (!is_above_threshold(i, pow_fall, th))
        pow_fall = 0;
    }

    if (pow_rise > sweeps_data->rise[peak_rise]) {
      peak_rise = i;
      found |= FOUND_RISE;
    }
    if (pow_fall > sweeps_data->fall[peak_fall]) {
      peak_fall = i;
      found |= FOUND_FALL;
    }
  }

  mvmt->peak_rise = peak_rise;
  mvmt->peak_fall = peak_fall;

  return found;
}

double estimate_peak(unsigned short *spectrum, int index) {
  double peak = spectrum[index];
  double next_peak = spectrum[index + 1];
  double prev_peak = spectrum[index - 1];

  return (next_peak - prev_peak) / (2.0 * peak - prev_peak - next_peak);
}

void calc_mvmt(proc_t *proc, mvmt_t* mvmt) {
  sweeps_data_t *sweeps_data = proc->data;
  int peak_rise = mvmt->peak_rise,
      peak_fall = mvmt->peak_fall;

  mvmt->epeak_rise = peak_rise + estimate_peak(sweeps_data->rise, peak_rise);
  mvmt->epeak_fall = peak_fall + estimate_peak(sweeps_data->fall, peak_fall);

  mvmt->sspeed = ((mvmt->epeak_fall - mvmt->epeak_rise) / 2.0) * 6.48;
  mvmt->aspeed = fabs(mvmt->sspeed);
  mvmt->raw_speed = mvmt->sspeed;

  mvmt->raw_dist = mvmt->fdist_peak = (mvmt->epeak_rise + mvmt->epeak_fall) / 2.0;
  mvmt->idist_peak = round(mvmt->fdist_peak);

}

void mvmt_set_spd(mvmt_t *mvmt, double spd) {
  mvmt->sspeed = spd;
  mvmt->aspeed = fabs(spd);
}

void mvmt_set_raw_spd(mvmt_t *mvmt, double spd) {
  mvmt->raw_speed = spd;
}

void mvmt_set_dist(mvmt_t *mvmt, double dist) {
  mvmt->fdist_peak = dist;
  mvmt->idist_peak = (int)round(mvmt->fdist_peak);
}

void clr_mvmt(mvmt_t *mvmt) {
  memset(mvmt,0,sizeof(mvmt_t));
}

void mvmt_copy(mvmt_t *dest, const mvmt_t *src) {
  memcpy(dest,src,sizeof(mvmt_t));
}

double calc_avg_spd(proc_t *proc) {
  double spd = 0;
  double *spds =  proc->avg_spds;
  int n = proc->avg_spds_filled;
  int i;

  for(i=0; i<n; i++) {
    spd += spds[i];
  }

  return spd / n;
}

void clr_avg_spds(proc_t *proc) {
  memset(proc->avg_spds,0,sizeof(double)*proc->avg_spds_num);
  proc->avg_spds_filled = 0;
}

void add_avg_spd(proc_t *proc, double spd) {
  double *spds = proc->avg_spds;
  int n = proc->avg_spds_filled;
  int i;


  for(i=n-1; i>=0; i--)
    spds[i+1] = spds[i];

  spds[0] = spd;
  proc->avg_spds_filled += (proc->avg_spds_filled < proc->avg_spds_num);
  spds[0] = calc_avg_spd(proc);
}

double recalc_dist(double harm, double spd) {
  double recalc_dist = harm*0.5;

  recalc_dist += ((spd*1000.0)/3600.0)*((double)RADAR_CLOCK/1000.0);
  recalc_dist /= 0.5;

  return recalc_dist;
}

int spd_status(double aspeed) {
  if(aspeed < SPD_LIM_MIN)
    return SPD_TOO_LOW;
  if(aspeed > SPD_LIM_MAX)
    return SPD_TOO_HIGH;
  return SPD_GOOD;
}

int dir_status(int sspeed) {
  if(sspeed < 0)
    return DIR_FROM;
  if(sspeed > 0)
    return DIR_TO;
  return DIR_NO;
}

int pow_status(double pow_val) {
  if(pow_val < POW_LIM_MIN)
    return POW_TOO_LOW;
  if(pow_val > POW_LIM_MAX)
    return POW_TOO_HIGH;
  return POW_GOOD;
}

void target_pt_fill(proc_t *proc, mvmt_t *mvmt) {
  double v;
  target_pt_t *pt = &(proc->pts[mvmt->idist_peak]);

  pt->det = DETECTED;
  pt->dir = dir_status((int)round(mvmt->sspeed));

  pt->spd_val = (unsigned char)round(mvmt->aspeed);
  pt->spd_status = spd_status(pt->spd_val);

//  pt->pow_val = proc->data->rise[mvmt->peak_rise];
  v = dbm((double)proc->data->rise[mvmt->peak_rise], mvmt->peak_rise);

  pt->pow_val = (v >= POW_LIM_MIN && v < POW_LIM_MAX) ? v : POW_LIM_MIN;
  pt->pow_status = pow_status(v);
}

//обработка обнаруженной цели
int process_target(proc_t *proc, mvmt_t *cur_mvmt) {

  calc_mvmt(proc,cur_mvmt);

//  flogprintf("%lf %lf\n",cur_mvmt->epeak_rise,cur_mvmt->epeak_fall);

//  flogprintf("%lf %lf %lf %lf %lf %lf\n",
//             proc->locked_mvmt.fdist_peak,
//             cur_mvmt->fdist_peak,
//             fabs(proc->locked_mvmt.fdist_peak - cur_mvmt->fdist_peak),
//             proc->locked_mvmt.sspeed,
//             cur_mvmt->sspeed,
//             fabs(proc->locked_mvmt.sspeed - cur_mvmt->sspeed));

  if(fabs(proc->locked_mvmt.raw_speed - cur_mvmt->sspeed) > 5.0)
    mvmt_set_spd(cur_mvmt, calc_avg_spd(proc));

  if(need_avg_spd(proc)) {
    add_avg_spd(proc,cur_mvmt->sspeed);
    mvmt_set_spd(cur_mvmt,calc_avg_spd(proc));
  }

  if(have_target(proc) &&
     (fabs(proc->locked_mvmt.fdist_peak - cur_mvmt->fdist_peak) > 4.0) &&
     ((int)(proc->locked_mvmt.raw_speed)!=0))
    mvmt_set_dist(cur_mvmt, recalc_dist(proc->locked_mvmt.fdist_peak,
                                        (proc->locked_mvmt.sspeed + calc_avg_spd(proc))/2));

  target_pt_fill(proc,cur_mvmt);

  clr_fails(proc);

  set_locked_mvmt(proc,cur_mvmt);
  lock_target(proc);

  return 0;
}

//ведение цели
int process_loss(proc_t *proc, mvmt_t *cur_mvmt) {

  clr_avg_spds(proc);
  clr_mvmt(&proc->locked_mvmt);
  clr_fails(proc);

  lose_target(proc);

  return 0;
}

//потеря захвата
int process_gap(proc_t *proc, mvmt_t *cur_mvmt) {

  inc_fails(proc);
  mvmt_copy(cur_mvmt,&(proc->locked_mvmt));

//  flogprintf("%lf %lf\n",cur_mvmt->epeak_rise,cur_mvmt->epeak_fall);

  if(need_avg_spd(proc)) {
    add_avg_spd(proc,cur_mvmt->sspeed);
    mvmt_set_spd(cur_mvmt, calc_avg_spd(proc));
  }

  if(need_recalc_dist(proc))
    mvmt_set_dist(cur_mvmt, recalc_dist(cur_mvmt->fdist_peak, cur_mvmt->sspeed));

  set_locked_mvmt(proc, cur_mvmt);
  target_pt_fill(proc, cur_mvmt);

  return 0;
}

int process_data(proc_t *proc) {
  int rv;
  mvmt_t cur_mvmt;

  memset(&cur_mvmt,0,sizeof(mvmt_t));

  clear_target_pts(proc);

  if(find_target(proc,&cur_mvmt) == FOUND_BOTH) {
//    printf("TARGET FOUND!\n");
//    printf("PROCESSING TARGET!\n");
    rv = process_target(proc,&cur_mvmt);
    return rv;
  }

//  printf("TARGET NOT FOUND!\n");
  if(need_restore_gaps(proc)) {
    if(proc->fails_counter < proc->max_fails_num) {
//      printf("PROCESSING GAP!\n");
      rv = process_gap(proc,&cur_mvmt);
    } else {
//      printf("PROCESSING LOSS OF TARGET!\n");
      rv = process_loss(proc,&cur_mvmt);
    }
    return rv;
  } else {
    rv = process_loss(proc,&cur_mvmt);
    return rv;
  }

  return 0;
}
