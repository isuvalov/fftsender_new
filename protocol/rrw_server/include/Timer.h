#ifndef TIMER_H
#define TIMER_H

#include<iostream>
#include <sys/time.h>
#include <time.h>

using namespace std;

class Timer
{
    public:
        Timer();
        ~Timer();
        void start();
        //void stop();
        unsigned long elapsed_ms();
        double elapsed_db_ms();
    protected:
    private:
        timeval t_begin;
        timeval t_end;



};

#endif // TIMER_H
