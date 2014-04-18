#include<radar.h>

void rdr_init(rdr_t *rdr, char *addr, int port, int pkt_sz,
	      int (*coll_fn)(rdr_t *rdr, void *coll, int coll_sz, int pkt_data_size)) {

  rdr->pkt = (char *)malloc(pkt_sz*sizeof(char));
  rdr->pkt_sz = pkt_sz;
  memset(rdr->pkt,0,sizeof(char)*rdr->pkt_sz);

  sprintf(rdr->addr,"%s",addr);
  rdr->port = port;

  rdr->coll_fn = coll_fn;
}

void rdr_deinit(rdr_t *rdr) {
  rdr_disconn(rdr);
  free(rdr->pkt);
}

void rdr_conn(rdr_t *rdr) {
  eudp_open_bl_reciever((eudp_t *)rdr,rdr->addr,rdr->port);
  eudp_set_timeout((eudp_t *)rdr,1000);
}

void rdr_disconn(rdr_t *rdr) {
  eudp_close((eudp_t *)rdr);
}

char *rdr_get_pkt(rdr_t *rdr) {
  return rdr->pkt;
}

int rdr_get_pkt_sz(rdr_t *rdr) {
  return rdr->pkt_sz;
}

int rdr_recv_pkt(rdr_t *rdr) {
    int rv;

    rv = eudp_recv((eudp_t *)rdr,rdr->pkt,rdr->pkt_sz);
    if(rv!=rdr->pkt_sz)
        return -1;

    return rv;
}

int rdr_collect_pkts(rdr_t *rdr, void *coll, int coll_sz, int pkt_data_size) {
  if(rdr->coll_fn==NULL)
    return -1;
  return rdr->coll_fn(rdr, coll, coll_sz, pkt_data_size);
}
