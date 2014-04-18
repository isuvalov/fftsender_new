#include "UdpServer.h"

UdpServer::UdpServer(bool start_after_init, string cfg_root):UdpConnection(cfg_root)
{
    radar = 0;

    if (!isInit())
        return;
    init_status = false;
    timeout_rcv = (int) cfg["timeout_rcv"];
    timeout_snd = (int) cfg["timeout_snd"];
    request.reserve(REQ_BUF_SZ);
    init_status = true;
    pthread_mutex_init(&mtx,NULL);

    if (start_after_init)
        start();
}

UdpServer::~UdpServer()
{
    if (radar)
        delete radar;

    close();
    pthread_mutex_destroy(&mtx);
}

bool UdpServer::open()
{
    bool rv = false;
    eudp_start();

    const char* str = ip.c_str();
    char *addr = new char[ip.size()];
    strcpy(addr, str);

    if (eudp_open_bl(&udp, addr, port) < 0) {
        cout << "UDP OPEN ERROR." << endl;
    } else {
        eudp_set_rcv_timeout(&udp, timeout_rcv);
        eudp_set_snd_timeout(&udp, timeout_snd);
        rv = true;
    }
    delete [] addr;
    return rv;
}

void UdpServer::close(void)
{
    eudp_close(&udp);
    eudp_finish();
}

void UdpServer::start()
{
    if (!isInit()) {
        cout << "ERROR init server." << endl;
        return;
    }
    if (radar)
        delete radar;
    radar = new UdpRadar();

    if (!open()) {
        delete radar;
        return;
    }

    radar->start();

    status.meas_mode = 0;
    status.fault = 0;
    status.ready = 0;
    status.has_unread = 1;
    status.last_unsucc = 0;

    cout << "Server is RUN!" << endl << "----------" << endl;
    is_busy = false;
    #ifdef LOG
       cout << "Server is waiting for client request...";
    #endif // LOG

    while(1)
        dispatch_request();
}

bool UdpServer::is_req_recieved()
{
    vector<char> request;
    request.reserve(REQ_BUF_SZ);
    request.assign(REQ_BUF_SZ, '\0');
    char req[REQ_BUF_SZ];
    int len = eudp_recvfrom(&udp, &from_addr, req, REQ_BUF_SZ);
    pthread_mutex_lock(&mtx);
    if (is_busy) {
        pthread_mutex_unlock(&mtx);
        //sleep_ms(10);
        return false;
    }
    pthread_mutex_unlock(&mtx);

    bool rv = false;
    if (len >= 0) {
        if (rv = protocol.load_request(req, len)) {
            #ifdef LOG
                cout << "OK!" << endl;
            #endif
        }
    }
    return rv;
}

void UdpServer::send_resp()
{
    pthread_mutex_lock(&mtx);
    if (!resp.empty()) {
        int fn = *((char*) (&resp[2]));
        string msg = "status";

        switch (fn) {
            case 1:
                char buf[20];
                sprintf(buf, "data # %d", (int)meas_data.meas_index);
                msg = buf;
                break;

            case 2:
                msg = "meas ctl";
                break;

            case 3:
                msg = "get th";
                break;

            case 4:
                msg = "set th";
                break;
        }
        #ifdef LOG
            cout << "SERVER: send " + msg + ".....";
        #endif // LOG
        string res = "Error";
        if (eudp_sendto(&udp, &from_addr, (char*) (&resp[0]), resp.size()))
            res = "Success";

        #ifdef LOG
                cout << res << endl << "------------" << endl;
        #endif // LOG

    }


    is_busy = false;
    #ifdef LOG
        cout << "SERVER: is waiting for client request....";
    #endif // LOG
    pthread_mutex_unlock(&mtx);
}

