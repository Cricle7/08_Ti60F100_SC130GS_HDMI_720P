
set SWITCH_1 SIM
set SWITCH_2 EFX_IPM

#Define vlib
vlib work

vlog -f flist

#Load the design.
vsim -t ps +notimingchecks -gui -voptargs="+acc" work.axi4_ctrl_tb

add wave -position insertpoint  \
sim:/axi4_ctrl_tb/axi_clk \
sim:/axi4_ctrl_tb/axi_reset \
sim:/axi4_ctrl_tb/axi_awready \
sim:/axi4_ctrl_tb/axi_wready \
sim:/axi4_ctrl_tb/axi_bid \
sim:/axi4_ctrl_tb/axi_bresp \
sim:/axi4_ctrl_tb/axi_bvalid \
sim:/axi4_ctrl_tb/axi_arready \
sim:/axi4_ctrl_tb/axi_rid \
sim:/axi4_ctrl_tb/axi_rdata \
sim:/axi4_ctrl_tb/axi_rresp \
sim:/axi4_ctrl_tb/axi_rlast \
sim:/axi4_ctrl_tb/axi_rvalid \
sim:/axi4_ctrl_tb/wframe_pclk \
sim:/axi4_ctrl_tb/wframe_vsync \
sim:/axi4_ctrl_tb/wframe_data_en \
sim:/axi4_ctrl_tb/wframe_data \
sim:/axi4_ctrl_tb/rframe_pclk \
sim:/axi4_ctrl_tb/rframe_vsync \
sim:/axi4_ctrl_tb/rframe_data_en \
sim:/axi4_ctrl_tb/axi_awid \
sim:/axi4_ctrl_tb/axi_awaddr \
sim:/axi4_ctrl_tb/axi_awlen \
sim:/axi4_ctrl_tb/axi_awsize \
sim:/axi4_ctrl_tb/axi_awburst \
sim:/axi4_ctrl_tb/axi_awlock \
sim:/axi4_ctrl_tb/axi_awcache \
sim:/axi4_ctrl_tb/axi_awprot \
sim:/axi4_ctrl_tb/axi_awqos \
sim:/axi4_ctrl_tb/axi_awvalid \
sim:/axi4_ctrl_tb/axi_wdata \
sim:/axi4_ctrl_tb/axi_wstrb \
sim:/axi4_ctrl_tb/axi_wlast \
sim:/axi4_ctrl_tb/axi_wvalid \
sim:/axi4_ctrl_tb/axi_bready \
sim:/axi4_ctrl_tb/axi_arid \
sim:/axi4_ctrl_tb/axi_araddr \
sim:/axi4_ctrl_tb/axi_arlen \
sim:/axi4_ctrl_tb/axi_arsize \
sim:/axi4_ctrl_tb/axi_arburst \
sim:/axi4_ctrl_tb/axi_arlock \
sim:/axi4_ctrl_tb/axi_arcache \
sim:/axi4_ctrl_tb/axi_arprot \
sim:/axi4_ctrl_tb/axi_arqos \
sim:/axi4_ctrl_tb/axi_arvalid \
sim:/axi4_ctrl_tb/axi_rready \
sim:/axi4_ctrl_tb/rframe_data

#Run simulation
#run -all
