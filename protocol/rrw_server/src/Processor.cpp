#include "Processor.h"
#include<math.h>
#include<fstream>

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
    status_find_trg = false;
}


void Processor::get_targets(vector<target_t> *targets_proto, capture_data_t* capture_data, unsigned short time_ms)
{
    unsigned char MAX_COUNT_TRG_LOST = 5;
    this->time_ms = time_ms;
    rrw_targets_t* new_targets = sweeps.get_targets(capture_data);

    if (targets.empty() && new_targets->empty()) {
        //cout << "TARGETS ARE LOST :(" << endl;
    } else {
        detect_targets(&targets, new_targets);

        if (!targets.empty()) {
            rrw_targets_t::iterator itr_trg = targets.begin();
            for (; itr_trg < targets.end(); itr_trg++) {
                if (itr_trg == targets.end())
                    break;
                if ((*itr_trg).is_detected == false) {
                    (*itr_trg).count_lost++;
                    if ((*itr_trg).count_lost == MAX_COUNT_TRG_LOST) {
                        //cout << " ---- ERASE TARGET: " << (*itr_trg).ID << endl;
                        targets.erase(itr_trg);
                    }
                }
            }
        }
    }

    for (int i = 0; i < targets.size(); i++) {
        target_t trg;
        trg.dist = targets[i].s;
        trg.spd = targets[i].v;
        trg.spd_status = 0;
        targets_proto->push_back(trg);

        /*
            cout.precision(1);
            cout.setf(std::ios::fixed, std::ios::floatfield);
            cout << "Trg " << targets[i].ID << ": vel = " << targets[i].v << " km/h, dist = " << targets[i].s << " m;";
            if (targets[i].count_lost > 0)
                cout << "---- Is LOST " << targets[i].count_lost << " time. -----" << endl;
            else
                cout << " status = " << (targets[i].is_updated ? " updated" : "new target.") << endl;
        */
    }
    //cout << endl << "---------------------------" << endl;
}

void Processor::detect_targets(rrw_targets_t *curr_targets, rrw_targets_t *new_targets) {

    for(int i = 0; i < curr_targets->size(); i++)
        (*curr_targets)[i].is_detected = false;

    unsigned long t_stamp = global_timer.elapsed_ms();
    double t = double(t_stamp) * 1e-3;

    for(int j = 0; j < new_targets->size(); j++) {

        rrw_target_t *new_trg = &(*new_targets)[j];
        new_trg->t = t;

        for(int i = 0; i < curr_targets->size(); i++) {
            rrw_target_t *curr_trg = &(*curr_targets)[i];
            if (curr_trg->is_detected)
                continue;

            if (fabs(curr_trg->s - new_trg->s) > 2.5) //2.5 м - это максимальное смещение за 100мс при 90км/ч
                continue;
                //double teor_s = targets[i].s + targets[i].v * t /*+ a * t*t / 2*/;//теоретическая координата цели
                //if ( fabs(teor_s - new_trg.s) > 3 )
                //    continue;

                //double ofst_v = new_trg.v - targets[i].v;

                /*
                double a = (new_trg.v - targets[i].v) / t;
                cout << "new v = " << new_trg.v << "; old v = " << targets[i].v << " t = "<<t <<endl;
                if (fabs(a) >= 2.5)//2 m/s2 - accelerance for fast auto
                {
                    cout << " NO: accel" << endl;
                    continue;
                }
                */

                new_trg->is_detected = true;
                new_trg->is_updated = true;
                new_trg->ID = curr_trg->ID;
                new_trg->is_moved = curr_trg->s != new_trg->s;
                new_trg->is_speed_const = curr_trg->v == new_trg->v;
                *curr_trg = *new_trg;
                break;
        }
        if (!new_trg->is_detected) {
            new_trg->is_detected = true;

            if (!curr_targets->empty())
               new_trg->ID = (*(curr_targets->end() - 1)).ID++;
            curr_targets->push_back(*new_trg);
        }
    }
}

void Processor::threshold_read(vector<int> *th) {
    if (!th)
        return;
    th->clear();
    ifstream f(THRESHOLD_FILE);
    if (!f)
        return;
    int val;

    while (!(f >> val).eof()) {
        th->push_back(val);
    }
    f.close();
}

void Processor::threshold_write(vector<int> *th) {
    if (!th)
        return;

    ofstream f(THRESHOLD_FILE);
    if (!f) {
        cout << "ERROR OPEN THRESHOLD FILE" << endl;
        return;
    }

    cout << endl << "SERVER: writing threshold in file...";
    for (int i = 0; i < th->size(); i++)
        f << th->at(i) << endl;
    f.close();
    threshold = *th;
    cout << "OK!" << endl;
}


/* Старая версия, когда порого определялся по ломаной кривой
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
*/
