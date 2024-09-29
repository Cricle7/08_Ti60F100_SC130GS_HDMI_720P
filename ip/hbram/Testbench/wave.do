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
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/axi_clk
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rstn
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/start
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/aid
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/aaddr
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/alen
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/asize
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/aburst
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/alock
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/avalid
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/aready
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/atype
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/wid
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/wdata
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/wstrb
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/wlast
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/wvalid
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/wready
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rid
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rdata
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rlast
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rvalid
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rready
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rresp
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/bid
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/bvalid
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/bready
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/one_round
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/test_fail
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/test_good
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/state
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/next_state
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/data_reg
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/mid_clear
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/op_idle
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/wr_req
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rd_op
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rd_req
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rd_compare
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/updata_addr
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/cycle_done
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/burst_hit_r
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/burst_cnt
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/addr_counter
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/wlast_counter
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/toggle_cnt
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/addr_hit
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/loop_hit
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/burst_hit
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/axi_slave_wr_idle
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/rd_mismatch
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/burst_hit_pulse
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/crc_clear
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/crc_en
add wave -noupdate /tb_hbram/hard_dut/DUT/genblk2/efx_ed_hyper_ram_axi_tc_inst/crc_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0} {{Cursor 2} {205790245 ps} 0} {{Cursor 3} {474003436 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 461
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
WaveRestoreZoom {221444304 ps} {1346911211 ps}
