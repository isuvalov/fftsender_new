#ifndef RRWPROTOCOL_H
#define RRWPROTOCOL_H

#include<types.h>
#include<common.h>
#include<rrw_proto.h>
#include<vector>

using namespace std;



typedef vector<vector<raw_pt_t> > data_sweeps_t;

typedef struct {
    unsigned short elapsed;
    data_sweeps_t data_sweeps;
    bool is_already_read;
    vector<target_t> targets;
    unsigned char meas_index;
} meas_data_t;


class RrwProtocol
{
    public:
        RrwProtocol();
        ~RrwProtocol();

        void load_request(const request_t *req);

        void create_response(status_t* srv_status, bool for_meas_ctl = false);
        void create_response(meas_data_t *meas_data, unsigned char result_status = 0);
        void create_response(vector<int> *threshold);

        const resp_t* get_response();//получить сформированный ответ

        unsigned short  parse_req_duration();
        unsigned char   parse_req_meas_mode();
        void            parse_req_threshold(vector<int> *threshold);

    private:
        resp_t resp;
        const request_t *client_req;
        void add_buf2resp(const unsigned char* buf, int sz = 1, bool is_big_endian = true);
        void create_header_of_resp(unsigned char result_status = 0);
};

#endif // RRWPROTOCOL_H
