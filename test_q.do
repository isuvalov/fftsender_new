quit -sim

do modelsim_my.tcl

vsim -novopt -t ps work.tb -pli dll.dll -gNOT_PLI=0
do wave.do

