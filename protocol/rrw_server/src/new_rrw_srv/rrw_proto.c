#include<rrw_proto.h>

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
		     int test_mode, int last_unsucc, int has_unread) {
  status_t status;
  
  status.fault = fault;
  status.ready = ready;
  status.meas_mode = meas_mode;
  status.test_mode = test_mode;
  status.last_unsucc = last_unsucc;
  status.has_unread = has_unread;

  return status;
}

status_resp_t *form_status_temps(char *buf, char t1, char t2, char t3) {
  status_resp_t *resp = (status_resp_t *)buf;
  
  resp->t1 = t1;
  resp->t2 = t2;
  resp->t3 = t3;
  
  return resp;
}

status_resp_t *form_status_amperage(char *buf, char i1, char i2, char i3) {
  status_resp_t *resp = (status_resp_t *)buf;
  
  resp->i1 = i1;
  resp->i2 = i2;
  resp->i3 = i3;

  return resp;
}

status_resp_t *form_status_voltage(char *buf, char u1, char u2, char u3, char u4) {

  status_resp_t *resp = (status_resp_t *)buf;

  resp->u1 = u1;
  resp->u2 = u2;
  resp->u3 = u3;
  resp->u4 = u4;

  return resp;
}

status_resp_t *form_status_resp(char *buf,
				status_t status, char details) {
  status_resp_t *resp = (status_resp_t *)buf;

  resp->status = status;
  resp->details = 0;

  resp->t1 = 0;
  resp->t2 = 0;
  resp->t3 = 0;
  resp->i1 = 0;
  resp->i2 = 0;
  resp->i3 = 0;
  resp->u1 = 0;
  resp->u2 = 0;
  resp->u3 = 0;
  resp->u4 = 0;

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
