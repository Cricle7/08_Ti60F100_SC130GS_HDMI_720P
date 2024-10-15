
set SWITCH_1 SIM
set SWITCH_2 EFX_IPM


vlib work

vlog +define+$SWITCH_1 -f flist 

#Load the design.
vsim -t ps +notimingchecks -gui -voptargs="+acc" work.testbench
add wave -position insertpoint sim:/testbench/*
add wave -position insertpoint sim:/testbench/uut/*
add wave -position insertpoint sim:/testbench/uut/u0_Line_Shift_RAM_8Bit/*
#add wave -position insertpoint sim:/tb_example_top/u_dut/u_inter_connector/*
#do wave.do
run 500ns
#Run simulation
#run 150ms
#run 150ms
