#include "RrwProtocol.h"
#include<iostream>



RrwProtocol::RrwProtocol()
{

}

RrwProtocol::~RrwProtocol()
{
    //dtor
}



bool RrwProtocol::load_request(const char* req, int len)
{
    request._ = req[0];
    request.no = req[1];
    request.fn = req[2];
    if (!is_valid_req()) {
        cout << "request is not valid\n" << endl;
        return false;
    }

    union ch2ush {
        unsigned short value;
        struct char2{
            char a;
            char b;
        } char2;
    } ch2ush;

    switch(request.fn) {
        case 2:
            meas_ctl_req.base_req = request;

            meas_ctl_req.mode = req[ (sizeof request) ];
            ch2ush.char2.a = req[ (sizeof request) + 2];
            ch2ush.char2.b = req[ (sizeof request) + 1];

            meas_ctl_req.cycle_dur = ch2ush.value;


            //cout << "Getted request: L = " << len << "; ";
            //for (int i = 0; i < len; i++)
            //    cout << hex << uppercase << (unsigned short)req[i] << " ";
            //cout << "\n";

            break;

    }

    return true;
}

int RrwProtocol::request_func_id ()
{
    return (int) request.fn;
}

meas_ctl_req_t RrwProtocol::get_meas_ctl_req(void)
{
    return meas_ctl_req;
}


bool RrwProtocol::is_valid_req()
{
    return request._ == 0x5A;
}



resp_t RrwProtocol::create_response(resp_t &resp, status_t srv_status, bool server_busy, bool for_meas_ctl)
{
    create_header_of_resp(server_busy ? 2 : 0);
    meas_ctl_resp_t meas_ctl_resp;
    status_resp_t status_resp;
    int len = sizeof meas_ctl_resp;

    if (for_meas_ctl) {

        meas_ctl_resp.base_resp = base_resp;
        meas_ctl_resp.status = srv_status;


    } else {

        status_resp.base_resp = base_resp;
        status_resp.status = srv_status;
        status_resp.details = 0;

        status_resp.i[0] = 30;
        status_resp.i[1] = 31;
        status_resp.i[2] = 32;
        status_resp.t[0] = 40;
        status_resp.t[1] = 41;
        status_resp.t[2] = 42;
        status_resp.u[0] = 50;
        status_resp.u[1] = 51;
        status_resp.u[2] = 52;
        status_resp.u[3] = 53;

        len = sizeof (status_resp_t);
    }

    resp.clear();

    for (int i = 0; i < len; i++)
        resp.push_back( for_meas_ctl ? ((unsigned char*)&meas_ctl_resp)[i] : ((unsigned char*)&status_resp)[i]);

    return resp;
}

resp_t RrwProtocol::create_response(resp_t &resp, meas_data_t *meas_data, unsigned char result_status)
{

    create_header_of_resp();

    resp.clear();

    //int sz = resp.size();
    //cout << "resp origin SIZE = " << sz << "\n";

    for (int i = 0; i < sizeof base_resp; i++)
        resp.push_back(((unsigned char*) &base_resp)[i]);

    //cout << "base_resp SIZE = " << resp.size() - sz << "\n";
    //sz = resp.size();


    resp.push_back(meas_data->meas_index);
    //cout << "meas_no SIZE = " << resp.size() - sz << "\n";
    //sz = resp.size();

    union ch2ush {
        unsigned short value;
        struct char2{
            unsigned char a;
            unsigned char b;
        } char2;
    } ch2ush;

    ch2ush.value = meas_data->elapsed;
    resp.push_back(ch2ush.char2.b);
    resp.push_back(ch2ush.char2.a);


    //for (int i = 0; i < sizeof meas_data->elapsed; i++)
        //resp.push_back(((unsigned char*) &meas_data->elapsed)[i]);



    //cout << "elapsed SIZE = " << resp.size() - sz << "\n";
    //sz = resp.size();

    unsigned char *bf = 0;
    if (meas_data->data_sweeps.empty()) {
        for (int i = 0; i < 1024 * 2 * sizeof(raw_pt_t); i++)
            resp.push_back(0);
    } else {
        for (int i = 0; i < meas_data->data_sweeps.size(); i++) {
            for (int j = 0; j < meas_data->data_sweeps[i].size(); j++) {
                int power = meas_data->data_sweeps[i][j].power;
                //cout << power << "\n";
                for (int k = 3; k >= 0 ; k--)
                    resp.push_back( ((unsigned char*) &power)[k]);
                resp.push_back(meas_data->data_sweeps[i][j].status);
            }
        }
    }

    resp.push_back(meas_data->ntargets);
    return resp;
}


void RrwProtocol::create_header_of_resp(unsigned char result_status)
{
    //memset(&base_resp, 0, sizeof(base_resp_t));

    base_resp._ = 0xA5;
    base_resp.fn = request.fn;
    base_resp.no = request.no;
    base_resp.rv = result_status;

}