void UdpServer::dispatch_request()
{

    if (!is_req_recieved())
        return;

    switch(protocol.request_func_id()) {
        case RRW_FN_STATUS:
            is_busy = true;
            #ifdef LOG
                cout << "CLIENT: request STATUS" << endl;
            #endif // LOG
            pthread_create(&disp_req_status_th, NULL, fn_req_status, this);

            break;

        case RRW_FN_DATA_ALT:
            is_busy = true;
            #ifdef LOG
                cout << "CLIENT: request DATA" << endl;
            #endif // LOG
            pthread_create(&disp_req_data_th, NULL, fn_data_alt, this);
            //fn_data_alt();
            break;

        case RRW_FN_MEAS_CTL:
            #ifdef LOG
                cout << "CLIENT: request  MEAS CTL" << endl;
            #endif // LOG

            //fn_meas_ctl();
            break;

        case RRW_FN_GET_TH:
            fn_get_th();
            break;

        case RRW_FN_SET_TH:
            fn_set_th();
            break;

        default:
            cout << "CLIENT: UNKNOWN REQ." << endl;
            break;
    }
}

void* UdpServer::fn_req_status(void* arg)
{
    UdpServer *server = (UdpServer*)arg;

    server->protocol.create_response(server->resp, server->status, false, false);
    server->send_resp();
}

void* UdpServer::fn_data_alt(void* arg)
{
    UdpServer *server = (UdpServer*)arg;

    unsigned char result_status = 0;

    if (!server->create_data())
        result_status = 2;

    server->protocol.create_response(server->resp, &server->meas_data, result_status);
    server->send_resp();
}

bool UdpServer::create_data() {
    Timer timer;
    timer.start();

    target_t *targets = 0;
    meas_data.data_sweeps.clear();
    meas_data.elapsed = 0;
    meas_data.ntargets = 0;

    timer.start();//fixing timestamp of meas start

    #ifdef LOG
        cout << "SERVER: waiting for DATA from radar....";
    #endif // LOG

    capture_data_t data = radar->wait_for_data();
    //int h;
    //cin >> h;


    if (data.empty()) {
        cout << "Data is NULL" << endl;
        return false;
    }

    if (data[0].size() != 1024) {
        cout << "ERROR: Data size <> 1024 byte" << endl;
        return false;
    }
    //cout << "DATA has come. data[0][100] = " << data[0][100] << "\n" << endl;


    for (int i = 0; i < data.size(); i++) {
        vector<raw_pt_t> vect;
        meas_data.data_sweeps.push_back(vect);

        for (int j = 0; j < data[i].size(); j++) {
            raw_pt_t pt;
            double pw = dbm(data[i][j], j);
            pt.power = pw * 1000;

            //cout << j << ": " << data[i][j] << " = ";

            //cout.precision(3);
            //cout.setf(std::ios::fixed, std::ios::floatfield);
            //cout <<  pw << " dbm\n";
            pt.status = j > 0 ? 0 : 3;
            meas_data.data_sweeps[i].push_back(pt);
        }
    }

    meas_data.meas_index ++;
    sleep_ms(80);
    meas_data.elapsed = (unsigned short) timer.elapsed_ms();
    #ifdef LOG
        cout << "OK (" << meas_data.elapsed << " ms)!" << endl;
    #endif // LOG

    //status.has_unread = 1;
    return true;
}


void UdpServer::fn_meas_ctl()
{
    #ifdef LOG
        cout << "set meas mode: was " << USHORT(status.meas_mode);
    #endif // LOG

    meas_ctl_req_t meas_ctl_req = protocol.get_meas_ctl_req();

    status.meas_mode = meas_ctl_req.mode;
    //status.has_unread = status.meas_mode;

    #ifdef LOG
        cout << "; now " << USHORT(status.meas_mode) <<  "\n" << "dur = " << meas_ctl_req.cycle_dur << "\n";
    #endif // LOG

    resp = protocol.create_response(resp, status, true);
    send_resp();

    //timer.start();
    //pthread_create(&cycle_meas_th, NULL, process_cycle_meas, this);
    //status.meas_mode = 0;
}

void UdpServer::fn_get_th()
{
    cout << "get th\n";

}

void UdpServer::fn_set_th()
{
    cout << "set th\n";
}

