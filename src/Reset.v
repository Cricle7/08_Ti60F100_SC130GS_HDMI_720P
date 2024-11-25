`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    12:52:08 12/03/2022 
// Module Name:    Reset 
//////////////////////////////////////////////////////////////////////////////////
module Reset(
	input 			clk_i,
	input 			locked_i,
	output reg			rstn_o,
	output reg			rst_o
);
	
	reg 			r_locked = 0; 
	always @(posedge clk_i or negedge locked_i) begin
		if(~locked_i)
			r_locked <= 0; 
		else
			r_locked <= 1; 
	end
	
	reg 	[15:0] 	r_rstn_dly = 0; 
	
	always @(posedge clk_i or negedge r_locked) begin
		if(~r_locked) begin
			rstn_o <= 0; 
			rst_o <= 1; 
			r_rstn_dly <= 0; 
		end else begin
			r_rstn_dly <= {r_rstn_dly, 1'b1}; 
			rstn_o <= r_rstn_dly[15]; 
			rst_o <= ~r_rstn_dly[15]; 
		end
	end
	
	
endmodule
