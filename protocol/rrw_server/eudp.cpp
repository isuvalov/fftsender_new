#include<common.h>
#include<eudp.h>

#ifdef WIN32
static WSADATA wsa;
#endif

int eudp_start() {
#ifdef WIN32
    if(WSAStartup(MAKEWORD(2,2),&wsa)!=0)
        return -1;
#endif
    return 0;
}

void eudp_finish() {
#ifdef WIN32
    WSACleanup();
#endif
}

void eudp_get_addr_str(eudp_addr_t *addr, char *str) {
    sprintf(str,"%s",inet_ntoa(addr->sin_addr));
}

unsigned short eudp_get_port_num(eudp_addr_t *addr) {
    return addr->sin_port;
}

eudp_addr_t eudp_new_addr(char *addr, unsigned short port) {
    eudp_addr_t a;
    a.sin_addr.s_addr = inet_addr(addr);
    a.sin_family = AF_INET;
    a.sin_port = htons(port);
    return a;
}

eudp_addr_t eudp_any_addr(unsigned short port) {
    eudp_addr_t a;
    a.sin_addr.s_addr = htonl(INADDR_ANY);
    a.sin_family = AF_INET;
    a.sin_port = htons(port);
    return a;
}

void eudp_set_src_addr(eudp_t *hnd, char *addr,unsigned short port) {
    hnd->src = eudp_new_addr(addr,port);
}

void eudp_set_dest_addr(eudp_t *hnd, char *addr, unsigned short port) {
    hnd->dest = eudp_new_addr(addr,port);
}

void eudp_set_dest_broadcast(eudp_t *hnd, int port) {
    hnd->dest.sin_addr.s_addr = htonl(INADDR_BROADCAST);
    hnd->dest.sin_family = AF_INET;
    hnd->dest.sin_port = htons(port);
}

void eudp_set_rcv_timeout(eudp_t *hnd, int ms) {
    hnd->tmo_ui = ms;
    hnd->tmo.tv_sec = ms/1000;
    hnd->tmo.tv_usec = (ms%1000)*1000;
#ifdef WIN32
    setsockopt(hnd->sock,SOL_SOCKET,SO_RCVTIMEO,(char *)&(hnd->tmo_ui),sizeof(int));
#else
    setsockopt(hnd->sock,SOL_SOCKET,SO_RCVTIMEO,(void *)&(hnd->tmo),sizeof(eudp_time_t));
#endif
}

void eudp_set_snd_timeout(eudp_t *hnd, int ms) {
    hnd->tmo_ui = ms;
    hnd->tmo.tv_sec = ms/1000;
    hnd->tmo.tv_usec = (ms%1000)*1000;
#ifdef WIN32
    setsockopt(hnd->sock,SOL_SOCKET,SO_SNDTIMEO,(char *)&(hnd->tmo_ui),sizeof(int));
#else
    setsockopt(hnd->sock,SOL_SOCKET,SO_SNDTIMEO,(void *)&(hnd->tmo),sizeof(eudp_time_t));
#endif
}

int eudp_open(eudp_t *hnd) {
    if((hnd->sock = socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP))==INVALID_SOCKET) {
        //COMMENTEDprintf("UDP socket creation error!\n");
        return -1;
    }
    return 0;
}

int eudp_close(eudp_t *hnd) {
#ifdef WIN32
    return closesocket(hnd->sock);
#else
    return close(hnd->sock);
#endif
}

int eudp_en_broadcast(eudp_t *hnd) {
    int bc_f = 1;
#ifdef WIN32
    return setsockopt(hnd->sock,SOL_SOCKET,SO_BROADCAST,(char *)&bc_f,sizeof(bc_f));
#else
    return setsockopt(hnd->sock,SOL_SOCKET,SO_BROADCAST,(char *)&bc_f,sizeof(bc_f));
#endif
}

