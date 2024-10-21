
set SWITCH_1 SIM
set SWITCH_2 EFX_IPM

#Define vlib
vlib work

vlog -f flist

#Load the design.
# vsim -t ps +notimingchecks -gui -voptargs="+acc" work.two_pass_tb
# vsim -t ps +notimingchecks -gui -voptargs="+acc" work.union_find_tb
 vsim -t ps +notimingchecks -gui -voptargs="+acc" work.pingpong_ram_tb
# add wave -position insertpoint sim:/two_pass_tb/uut/*
# add wave -position insertpoint sim:/two_pass_tb/uut/u_union_find/*
# add wave -position insertpoint sim:/two_pass_tb/uut/prev_image_valid/*
# add wave -position insertpoint sim:/two_pass_tb/uut/prev_image_label/*
#do wave.do
#Run simulation
# run -all
