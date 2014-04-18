#include "RadarClient.h"

RadarClient::RadarClient(UdpRadar* radar, string file_name, string root_name)
{
    init_status = false;
    this->radar = radar;
    cfg.load(file_name, root_name);
    if (cfg.isLoaded())
        init();
}

RadarClient::~RadarClient()
{
    for (int i = 0; i < targets.size(); i++)
        delete targets[i];
    targets.clear();
}

void RadarClient::init(void) {
    meas_no = 0;
    has_unread = 0;
    elapsed = 0;
    last_unsucc = 0;

    pthread_mutex_init(&(mtx), NULL);

    meas_mode = MEAS_MODE_ON_REQ;
    rcv_loop_state = RCV_ENDED;
    cycle_state = CYCLE_ENDED;

    cycle_dly = (int) cfg["meas_cycle.iter_delay"];
    cycle_dur = (int) cfg["meas_cycle.cycle_dur"];
    coll_sz = (int) cfg["data.coll"];

    int meas_data_unit_sz = cfg["data.unit"];
    int meas_data_sz = (radar->packet_size() / meas_data_unit_sz) * coll_sz;

    for (int i = 0; i < meas_data_sz; i++)
        targets.push_back(new data_el_t);

    //th.points = th_pts;
    //th.size = th_pts_num;

    win_min = (int) cfg["window.min"];
    win_max = (int) cfg["window.max"];

    //const Setting& root = cfg.getRoot();
    try {
        const Setting& points = cfg["window.threshold_polyline"];
        //const Setting& points = root["radar_client"]["window"]["threshold_polyline"];
        int n = points.getLength();
        for (int i = 0; i < n; i++) {
            int x = points[i][0];
            int y = points[i][1];
            cout << "x = " << x << "; y = " << y << "\n" << endl;
        }
    } catch(const SettingNotFoundException &nfex) {
        cout << "ERROR POLYLINE" << endl;
    }

    //polyline = &cfg["window.threshold_polyline"];



    init_status = true;
}

bool RadarClient::isInit(void) {
    return init_status;
}