int eudp_dis_broadcast(eudp_t *hnd) {
    int bc_f = 0;
#ifdef WIN32
    return setsockopt(hnd->sock,SOL_SOCKET,SO_BROADCAST,(char *)&bc_f,sizeof(bc_f));
#else
    return setsockopt(hnd->sock,SOL_SOCKET,SO_BROADCAST,(void *)&bc_f,sizeof(bc_f));
#endif
}

int eudp_set_non_blocking(eudp_t *hnd) {
    int rv;
#ifdef WIN32
    unsigned long ul = 1;
    rv = ioctlsocket(hnd->sock,FIONBIO,&ul);
#else
    rv = fcntl(hnd->sock, F_SETFL, O_NONBLOCK);
#endif
    if(rv==-1) {
        //COMMENTEDprintf("UDP socket non-blocking mode enabling error!\n");
        return -1;
    }
    return 0;
}

int eudp_set_blocking(eudp_t *hnd) {
    int rv;
#ifdef WIN32
    unsigned long ul = 0;
    rv = ioctlsocket(hnd->sock,FIONBIO,&ul);
#else
    int flags = fcntl(hnd->sock, F_GETFL, 0);
    flags &= (~O_NONBLOCK);
    rv = fcntl(hnd->sock,F_SETFL,flags);
#endif
    if(rv==-1) {
        //COMMENTEDprintf("UDP socket blocking mode enabling error!\n");
        return -1;
    }
    return 0;
}

int eudp_bind(eudp_t *hnd) {
    int rv = bind(hnd->sock,(struct sockaddr *)&(hnd->src),sizeof(hnd->src));
    if(rv==-1) {
        //COMMENTEDprintf("UDP socket binding error!\n");
        return -1;
    }
    return 0;
}

void eudp_en_reuseaddr(eudp_t *hnd) {
    unsigned long f = 1;
    #ifdef WIN32
    setsockopt(hnd->sock,SOL_SOCKET,SO_REUSEADDR,(char *)&f,sizeof(f));
    #else
    setsockopt(hnd->sock,SOL_SOCKET,SO_REUSEADDR,(void *)&f,sizeof(f));
    #endif
}

void eudp_dis_reuseaddr(eudp_t *hnd) {
    unsigned long f = 0;
    #ifdef WIN32
    setsockopt(hnd->sock,SOL_SOCKET,SO_REUSEADDR,(char *)&f,sizeof(f));
    #else
    setsockopt(hnd->sock,SOL_SOCKET,SO_REUSEADDR,(void *)&f,sizeof(f));
    #endif
}

