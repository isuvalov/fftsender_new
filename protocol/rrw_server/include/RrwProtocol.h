#ifndef RRWPROTOCOL_H
#define RRWPROTOCOL_H

#include<common.h>
#include<rrw_proto.h>
#include<vector>

using namespace std;

typedef vector<unsigned char> resp_t;
typedef vector<vector<raw_pt_t> > data_sweeps_t;

typedef struct {
    unsigned short elapsed;
    data_sweeps_t data_sweeps;
    bool is_already_read;
    unsigned char ntargets;
    target_t *targets;
    unsigned char meas_index;
} meas_data_t;


class RrwProtocol
{
    public:
        RrwProtocol();
        ~RrwProtocol();

        bool load_request(const char* req, int len);

        resp_t create_response(resp_t &resp, status_t srv_status, bool server_busy, bool for_meas_ctl = false);
        resp_t create_response(resp_t &resp, meas_data_t *meas_data, unsigned char result_status = 0);
        //void create_response(unsigned char** resp, int &resp_len, status_t srv_status, bool for_meas_ctl = false);

        int request_func_id ();
        int request_meas_mode();

        meas_ctl_req_t get_meas_ctl_req(void);

        unsigned short request_elapsed();
    protected:
        //char resp[RESP_BUF_SZ];
        //vector<char> resp;

        //unsigned char *resp;
        //int resp_len;

        resp_t resp;


        base_req_t request;
        base_resp_t base_resp;

        meas_ctl_req_t meas_ctl_req;


        bool is_valid_req();
        void create_header_of_resp(unsigned char result_status = 0);



    private:
};

#endif // RRWPROTOCOL_H
