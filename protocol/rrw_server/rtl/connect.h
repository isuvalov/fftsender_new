//#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <tchar.h>
#include "data_s.h"

int MemFileOpen  (MemFile_p MemFile, char *FileNameStr);
int MemFileClose (MemFile_p MemFile);

int WrReg16 (int Addr, int WrData);
int RdReg16 (int Addr);


int WrReg256 (int *Addr, int *WrData);
int RdReg256 (int *Addr, int *RdData);

int ConnectClose ();
int ConnectInit (char *RegFileName);