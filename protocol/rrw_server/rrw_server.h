#ifndef RRW_SERVER_H
#define RRW_SERVER_H

#define REQ_BUF_SZ 128
#define RESP_BUF_SZ 32768

#define MEAS_CYCLIC 1
#define MEAS_BY_REQ 0

#include<eudp.h>
#include<rrw_proto.h>
#include<radar_cli.h>

/**Server object declaration*/
typedef struct {
  eudp_t udp;
  rcli_t *rcli;
  char addr[16];
  int port;

  eudp_addr_t from_addr;

  char req[REQ_BUF_SZ];
  int req_len;
  char resp[RESP_BUF_SZ];
  int resp_len;

  int working;
  int fn_rv;

  status_t status;

  int fault;
  int last_err;
  int rcv_tmo;
  int snd_tmo;
} srv_t;

void srv_init(srv_t *srv, char *addr, int port, int rcv_tmo, int snd_tmo, rcli_t *rcli);
void srv_open(srv_t *srv);
void srv_close(srv_t *srv);
void srv_start(srv_t *srv);
void srv_stop(srv_t *srv);
void srv_do(srv_t *srv);

int srv_handle_req(srv_t *srv);
int srv_handle_status_req(srv_t *srv);
int srv_handle_data_req(srv_t *srv);
int srv_handle_meas_ctl_req(srv_t *srv);
int srv_handle_setth_req(srv_t *srv);
int srv_handle_getth_req(srv_t *srv);

int srv_prepare_resp(srv_t *srv);
int srv_prepare_status_resp(srv_t *srv);
int srv_prepare_meas_ctl_resp(srv_t *srv);
int srv_prepare_data_resp(srv_t *srv);
int srv_prepare_data_alt_resp(srv_t *srv);
int srv_prepare_getth_resp(srv_t *srv);

int srv_has_req(srv_t *srv);
int srv_is_working(srv_t *srv);
int srv_recv_req(srv_t *srv);
int srv_send_resp(srv_t *srv);

#endif
