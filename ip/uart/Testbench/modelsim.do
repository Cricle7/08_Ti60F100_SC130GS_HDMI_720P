onerror {quit -f}
vlib work
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./command_state.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./decoder.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./encoder.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./led_ctl.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./resets.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./tb_uart.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./uart_defines.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./uart_demo_top.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./user_register.v
vlog +define+SIM+SIM_MODE+EFX_SIM -sv ./uart.v
vsim -t ns work.tb_uart
run -all
