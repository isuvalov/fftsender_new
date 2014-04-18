#include <common.h>
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<rrw_server.h>
#include<pthread.h>
#include<limits.h>
#include<cfg.h>

/**Initialize server*/
void srv_init(srv_t *srv, char *addr, int port, int rcv_tmo, int snd_tmo, rcli_t *rcli) {
  srv->rcli = rcli;
  sprintf(srv->addr,"%s",addr);
  srv->port = port;
  srv->rcv_tmo = rcv_tmo;
  srv->snd_tmo = snd_tmo;
  srv->fault = 0;
}

/**Establish server connection*/
void srv_open(srv_t *srv) {
  eudp_open_bl((eudp_t *)srv,srv->addr,srv->port);
  eudp_set_rcv_timeout((eudp_t *)srv,srv->rcv_tmo);
  eudp_set_snd_timeout((eudp_t *)srv,srv->snd_tmo);
}

/**Terminate server connection*/
void srv_close(srv_t *srv) {
  eudp_close((eudp_t *)srv);
}

/**Start main server routine*/
void srv_start(srv_t *srv) {
  srv->working = 1;
  srv_do(srv);
}

/**Stop main server routine*/
void srv_stop(srv_t *srv) {
  srv->working = 0;
}

/**Main server routine*/
void srv_do(srv_t *srv) {
  while(srv_is_working(srv)) {
    srv_recv_req(srv);
    if(srv_has_req(srv)) {
      srv_handle_req(srv); //sets srv->fn_rv, which influences further processing
      srv_prepare_resp(srv);
      srv_send_resp(srv);
    }
  }
}

/**Check if server is working*/
int srv_is_working(srv_t *srv) {
  return srv->working;
}

/**Check if request was recieved*/
int srv_has_req(srv_t *srv) {
  return srv->req_len > 0;
}

/**Recieve request*/
int srv_recv_req(srv_t *srv) {
  return (srv->req_len = eudp_recvfrom((eudp_t *)srv,&(srv->from_addr),srv->req,REQ_BUF_SZ));
}

/**Send response*/
int srv_send_resp(srv_t *srv) {
  return eudp_sendto((eudp_t *)srv,&(srv->from_addr),srv->resp,srv->resp_len);
}

/**Check if server is ready to communicate with radar*/
int srv_is_ready(srv_t *srv) {
  return 0;
}

/**Update status*/
void srv_update_status(srv_t *srv) {
  srv->status.has_unread = rcli_has_unread(srv->rcli);
  srv->status.last_unsucc = rcli_is_last_unsucc(srv->rcli);
  srv->status.meas_mode = rcli_meas_mode(srv->rcli);

  srv->status.ready = srv_is_ready(srv);
  srv->status.fault = 0;
}

/**Perform status request related routines*/
int srv_handle_status_req(srv_t *srv) {
  srv_update_status(srv);
  return RRW_RV_SUCCESS;
}

/**Perform data request related routines*/
int srv_handle_data_req(srv_t *srv) {

  //perform measurement if in on-request mode
  if(rcli_meas_mode(srv->rcli)==MEAS_MODE_ON_REQ) {
    rcli_meas(srv->rcli);
  }

  srv_update_status(srv);

  return RRW_RV_SUCCESS;
}

/**Perform measurement control requst related routines*/
int srv_handle_meas_ctl_req(srv_t *srv) {
  meas_ctl_req_t *req = (meas_ctl_req_t *)srv->req;

  switch(req->mode) {
  case RRW_MEAS_ON_REQ:
    //if in cyclic mode switch to on-request mode
    if(rcli_meas_mode(srv->rcli)==MEAS_MODE_CYCLE) {
      rcli_en_onreq_mode(srv->rcli);
    }
//    rcli_set_cycle_dly(srv->rcli,req->cycle_dly);
    rcli_set_cycle_dur(srv->rcli,req->cycle_dur);
    break;
  case RRW_MEAS_CYCLE:
    //if in on-request mode switch to cyclic mode
    if(rcli_meas_mode(srv->rcli)==MEAS_MODE_ON_REQ) {
//      rcli_set_cycle_dly(srv->rcli,req->cycle_dly);
      rcli_set_cycle_dur(srv->rcli,req->cycle_dur);
      rcli_en_cycle_mode(srv->rcli);
    } else {
      rcli_cycle_stop(srv->rcli);
//      rcli_set_cycle_dly(srv->rcli,req->cycle_dly);
      rcli_set_cycle_dur(srv->rcli,req->cycle_dur);
      rcli_cycle_start(srv->rcli);
    }
    break;
  }

  srv_update_status(srv);

  return RRW_RV_SUCCESS;
}

