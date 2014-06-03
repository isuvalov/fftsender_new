#include "RrwProtocol.h"
#include<iostream>
#include<string.h>


RrwProtocol::RrwProtocol()
{

}

RrwProtocol::~RrwProtocol()
{
    //dtor
}

const resp_t* RrwProtocol::get_response() {
    return &resp;
}

void RrwProtocol::load_request(const request_t *req)
{
    client_req = req;
}

unsigned short RrwProtocol::parse_req_duration() {
    if (client_req == 0)
        cout << "PROTOCOL: ERROR. request did not loaded";
    else {
        if (client_req->at(2) == RRW_FN_MEAS_CTL) {
            int ofst = sizeof(base_req_t);
            unsigned char buf[2] = {client_req->at(ofst + 2), client_req->at(ofst + 1)};
            return *((unsigned short*) buf);
        }
    }
    return 0;
}

unsigned char RrwProtocol::parse_req_meas_mode() {
    if (client_req == 0)
        cout << "PROTOCOL: ERROR. request did not loaded";
    else {
        if (client_req->at(2) == RRW_FN_MEAS_CTL) {
            int ofst = sizeof(base_req_t);
            return client_req->at(ofst);
        }
    }
    return 0;
}

void RrwProtocol::parse_req_threshold(vector<int> *threshold) {
    if (client_req == 0) {
        cout << "PROTOCOL: ERROR. request did not loaded";
        return;
    }
    ch2int_t ch2int;

    int ofst = sizeof (base_req_t);
    threshold->clear();
    for (int i = 0, k = 3; i <= 1024 * 4; i++, k--) { // 4 = sizeof int
        if (k == 0) {
            threshold->push_back(ch2int.value);
            k = 3;
        }
        ch2int.chars[k] = client_req->at(ofst + i);
    }
}

void RrwProtocol::create_response(status_t* srv_status, bool for_meas_ctl)
{
    create_header_of_resp();
    add_buf2resp((unsigned char*) srv_status, sizeof (status_t));

    if (!for_meas_ctl) {
        for (int i = 0; i < 11; i++)
            resp.push_back(0);
    }
}

void RrwProtocol::create_response(vector<int> *threshold) {
    create_header_of_resp();
    for (int i = 0; i < threshold->size(); i++)
        add_buf2resp((unsigned char*)&threshold->at(i), sizeof (threshold->at(i)));

}


void RrwProtocol::create_response(meas_data_t *meas_data, unsigned char result_status)
{

    create_header_of_resp();

    //cout << "base_resp SIZE = " << resp.size() - sz << "\n";
    //sz = resp.size();
    add_buf2resp(&meas_data->meas_index);
    //cout << "meas_no SIZE = " << resp.size() - sz << "\n";
    //sz = resp.size();

    add_buf2resp((unsigned char*)&meas_data->elapsed, sizeof(meas_data->elapsed));
    //cout << "t = " << meas_data->elapsed << "|";

    ch2int_t ch2int;
    unsigned char *bf = 0;
    if (meas_data->data_sweeps.empty()) {
        for (int i = 0; i < 1024 * 2 * sizeof(raw_pt_t); i++)
            resp.push_back(0);
    } else {
        cout << "data for response: ";
        for (int i = 0; i < meas_data->data_sweeps.size(); i++) {
            cout << endl << "sweep #" << (i + 1) << ": ";
            for (int j = 0; j < meas_data->data_sweeps[i].size(); j++) {
                ch2int.value = meas_data->data_sweeps[i][j].power;
                cout << ch2int.value;
                //cout << power << "\n";
                add_buf2resp(&ch2int.chars[0], sizeof(ch2int.chars));
                add_buf2resp(&meas_data->data_sweeps[i][j].status);
            }
        }
        cout << endl;
    }

    unsigned char num_trg = meas_data->targets.size();
    add_buf2resp(&num_trg);

    ch2d_t ch2d;
    //cout << "--- targets -----" << endl;
    for (int i = 0; i < meas_data->targets.size(); i++) {
        ch2d.value = meas_data->targets[i].spd;
        //cout << " spd = " << ch2d.value;
        add_buf2resp(&ch2d.chars[0], sizeof(ch2d.chars));

        //cout << " | ";
        ch2d.value = meas_data->targets[i].dist;
        //cout << "; dist = " << ch2d.value << endl;
        add_buf2resp(&ch2d.chars[0], sizeof(ch2d.chars));
        add_buf2resp(&meas_data->targets[i].spd_status);
    }
    //cout << "--- targets -----" << endl;
}


void RrwProtocol::add_buf2resp(const unsigned char* buf, int sz, bool is_big_endian) {
    int i_start = is_big_endian ? sz - 1: 0;
    for (int i = i_start; is_big_endian ? i >= 0: i < sz; i = i + (is_big_endian? -1: 1)) {
        resp.push_back( buf[i]);
        //cout << "[" << i << "]=" << ios::hex << buf[i]<< endl;
    }
    //cout << endl;
}

void RrwProtocol::create_header_of_resp(unsigned char result_status)
{
    resp.clear();
    resp.push_back(0xA5);
    resp.push_back(client_req->at(1));
    resp.push_back(client_req->at(2));
    resp.push_back(result_status);
}
