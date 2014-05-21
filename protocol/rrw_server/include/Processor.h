#ifndef PROCESSOR_H
#define PROCESSOR_H


#include <CfgClass.h>
#include<Timer.h>

#include<types.h>
#include<SweepRadar.h>

using namespace std;

#define THRESHOLD_FILE "thresholds.cfg"


class Processor
{
    public:
        Processor(string cfg_root = "processor");
        ~Processor();
        //bool is_above_threshold (point_t point);
        void get_targets(vector<target_t> *targets_proto, capture_data_t *capture_data, unsigned short time_ms = 100);
        void threshold_read(vector<int> *th);
        void threshold_write(vector<int> *th);

    protected:
        unsigned long time_ms;
        bool status_find_trg;
        Timer global_timer;//таймер для отсчета общего времени - нужен для оценки кинематических характеритик целей

        vector<int> threshold;

        CfgClass cfg;
        SweepRadar sweeps;

        rrw_targets_t targets;

        void init();

        void detect_targets(rrw_targets_t *curr_targets, rrw_targets_t *new_targets);//Идентифицировать старые цели в наборе новых

};

#endif // PROCESSOR_H
