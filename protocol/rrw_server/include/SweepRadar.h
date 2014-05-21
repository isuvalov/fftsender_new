#ifndef SWEEPRADAR_H
#define SWEEPRADAR_H

#include<types.h>
#include<algorithm>
#include<math.h>

class SweepRadar
{
    public:
        SweepRadar();
        ~SweepRadar();
        vector<rrw_target_t> *get_targets(capture_data_t* capture_data);
    private:
        capture_data_t* capture_data;
        points_t peaks; //координаты точек пиков спектра
        points_t maximumes;//двумерный
        vector<rrw_target_t> targets;

        bool calculate();
        void search_maximums(point_t::iterator itr_begin, point_t::iterator itr_end, int sweep = 0, int harm_ofst = 0);
        double estimate_harm(int harm, int sweep);
};

#endif // SWEEPRADAR_H
