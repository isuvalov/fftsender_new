#ifndef CFG_H
#define CFG_H

#include<libconfig.h>
#include<common.h>

#define CFG_INT    0xC1
#define CFG_STR    0xC2
#define CFG_FLOAT  0xC3
#define CFG_BOOL   0xC4
#define CFG_POINTS 0xC5
typedef struct {
  config_t hnd;
  char fname[1024];

  char *radar_cli_addr;
  int radar_cli_port;
  int radar_pkt_size;
  int radar_rcv_timeout;

  int data_unit_size;
  int data_coll_size;
  int meas_data_size;

  int meas_cycle_iter_delay;
  int meas_cycle_dur;
  int meas_mode;

  char *server_addr;
  int server_port;
  int server_rcv_timeout;
  int server_snd_timeout;

  int window_min;
  int window_max;
  ipt_t *threshold_polyline;
  int threshold_pts_num;

  int max_fails_num;
  int avg_spds_num;

  int do_restore_gaps;
  int do_check_spd;
  int do_recalc_dist;
  int do_avg_spd;
  int do_check_dist;
} cfg_t;

int cfg_load(cfg_t *cfg, char *file_name);
void cfg_unload(cfg_t *cfg);
int cfg_get(cfg_t *cfg, char *id, int type, void *val);
void cfg_update_th_pts(cfg_t *cfg, ipt_t *pts, int npts);

extern cfg_t cfg;

#endif // CFG_H
