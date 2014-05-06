quit -sim

do modelsim_my.tcl

vsim -novopt -t ps work.tb -pli dll.dll 
do wave.do

