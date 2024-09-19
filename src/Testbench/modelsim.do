
set SWITCH_1 SIM
set SWITCH_2 EFX_IPM


vlib work


vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/top*v
vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/efx_crc32.v
vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/efx_ed_hyper_ram_axi_tc.v
vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/efx_ed_hyper_ram_native_tc.v
vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/top.v
vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/EFX_GPIO_model.v
vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/efx_lut4.v
vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/clock_gen.v
vlog +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/tb.v
vlog -sv -sv09compat +define+$SWITCH_1+$SWITCH_2 ../../ip/hbram/Testbench/modelsim/hbram.v

vlog -sv -sv09compat +define+$SWITCH_1 ../../ip/hbram/Testbench/W958D6NKY.modelsim.vp

vlog -f flist

#Load the design.
vsim -t ps +notimingchecks -gui -voptargs="+acc" work.tb_example_top
do wave.do
#Run simulation
run 150ms
run 150ms
