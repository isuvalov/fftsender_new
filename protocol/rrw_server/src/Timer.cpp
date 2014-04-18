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

unsigned int Timer::elapsed_ms()
{
    struct timeval t;
    gettimeofday(&t_end, NULL);
    double ms = (t_end.tv_sec - t_begin.tv_sec) * 1e6 + (t_end.tv_usec - t_begin.tv_usec);
    ms /= 1e3;
    return ms;

}