int srv_handle_setth_req(srv_t *srv) {
  setth_req_t *req = (setth_req_t *)srv->req;
  ipt_t *pts;
  int i;

  pts = (ipt_t*) malloc(sizeof(ipt_t)*req->npts);
  for(i=0; i<req->npts; i++) {
    pts[i].x = req->pts[i].d;
    pts[i].y = req->pts[i].p;
  }

  pthread_mutex_lock(&(srv->rcli->mtx));
  data_proc_set_th_pts(&(srv->rcli->data_proc),pts,req->npts);
  pthread_mutex_unlock(&(srv->rcli->mtx));

  return 0;
}

int srv_handle_getth_req(srv_t *srv) {
  //NOTHING TO DO
  return 0;
}

/**Handle request in dependence of its type*/
int srv_handle_req(srv_t *srv) {
  base_req_t *req = (base_req_t *)srv->req;

  //if request has no validity mark stop further processing
  if(!req_is_valid(req)) {
    #ifdef DBG_SRV
    logprintf("SERVER: invalid request!\n");
    #endif // DBG_SRV
    return (srv->fn_rv = RRW_RV_BAD_REQ);
  }
  //call appropriate handler and set request return value (srv->fn_rv)
  switch(req->fn) {
  case RRW_FN_STATUS:
    #ifdef DBG_SRV
    logprintf("SERVER: %d get status!\n",((base_req_t *)srv->req)->no);
    #endif
    srv->fn_rv = srv_handle_status_req(srv);
    break;

  case RRW_FN_MEAS_CTL:
    #ifdef DBG_SRV
    logprintf("SERVER: %d measurement control!\n",((base_req_t *)srv->req)->no);
    #endif
    srv->fn_rv = srv_handle_meas_ctl_req(srv);
    break;

  case RRW_FN_DATA_ALT:
    #ifdef DBG_SRV
    if(req->fn == RRW_FN_DATA)
      logprintf("SERVER: %d get data!\n",((base_req_t *)srv->req)->no);
    if(req->fn == RRW_FN_DATA_ALT)
      logprintf("SERVER: %d get data alt!\n",((base_req_t *)srv->req)->no);
    #endif
    srv->fn_rv = srv_handle_data_req(srv);
    break;
  case RRW_FN_SET_TH:
    #ifdef DBG_SRV
    logprintf("SERVER: %d set threshold!\n",((base_req_t *)srv->req)->no);
    #endif
    srv->fn_rv = srv_handle_setth_req(srv);
    break;
  case RRW_FN_GET_TH:
    #ifdef DBG_SRV
    logprintf("SERVER: %d get threshold!\n",((base_req_t *)srv->req)->no);
    #endif
    srv->fn_rv = srv_handle_getth_req(srv);
    break;
  default:
    #ifdef DBG_SRV
    logprintf("SERVER: %d incorrect function code!\n",((base_req_t *)srv->req)->no);
    #endif
    //if request contains incorrect function code process it as bad request
    srv->fn_rv = RRW_RV_BAD_REQ;
    break;
  }

  return srv->fn_rv;
}

/**Prepare status response packet*/
int srv_prepare_status_resp(srv_t *srv) {
  char details;
  details = 0;

  form_status_resp(srv->resp,srv->status,0x0D);

  //FILLERS FOR RADAR STATE PARAMS ->
  form_status_temps(srv->resp,
                    -1,-2,-3);
//		    (unsigned short)(((double)rand()/USHRT_MAX)*30.0),
//		    (unsigned short)(((double)rand()/USHRT_MAX)*30.0),
//		    (unsigned short)(((double)rand()/USHRT_MAX)*30.0));
  form_status_amperage(srv->resp,
                       4,5,6);
//		       (unsigned short)(((double)rand()/USHRT_MAX)*30.0),
//		       (unsigned short)(((double)rand()/USHRT_MAX)*30.0),
//		       (unsigned short)(((double)rand()/USHRT_MAX)*30.0));
  form_status_voltage(srv->resp,
                      -7,-8,9,10);
//		      (unsigned short)(((double)rand()/USHRT_MAX)*30.0),
//		      (unsigned short)(((double)rand()/USHRT_MAX)*30.0),
//		      (unsigned short)(((double)rand()/USHRT_MAX)*30.0),
//		      (unsigned short)(((double)rand()/USHRT_MAX)*30.0));
  //<-
  return sizeof(status_resp_t);
}

