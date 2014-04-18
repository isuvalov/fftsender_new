#include "Processor.h"

Processor::Processor(string cfg_root)
{
    if (!cfg_root.empty())
        cfg.load(cfg_root);
    if (cfg.isLoaded())
        init();
}

Processor::~Processor()
{
    //dtor
}

void Processor::init()
{

    threshold = cfg.read_array("threshold_polyline");
    window.push_back((int)cfg["window.min"]);
    window.push_back((int)cfg["window.max"]);


}

bool Processor::is_above_threshold (point_t point)
{
    if (threshold.empty())
        return true;
    if (point[0] < threshold[0][0])
        return false;

    for (int i = 0; i < threshold.size() - 1; i++) {
        if (point[0] == threshold[i][0])
            return point[1] >= threshold[i][1];
        if (point[0] == threshold[i + 1][1])
            return point[1] >= threshold[i + 1][1];

        if (point[0] < threshold[i + 1][0]) {
            float alfa = float(point[1] - threshold[i][1]) / float(point[0] - threshold[i][0]);
            float beta = float(threshold[i + 1][1] - threshold[i][1]) / float(threshold[i + 1][0] - threshold[i][0]);
            return alfa >= beta;
        }
    }
    return false;
}

struct sort_condition_t {
    int a;
    bool operator() (int i, int j) { return abs(i - a) < abs(j - a);};
};

void Processor::find_target(capture_data_t capture_data)
{
    this->capture_data = capture_data;

    peaks.clear();
    point_t::iterator itr;

    maximumes.clear();

    for (int i = 0; i < capture_data.size(); i++) {
        peaks_sweep[i].clear();

        point_t arr_max;
        maximumes.push_back(arr_max);

        search_maximums(capture_data[i].begin(), capture_data[i].end(), i);
        /*
        itr = max_element(capture_data[i].begin(), capture_data[i].end());
        point_t peak;
        peak.push_back(itr - capture_data[i].begin()); //save harm
        peak.push_back(*itr);//save power
        peaks.push_back(peak);
        cout << "i_" << i << " = " << peak[0] << "; ";
        */
        cout << (i==0 ? "sweep rise: " : "sweep fall: ");
        for (int j = 0; j < peaks_sweep[i].size(); j++) {
            cout << "(" << peaks_sweep[i][j][0] << ", " << peaks_sweep[i][j][1] << "); ";
        }
        cout << endl;
    }
    cout << "-----------------" << endl;

    for(int sweep = 0; sweep < 2; sweep++)
        std::sort(maximumes[sweep].begin(), maximumes[sweep].end());


    for(int i = 0; i < maximumes[0].size(); i++) {
        std::sort(maximumes[sweep].begin(), maximumes[sweep].end());

    }

}



void Processor::search_maximums(point_t::iterator itr_begin, point_t::iterator itr_end, int sweep)
{
    point_t::iterator itr_max;
    itr_max = max_element(itr_begin, itr_end);
    int harm = itr_max - itr_begin;
    unsigned short val = *itr_max;

    if (dbm(double(val), harm) < -50 )
        return;
    //Save max
    point_t point;
    point.push_back(harm);
    point.push_back(val);
    peaks_sweep[sweep].push_back(point);

    maximumes[sweep].push_back(harm);

    if (itr_max - itr_begin > 10)
        search_maximums(itr_begin, itr_max - 5, sweep);
    if (itr_end - itr_max > 10)
        search_maximums(itr_max +  5, itr_end, sweep);
}


