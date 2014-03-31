#ifndef DATA_PROCESSOR_H
#define DATA_PROCESSOR_H

#include<common.h>
#include<rrw_proto.h>

#define ACCEL_LIMIT 3.5
#define RADAR_CLOCK 100

#define DIR_NO   0
#define DIR_TO   1
#define DIR_FROM 2

#define POW_GOOD     0
#define POW_TOO_LOW  1
#define POW_TOO_HIGH 2
#define POW_BAD      3

#define SPD_GOOD     0
#define SPD_TOO_LOW  1
#define SPD_TOO_HIGH 2
#define SPD_BAD      3

#define DETECTED    1
#define NOT_DETECTED 0

#define DIST_UNIT    0.5

#define SPD_LIM_MIN  5
#define SPD_LIM_MAX  200

#define DIST_LIM_MIN 0
#define DIST_LIM_MAX 500

#define POW_LIM_MIN  -90
#define POW_LIM_MAX  0

typedef struct {
    unsigned short rise[1024];
    unsigned short fall[1024];
} sweeps_data_t;

typedef struct mvmt_t {
  int peak_rise;
	double epeak_rise;
  int peak_fall;
	double epeak_fall;

	double dist_rise;
	double edist_rise;
	double dist_fall;
	double edist_fall;

	double fdist_peak;
	int idist_peak;
	double aspeed;
	double sspeed;
	int dir;
	double raw_speed;
	double raw_dist;
} mvmt_t;

typedef struct {
  unsigned char do_restore_gaps : 1;
  unsigned char do_recalc_dist  : 1;
  unsigned char do_check_spd    : 1;
  unsigned char do_avg_spd      : 1;
  unsigned char do_check_dist   : 1;
  unsigned char locked   : 1;
  unsigned char                 : 2;

  int max_fails_num;
  int fails_counter;

  double *avg_spds;
  int avg_spds_num;
  int avg_spds_filled;

  mvmt_t locked_mvmt;
  target_pt_t lock_pt;

  mvmt_t cur_mvmt;

  sweeps_data_t *data;
  target_pt_t *pts;
  int pts_num;

  int win_min;
  int win_max;
  threshold_t *th;

} proc_t;

void data_proc_init(proc_t *proc,
                    int do_restore_gaps, int do_recalc_dist,
                    int do_check_spd, int do_avg_spd,
                    int do_check_dist,
                    int max_fails_num, int avg_spds_num,
                    sweeps_data_t *data, int win_min, int win_max,
                    threshold_t *th,
                    target_pt_t *pts, int pts_num);
void data_proc_deinit(proc_t *proc);

void inc_fails(proc_t *proc);
void clr_fails(proc_t *proc);

int need_restore_gaps(proc_t *proc);
int need_recalc_dist(proc_t *proc);
int need_check_spd(proc_t *proc);
int need_check_dist(proc_t *proc);
int need_avg_spd(proc_t *proc);

void lock_target(proc_t *proc);
void lose_target(proc_t *proc);
int have_target(proc_t *proc);

void set_locked_mvmt(proc_t *proc, mvmt_t *mvmt);
mvmt_t *get_locked_mvmt(proc_t *proc);

void target_pt_init(target_pt_t* pt, int i, double pow_val);
void target_pt_fill(proc_t *proc, mvmt_t *mvmt);

void clear_target_pts(proc_t *proc);

int is_above_threshold (int harm, unsigned short lev, threshold_t* threshold);
int find_target(proc_t *proc, mvmt_t *mvmt);

double estimate_peak(unsigned short *spectrum, int index);
void calc_mvmt(proc_t *proc, mvmt_t* mvmt);
void clr_mvmt(mvmt_t *mvmt);
void mvmt_set_spd(mvmt_t *mvmt,double spd);
void mvmt_set_raw_spd(mvmt_t *mvmt, double spd);
void mvmt_set_dist(mvmt_t *mvmt, double dist);
void mvmt_copy(mvmt_t *dest, const mvmt_t *src);

double calc_avg_spd(proc_t *proc);
void clr_avg_spds(proc_t *proc);
void add_avg_spd(proc_t *proc, double spd);
double recalc_dist(double harm, double spd);

int spd_status(double aspeed);
int dir_status(int sspeed);
int pow_status(double pow_val);

int process_target(proc_t *proc, mvmt_t *cur_mvmt);
int process_gap(proc_t *proc, mvmt_t *cur_mvmt);
int process_data(proc_t *proc);
void data_proc_set_th_pts(proc_t *proc, ipt_t *pts, int n);

double dbm(double val, int harm);
#endif
