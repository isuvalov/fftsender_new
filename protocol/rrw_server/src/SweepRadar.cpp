#include "SweepRadar.h"

SweepRadar::SweepRadar()
{

}

SweepRadar::~SweepRadar()
{
    //dtor
}

vector<rrw_target_t>* SweepRadar::get_targets(capture_data_t* capture_data) {
    this->capture_data = 0;
    this->capture_data = capture_data;
    targets.clear();
    if (calculate()){
        double estim_peaks[2];
        for(int i = 0; i < maximumes[0].size(); i++) {
            for (int j = 0; j < maximumes[1].size(); j++) {
                if (abs(maximumes[1][j] - maximumes[0][i]) < 10) { //10 - это ограничение количества гармоник между пиками на свипах
                    rrw_target_t target;
                    target.max_harms[0] = maximumes[0][i];
                    target.max_harms[1] = maximumes[1][j];
                    estim_peaks[0] = double(maximumes[0][i]) + estimate_harm(maximumes[0][i], 0);
                    estim_peaks[1] = double(maximumes[1][j]) + estimate_harm(maximumes[1][j], 1);

                    /*
                    cout << endl;
                    cout << "rise = " << estim_peaks[0] << " fall = " << estim_peaks[1] << "; ";
                    cout << "S/2 = " << (estim_peaks[1] + estim_peaks[0]) * 0.5 << "; div/2 = " << (estim_peaks[1] - estim_peaks[0]) * 0.5 << endl;
                    */
                    target.v = (estim_peaks[1] - estim_peaks[0]) * 0.5 * 6.48; //km/h
                    if (fabs(target.v) < 3 )
                        target.v = 0;

                    target.s = (estim_peaks[1] + estim_peaks[0]) * 0.5 * 0.5 ; // m
                    target.t = 0;

                    target.is_updated = false;
                    target.is_detected = false;
                    target.count_lost = 0;
                    target.ID = 1;
                    if (target.v < 150 && target.s < 1000)
                        targets.push_back(target);
                }
            }
        }
    }
    return &targets;
}

bool SweepRadar::calculate() {
    if (capture_data == 0)
        return false;

    if (capture_data->size() != 2)
        return false;

    peaks.clear();
    maximumes.clear();
    point_t::iterator itr;

    for (int sweep = 0; sweep < capture_data->size(); sweep++) {
        point_t arr_max;
        maximumes.push_back(arr_max);
        search_maximums((*capture_data)[sweep].begin(), (*capture_data)[sweep].end(), sweep);
    }
    return true;
}

void SweepRadar::search_maximums(point_t::iterator itr_begin, point_t::iterator itr_end, int sweep, int harm_ofst)
{
    point_t::iterator itr_max;
    itr_max = max_element(itr_begin, itr_end);

    int maximum_aria = 5; //диапазон гармоник где искать только один максимум
    if (itr_max == itr_end)
        return;
    unsigned short harm = harm_ofst + itr_max - itr_begin;
    unsigned short val = *itr_max;

    //Проверка на уровень сигнала в Дбм
    //if (dbm(double(val), harm) < -50 )
    //    return;

    if( abs(itr_max - itr_begin) < maximum_aria || abs(itr_max - itr_end) < maximum_aria)
        return;
    //Поиск новых границ для нового поиска максимумов
    point_t::iterator itr_min_left, itr_min_right;
    itr_min_left = max_element(itr_max - maximum_aria, itr_max - 1);// 1 - это для уточнения пика
    itr_min_right = max_element(itr_max + 1, itr_max + maximum_aria);//
    double lev_min = double(*itr_max) * 0.3;//уровень амплитуды соседних максимумов, при котором это максимум считается локальным максимумом достоверно
    if (*itr_min_left > lev_min  || *itr_min_right > lev_min)
        return;

    /*
    int c = harm - harm % 10;
    cout << "aria sweep " << sweep << " max_harm =" << harm << ": ";
    for (int i = 0; i < 16; i++) {

        cout << capture_data[sweep][c + i] << ", ";
    }
    cout << endl;
    */

    //Save max
    point_t point;
    point.push_back(harm);
    point.push_back(val);
    //peaks[sweep].push_back(point);
    maximumes[sweep].push_back(harm);

    /********************/
    //return; //ищем одну цель
    /*******************/

    search_maximums(itr_begin, itr_max - maximum_aria, sweep, harm_ofst);
    search_maximums(itr_max + maximum_aria, itr_end, sweep, harm_ofst +  harm + maximum_aria);
}

double SweepRadar::estimate_harm(int harm, int sweep) {
    if (capture_data == 0)
        return 0;
    double peak = (*capture_data)[sweep][harm];
    double next_peak = (*capture_data)[sweep][harm + 1];
    double prev_peak = (*capture_data)[sweep][harm - 1];
    //cout << "harm = " << harm << "prev = " << prev_peak << ": peak = " << peak  << "next = " << next_peak << endl;
    return (next_peak - prev_peak) / (2.0 * peak - prev_peak - next_peak);
}


