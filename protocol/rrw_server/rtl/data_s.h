#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <tchar.h>


#define FILE_OPEN  1
#define MSIM_START 2
#define MSIM_IDLE  3
#define RCV_START  4
#define RCV_RST    5


#define RST 0
#define SET 1

typedef struct Data_t {
  int Wr;
  int Ack;
  int Status;
  int Integer[8];
  int Bit [256];
} Data_s, *Data_p;

typedef struct MemFile_t {
  HANDLE Handle;
  LPCTSTR Buff_p;
} MemFile_s, *MemFile_p;
                              
typedef struct ChExchange_t {
  MemFile_s MemFileIn;
  MemFile_s MemFileOut;
} ChExchange_s, *ChExchange_p;

#define IDLE   0
#define WR_REG 1
#define RD_REG 2

typedef struct RegData_t {
  int Trn;
  int Ack;
  int MSimStatus;
  int RcvStatus;
  int addr  [8];
  int idata [8];
  int odata [8];
} RegData_s, *RegData_p;
