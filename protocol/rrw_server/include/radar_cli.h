#ifndef RADAR_CLI_H
#define RADAR_CLI_H

#include<data_processor.h>
#include<common.h>
#include<timeutils.h>
#include<pthread.h>
#include<rrw_proto.h>
#include<radar.h>

#define MEAS_MODE_ON_REQ 0
#define MEAS_MODE_CYCLE  1

#define CYCLE_START  0xC1
#define CYCLE_STOP   0xC2
#define CYCLE_DURING 0xC3
#define CYCLE_ENDED  0xC4

#define RCV_START  0x01
#define RCV_STOP   0x02
#define RCV_DURING 0x03
#define RCV_ENDED  0x04

typedef struct {
  unsigned short *rise;
  unsigned short *fall;
  int len;
} rrw_rdata_t;

#define SWEEP_RISE 0
#define SWEEP_FALL 1

#define DIR_RISE ((char)0xF)
#define DIR_FALL ((char)0xC)

typedef union {
  unsigned short data[2][1024];
  sweeps_data_t sweeps;
} rrw_data2_t;

typedef struct {
  rdr_t *rdr;

  char meas_no;
  struct timeval last_tm;
  double elapsed;
  int has_unread;
  int last_unsucc;

  pthread_t cycle_meas_th;
  pthread_t rcv_loop_th;
  pthread_mutex_t mtx;

  int meas_mode;
  int cycle_state;
  int rcv_loop_state;

  unsigned short cycle_dly;
  unsigned short cycle_dur;

  data_el_t *targets;
  rrw_data2_t data;

  int coll_sz;
  int meas_data_unit_sz;
  int meas_data_sz;
  threshold_t th;
  int win_min;
  int win_max;

  int has_data;
  int last_cycle;

  proc_t data_proc;

} rcli_t;

int rcli_is_last_unsucc(rcli_t *cli);
int rcli_has_unread(rcli_t *cli);
unsigned short rcli_get_elapsed(rcli_t *cli);
unsigned char rcli_get_meas_no(rcli_t *cli);
void rcli_incr_meas_no(rcli_t *cli);

void rcli_en_cycle_mode(rcli_t *cli);
void rcli_en_onreq_mode(rcli_t *cli);

void rcli_set_cycle_dur(rcli_t *cli, unsigned short dur);
void rcli_set_cycle_dly(rcli_t *cli, unsigned short dly);

void rcli_cycle_start(rcli_t *cli);
void rcli_cycle_stop(rcli_t *cli);

void rcli_rcv_loop_start(rcli_t *cli);
void rcli_rcv_loop_stop(rcli_t *cli);

int rcli_meas(rcli_t *cli);
void rcli_copy_last(rcli_t *cli, char *buf);

int rcli_meas_mode(rcli_t *cli);

int rcli_collect(rdr_t *rdr, void *coll, int coll_sz, void *arg);

void rcli_init(rcli_t *cli, rdr_t *rdr,
               int cycle_dly, int cycle_dur, int meas_mode,
               int coll_sz, int meas_data_unit_sz,
               ipt_t *th_pts, int th_pts_num,
               int win_min, int win_max);
void rcli_deinit(rcli_t *cli);

void rcli_copy_last_raw(rcli_t *cli, raw_pt_t *rbuf, raw_pt_t *fbuf);

#endif