/**Prepare measurement control response packet*/
int srv_prepare_meas_ctl_resp(srv_t *srv) {
  form_meas_ctl_resp(srv->resp,srv->status);
  return sizeof(meas_ctl_resp_t);
}

/**Prepare data response packet*/
int srv_prepare_data_resp(srv_t *srv) {
//  int i;
//  data_resp_t *resp = (data_resp_t *)srv->resp;
  data_el_t *elems = (data_el_t *)(srv->resp + sizeof(data_resp_t));

  form_data_resp(srv->resp,
		 srv->status,
		 rcli_get_meas_no(srv->rcli),
		 rcli_get_elapsed(srv->rcli));

  //if server is busy (e.g. if test mode is enabled) shrink packet to size of header
  if(srv->fn_rv==RRW_RV_BUSY) {
    #ifdef DBG_SRV
    logprintf("SERVER: busy!\n");
    #endif
    return sizeof(data_resp_t);
  }

  //increment measurement ordinal number
  rcli_incr_meas_no(srv->rcli);

  if(srv->rcli->has_data) {
  //copy last targets data to response buffer
    rcli_copy_last(srv->rcli,(char*)elems);
    return sizeof(data_resp_t)+1024*sizeof(data_el_t);
  } else {
    return sizeof(data_resp_t);
  }

//  logprintf("RESP!\n");

//  return sizeof(data_resp_t)+1024*sizeof(data_el_t);
}

int srv_prepare_data_alt_resp(srv_t *srv) {
  int i;
  base_req_t *req = (base_req_t *)srv->req;
  data_alt_resp_t *resp = (data_alt_resp_t *)(srv->resp);

  resp->meas_no = rcli_get_meas_no(srv->rcli);
  resp->elapsed = rcli_get_elapsed(srv->rcli);

  rcli_copy_last_raw(srv->rcli,resp->rise,resp->fall);
  resp->ntargets = 0;

//  return sizeof(base_resp_t);

  int sz = sizeof(data_alt_resp_t) - 255*sizeof(target_t);
  printf("SIZE OF RESP %d\n",sz);
  return sz;
//  return sizeof(data_alt_resp_t) - 255*sizeof(target_t);
}

int srv_prepare_getth_resp(srv_t *srv) {
  base_req_t *req = (base_req_t *)srv->req;
  getth_resp_t *resp = (getth_resp_t *)srv->resp;

  form_getth_resp(srv->resp,
                  srv->rcli->data_proc.th->points,
                  srv->rcli->data_proc.th->size);

  return sizeof(getth_resp_t) - (RRW_MAX_TH_PTS_NUM - resp->npts)*sizeof(thpt_t);
}

/**Prepare response in dependence of request type*/
int srv_prepare_resp(srv_t *srv) {
  base_req_t *req = (base_req_t *)srv->req;

  //fill base response fields
  form_base_resp(srv->resp,req->no,req->fn,srv->fn_rv);

  //stop further processing if bad request
  if(srv->fn_rv==RRW_RV_BAD_REQ) {
    printf("BAD REQUEST!\n");
    return (srv->resp_len = sizeof(base_resp_t));
  }

  //call response forming routines and calculate length of data to send back
  switch(req->fn) {
  case RRW_FN_STATUS:
    srv->resp_len = srv_prepare_status_resp(srv);
    int i;

    for(i=0; i<srv->resp_len; i++) {
      printf("%d ",srv->resp[i]);
    }
    printf("\n");

    break;

  case RRW_FN_MEAS_CTL:
    srv->resp_len = srv_prepare_meas_ctl_resp(srv);
    break;
//  case RRW_FN_DATA:
//    srv->resp_len = srv_prepare_data_resp(srv);
//    break;
  case RRW_FN_DATA_ALT:
    srv->resp_len = srv_prepare_data_alt_resp(srv);
    break;
  case RRW_FN_GET_TH:
  case RRW_FN_SET_TH:
    srv->resp_len = srv_prepare_getth_resp(srv);
    break;
  }

  return srv->resp_len;
}