int eudp_open_nonbl_with_dest(eudp_t *hnd,
                              char *src_addr, int src_port,
                              char *dest_addr, int dest_port) {

    int rv;

    eudp_set_src_addr(hnd,src_addr,src_port);
    eudp_set_dest_addr(hnd,dest_addr,dest_port);

    rv = eudp_open(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_set_non_blocking(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);
    return rv;
}

int eudp_open_bl_src_any_addr_with_dest(eudp_t *hnd,
                                        int src_port,
                                        char *dest_addr, int dest_port) {
    int rv;
    unsigned long f;

    hnd->src.sin_addr.s_addr = htonl(INADDR_ANY);
    hnd->src.sin_family = AF_INET;
    hnd->src.sin_port = src_port;
    eudp_set_dest_addr(hnd,dest_addr,dest_port);

    rv = eudp_open(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_set_blocking(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);
    f = 1;
    #ifdef WIN32
    setsockopt(hnd->sock,SOL_SOCKET,SO_REUSEADDR,(char *)&f,sizeof(f));
    #else
    setsockopt(hnd->sock,SOL_SOCKET,SO_REUSEADDR,(void *)&f,sizeof(f));
    #endif
    return rv;
}

int eudp_open_bl_with_dest(eudp_t *hnd,
                           char *src_addr, int src_port,
                           char *dest_addr, int dest_port) {
    int rv;
    unsigned long f;

    eudp_set_src_addr(hnd,src_addr,src_port);
    eudp_set_dest_addr(hnd,dest_addr,dest_port);

    rv = eudp_open(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_set_blocking(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);
    f = 1;
    setsockopt(hnd->sock,SOL_SOCKET,SO_REUSEADDR,(char *)&f,sizeof(f));

    return rv;
}

int eudp_open_bl_reciever(eudp_t *hnd,
                          char *addr, int port) {

    int rv = 0;

    eudp_set_src_addr(hnd,addr,port);

    rv = eudp_open(hnd);

    if(rv!=EUDP_ERR)
        rv = eudp_set_blocking(hnd);

    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);

    eudp_en_reuseaddr(hnd);

    return rv;
}

int eudp_open_bl(eudp_t *hnd,
		 char *addr, int port) {

    int rv = 0;

    eudp_set_src_addr(hnd,addr,port);

    rv = eudp_open(hnd);

    if(rv!=EUDP_ERR)
        rv = eudp_set_blocking(hnd);

    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);

    eudp_en_reuseaddr(hnd);

    return rv;
}


int eudp_open_bl_reciever2(eudp_t *hnd, int port) {

    int rv = 0;

    hnd->src = eudp_any_addr(port);

    rv = eudp_open(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_set_blocking(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);

    eudp_en_reuseaddr(hnd);

    return rv;
}

int eudp_open_nonbl_broadcast(eudp_t *hnd,
                              char *src_addr, int src_port,
                              int dest_port) {

    int rv;

    eudp_set_src_addr(hnd,src_addr,src_port);
    eudp_set_dest_broadcast(hnd,dest_port);

    rv = eudp_open(hnd);

    eudp_en_broadcast(hnd);

    if(rv!=EUDP_ERR)
        rv = eudp_set_non_blocking(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);

    return rv;
}

int eudp_open_bl_broadcast(eudp_t *hnd,
                           char *src_addr, int src_port,
                           int dest_port) {

    int rv;

    eudp_set_src_addr(hnd,src_addr,src_port);
    eudp_set_dest_broadcast(hnd,dest_port);

    rv = eudp_open(hnd);

    eudp_en_broadcast(hnd);

    if(rv!=EUDP_ERR)
        rv = eudp_set_non_blocking(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);

    return rv;
}

int eudp_open_bl_subnet(eudp_t *hnd, char *src_addr, int src_port,
                        char *dest_subnet, int dest_port) {
    int rv;
    char subnet_addr[16];
    char *ds;

    sprintf(subnet_addr,"%s",dest_subnet);
    ds = strchr(subnet_addr,'.');
    ds = strchr(ds+1,'.');
    ds = strchr(ds+1,'.');
    ds+=1;
    ds[0] = '2';
    ds[1] = '5';
    ds[2] = '5';
    ds[3] = 0;

    eudp_set_src_addr(hnd,src_addr,src_port);
    eudp_set_dest_addr(hnd,subnet_addr,dest_port);

    rv = eudp_open(hnd);

    eudp_en_broadcast(hnd);

    if(rv!=EUDP_ERR)
        rv = eudp_set_blocking(hnd);
    if(rv!=EUDP_ERR)
        rv = eudp_bind(hnd);

    eudp_en_reuseaddr(hnd);
  return rv;
}

int eudp_recv(eudp_t *hnd, char *buf, int len) {
    memset(buf,0,sizeof(char)*len);
    return recv(hnd->sock,buf,len,0);
}

int eudp_recvfrom(eudp_t *hnd, eudp_addr_t *from, char *buf, int len) {
  int addr_len = sizeof(struct sockaddr);
  return recvfrom(hnd->sock,buf,sizeof(char)*len,0,(struct sockaddr *)from,&addr_len);
}

int eudp_send(eudp_t *hnd, char *buf, int len) {
    return sendto(hnd->sock,buf,len,0,(struct sockaddr *)&(hnd->dest),sizeof(hnd->dest));
}

int eudp_sendto(eudp_t *hnd, eudp_addr_t *dest, char *buf, int len) {
    return sendto(hnd->sock,buf,len,0,(struct sockaddr *)dest,sizeof(eudp_addr_t));
}

