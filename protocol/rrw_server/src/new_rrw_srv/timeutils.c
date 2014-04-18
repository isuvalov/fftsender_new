#include<timeutils.h>
#include<stdio.h>

double get_elapsed_time(struct timeval *t1) {
    struct timeval t2;
    double elapsedTime;

    gettimeofday(&t2, NULL);

    elapsedTime = (t2.tv_sec - t1->tv_sec) * 1000.0;      // sec to ms
    elapsedTime += (t2.tv_usec - t1->tv_usec) / 1000.0;   // us to ms

    return elapsedTime;
}

char *get_timestamp_str() {
    static char ts_str[256];
    time_t time_val = 0;
    struct tm *sys_time = NULL;
    struct timeval tv;

    time(&time_val);
    gettimeofday(&tv,NULL);
    sys_time = localtime(&time_val);

    sprintf(ts_str,"%04d.%02d.%02d_%02d_%02d_%02d.%03ld",
            1900+sys_time->tm_year,
            sys_time->tm_mon+1,
            sys_time->tm_mday,
            sys_time->tm_hour,
            sys_time->tm_min,
            sys_time->tm_sec,
            tv.tv_usec/1000);

    return ts_str;
}
