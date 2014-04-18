#ifndef COMMON_H
#define COMMON_H

extern int MAX_COUNT_FAIL_DETECT;
extern int do_restore;
extern int do_recalc_dist;
extern int do_check_accel;
extern int v_avg_n;
extern const int _endian_check_const;

#define is_bigendian() ( (*(char*)&_endian_check_const) == 0 )

unsigned short reverse_us (unsigned short s);
short reverse_s (short s);
unsigned int reverse_ui (unsigned int i);
int reverse_i (int i);

//#define DBG_SRV 1
//#define DBG_RDR 1
//#define DBG_PROC 1
//#define DBG_RCLI 1
//#define DBG_EUDP 1
//#define DBG_CFG 1

typedef struct {
  int x;
  int y;
} ipt_t;

typedef struct {
  double x;
  double y;
} fpt_t;

typedef struct {
	ipt_t* points;
	int size;
} threshold_t;

void logprintf(char *format,...);

void flog_open(char *path);
void flog_close();
void flogprintf(char *format,...);

#endif // COMMON_H
