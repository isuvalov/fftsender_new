#include <common.h>
#include<rrw_proto.h>
#include<string.h>
int req_is_valid(base_req_t *req) {
  return req->_ == 0x5A;
}

base_resp_t *form_base_resp(char *buf, char no, char fn, char rv) {
  base_resp_t *resp = (base_resp_t *)buf;
  resp->_ = 0xA5;
  resp->no = no;
  resp->fn = fn;
  resp->rv = rv;
  return resp;
}

status_t form_status(int fault, int ready, int meas_mode,
                     int last_unsucc, int has_unread) {
  status_t status;

  status.fault = fault;
  status.ready = ready;
  status.meas_mode = meas_mode;
  status.last_unsucc = last_unsucc;
  status.has_unread = has_unread;

  return status;
}

status_resp_t *form_status_temps(char *buf, char t1, char t2, char t3) {
  status_resp_t *resp = (status_resp_t *)buf;

  resp->t[0] = t1;
  resp->t[1] = t2;
  resp->t[2] = t3;

  return resp;
}

status_resp_t *form_status_amperage(char *buf,
                                    unsigned char i1,
                                    unsigned char i2,
                                    unsigned char i3) {
  status_resp_t *resp = (status_resp_t *)buf;

  resp->i[0] = i1;
  resp->i[1] = i2;
  resp->i[2] = i3;

  return resp;
}

status_resp_t *form_status_voltage(char *buf, char u1, char u2, char u3, char u4) {

  status_resp_t *resp = (status_resp_t *)buf;

  resp->u[0] = u1;
  resp->u[1] = u2;
  resp->u[2] = u3;
  resp->u[3] = u4;

  return resp;
}

status_resp_t *form_status_resp(char *buf,
				status_t status, char details) {
  status_resp_t *resp = (status_resp_t *)buf;

  resp->status = status;
  resp->details = details;

  memset(resp->t,0,sizeof(unsigned char)*3);
  memset(resp->i,0,sizeof(unsigned char)*3);
  memset(resp->u,0,sizeof(unsigned char)*4);

  return resp;
}

data_resp_t *form_data_resp(char *buf, status_t status, char meas_no, unsigned short elapsed) {
  data_resp_t *resp = (data_resp_t *)buf;

  resp->status = status;
  resp->meas_no = meas_no;
  resp->elapsed = elapsed;
  return resp;
}

meas_ctl_resp_t *form_meas_ctl_resp(char *buf, status_t status) {
  meas_ctl_resp_t *resp = (meas_ctl_resp_t *)buf;
  resp->status = status;
  return resp;
}

getth_resp_t *form_getth_resp(char *buf, ipt_t *pts, int npts) {
  int i;
  getth_resp_t *resp = (getth_resp_t *)buf;
  resp->npts = npts;
  for(i=0; i<npts; i++) {
    resp->pts[i].d = pts[i].x;
    resp->pts[i].p = pts[i].y;
  }

  return resp;
}



