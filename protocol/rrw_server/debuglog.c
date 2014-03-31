#include<debuglog.h>
#include<stdarg.h>
#include<stdio.h>
FILE *dbglog;


void dbglog_open() {
  dbglog = fopen("dbglog.txt","a");
}

void dbglog_close() {
  fclose(dbglog);
}

void dbglog_wr(char *format,...) {
  va_list va;
  va_start(va,format);
  dbglog_open();
  vprintf(format,va);
  vfprintf(dbglog,format,va);
  dbglog_close();
  va_end(va);
}

