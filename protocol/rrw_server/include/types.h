#ifndef TYPES_H_INCLUDED
#define TYPES_H_INCLUDED

#include<vector>
#include <data_processor.h>
#define LOG

using namespace std;

typedef struct {
    int max_harms[2];
    double s;
    double v;
    double t;
    int count_lost;
    bool is_updated;
    bool is_detected;
    long ID;
    bool is_moved;
    bool is_speed_const;
} rrw_target_t;

typedef struct {
    int size;
    int count;
    int unit;
} pkt_params_t ;

typedef vector<char> packet_t;
typedef vector<packet_t> packets_t;
typedef vector<packets_t> sweeps_t;

typedef vector<rrw_target_t> rrw_targets_t;
typedef vector<unsigned short> point_t;
typedef vector<point_t> points_t;

typedef points_t capture_data_t;

typedef vector<unsigned char> resp_t;
typedef vector<unsigned char> request_t;

typedef union {
    int value;
    unsigned char chars[sizeof(int)];
} ch2int_t;

typedef union {
    unsigned short value;
    unsigned char chars[sizeof(unsigned short)];
} ch2ush_t;

typedef union {
    double value;
    unsigned char chars[sizeof(double)];
} ch2d_t;



//typedef vector<target_t> targets_t;
#endif // TYPES_H_INCLUDED
