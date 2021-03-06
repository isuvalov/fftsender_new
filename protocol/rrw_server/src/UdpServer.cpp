#include "UdpServer.h"

UdpServer::UdpServer(string cfg_root):UdpConnection(cfg_root)
{
    //radar = 0;
    if (!isInit())
        return;
    init_status = false;
    port = 60606;
    timeout_rcv = 100;//(int) cfg["timeout_rcv"];
    timeout_snd = 100;//(int) cfg["timeout_snd"];
    request.reserve(REQ_BUF_SZ);
    init_status = true;
}

UdpServer::~UdpServer()
{
    is_need_udp_finish = true;
}

bool UdpServer::open()
{
    bool rv = false;

    const char* str = ip.c_str();
    char *addr = new char[ip.size()];
    strcpy(addr, str);

    if (eudp_open_bl(&udp, addr, port) < 0) {
        cout << cfg.get_cfg_root() << ": UDP OPEN ERROR\n" << endl;
    } else {
        eudp_set_rcv_timeout(&udp, timeout_rcv);
        eudp_set_snd_timeout(&udp, timeout_snd);
        rv = true;
    }
    delete [] addr;
    return rv;
}

void UdpServer::start()
{
    if (!isInit()) {
        cout << "ERROR init server." << endl;
        return;
    }

    if (!open() || !radar.is_working) {
        cout << "START ERROR!" << endl;
        return;
    }

    status.meas_mode = 0;
    status.fault = 0;
    status.ready = 0;
    status.has_unread = 0;
    status.last_unsucc = 0;

    cout << "SYSTEM is RUN!" << endl << "----------" << endl;
    #ifdef LOG
       cout << "is waiting for client request...";
    #endif // LOG

    pthread_t th;
    pthread_create(&th, NULL, th_start_dispatch, this);

    bool res = 0;
    is_working = true;

    start_measure();
}

void UdpServer::start_measure() {
    while(is_working) {
        mutex_lock();
        if (status.meas_mode) {

            mutex_lock(false);
            //sleep_ms(50);
            create_data();

        } else
            mutex_lock(false);
    }
    sleep_ms(1);
}

void UdpServer::stop() {
    cout << endl <<"RADAR is stoping...";
    is_working = false;
    sleep_ms(200);
}

void* UdpServer::th_start_dispatch(void* arg) {
    UdpServer *server = (UdpServer*)arg;
    while(server->is_working)
        server->dispatch_request();
}

bool UdpServer::get_request() {
    request.clear();
    char req[REQ_BUF_SZ];
    int len = eudp_recvfrom(&udp, &from_addr, req, REQ_BUF_SZ);
    if (len <= 0)
        return false;
    request.assign(req, req + len);

    cout << "Your request:";
    for (int i = 0; i < request.size(); i++)
        cout << " " << hex << request[i];
    cout << endl;

    if (request[0] != 0x5A) {
        request.clear();
        cout << "SERVER: request is not valid" << endl;
        return false;
    }
    return true;
}

void UdpServer::send_resp(RrwProtocol* prot)
{
    if (prot == 0)
        return;
    const resp_t *resp = prot->get_response();

    if (!resp->empty()) {
        int fn = resp->at(2);
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
            cout << "SERVER: send resp ... ";
        #endif // LOG
        string res = "Error";
        if (eudp_sendto(&udp, &from_addr, (char*) resp->data(), resp->size()))
            res = "OK!";

        #ifdef LOG
                cout << res << endl << "------------" << endl;
        #endif // LOG

    }
    #ifdef LOG
        if (status.meas_mode)
            cout << "SERVER: continue measuring...." << endl;
        else
            cout << "is waiting for client request....";
    #endif // LOG
}

