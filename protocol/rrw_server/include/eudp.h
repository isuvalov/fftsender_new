#ifndef EASY_UDP_H
#define EASY_UDP_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include<sys/types.h>

#define EUDP_ERR -1

#ifdef WIN32

#include <windows.h>
#include <winsock2.h>

#define IOCTL_ERROR -1
#define BIND_ERROR -1

#define eudp_sleep_ms Sleep
#define eudp_sleep_s(s) Sleep(s*1000)

#else



#include<netinet/in.h>
#include<sys/socket.h>
#include<unistd.h>
#include<sys/select.h>
#include<sys/time.h>
#include <fcntl.h>
#define INVALID_SOCKET -1
#define IOCTL_ERROR -1
#define BIND_ERROR -1

#define eudp_sleep_ms(ms) usleep(ms*1000)
#define eudp_sleep_s sleep

#endif

typedef int eudp_sock_t;
typedef struct sockaddr_in eudp_addr_t;
typedef struct timeval eudp_time_t;

typedef struct {
    eudp_sock_t sock;
    eudp_addr_t src;
    eudp_addr_t dest;
    eudp_time_t tmo;
    int tmo_ui;
    int has_dest;
    char *buf_rd;
    int sz_buf_rd;
    char *buf_wr;
    int sz_buf_wr;
    #ifndef RTL_SIMULATION
        static int rx_busy;
    #endif // RTL_SIMULATION
} eudp_t;
#ifndef RTL_SIMULATION
int eudp_t::rx_busy = 0;
#endif // RTL_SIMULATION


//Address utilities
void eudp_get_addr_str(eudp_addr_t *addr, char *str);
unsigned short eudp_get_port_num(eudp_addr_t *addr);
eudp_addr_t eudp_new_addr(char *addr, unsigned short port);

//Initialization/deinitialization
int eudp_start();
void eudp_finish();
int eudp_open(eudp_t *hnd);
int eudp_close(eudp_t *hnd);
int eudp_en_broadcast(eudp_t *hnd);
int eudp_dis_broadcast(eudp_t *hnd);
int eudp_set_non_blocking(eudp_t *hnd);
int eudp_set_blocking(eudp_t *hnd);
void eudp_en_reuseaddr(eudp_t *hnd);
void eudp_dis_reuseaddr(eudp_t *hnd);

//Default configurations
int eudp_open_nonbl_with_dest(eudp_t *hnd,
                              char *src_addr, int src_port,
                              char *dest_addr, int dest_port);
int eudp_open_bl_with_dest(eudp_t *hnd,
                           char *src_addr, int src_port,
                           char *dest_addr, int dest_port);
int eudp_open_nonbl_broadcast(eudp_t *hnd,
                              char *src_addr, int src_port,
                              int dest_port);
int eudp_open_bl_broadcast(eudp_t *hnd,
                           char *src_addr, int src_port,
                           int dest_port);

//Configuration
void eudp_set_src_addr(eudp_t *hnd, char *addr,unsigned short port);
void eudp_set_dest_addr(eudp_t *hnd, char *addr, unsigned short port);
void eudp_set_dest_broadcast(eudp_t *hnd, int port);
void eudp_set_timeout(eudp_t *hnd, int ms);

//Transmission
int eudp_bind(eudp_t *hnd);
int eudp_recv(eudp_t *hnd, char *buf, int len);
int eudp_recvfrom(eudp_t *hnd, eudp_addr_t *from, char *buf, int len);
int eudp_send(eudp_t *hnd, char *buf, int len);
int eudp_sendto(eudp_t *hnd, eudp_addr_t *dest, char *buf, int len);

int eudp_open_bl_src_any_addr_with_dest(eudp_t *hnd,
                                        int src_port,
                                        char *dest_addr, int dest_port);

int eudp_open_bl_reciever(eudp_t *hnd,
                          char *addr, int port);

eudp_addr_t eudp_any_addr(unsigned short port);


int eudp_open_bl_reciever2(eudp_t *hnd,int port);

int eudp_open_bl_subnet(eudp_t *hnd, char *src_addr, int src_port,
                        char *dest_subnet, int dest_port);

int eudp_open_bl(eudp_t *hnd,
		 char *addr, int port);
#endif

void eudp_set_rcv_timeout(eudp_t *hnd, int ms);
void eudp_set_snd_timeout(eudp_t *hnd, int ms);
