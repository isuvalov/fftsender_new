#ifndef RADAR_CLI_H
#define RADAR_CLI_H

#include<timeutils.h>
#include<pthread.h>
#include<rrw_proto.h>
#include<radar.h>

#define MEAS_DATA_SIZE 1024

#define MEAS_MODE_ON_REQ 0
#define MEAS_MODE_CYCLE  1

#define CYCLE_START  0xC1
#define CYCLE_STOP   0xC2
#define CYCLE_DURING 0xC3
#define CYCLE_ENDED    0xC4

typedef struct {
  unsigned short *sweep1;
  unsigned short *sweep2;
  int len;
} rrw_data_t;

typedef union {  
  unsigned short data[2][1024];
  struct {
    unsigned short sw1[1024];
    unsigned short sw2[1024];
  } sweeps;
} rrw_data2_t;

typedef struct {
  rdr_t *rdr;

  char meas_no;
  struct timeval last_tm;
  double elapsed;
  int has_unread;
  int last_unsucc;

  pthread_t cycle_meas_th;
  pthread_mutex_t mtx;

  int meas_mode;
  int cycle_state;

  unsigned short cycle_dly;
  unsigned short cycle_dur;
  
  data_el_t *targets;
  rrw_data2_t data;

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

void rcli_meas(rcli_t *cli);
void rcli_copy_last(rcli_t *cli, char *buf);

int rcli_meas_mode(rcli_t *cli);

int rcli_collect(rdr_t *rdr, void *coll, int coll_sz, int pkt_data_size);

#endif

