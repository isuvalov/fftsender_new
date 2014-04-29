#include <UdpRadar.h>

UdpRadar::UdpRadar(string cfg_root):UdpConnection(cfg_root)
{
    if (!isInit())
        return;


    ip ="127.0.0.1";
    port = 65002;

    timeout = 100;
    pkt_params.count = 4;
    pkt_params.size = 514;
    pkt_params.unit = 2;

    packet.assign(pkt_params.size,'\0');

    data_len = (pkt_params.size - 2) * 2;

    for (int i = 0; i < 2; i++) {
        vector<unsigned short> values(data_len, 0);
        data.push_back(values);

        packets_t packets(pkt_params.count);
            sweeps.push_back(packets);
    }
    data_is_captured = false;
    pthread_mutex_init(&mtx,NULL);
}

UdpRadar::~UdpRadar()
{
    packet.clear();
    pthread_mutex_destroy(&mtx);
}

void UdpRadar::start()
{
    if (!open())
        return;

    pthread_create(&main_th, NULL, th_fnc_main, this);
}

void* UdpRadar::th_fnc_main(void* arg)
{
    UdpRadar *radar = (UdpRadar*) arg;

    //cout << "START READ\n" << endl;
    Timer timer;
    while (true) {
        timer.start();
        radar->read_sweeps();
        //cout << "Radar create data for " << timer.elapsed_ms() << " ms\n";
    }
}

bool UdpRadar::isWorking()
{
    return is_working;
}

bool UdpRadar::open()
{
    const char* str = ip.c_str();
    char *addr = new char[ip.size()];
    strcpy(addr, str);

    if (eudp_open_bl_reciever(&udp, addr, port) < 0) {
        cout << "UDP OPEN ERROR\n" << endl;
        delete [] addr;
        return false;
    }
    delete [] addr;

    eudp_set_rcv_timeout(&udp, timeout);
    is_working = true;
    return true;
}

bool UdpRadar::is_data_captured()
{
    //cout << data_is_captured ? "data is captured\n" : "no data\n";
    return data_is_captured;
}

int UdpRadar::collect_packets()
{

    clear_data();
    int i = 0, j = 0;
    while (!is_packets_collected()) {

        if (pkt_params.size != eudp_recv(&udp, &packet[0], pkt_params.size))
            return -1;

        char pkt = *(&packet[0]);
        j = (unsigned char) pkt >> 4;

        char cur_dir = (unsigned char) pkt & 0x0F;
        i = cur_dir == DIR_RISE ? 0: (cur_dir == DIR_FALL ? 1: -1);

        if (i < 0) {
            cout << "ERROR: Number of sweep is -1\n" << endl;
            return -1;
        }

        if (sweeps[i][j].empty())
            sweeps[i][j] = packet;
    }
    return 1;
}

void UdpRadar::read_sweeps()
{
    if(collect_packets() < 0)
        return;

    //cout << "packets is collected\nStart write in DATA\n" << endl;

    union ch2ush {
        unsigned short value;
        struct char2{
            unsigned char a;
            unsigned char b;
        } char2;
    } ch2ush;


    for (int i = 0; i < 2; i++) {
        int n = 0;
        for (int j = 0; j < pkt_params.count; j++) {

            ch2ush.char2.a = sweeps[i][j][0];
            ch2ush.char2.b = sweeps[i][j][1];
            int exp_val = (ch2ush.value >> 8) - 243;

            for (int k = 2; k < pkt_params.size; k += 2, n++) {
                ch2ush.char2.a = sweeps[i][j][k];
                ch2ush.char2.b = sweeps[i][j][k + 1];

                data[i][ n] = (ch2ush.value << 5) >> exp_val;
            }
        }
    }
    pthread_mutex_lock(&mtx);
    data_is_captured = true;
    data_for_server.clear();
    data_for_server = data;
    pthread_mutex_unlock(&mtx);
}

bool UdpRadar::is_packets_collected()
{
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 4; j++) {
            if (sweeps[i][j].size() != pkt_params.size)
                return false;
        }
    }
    return true;
}

void UdpRadar::clear_data()
{

    //cout << "clear\n" << endl;
    if(!data.empty()) {
        for (int i = 0; i < data.size(); i++) {
            data[i].assign(data_len, 0);

            for (int j = 0; j < pkt_params.count; j++)
                sweeps[i][j].clear();
        }
    }

}

capture_data_t* UdpRadar::get_data()
{
    capture_data_t* rv_data = 0;
    if (is_data_captured())
        rv_data = &data;
    data_is_captured = false;
    return rv_data;
}

capture_data_t UdpRadar::wait_for_data(int time_wait_ms)
{
    Timer timer;
    timer.start();

    capture_data_t rv_data;
    while(true) {

        pthread_mutex_lock(&mtx);
        if (data_is_captured)
            break;
        pthread_mutex_unlock(&mtx);
        sleep_ms(30);
        if (timer.elapsed_ms() > time_wait_ms)
            return rv_data;

    }
    rv_data = data_for_server;
    data_is_captured = false;
    pthread_mutex_unlock(&mtx);
    return rv_data;
}
