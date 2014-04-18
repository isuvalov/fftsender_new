#ifndef UDPCONNECTION_H
#define UDPCONNECTION_H

#include <CfgClass.h>
#include<eudp.h>
#include<timeutils.h>
#include<pthread.h>
#include<vector>
#include<Timer.h>

class UdpConnection
{
    public:
        string ip;
        int port;
        UdpConnection(string cfg_root = "");
        virtual ~UdpConnection();
    protected:

        bool init_status;
        eudp_t udp;
        eudp_addr_t from_addr;
        CfgClass cfg;
        bool isInit();
        void init(void);
        virtual bool open(void){};
        void close(void);
    private:
};

#endif // UDPCONNECTION_H
