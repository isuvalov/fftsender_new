#include "Timer.h"

Timer::Timer()
{

}

Timer::~Timer()
{

}

void Timer::start()
{
    gettimeofday(&t_begin, NULL);

}

unsigned long Timer::elapsed_ms()
{
    struct timeval t;
    gettimeofday(&t_end, NULL);
    double ms = (t_end.tv_sec - t_begin.tv_sec) * 1e6 + (t_end.tv_usec - t_begin.tv_usec);//в микросекундах
    ms /= 1e3;//перевод в милисекунды
    return ms;
}

double Timer::elapsed_db_ms() {
    struct timeval t;
    gettimeofday(&t_end, NULL);
    double ms = (t_end.tv_sec - t_begin.tv_sec) * 1e6 + (t_end.tv_usec - t_begin.tv_usec);//в микросекундах
    ms /= 1e3;//перевод в милисекунды
    return ms;
}

