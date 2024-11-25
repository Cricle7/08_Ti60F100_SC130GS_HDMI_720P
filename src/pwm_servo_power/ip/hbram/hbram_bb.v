`timescale 1ns / 1ps

module hbram (
input io_axi_clk,
input ram_clk_cal,
input ram_clk,
input rst,


input [31:0] io_arw_payload_addr,
input [7:0] io_arw_payload_id,
input [7:0] io_arw_payload_len,
input [2:0] io_arw_payload_size,
input [1:0] io_arw_payload_burst,
input [1:0] io_arw_payload_lock,
input io_arw_payload_write,
output reg io_arw_ready,
input io_arw_valid,


input [7:0] io_w_payload_id,
output io_w_ready,
input io_w_valid,
input [127:0] io_w_payload_data,
input [15:0] io_w_payload_strb,
input io_w_payload_last, 


output io_b_valid,
output [7:0] io_b_payload_id,
input io_b_ready,


output io_r_valid,
output [127:0] io_r_payload_data,
input io_r_ready,
output [7:0] io_r_payload_id,
output io_r_payload_last,
output [1:0] io_r_payload_resp,


output [15:0] hbc_cal_debug_info,
output hbc_cal_pass,
output [15:0] hbc_dq_OE,
input [15:0] hbc_dq_IN_LO,
input [15:0] hbc_dq_IN_HI,
output [15:0] hbc_dq_OUT_LO,
output [15:0] hbc_dq_OUT_HI,
output [1:0] hbc_rwds_OE,
input [1:0] hbc_rwds_IN_LO,
input [1:0] hbc_rwds_IN_HI,
output [1:0] hbc_rwds_OUT_LO,
output [1:0] hbc_rwds_OUT_HI,
output hbc_ck_n_LO,
output hbc_ck_n_HI,
output hbc_ck_p_LO,
output hbc_ck_p_HI,
output hbc_cs_n,
output hbc_rst_n,
output [4:0] hbc_cal_SHIFT_SEL,
output [2:0] hbc_cal_SHIFT,
output hbc_cal_SHIFT_ENA,
input [2:0] dyn_pll_phase_sel,
input dyn_pll_phase_en
);
	
	initial begin
		io_arw_ready = 0; 
	end
	
	always begin
		@(posedge io_axi_clk); 
		
		if(io_arw_valid) begin
		end else begin
		end
	end
	
	
	
	
	
	
	
	
endmodule 

