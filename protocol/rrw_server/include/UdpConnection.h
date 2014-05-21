#ifndef UDPCONNECTION_H
#define UDPCONNECTION_H

#include<types.h>
#include <CfgClass.h>
#include<eudp.h>
#include<timeutils.h>
#include<pthread.h>
#include<vector>
#include<Timer.h>

class UdpConnection
{
    public:
        static bool is_need_udp_start;
        bool is_need_udp_finish;
        string ip;
        int port;
        bool is_working;
        UdpConnection(string cfg_root = "");
        ~UdpConnection();

    protected:
        bool init_status;
        eudp_t udp;
        eudp_addr_t from_addr;
        CfgClass cfg;
        bool isInit();
        void init(void);
        bool open(void){};
        void close(void);
        void mutex_lock(bool on = true);
    private:
        pthread_mutex_t mtx;


};

#endif // UDPCONNECTION_H
