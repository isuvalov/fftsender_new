#ifndef UDPRADAR_H
#define UDPRADAR_H

#include<radar_cli.h>
#include<UdpConnection.h>



class UdpRadar : public UdpConnection
{
    public:
        int timeout;


        UdpRadar(string cfg_root = "radar");
        ~UdpRadar();
        void start();
        void read_sweeps();
        bool is_data_captured();

        bool wait_for_data(capture_data_t *capture_data, int time_wait_ms = 300);

        capture_data_t* get_data();
    protected:
        pkt_params_t pkt_params;
        pthread_t main_th;
        pthread_mutex_t mtx;

        bool data_is_captured;
        packet_t packet;
        sweeps_t sweeps;
        capture_data_t data;
        capture_data_t data_for_server;

        int data_len;

        static void* th_fnc_main(void* arg);
        bool open(void);

        int collect_packets();
        void clear_data();
        bool is_packets_collected();

    private:
};

#endif // UDPRADAR_H
