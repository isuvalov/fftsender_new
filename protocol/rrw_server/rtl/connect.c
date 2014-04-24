#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <tchar.h>
#include "connect.h"

#pragma comment(lib, "user32.lib")

//TCHAR RegFileName[] =TEXT("Global\\cpu_8_reg");
extern TCHAR RegFileName[];

  MemFile_s MemFile;
  RegData_p RegData;

int MemFileOpen (MemFile_p MemFile, char *FileNameStr)
{

  MemFile->Handle = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, FileNameStr);
  if (MemFile->Handle == NULL)
  {
    return 1;
  }

//  MemFile->Buff_p = MapViewOfFile(MemFile->Handle, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(Data_s));
   MemFile->Buff_p =(LPCTSTR) MapViewOfFile(MemFile->Handle, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(Data_s));
  if (MemFile->Buff_p == NULL)
  {
    return 2;
  }

  return 0;
};

int MemFileClose (MemFile_p MemFile)
{

//  UnmapViewOfFile(MemFile->Buff_p);
  UnmapViewOfFile((LPVOID)MemFile->Buff_p);
  CloseHandle(MemFile->Handle);

  return 0;
};

int ConnectInit (char *RegFileName)
{
  if (MemFileOpen (&MemFile, RegFileName) != 0)
  {
    printf ("MSim is stop\n");
    while (MemFileOpen (&MemFile, RegFileName) != 0) {};
  }
  printf ("MSim is start\n");

  RegData  = (RegData_p) MemFile.Buff_p;
  RegData->Trn = IDLE;
  RegData->RcvStatus = RCV_START;

  // MSimWaiting
  while (RegData->MSimStatus != MSIM_START) {};

  return 0;
}

int ConnectClose ()
{
  MemFileClose (&MemFile);
  return 0;
}



int WrReg256 (int *Addr, int *WrData)
{
  int i;

  for (i=0; i<8; i++)
  {
    RegData->addr  [i] = *Addr++;
    RegData->odata [i] = *WrData++;
  }

    RegData->Trn = WR_REG;
    while (RegData->Ack != 1) {};
    RegData->Trn = IDLE;
    while (RegData->Ack != 0) {};
    printf ("-> WR_REG addr = %8x  odata = %8x\n", RegData->addr[0], RegData->odata[0]);
    return 0;
}

int RdReg256 (int *Addr, int *RdData)
{
  int i;

  for (i=0; i<8; i++)
  {
    RegData->addr  [i] = *Addr++;
  }
  RegData->Trn = RD_REG;
  while (RegData->Ack != 1) {};
  RegData->Trn = IDLE;
  while (RegData->Ack != 0) {};
  for (i=0; i<8; i++)
  {
    *RdData++ = RegData->idata [i];
  }

  printf ("-> RD_REG addr = %8x  idata = %8x\n", RegData->addr [0], RegData->idata [0]);
  return 0;
}

int WrReg16 (int Addr, int WrData)
{
    RegData->addr  [0] = Addr;
    RegData->odata [0] = WrData;

    RegData->Trn = WR_REG;
    while (RegData->Ack != 1) {};
    RegData->Trn = IDLE;
    while (RegData->Ack != 0) {};

    return 0;
}

int RdReg16 (int Addr)
{
  RegData->addr  [0] = Addr;

  RegData->Trn = RD_REG;
  while (RegData->Ack != 1) {};
  RegData->Trn = IDLE;
  while (RegData->Ack != 0) {};

  return (RegData->idata [0]);
}