void UdpServer::dispatch_request()
{
    mutex_lock();

    if(!get_request()) {
        mutex_lock(false);
        return;
    }
    int func_ID = request[2];

    #ifdef LOG
        cout << "CLIENT: request #" << (int)request[1] << ": ";
    #endif

    RrwProtocol* proto = (func_ID == RRW_FN_DATA_ALT)? &protocol_data: &protocol;
    proto->load_request(&request);

    vector<int> threshold;
    switch(func_ID) {
        case RRW_FN_STATUS:
            #ifdef LOG
                cout << "STATUS" << endl;
            #endif // LOG
            if(status._unused) {//������������� ���� ����������� ��� ����������� ������� ������ ����� ������� ������
                status.has_unread = 0;
                status._unused = 0;

                //meas_data.data_sweeps.clear();
                //meas_data.elapsed = 0;
                //meas_data.targets.clear();
            }
            proto->create_response(&status);
            //cout << "status: has unread = " << (int)status.has_unread << endl;
            //cout << "status: has meas mode = " << (int)status.meas_mode << endl;
            break;

        case RRW_FN_DATA_ALT:
            #ifdef LOG
                cout << "DATA" << endl;
            #endif // LOG
            proto = &protocol_data;
            proto->create_response(&meas_data);
            status._unused = 1;
            break;

        case RRW_FN_MEAS_CTL:
            #ifdef LOG
                cout << "MEAS CTL" << endl;
            #endif // LOG
            //������ ����� � ������������ �� ������� �������
            duration_meas = proto->parse_req_duration();
            status.meas_mode = proto->parse_req_meas_mode();
            proto->create_response(&status, true);
            break;

        case RRW_FN_GET_TH:
        case RRW_FN_SET_TH:
            if (func_ID == RRW_FN_GET_TH)
                processor.threshold_read(&threshold);
            else {
                proto->parse_req_threshold(&threshold);
                processor.threshold_write(&threshold);
            }
            proto->create_response(&threshold);
            break;

        default:
            proto = 0;
            cout << "UNKNOWN REQ." << endl;
            break;
    }
    if (proto)
        send_resp(proto);
    mutex_lock(false);
}

int UdpServer::create_data() {
    Timer timer;
    timer.start();//fixing timestamp of meas start

    #ifdef LOG1
        cout << "capture data..." << endl;
    #endif // LOG

    capture_data_t data;
    meas_data_t meas_data_curr;
    if (!radar.wait_for_data(&data)) {
        cout << "SERVER: NO Data." << endl;
        return 0;
    }

    sleep_ms(1);

    #ifdef LOG1
        cout << "data has come (" << timer.elapsed_ms() << " ms)!" << endl;
    #endif // LOG endl;

    /*
    meas_data.data_sweeps.clear();
    meas_data.elapsed = 0;
    meas_data.targets.clear();
    */

    vector<target_t> targets;
    processor.get_targets(&targets, &data, timer.elapsed_ms());

    for (int i = 0; i < data.size(); i++) {

        vector<raw_pt_t> vect;
        meas_data_curr.data_sweeps.push_back(vect);
        for (int j = 0; j < data[i].size(); j++) {
            raw_pt_t pt;
            double pw = dbm(data[i][j], j);
            pt.power = pw;
            //cout.precision(3);
            //cout.setf(std::ios::fixed, std::ios::floatfield);
            //cout <<  pw << " dbm\n";
            pt.status = j > 0 ? 0 : 3;
            meas_data_curr.data_sweeps[i].push_back(pt);
        }
    }

    meas_data_curr.meas_index ++;
    unsigned short elapsed = timer.elapsed_ms();
    unsigned short elapsed_add = elapsed >= 90? 0: 90 - elapsed;
    if (elapsed_add > 0)
        sleep_ms(elapsed_add);//�������� �� 100 ��
    meas_data_curr.elapsed = timer.elapsed_ms();

    #ifdef LOG1
        cout << "OK (" << meas_data_curr.elapsed << "  " << elapsed_add << " ms)!" << endl;
    #endif // LOG

    mutex_lock();
    meas_data = meas_data_curr;
    meas_data.targets = targets;

    status.has_unread = 1;
    mutex_lock(false);

    return 1;
}
