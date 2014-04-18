#ifndef PROCESSOR_H
#define PROCESSOR_H

#include <CfgClass.h>
#include<algorithm>
#include<types.h>
#include <data_processor.h>

typedef vector<unsigned short> point_t;

class Processor
{
    public:
        Processor(string cfg_root = "processor");
        ~Processor();
        bool is_above_threshold (point_t point);
        void find_target(capture_data_t capture_data);

    protected:
        point_t window;
        points_t threshold;
        CfgClass cfg;
        capture_data_t capture_data;

        points_t peaks; //координаты точек пиков спектра

        points_t peaks_sweep[2]; //координаты точек пиков спектра
        points_t maximumes;

        void init();
        void read_threshold();

        void search_maximums(point_t::iterator itr_begin, point_t::iterator itr_end, int sweep = 0);


    private:
};

#endif // PROCESSOR_H
