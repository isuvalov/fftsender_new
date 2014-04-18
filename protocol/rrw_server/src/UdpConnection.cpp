#include "UdpConnection.h"


UdpConnection::UdpConnection(string cfg_root)
{
    ip ="0.0.0.0";
    port = -1;
    init_status = false;
    if (!cfg_root.empty())
        cfg.load(cfg_root);
    if (cfg.isLoaded())
        init();

}

UdpConnection::~UdpConnection()
{
}

void UdpConnection::init() {

    ip = (const char*) cfg["ip"];
    port = (int) cfg["port"];
    init_status = true;

    cout << cfg.get_cfg_root() + ": ip = " << ip << "; port = " << port << "\n" << endl;
}

bool UdpConnection::isInit(void) {
    return init_status;
}

void UdpConnection::close() {
    eudp_close(&udp);
}

