#include "UdpConnection.h"

bool UdpConnection::is_need_udp_start = true;


UdpConnection::UdpConnection(string cfg_root)
{
    is_need_udp_finish = false;
    is_working = false;
    ip ="127.0.0.1";
    port = 60606;
    init_status = false;

    if (!cfg_root.empty())
        cfg.load(cfg_root);
    if (cfg.isLoaded())
        init();

    if (is_need_udp_start) {
        eudp_start();
        is_need_udp_start = false;
    }
    pthread_mutex_init(&mtx,NULL);
}

UdpConnection::~UdpConnection()
{
    pthread_mutex_destroy(&mtx);
    eudp_close(&udp);
    if (is_need_udp_finish) {
        eudp_finish();
        is_need_udp_finish = false;
    }
}

void UdpConnection::init() {

    //ip = "127"//(const char*) cfg["ip"];
    //port = //(int) cfg["port"];
    init_status = true;
    cout << cfg.get_cfg_root() + ": ip = " << ip << "; port = " << port << "\n" << endl;
}

bool UdpConnection::isInit(void) {
    return init_status;
}

void UdpConnection::close() {

}

void UdpConnection::mutex_lock(bool on) {
    if (on)
        pthread_mutex_lock(&mtx);
    else
        pthread_mutex_unlock(&mtx);
}

