#ifndef UDPSERVER_H
#define UDPSERVER_H

#include<conio.h>
#include <UdpConnection.h>
#include <UdpRadar.h>
#include <RrwProtocol.h>
#include <Processor.h>


#define REQ_BUF_SZ 5000
#define RESP_BUF_SZ 32768


class UdpServer : public UdpConnection
{
    public:
        status_t status;
        resp_t resp;
        resp_t resp_for_data;
        meas_data_t meas_data;
        unsigned short unlim_meas_duration;
        Timer timer_unlim_meas;
        Timer timer_1;
        bool is_dispatcher_work;
        RrwProtocol protocol;
        RrwProtocol protocol_data;

        UdpServer(string cfg_root = "server");
        ~UdpServer();
        void start();

        void stop();
        void send_resp(RrwProtocol* prot);

    protected:
        bool is_busy;
        pthread_mutex_t mtx;
        bool data_was_null;



        unsigned short duration_meas;

        int timeout_rcv;
        int timeout_snd;
        request_t request;
        UdpRadar radar;
        Processor processor;

        bool open(void);
        bool get_request();
        void dispatch_request();
        int create_data();

        static void* th_start_dispatch(void* arg);

        void resp_in_file();

    private:
        void start_measure();

};

#endif // UDPSERVER_H
