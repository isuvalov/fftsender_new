#include<common.h>
#include<stdarg.h>
#include<stdio.h>
#include<timeutils.h>

const int _endian_check_const = 1;

unsigned short reverse_us (unsigned short s) {
    unsigned char c1, c2;

    if (is_bigendian()) {
        return s;
    } else {
        c1 = s & 255;
        c2 = (s >> 8) & 255;
        return (c1 << 8) + c2;
    }
}

short reverse_s (short s) {
    unsigned char c1, c2;

    if (is_bigendian()) {
        return s;
    } else {
        c1 = s & 255;
        c2 = (s >> 8) & 255;
        return (c1 << 8) + c2;
    }
}

unsigned int reverse_ui (unsigned int i) {
    unsigned char c1, c2, c3, c4;

    if (is_bigendian()) {
        return i;
    } else {
        c1 = i & 255;
        c2 = (i >> 8) & 255;
        c3 = (i >> 16) & 255;
        c4 = (i >> 24) & 255;

        return ((int)c1 << 24) + ((int)c2 << 16) + ((int)c3 << 8) + c4;
    }
}

int reverse_i (int i) {
    unsigned char c1, c2, c3, c4;

    if (is_bigendian()) {
        return i;
    } else {
        c1 = i & 255;
        c2 = (i >> 8) & 255;
        c3 = (i >> 16) & 255;
        c4 = (i >> 24) & 255;

        return ((int)c1 << 24) + ((int)c2 << 16) + ((int)c3 << 8) + c4;
    }
}


void logprintf(char *format,...) {
  char ts_str[32];
  va_list va;
  printf("%s ",get_timestamp_h_m_s_ms(ts_str));
  va_start(va,format);
  vprintf(format,va);
  va_end(va);
}

static FILE *flog;
void flog_open(char *path) {
  flog = fopen(path,"w+");
}

void flog_close() {
  fclose(flog);
}

void flogprintf(char *format,...) {
  char ts_str[32];
  va_list va;
//  fprintf(flog,"%s ",get_timestamp_h_m_s_ms(ts_str));
//  printf("%s ",get_timestamp_h_m_s_ms(ts_str));
  va_start(va,format);
  vfprintf(flog,format,va);
//  vprintf(format,va);
  va_end(va);
}
