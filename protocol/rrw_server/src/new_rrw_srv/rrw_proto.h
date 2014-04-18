#ifndef RRW_PROTO_H
#define RRW_PROTO_H

//Function codes
#define RRW_FN_STATUS   0x00
#define RRW_FN_DATA     0x01
#define RRW_FN_MEAS_CTL 0x02
#define RRW_FN_TEST     0x03

//Function return codes
#define RRW_RV_SUCCESS  0x00
#define RRW_RV_BAD_REQ  0x01
#define RRW_RV_BUSY     0x02
#define RRW_RV_ERROR    0xFF

//Measurement modes
#define RRW_MEAS_ON_REQ 0x00
#define RRW_MEAS_CYCLE 0x01

typedef struct {
    char _;
    char no;
    char fn;
} base_req_t;

typedef struct {
    char _;
    char no; 
    char fn;
    char rv;
} base_resp_t;

 typedef struct {
    unsigned char fault : 1;
    unsigned char ready : 1;
    unsigned char meas_mode : 1;
    unsigned char test_mode : 1;
    unsigned char last_unsucc : 1;
    unsigned char has_unread : 1;
} status_t;

typedef struct {
    base_resp_t base_resp;
    status_t status;
    char details;
    char t1,t2,t3;
    char i1,i2,i3;
    char u1,u2,u3,u4;
} status_resp_t;

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
    unsigned char trgt_det : 1;
    unsigned char mov_dir : 2;
    unsigned char spd_stat : 2;
    unsigned char pwr_stat : 2;
    unsigned char spd;
    unsigned short pwr;
} data_el_t;

typedef struct {
    base_req_t base_req;
    char mode;
    unsigned short cycle_dly;
    unsigned short cycle_dur;
} meas_ctl_req_t;

typedef struct {
    base_req_t base_req;
    char ctl;
} test_req_t;

int req_is_valid(base_req_t *req);

base_resp_t *form_base_resp(char *buf, char no, char fn, char rv);

status_t form_status(int fault, int ready, int meas_mode,
		     int test_mode, int last_unsucc, int has_unread);
status_resp_t *form_status_temps(char *buf, char t1, char t2, char t3);
status_resp_t *form_status_amperage(char *buf, char i1, char i2, char i3);
status_resp_t *form_status_voltage(char *buf, char u1, char u2, char u3, char u4);
status_resp_t *form_status_resp(char *buf,
				status_t status, char details);

data_resp_t *form_data_resp(char *buf, status_t status, char meas_no, unsigned short elapsed);

meas_ctl_resp_t *form_meas_ctl_resp(char *buf, status_t status);

#endif 
