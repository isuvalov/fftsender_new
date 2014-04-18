#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<rrw_server.h>
#include<pthread.h>
#include<limits.h>

void srv_init(srv_t *srv, char *addr, int port, rcli_t *rcli) {
  srv->rcli = rcli;
  sprintf(srv->addr,"%s",addr);
  srv->port = port;

  srv->fault = 0;
  srv->test_mode = 0;
}

void srv_open(srv_t *srv) {
  eudp_open_bl((eudp_t *)srv,srv->addr,srv->port);
  eudp_set_timeout((eudp_t *)srv,1000);
}

void srv_close(srv_t *srv) {
  eudp_close((eudp_t *)srv);
}

void srv_start(srv_t *srv) {
  srv->working = 1;
  srv_do(srv);
}

void srv_stop(srv_t *srv) {
  srv->working = 0;
}

void srv_do(srv_t *srv) {
  char addr_str[16];
  int rv;
  
  while(srv_is_working(srv)) {    
    srv_recv_req(srv);
    if(srv_has_req(srv)) {
      srv_handle_req(srv); //sets srv->fn_rv, which influences further processing
      srv_prepare_resp(srv);
      srv_send_resp(srv);
    } else {
      /* printf("RECV: NOTHING\n"); */
    }
  }
}

int srv_is_working(srv_t *srv) {
  return srv->working;
}

int srv_has_req(srv_t *srv) {
  return srv->req_len > 0;
}

int srv_recv_req(srv_t *srv) {
  return (srv->req_len = eudp_recvfrom((eudp_t *)srv,&(srv->from_addr),srv->req,REQ_BUF_SZ));
}

int srv_send_resp(srv_t *srv) {
  return eudp_sendto((eudp_t *)srv,&(srv->from_addr),srv->resp,srv->resp_len);
}

int srv_is_ready(srv_t *srv) {
  return !(srv->fault) && !(srv->test_mode);
}

void srv_update_status(srv_t *srv) {
  srv->status.has_unread = rcli_has_unread(srv->rcli);
  srv->status.last_unsucc = rcli_is_last_unsucc(srv->rcli);
  srv->status.meas_mode = rcli_meas_mode(srv->rcli);

  srv->status.ready = srv_is_ready(srv);
  srv->status.fault = srv->fault;
  srv->status.test_mode = srv->test_mode;
}

int srv_handle_status_req(srv_t *srv) {
  srv_update_status(srv);
  return RRW_RV_SUCCESS;
}

int srv_handle_data_req(srv_t *srv) {
  if(srv->test_mode) {
    return RRW_RV_BUSY;
  }

  if(rcli_meas_mode(srv->rcli)==MEAS_MODE_ON_REQ) {
    rcli_meas(srv->rcli);
  }
  srv_update_status(srv);
  
  return RRW_RV_SUCCESS;
}

int srv_handle_meas_ctl_req(srv_t *srv) {
  meas_ctl_req_t *req = (meas_ctl_req_t *)srv->req;

  if(srv->test_mode) {
    srv_update_status(srv);
    return RRW_RV_BUSY;
  }
  
  switch(req->mode) {
  case RRW_MEAS_ON_REQ:
    if(rcli_meas_mode(srv->rcli)==MEAS_MODE_CYCLE) {
      rcli_en_onreq_mode(srv->rcli);
    }
    rcli_set_cycle_dly(srv->rcli,req->cycle_dly);
    rcli_set_cycle_dur(srv->rcli,req->cycle_dur);
    break;
  case RRW_MEAS_CYCLE:
    if(rcli_meas_mode(srv->rcli)==MEAS_MODE_ON_REQ) {
      rcli_set_cycle_dly(srv->rcli,req->cycle_dly);
      rcli_set_cycle_dur(srv->rcli,req->cycle_dur);
      rcli_en_cycle_mode(srv->rcli);
    } else {
      rcli_cycle_stop(srv->rcli);
      rcli_set_cycle_dly(srv->rcli,req->cycle_dly);
      rcli_set_cycle_dur(srv->rcli,req->cycle_dur);      
      rcli_cycle_start(srv->rcli);
    }
    break;
  }
  
  srv_update_status(srv);

  return RRW_RV_SUCCESS;
}

