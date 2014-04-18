#include<radar.h>

/**Initialize radar*/
void rdr_init(rdr_t *rdr, char *addr, int port, int rcv_tmo, int pkt_sz,
	      int (*coll_fn)(rdr_t *rdr, void *coll, int coll_sz, void *arg)) {

  #ifdef DBG_RDR
  logprintf("RADAR: init\n");
  #endif // DBG__RADAR

  rdr->pkt = (char *)malloc(pkt_sz*sizeof(char));
  rdr->pkt_sz = pkt_sz;
  memset(rdr->pkt,0,sizeof(char)*rdr->pkt_sz);

  sprintf(rdr->addr,"%s",addr);
  rdr->port = port;
  rdr->coll_fn = coll_fn;

  rdr->rcv_tmo = rcv_tmo;
}

/**Deinitialize radar*/
void rdr_deinit(rdr_t *rdr) {
  rdr_disconn(rdr);
  free(rdr->pkt);
}

/**Connect to radar*/
void rdr_conn(rdr_t *rdr) {
  #ifdef DBG_RDR
    int rv =
  #endif
  eudp_open_bl_reciever((eudp_t *)rdr,rdr->addr,rdr->port);
  eudp_set_rcv_timeout((eudp_t *)rdr,rdr->rcv_tmo);
//  eudp_set_snd_timeout((eudp_t *)rdr,rdr->snd_tmo);

  #ifdef DBG_RDR
  logprintf("RADAR: connect, %d\n",rv);
  #endif // DBG__RADAR
}

/**Disconnect from radar*/
void rdr_disconn(rdr_t *rdr) {
  eudp_close((eudp_t *)rdr);
}

/**Get current recieved packet*/
char *rdr_get_pkt(rdr_t *rdr) {
  return rdr->pkt;
}

/**Get packet size*/
int rdr_get_pkt_sz(rdr_t *rdr) {
  return rdr->pkt_sz;
}

/**Recieve packet*/
int rdr_recv_pkt(rdr_t *rdr) {
    int rv;

    rv = eudp_recv((eudp_t *)rdr,rdr->pkt,rdr->pkt_sz);
    #ifdef DBG_RDR
    logprintf("RADAR: recieve, %d\n",rv);
    #endif // DBG__RADAR
    if(rv!=rdr->pkt_sz)
      return -1;

    return rv;
}

/**Collect packets (custom handler driven)*/
int rdr_collect_pkts(rdr_t *rdr, void *coll, int coll_sz, void *arg) {
  if(rdr->coll_fn==NULL)
    return 1;
  return rdr->coll_fn(rdr, coll, coll_sz, arg);
}
