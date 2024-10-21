vlib work
vlog -sv tb.v
vlog -f  flist
vsim -t ps +notimingchecks -voptargs="+acc" work.tb
add wave -position insertpoint sim:/tb/*
run -All