void srv_test_mode(srv_t *srv, int ctl) {
  if(ctl) {
    if(rcli_meas_mode(srv->rcli)==MEAS_MODE_CYCLE)
      rcli_cycle_stop(srv->rcli);
    srv->test_mode = 1;
  } else {
    if(rcli_meas_mode(srv->rcli)==MEAS_MODE_CYCLE)
      rcli_cycle_start(srv->rcli);
    srv->test_mode = 0;
  }
  srv_update_status(srv);
}

int srv_handle_test_req(srv_t *srv) {
  test_req_t *req = (test_req_t *)srv->req;

  srv_test_mode(srv,req->ctl);

  return RRW_RV_SUCCESS;
}

int srv_handle_req(srv_t *srv) {
  base_req_t *req = (base_req_t *)srv->req;

  if(!req_is_valid(req))
    return (srv->fn_rv = RRW_RV_BAD_REQ);

  switch(req->fn) {
  case RRW_FN_STATUS:
    srv->fn_rv = srv_handle_status_req(srv);
    break;

  case RRW_FN_MEAS_CTL:
    srv->fn_rv = srv_handle_meas_ctl_req(srv);    
    break;

  case RRW_FN_TEST:
    srv->fn_rv = srv_handle_test_req(srv);
    break;

  case RRW_FN_DATA:    
    srv->fn_rv = srv_handle_data_req(srv);
    break;

  default:
    srv->fn_rv = RRW_RV_BAD_REQ;
    break;
  }
    
  return srv->fn_rv;
}

int srv_prepare_status_resp(srv_t *srv) {  
  form_status_resp(srv->resp,srv->status,0);  
  
  form_status_temps(srv->resp,
		    (unsigned short)(((double)rand()/INT_MAX)*30.0),
		    (unsigned short)(((double)rand()/INT_MAX)*30.0),
		    (unsigned short)(((double)rand()/INT_MAX)*30.0));
  form_status_amperage(srv->resp,
		       (unsigned short)(((double)rand()/INT_MAX)*30.0),
		       (unsigned short)(((double)rand()/INT_MAX)*30.0),
		       (unsigned short)(((double)rand()/INT_MAX)*30.0));
  form_status_voltage(srv->resp,
		      (unsigned short)(((double)rand()/INT_MAX)*30.0),
		      (unsigned short)(((double)rand()/INT_MAX)*30.0),
		      (unsigned short)(((double)rand()/INT_MAX)*30.0),
		      (unsigned short)(((double)rand()/INT_MAX)*30.0));
  
  return sizeof(status_resp_t);
}

int srv_prepare_meas_ctl_resp(srv_t *srv) {
  form_meas_ctl_resp(srv->resp,srv->status);
  return sizeof(meas_ctl_resp_t);
}

int srv_prepare_test_resp(srv_t *srv) {
  return sizeof(base_resp_t);
}

int srv_prepare_data_resp(srv_t *srv) {
  int i;
  data_resp_t *resp = (data_resp_t *)srv->resp;
  data_el_t *elems = (data_el_t *)(srv->resp + sizeof(data_resp_t));
  
  srv_update_status(srv);
  
  form_data_resp(srv->resp,
		 srv->status,
		 rcli_get_meas_no(srv->rcli),
		 rcli_get_elapsed(srv->rcli));
  
  if(srv->fn_rv==RRW_RV_BUSY)
    return sizeof(data_resp_t);

  rcli_incr_meas_no(srv->rcli);
  
  rcli_copy_last(srv->rcli,(char*)elems);

  return sizeof(data_resp_t)+1024*sizeof(data_el_t);
}

int srv_prepare_resp(srv_t *srv) {
  base_req_t *req = (base_req_t *)srv->req;
  
  form_base_resp(srv->resp,req->no,req->fn,srv->fn_rv);

  if(srv->fn_rv==RRW_RV_BAD_REQ) {
    return (srv->resp_len = sizeof(base_resp_t));
  }

  switch(req->fn) {
  case RRW_FN_STATUS:
    srv->resp_len = srv_prepare_status_resp(srv);
    break;

  case RRW_FN_MEAS_CTL:
    srv->resp_len = srv_prepare_meas_ctl_resp(srv);
    break;

  case RRW_FN_TEST:
    srv->resp_len = srv_prepare_test_resp(srv);
    break;
    
  case RRW_FN_DATA:
    srv->resp_len = srv_prepare_data_resp(srv);
    break;
  }

  return srv->resp_len;
}
