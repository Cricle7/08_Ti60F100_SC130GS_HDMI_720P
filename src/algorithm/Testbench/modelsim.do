
set SWITCH_1 SIM
set SWITCH_2 EFX_IPM

#Define vlib
vlib work

vlog -f flist

#Load the design.
vsim -t ps +notimingchecks -gui -voptargs="+acc" work.testbench
#do wave.do
#Run simulation
#run -all
