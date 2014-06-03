#include <UdpRadar.h>

UdpRadar::UdpRadar(string cfg_root):UdpConnection(cfg_root)
{
    if (!isInit())
        return;

    port = 65002;
    timeout = 300;
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

    start();
}

UdpRadar::~UdpRadar()
{

}

void UdpRadar::start()
{
    //if (!open())
    //    return;

    is_working = true;
    pthread_create(&main_th, NULL, th_fnc_main, this);
}

void* UdpRadar::th_fnc_main(void* arg)
{
    UdpRadar *radar = (UdpRadar*) arg;

    //cout << "START READ\n" << endl;
    Timer timer;

    while (true)
        radar->read_sweeps();

}

bool UdpRadar::open()
{
    const char* str = ip.c_str();
    char *addr = new char[ip.size()];
    strcpy(addr, str);

    if (eudp_open_bl_reciever(&udp, addr, port) < 0) {
        cout << cfg.get_cfg_root() << ": UDP OPEN ERROR\n" << endl;
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

        if (pkt_params.size != eudp_recv(&udp, &packet[0], pkt_params.size)) {
            cout << "RADAR: error packet size." << endl;
            return -1;
        }


        char pkt = *(&packet[0]);
        j = (unsigned char) pkt >> 4;//Парсим номер пакета

        char cur_dir = (unsigned char) pkt & 0x0F;
        i = cur_dir == DIR_RISE ? 0: (cur_dir == DIR_FALL ? 1: -1);//Парсим номер свипа

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
    #ifndef RTL_SIMULATION
    if(collect_packets() < 0)
        return;

    //cout << "packets is collected\nStart write in DATA\n" << endl;

    ch2ush_t ch2ush;//для перевода двух char в один short
    for (int i = 0; i < 2; i++) {
        int n = 0;
        for (int j = 0; j < pkt_params.count; j++) {
            ch2ush.chars[0] = sweeps[i][j][0];//выделяем 1 char
            ch2ush.chars[1] = sweeps[i][j][1];//выделяем 2 char; сейчас в ch2ush.value - лежит наш short
            int exp_val = (ch2ush.value >> 8) - 243;//выделяем экспоненту

            for (int k = 2; k < pkt_params.size; k += 2, n++) {//цикл для парсинга данных фурье
                ch2ush.chars[0] = sweeps[i][j][k];
                ch2ush.chars[1] = sweeps[i][j][k + 1];

                data[i][ n] = (ch2ush.value << 5) >> exp_val;//сохраняем значение спектра, которое будет использоваться далее в расчетах
            }
        }
    }
    #else
    for (int i = 0; i < data.size(); i++)
        for (int j = 0; j < data[i].size(); j++)
            data[i][j] = j * 10; //

    #endif
    mutex_lock();

    data_for_server = data;
    data_is_captured = true;

    mutex_lock(false);
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

bool UdpRadar::wait_for_data(capture_data_t *capture_data, int time_wait_ms)
{
    Timer timer;
    timer.start();
    bool rv = false;
    while(true) {
        mutex_lock();
        if (data_is_captured)
            break;
        mutex_lock(false);

        if (timer.elapsed_ms() > time_wait_ms) {
            cout << cfg.get_cfg_root() << ": timeout." << endl;
            return rv;
        }

    }

    //mutex_lock();
    *capture_data = data_for_server;
    data_is_captured = false;
    rv = !capture_data->empty();
    mutex_lock(false);
    if (!rv) {
        cout << "Radar: there is Not DATA." << endl;
    }
    return rv;
}
