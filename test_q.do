quit -sim

do modelsim_my.tcl

vsim -novopt -t ps work.tb -pli protcol_rtl/dll.dll 
do wave.do

