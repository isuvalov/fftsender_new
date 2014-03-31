#ifndef RRW_PROTO_H
#define RRW_PROTO_H

//Function codes
#define RRW_FN_STATUS    0x00
#define RRW_FN_DATA_ALT  0x01
#define RRW_FN_MEAS_CTL  0x02
#define RRW_FN_SET_TH    0x03
#define RRW_FN_GET_TH    0x04

//Function return codes
#define RRW_RV_SUCCESS  0x00
#define RRW_RV_BAD_REQ  0x01
#define RRW_RV_BUSY     0x02
#define RRW_RV_ERROR    0xFF

//Measurement modes
#define RRW_MEAS_ON_REQ 0x00
#define RRW_MEAS_CYCLE 0x01

#define RRW_MAX_TH_PTS_NUM 1024
#define RRW_MAX_TRGTS_NUM 255

typedef struct {
  unsigned char _;
  unsigned char no;
  unsigned char fn;
} base_req_t;

typedef struct {
  unsigned char _;
  unsigned char no;
  unsigned char fn;
  unsigned char rv;
} base_resp_t;

#pragma pack(push,1)
typedef struct {
  unsigned char fault       : 1;
  unsigned char ready       : 1;
  unsigned char meas_mode   : 1;
  unsigned char last_unsucc : 1;
  unsigned char has_unread  : 1;
} status_t;
#pragma pack(pop)

#pragma pack(push,1)
typedef struct {
  base_resp_t base_resp;
  status_t status;
  unsigned char details;
  signed char t[3];
  unsigned char i[3];
  signed char u[4];
} status_resp_t;
#pragma pack(pop)

typedef struct {
  base_resp_t base_resp;
  status_t status;
} meas_ctl_resp_t;

typedef struct {
  base_resp_t base_resp;
  status_t status;
  unsigned char meas_no;
  unsigned short elapsed;
} data_resp_t;

typedef struct {
	unsigned char det : 1;
	unsigned char dir : 2;
	unsigned char spd_status : 2;
	unsigned char pow_status : 2;
	unsigned char spd_val;
	short pow_val;
} data_el_t;

typedef struct {
  double spd;
  double dist;
} target_t;

typedef struct {
  int power;
  unsigned char status;
} raw_pt_t;

typedef struct {
  base_resp_t base_resp;
  unsigned char meas_no;
  unsigned short elapsed;
  raw_pt_t rise[1024];
  raw_pt_t fall[1024];
  unsigned char ntargets;
  target_t targets[255];
} data_alt_resp_t;

typedef struct {
  unsigned short p;
  unsigned short d;
} thpt_t;

typedef struct {
  base_resp_t base_resp;
  unsigned short npts;
  thpt_t pts[1024];
} getth_resp_t;

typedef data_el_t target_pt_t;

typedef struct {
  base_req_t base_req;
  char mode;
  unsigned short cycle_dur;
} meas_ctl_req_t;

typedef struct {
  base_req_t base_req;
  unsigned short npts;
  thpt_t pts[1024];
} setth_req_t;

int req_is_valid(base_req_t *req);

base_resp_t *form_base_resp(char *buf, char no, char fn, char rv);

status_t form_status(int fault, int ready, int meas_mode,int last_unsucc, int has_unread);
status_resp_t *form_status_temps(char *buf, char t1, char t2, char t3);
status_resp_t *form_status_amperage(char *buf,
                                    unsigned char i1,
                                    unsigned char i2,
                                    unsigned char i3);
status_resp_t *form_status_voltage(char *buf, char u1, char u2, char u3, char u4);
status_resp_t *form_status_resp(char *buf,
				status_t status, char details);

data_resp_t *form_data_resp(char *buf, status_t status, char meas_no, unsigned short elapsed);

meas_ctl_resp_t *form_meas_ctl_resp(char *buf, status_t status);
getth_resp_t *form_getth_resp(char *buf, ipt_t *pt, int npts);
#endif
