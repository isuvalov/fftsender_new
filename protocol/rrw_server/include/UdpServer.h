#ifndef UDPSERVER_H
#define UDPSERVER_H

#include <UdpConnection.h>
#include <UdpRadar.h>
#include <RrwProtocol.h>
#include <types.h>

#define REQ_BUF_SZ 128
#define RESP_BUF_SZ 32768


class UdpServer : public UdpConnection
{
    public:
        status_t status;
        resp_t resp;
        meas_data_t meas_data;
        RrwProtocol protocol;

        UdpServer(bool start_after_init = true, string cfg_root = "server");
        ~UdpServer();
        void start();
        void send_resp();
        bool create_data();
        void dispatch_request();
    protected:
        bool is_busy;
        pthread_mutex_t mtx;

        int timeout_rcv;
        int timeout_snd;
        vector<char> request;
        UdpRadar *radar;

        bool open(void);
        void close(void);
        bool is_req_recieved(void);

        pthread_t disp_req_status_th;
        pthread_t disp_req_data_th;

        //Функции для протокола РЖД

        static void* fn_req_status(void* arg);
        static void* fn_data_alt(void* arg);
        void fn_meas_ctl(); // не реализована
        void fn_get_th();   // не реализована
        void fn_set_th();   // не реализована

    private:
};

#endif // UDPSERVER_H
