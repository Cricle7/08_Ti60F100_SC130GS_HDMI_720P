onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_hbram/RAM_DBW
add wave -noupdate /tb_hbram/RAM_ABW
add wave -noupdate /tb_hbram/CR0_DPD
add wave -noupdate /tb_hbram/CR0_ILC
add wave -noupdate /tb_hbram/CR0_ODS
add wave -noupdate /tb_hbram/CR0_HBE
add wave -noupdate /tb_hbram/CR0_WBL
add wave -noupdate /tb_hbram/CR0_FLE
add wave -noupdate /tb_hbram/CR1_MCT
add wave -noupdate /tb_hbram/CR1_PAR
add wave -noupdate /tb_hbram/CR1_HSE
add wave -noupdate /tb_hbram/DDIN_MODE
add wave -noupdate /tb_hbram/AXI_AWR_DEPTH
add wave -noupdate /tb_hbram/CAL_CLK_CH
add wave -noupdate /tb_hbram/CAL_MODE
add wave -noupdate /tb_hbram/TRTR
add wave -noupdate /tb_hbram/TRH
add wave -noupdate /tb_hbram/TVCS
add wave -noupdate /tb_hbram/TCSM
add wave -noupdate /tb_hbram/MHZ
add wave -noupdate /tb_hbram/CAL_RWDS_STEPS
add wave -noupdate /tb_hbram/CAL_DQ_STEPS
add wave -noupdate /tb_hbram/CAL_BYTES
add wave -noupdate /tb_hbram/AXI_IF
add wave -noupdate /tb_hbram/AXI_DBW
add wave -noupdate /tb_hbram/AXI_SBW
add wave -noupdate /tb_hbram/AXI_R_DEPTH
add wave -noupdate /tb_hbram/AXI_W_DEPTH
add wave -noupdate /tb_hbram/DUAL_RAM
add wave -noupdate /tb_hbram/INDIVI_DUAL_CAL
add wave -noupdate /tb_hbram/CAL_CLK_CH_LO
add wave -noupdate /tb_hbram/CAL_CLK_CH_HI
add wave -noupdate /tb_hbram/TCYC
add wave -noupdate /tb_hbram/TS
add wave -noupdate /tb_hbram/U_DLY
add wave -noupdate /tb_hbram/LINEAR
add wave -noupdate /tb_hbram/WAPPED
add wave -noupdate /tb_hbram/REG
add wave -noupdate /tb_hbram/MEM
add wave -noupdate /tb_hbram/IR0
add wave -noupdate /tb_hbram/IR1
add wave -noupdate /tb_hbram/CR0
add wave -noupdate /tb_hbram/CR1
add wave -noupdate /tb_hbram/test_done
add wave -noupdate /tb_hbram/test_fail
add wave -noupdate /tb_hbram/my_pll_locked
add wave -noupdate /tb_hbram/clk_pll_locked
add wave -noupdate /tb_hbram/io_rst
add wave -noupdate /tb_hbram/io_rst_n
add wave -noupdate /tb_hbram/rst
add wave -noupdate /tb_hbram/rst_n
add wave -noupdate /tb_hbram/io_clk
add wave -noupdate /tb_hbram/clk
add wave -noupdate /tb_hbram/clk_90
add wave -noupdate /tb_hbram/checkerd
add wave -noupdate /tb_hbram/checkerp
add wave -noupdate /tb_hbram/io_arw_valid
add wave -noupdate /tb_hbram/io_arw_ready
add wave -noupdate /tb_hbram/io_arw_payload_addr
add wave -noupdate /tb_hbram/io_arw_payload_id
add wave -noupdate /tb_hbram/io_arw_payload_len
add wave -noupdate /tb_hbram/io_arw_payload_size
add wave -noupdate /tb_hbram/io_arw_payload_burst
add wave -noupdate /tb_hbram/io_arw_payload_lock
add wave -noupdate /tb_hbram/io_arw_payload_write
add wave -noupdate /tb_hbram/io_w_payload_id
add wave -noupdate /tb_hbram/io_w_valid
add wave -noupdate /tb_hbram/io_w_ready
add wave -noupdate /tb_hbram/io_w_payload_data
add wave -noupdate /tb_hbram/io_w_payload_strb
add wave -noupdate /tb_hbram/io_w_payload_last
add wave -noupdate /tb_hbram/io_b_valid
add wave -noupdate /tb_hbram/io_b_ready
add wave -noupdate /tb_hbram/io_b_payload_id
add wave -noupdate /tb_hbram/io_r_valid
add wave -noupdate /tb_hbram/io_r_ready
add wave -noupdate /tb_hbram/io_r_payload_data
add wave -noupdate /tb_hbram/io_r_payload_id
add wave -noupdate /tb_hbram/io_r_payload_resp
add wave -noupdate /tb_hbram/io_r_payload_last
add wave -noupdate /tb_hbram/io_b_payload_resp
add wave -noupdate /tb_hbram/hbc_rst_n
add wave -noupdate /tb_hbram/hbc_cs_n
add wave -noupdate /tb_hbram/hbc_ck_p_HI
add wave -noupdate /tb_hbram/hbc_ck_p_LO
add wave -noupdate /tb_hbram/hbc_ck_n_HI
add wave -noupdate /tb_hbram/hbc_ck_n_LO
add wave -noupdate /tb_hbram/hbc_rwds_OUT_HI
add wave -noupdate /tb_hbram/hbc_rwds_OUT_LO
add wave -noupdate /tb_hbram/hbc_rwds_IN_HI
add wave -noupdate /tb_hbram/hbc_rwds_IN_LO
add wave -noupdate /tb_hbram/hbc_rwds_IN
add wave -noupdate /tb_hbram/hbc_rwds_IN_delay
add wave -noupdate /tb_hbram/hbc_rwds_OE
add wave -noupdate /tb_hbram/hbc_dq_OUT_HI
add wave -noupdate /tb_hbram/hbc_dq_OUT_LO
add wave -noupdate /tb_hbram/hbc_dq_IN_HI
add wave -noupdate /tb_hbram/hbc_dq_IN_LO
add wave -noupdate /tb_hbram/hbc_dq_IN
add wave -noupdate /tb_hbram/hbc_dq_OE
add wave -noupdate /tb_hbram/hbc_cal_SHIFT
add wave -noupdate /tb_hbram/hbc_cal_SHIFT_SEL
add wave -noupdate /tb_hbram/hbc_cal_SHIFT_HI
add wave -noupdate /tb_hbram/hbc_cal_SHIFT_SEL_HI
add wave -noupdate /tb_hbram/hbc_cal_SHIFT_LO
add wave -noupdate /tb_hbram/hbc_cal_SHIFT_SEL_LO
add wave -noupdate /tb_hbram/hbc_cal_SHIFT_ENA
add wave -noupdate /tb_hbram/hbc_cal_pass
add wave -noupdate /tb_hbram/rwds_delay
add wave -noupdate /tb_hbram/ram_rst_n
add wave -noupdate /tb_hbram/ram_cs_n
add wave -noupdate /tb_hbram/ram_ck_p
add wave -noupdate /tb_hbram/ram_ck_n
add wave -noupdate /tb_hbram/ram_rwds
add wave -noupdate /tb_hbram/ram_rds
add wave -noupdate /tb_hbram/ram_dq
add wave -noupdate /tb_hbram/i
add wave -noupdate /tb_hbram/j
add wave -noupdate /tb_hbram/hbc_cal_done
add wave -noupdate /tb_hbram/hard_dut/DUT/intosc_clkout
add wave -noupdate /tb_hbram/hard_dut/DUT/intosc_en
add wave -noupdate /tb_hbram/hard_dut/DUT/io_asyncReset
add wave -noupdate /tb_hbram/hard_dut/DUT/clk
add wave -noupdate /tb_hbram/hard_dut/DUT/hbramClk
add wave -noupdate /tb_hbram/hard_dut/DUT/hbramClk_cal
add wave -noupdate /tb_hbram/hard_dut/DUT/hbramClk_pll_locked
add wave -noupdate /tb_hbram/hard_dut/DUT/hbramClk_pll_rstn
add wave -noupdate /tb_hbram/hard_dut/DUT/sysClk_pll_rstn
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cal_SHIFT
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cal_SHIFT_SEL
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cal_SHIFT_ENA
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_rst_n
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cs_n
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_ck_p_HI
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_ck_p_LO
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_ck_n_HI
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_ck_n_LO
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_rwds_OUT_HI
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_rwds_OUT_LO
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_rwds_IN_HI
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_rwds_IN_LO
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_dq_IN_LO
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_dq_IN_HI
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_rwds_OE
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_dq_OUT_HI
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_dq_OUT_LO
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_dq_OE
add wave -noupdate /tb_hbram/hard_dut/DUT/one_round
add wave -noupdate /tb_hbram/hard_dut/DUT/test_good
add wave -noupdate /tb_hbram/hard_dut/DUT/test_fail
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cal_pass
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cal_done
add wave -noupdate /tb_hbram/hard_dut/DUT/start
add wave -noupdate /tb_hbram/hard_dut/DUT/reset
add wave -noupdate /tb_hbram/hard_dut/DUT/memoryFail
add wave -noupdate -expand -group a -color Magenta /tb_hbram/hard_dut/DUT/io_arw_valid
add wave -noupdate -expand -group a -color Magenta /tb_hbram/hard_dut/DUT/io_arw_ready
add wave -noupdate -expand -group a -color Magenta -radix hexadecimal /tb_hbram/hard_dut/DUT/io_arw_payload_addr
add wave -noupdate -expand -group a -color Magenta /tb_hbram/hard_dut/DUT/io_arw_payload_id
add wave -noupdate -expand -group a -color Magenta /tb_hbram/hard_dut/DUT/io_arw_payload_len
add wave -noupdate -expand -group a -color Magenta /tb_hbram/hard_dut/DUT/io_arw_payload_size
add wave -noupdate -expand -group a -color Magenta /tb_hbram/hard_dut/DUT/io_arw_payload_burst
add wave -noupdate -expand -group a -color Magenta /tb_hbram/hard_dut/DUT/io_arw_payload_lock
add wave -noupdate -expand -group a -color Magenta /tb_hbram/hard_dut/DUT/io_arw_payload_write
add wave -noupdate -expand -group w -color Thistle /tb_hbram/hard_dut/DUT/io_w_payload_id
add wave -noupdate -expand -group w -color Thistle /tb_hbram/hard_dut/DUT/io_w_valid
add wave -noupdate -expand -group w -color Thistle /tb_hbram/hard_dut/DUT/io_w_ready
add wave -noupdate -expand -group w -color Thistle -radix hexadecimal /tb_hbram/hard_dut/DUT/io_w_payload_data
add wave -noupdate -expand -group w -color Thistle /tb_hbram/hard_dut/DUT/io_w_payload_strb
add wave -noupdate -expand -group w -color Thistle /tb_hbram/hard_dut/DUT/io_w_payload_last
add wave -noupdate -expand -group r -color Yellow /tb_hbram/hard_dut/DUT/io_r_valid
add wave -noupdate -expand -group r -color Yellow /tb_hbram/hard_dut/DUT/io_r_ready
add wave -noupdate -expand -group r -color Yellow -radix hexadecimal /tb_hbram/hard_dut/DUT/io_r_payload_data
add wave -noupdate -expand -group r -color Yellow /tb_hbram/hard_dut/DUT/io_r_payload_id
add wave -noupdate -expand -group r -color Yellow /tb_hbram/hard_dut/DUT/io_r_payload_resp
add wave -noupdate -expand -group r -color Yellow /tb_hbram/hard_dut/DUT/io_r_payload_last
add wave -noupdate /tb_hbram/hard_dut/DUT/io_b_payload_resp
add wave -noupdate /tb_hbram/hard_dut/DUT/io_b_valid
add wave -noupdate /tb_hbram/hard_dut/DUT/io_b_ready
add wave -noupdate /tb_hbram/hard_dut/DUT/io_b_payload_id
add wave -noupdate /tb_hbram/hard_dut/DUT/native_ram_rdwr
add wave -noupdate /tb_hbram/hard_dut/DUT/native_ram_en
add wave -noupdate /tb_hbram/hard_dut/DUT/native_wr_data
add wave -noupdate /tb_hbram/hard_dut/DUT/native_wr_datamask
add wave -noupdate /tb_hbram/hard_dut/DUT/native_ram_address
add wave -noupdate /tb_hbram/hard_dut/DUT/native_wr_en
add wave -noupdate /tb_hbram/hard_dut/DUT/native_ram_burst_len
add wave -noupdate /tb_hbram/hard_dut/DUT/native_wr_buf_ready
add wave -noupdate /tb_hbram/hard_dut/DUT/native_rd_data
add wave -noupdate /tb_hbram/hard_dut/DUT/native_rd_valid
add wave -noupdate /tb_hbram/hard_dut/DUT/native_ctrl_idle
add wave -noupdate /tb_hbram/hard_dut/DUT/dyn_pll_phase_en
add wave -noupdate /tb_hbram/hard_dut/DUT/dyn_pll_phase_sel
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cal_debug_info
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cal_SHIFT_int
add wave -noupdate /tb_hbram/hard_dut/DUT/hbc_cal_SHIFT_ENA_int
add wave -noupdate /tb_hbram/hard_dut/DUT/override
add wave -noupdate /tb_hbram/hard_dut/DUT/clk_monitor
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {210313646 ps} 0} {{Cursor 2} {258318301 ps} 0} {{Cursor 3} {429683982 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 307
configure wave -valuecolwidth 248
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {161615156 ps} {855223494 ps}
