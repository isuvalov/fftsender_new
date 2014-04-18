#ifndef TIMEUTILS_H
#define TIMEUTILS_H

#include <sys/time.h>
#include <time.h>

#ifdef WIN32
#include <windows.h>
#define sleep_ms Sleep
#define sleep_s(s) Sleep(s*1000)
#else
#define sleep_ms(ms) usleep(1000*ms)
#define sleep_s sleep
#endif


double get_elapsed_time(struct timeval *t1);
char *get_timestamp_str();
char *get_timestamp_h_m_s_ms(char *ts_str);
char *get_timestamp_log_path();
#endif // TIMEUTILS_H
