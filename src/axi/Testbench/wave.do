onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {r&w frame} /axi4_ctrl_tb/wframe_pclk
add wave -noupdate -expand -group {r&w frame} /axi4_ctrl_tb/wframe_vsync
add wave -noupdate -expand -group {r&w frame} /axi4_ctrl_tb/wframe_data_en
add wave -noupdate -expand -group {r&w frame} -radix hexadecimal /axi4_ctrl_tb/wframe_data
add wave -noupdate -expand -group {r&w frame} /axi4_ctrl_tb/rframe_data
add wave -noupdate -expand -group {r&w frame} /axi4_ctrl_tb/rframe_pclk
add wave -noupdate -expand -group {r&w frame} /axi4_ctrl_tb/rframe_vsync
add wave -noupdate -expand -group {r&w frame} /axi4_ctrl_tb/rframe_data_en
add wave -noupdate -expand -group aw /axi4_ctrl_tb/axi_awready
add wave -noupdate -expand -group aw -radix unsigned /axi4_ctrl_tb/axi_awaddr
add wave -noupdate -expand -group aw /axi4_ctrl_tb/axi_awvalid
add wave -noupdate -expand -group aw /axi4_ctrl_tb/axi_awlen
add wave -noupdate -expand -group {New Group} -color Yellow -radix hexadecimal /axi4_ctrl_tb/axi_wdata
add wave -noupdate -expand -group {New Group} -color Yellow /axi4_ctrl_tb/axi_wvalid
add wave -noupdate -expand -group {New Group} -color Yellow /axi4_ctrl_tb/axi_wstrb
add wave -noupdate -expand -group {New Group} -color Yellow /axi4_ctrl_tb/axi_wlast
add wave -noupdate -expand -group {New Group} -color Yellow /axi4_ctrl_tb/axi_wready
add wave -noupdate /axi4_ctrl_tb/axi_awid
add wave -noupdate /axi4_ctrl_tb/axi_awsize
add wave -noupdate /axi4_ctrl_tb/axi_awlock
add wave -noupdate /axi4_ctrl_tb/axi_awburst
add wave -noupdate /axi4_ctrl_tb/axi_awcache
add wave -noupdate /axi4_ctrl_tb/axi_awprot
add wave -noupdate /axi4_ctrl_tb/axi_awqos
add wave -noupdate /axi4_ctrl_tb/axi_arready
add wave -noupdate /axi4_ctrl_tb/axi_rid
add wave -noupdate /axi4_ctrl_tb/axi_rdata
add wave -noupdate /axi4_ctrl_tb/axi_rresp
add wave -noupdate /axi4_ctrl_tb/axi_rlast
add wave -noupdate /axi4_ctrl_tb/axi_rvalid
add wave -noupdate /axi4_ctrl_tb/axi_bready
add wave -noupdate /axi4_ctrl_tb/axi_arid
add wave -noupdate /axi4_ctrl_tb/axi_araddr
add wave -noupdate /axi4_ctrl_tb/axi_arlen
add wave -noupdate /axi4_ctrl_tb/axi_arsize
add wave -noupdate /axi4_ctrl_tb/axi_arburst
add wave -noupdate /axi4_ctrl_tb/axi_arlock
add wave -noupdate /axi4_ctrl_tb/axi_arcache
add wave -noupdate /axi4_ctrl_tb/axi_arprot
add wave -noupdate /axi4_ctrl_tb/axi_arqos
add wave -noupdate /axi4_ctrl_tb/axi_arvalid
add wave -noupdate /axi4_ctrl_tb/axi_rready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11633562 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 248
configure wave -valuecolwidth 258
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
WaveRestoreZoom {7412314 ps} {16622151 ps}
