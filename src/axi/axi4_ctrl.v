//  by CrazyBird
module axi4_ctrl #(
	parameter 	C_ID_LEN      = 8, 
			C_DATA_SIZE   = 4, 			//	C_DATA_LEN=8:0, 16:1, 32:2, 64:3, 128:4, 256:5, 512:6, 1024:7
			
			C_BURST_LEN   = 128,			//	R / W of 128 bursts to improve throughput. 
			
			
			C_DATA_LEN    = 8 * (2 ** C_DATA_SIZE), 	
			C_STRB_LEN    = C_DATA_LEN / 8, 		
			C_ADDR_INC    = C_BURST_LEN * C_STRB_LEN,	
			
			C_BASE_ADDR   = 32'h00000000, 	//	Start at 0x00000000 by default
			C_BUF_SIZE    = 22, 			//	Allocate 2^24 bytes (16MB) for 1080P24. The module takes 4*16MB by default. 
			C_RD_END_ADDR = 1920 * 1080,
			
			C_W_WIDTH     = 24, 
			C_R_WIDTH     = 24			//	Read of RGB888 only. 
)(
	input 				axi_clk,
	input 				axi_reset,
	
	output 	[C_ID_LEN-1:0] 	axi_awid,
	output 	[31:0] 		axi_awaddr,
	output 	[ 7:0] 		axi_awlen,
	output 	[ 2:0] 		axi_awsize,
	output 	[ 1:0] 		axi_awburst,
	output 				axi_awlock,
	output 	[ 3:0] 		axi_awcache,
	output 	[ 2:0] 		axi_awprot,
	output 	[ 3:0] 		axi_awqos,
	output reg 				axi_awvalid,
	input 				axi_awready,
	
	output 	[C_DATA_LEN-1:0] 	axi_wdata,
	output 	[C_STRB_LEN-1:0] 	axi_wstrb,
	output 				axi_wlast,
	output reg 				axi_wvalid,
	input 				axi_wready,
	
	input 	[C_ID_LEN-1:0] 	axi_bid,
	input 	[ 1:0] 		axi_bresp,
	input 				axi_bvalid,
	output 				axi_bready,
	
	output 	[C_ID_LEN-1:0] 	axi_arid,
	output 	[31:0] 		axi_araddr,
	output 	[ 7:0] 		axi_arlen,
	output 	[ 2:0] 		axi_arsize,
	output 	[ 1:0] 		axi_arburst,
	output 				axi_arlock,
	output 	[ 3:0] 		axi_arcache,
	output 	[ 2:0] 		axi_arprot,
	output 	[ 3:0] 		axi_arqos,
	output reg 				axi_arvalid,
	input 				axi_arready,
	
	input 	[C_ID_LEN-1:0] 	axi_rid,
	input 	[C_DATA_LEN-1:0] 	axi_rdata,
	input 	[ 1:0] 		axi_rresp,
	input 				axi_rlast,
	input 				axi_rvalid,
	output 				axi_rready,
	
	
	//	Writer Interface 
	input 				wframe_pclk,
	input 				wframe_vsync,		//	Writter VSync. Flush on falling edge. Connect to EOF. 
	input 				wframe_data_en,
	input 	[C_W_WIDTH-1:0] 	wframe_data,
	
	//	Reader Interface
	input 				rframe_pclk,
	input 				rframe_vsync,		//	Reader VSync. Sync / Async. Trigger read on falling edge. 
	output 				rframe_data_valid, 	//	Data Valid. 
	input 				rframe_data_en,
	output 	[C_R_WIDTH-1:0] 	rframe_data,
	output 				rframe_idle, 		//	Read Done. 
	
	output 	[31:0] 		tp_o
);
	
	initial begin
		axi_awvalid <= 0; 
		axi_wvalid <= 0; 
		axi_arvalid <= 0; 
	end

	assign axi_awid    = {C_ID_LEN{1'b0}};
	assign axi_awlen   = C_BURST_LEN - 1'b1;
	assign axi_awsize  = C_DATA_SIZE;
	assign axi_awburst = 2'b01;	//	INCR
	assign axi_awlock  = 1'b0;
	assign axi_awcache = 0;
	assign axi_awprot  = 3'b0;
	assign axi_awqos   = 4'b0;
	assign axi_wstrb   = 32'hFFFFFFFF;
	assign axi_bready  = 1; 
	    
	assign axi_arid    = {C_ID_LEN{1'b0}};
	assign axi_arlen   = C_BURST_LEN - 1'b1;
	assign axi_arsize  = C_DATA_SIZE;
	assign axi_arburst = 2'b01;	//	INCR
	assign axi_arlock  = 1'b0;
	assign axi_arcache = 0;
	assign axi_arprot  = 3'b0;
	assign axi_arqos   = 4'b0;
	assign axi_rready  = 1; 
	
	
	
	
	////////////////////////////////////////////////////////////////
	//	R/W Schedule
	reg	[1:0] 	rc_wframe_index = 0;
	reg	[1:0] 	rc_rframe_index = 0;

	//	Use 4 data buffers to simplify control. 
	wire 	[1:0] 	w_wframe_index_p1 = rc_wframe_index + 1; 
	wire 	[1:0] 	w_wframe_index_next = (w_wframe_index_p1 == rc_rframe_index) ? rc_wframe_index + 2 : rc_wframe_index + 1; 

	reg 	[1:0] 	r_wframe_index_last = 0; 
	
	reg 			r_wframe_inc = 0, r_rframe_inc = 0; 
	
	always @(posedge axi_clk) begin
		if(axi_reset) begin
			rc_wframe_index <= 2'b0;
			rc_rframe_index <= 2'd0;	//	Set initial ptr to 0. Continue only when rc_rframe_index != r_wframe_index_last. 
			r_wframe_index_last <= 0; 
			
		end else begin
			rc_wframe_index <= rc_wframe_index; 
			rc_rframe_index <= rc_rframe_index; 
			
			//	When wfifo_rd_rst_busy_neg, write pointer increments. When rfifo_wr_rst_busy_neg, read pointer increments. 
			case ({r_rframe_inc, r_wframe_inc})
				2'b01: begin
						//	Write increment only. 
						rc_wframe_index <= w_wframe_index_next; 	//	Use 4 buffers. 
						r_wframe_index_last <= rc_wframe_index; 
					end
				2'b10: begin
						//	Use r_wframe_index_last. 
						rc_rframe_index <= r_wframe_index_last; 
					end
				2'b11: begin
						//	Update write & read pointer simutaneously. 
						rc_wframe_index <= w_wframe_index_next; 	//	Use 4 buffers. 
						rc_rframe_index <= rc_wframe_index; 		
					end
			endcase
			
		end
	end
	
	
	
	////////////////////////////////////////////////////////////////
	//	AXI Writter

	wire 				w_wfifo_pempty, w_wfifo_empty; 
	wire 				w_wfifo_ren; 
	wire 	[C_DATA_LEN-1:0] 	w_wfifo_rdata; 

	//	On EOF when ~empty, flush the last data then reset FIFO. 
	reg 	[3:0] 	rs_w = 0; 
	wire 	[3:0] 	ws_w_idle = 0; 
	wire 	[3:0] 	ws_w_wdata = 1; 
	wire 	[3:0] 	ws_w_winc = 2; 
	wire 	[3:0] 	ws_w_eof = 3; 
	wire 	[3:0] 	ws_w_wend = 4; 

	//	Write Pointer. Burst bytes is always C_ADDR_INC. 
	reg 	[C_BUF_SIZE-1:0] 	rc_w_ptr = 0; 
	reg 	[0:0] 		rc_w_eof = 0; 
	reg 				r_w_rst = 1; 
	
	//	Burst Control
	reg 	[7:0] 	rc_burst = 0; 	//	Compare to C_BURST_LEN - 1. 
	
	//	EOF Monitor. 
	reg 	[1:0] 	r_wframe_sync = 0; 	
	reg 			r_weof_pending = 0; 

	always @(posedge axi_clk or posedge axi_reset) begin
		if(axi_reset) begin
			rs_w <= 0; 
			rc_w_ptr <= 0; 
			rc_w_eof <= 0; 
			r_w_rst <= 1; 
			axi_awvalid <= 0; 
			axi_wvalid <= 0; 
			r_wframe_sync <= 0; 
			r_weof_pending <= 0; 
			r_wframe_inc <= 0; 
			
		end else begin
			rc_w_eof <= 0; 
			r_wframe_inc <= 0; 
			
			//	Raise EOF on falling edge of VSYNC. 
			r_wframe_sync <= {r_wframe_sync, wframe_vsync}; 
			if(r_wframe_sync == 2'b10) begin
				r_weof_pending <= 1; 
			end else begin
			end
			
			if(axi_awready) begin
				axi_awvalid <= 0; 
			end else begin
			end
			
			case (rs_w)
				ws_w_idle: begin
						rc_burst <= 0; 
						r_w_rst <= 0; 
						
						if(~w_wfifo_pempty) begin
							axi_awvalid <= 1; 
							axi_wvalid <= 1; 
							rs_w <= ws_w_wdata; 
						
						end else if(r_weof_pending && (~w_wfifo_empty)) begin
							//	There's some data in the FIFO. write last. 
							axi_awvalid <= 1; 
							axi_wvalid <= 1; 
							rs_w <= ws_w_wdata; 
							
						end else if(r_weof_pending) begin
							//	EOF. Reset FIFO. Increment write pointer. 
							r_w_rst <= 1; 
							r_wframe_inc <= 1; 
							rs_w <= ws_w_eof; 
							
						end else begin
						end
					end
					
				ws_w_eof: begin
						//	Wait for some cycles to release reset. 
						r_weof_pending <= 0; 
						rc_w_ptr <= 0; 
						
						rc_w_eof <= rc_w_eof + 1; 
						if(&rc_w_eof)
							rs_w <= ws_w_idle; 
						else begin
						end
					end
					
				ws_w_wdata: begin
						rc_burst <= rc_burst + axi_wready; 
						
						//	On last transaction terminate write. 
						if(axi_wlast && axi_wready) begin
							axi_wvalid <= 0; 
							rs_w <= ws_w_wend; 
						end else begin
						end
					end
				ws_w_wend: begin
						//	Wait until ~axi_awvalid. When not waiting for ~awvalid, this may cause troubles if the last awvalid is not cleared. 
						if(~axi_awvalid) begin
							rs_w <= ws_w_winc; 
						end else begin
						end
					end
					
				ws_w_winc: begin
						rc_w_ptr <= rc_w_ptr + C_ADDR_INC; 
						rs_w <= ws_w_idle; 
					end
			endcase
		end
	end
	assign axi_awaddr = C_BASE_ADDR + {rc_wframe_index, rc_w_ptr}; 
	assign axi_wdata = w_wfifo_rdata; 
	assign axi_wlast = (rc_burst >= C_BURST_LEN - 1); 
	
	assign w_wfifo_ren = axi_wvalid && axi_wready; 
	
	
	assign tp_o[1:0] = {rs_w[1:0]}; 
	assign tp_o[2] = axi_wvalid; 
	assign tp_o[3] = wframe_data_en; 
	
	
	reg 	[C_DATA_LEN-1:0] 		r_wfifo_wdata = 0; 
	//	For 24 bit mode drop the upper unused data bits. 
	wire 	[C_DATA_LEN-1:0] 		w_wfifo_wdata = (C_W_WIDTH == 24) ? {wframe_data, r_wfifo_wdata[C_W_WIDTH*5-1:C_W_WIDTH]} : {wframe_data, r_wfifo_wdata[C_DATA_LEN-1:C_W_WIDTH]}; 
	
	//	Add 24 bit mode. When 24 bit mode, output 5 words for 128 bits. 
	localparam WFIFO_CNT_SIZE = (C_W_WIDTH == 8) ? 4 : (((C_W_WIDTH == 16) || (C_W_WIDTH == 24)) ? 3 : ((C_W_WIDTH == 32) ? 2 : 1)); 
	reg 	[WFIFO_CNT_SIZE-1:0] 	rc_wfifo_we = 0; 
	
	always @(posedge wframe_pclk) begin
		//	Assume Lsb first. Shift in when wframe_data_en. 
		if(wframe_data_en) begin
			r_wfifo_wdata <= w_wfifo_wdata; 
		end else begin
		end
		
		if(r_w_rst) begin
			rc_wfifo_we <= 0; 
		end else begin
			if(wframe_data_en) begin
				if(C_W_WIDTH == 24) begin
					//	When 24 bit, rc_wfifo_we can only be [0, 1, 2, 3, 4]. 
					if(rc_wfifo_we >= 4)
						rc_wfifo_we <= 0; 
					else
						rc_wfifo_we <= rc_wfifo_we + 1; 
				end else begin
					rc_wfifo_we <= rc_wfifo_we + 1; 
				end
			end else begin
			end
		end
	end
	
	//	Write FIFO. Use full thresh of 256, and empty thresh of 128. 
	W0_FIFO_128 u_W0_FIFO_128
	(
		.wr_clk_i 		(wframe_pclk ),
		.wr_en_i 		(wframe_data_en && ((C_W_WIDTH == 24) ? (rc_wfifo_we == 4) : (&rc_wfifo_we))),	//	Write 5 words for 24 bit. 
		.wdata 		(w_wfifo_wdata ),
		.a_rst_i		(r_w_rst), 
		.full_o		(), 
		.prog_full_o	(),
		
		.rd_clk_i 		(axi_clk ),
		.rd_en_i 		(w_wfifo_ren ),
		.rdata 		(w_wfifo_rdata ),
		//.rd_rst		(r_w_rst), 
		.empty_o 		(w_wfifo_empty),		//	Empty triggers EOF non-full burst write. 
		.prog_empty_o	(w_wfifo_pempty)		//	AEmpty triggers full burst write. 
	);
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	AXI Read Controller
	
	reg 	[C_BUF_SIZE-1:0] 	rc_r_ptr = 0; 
	
	//	FIFO State
	wire 				w_rfifo_wfull; 
	
	reg 				r_r_eof = 0; 
	
	
	reg 	[3:0] 	rs_r = 0; 
	
	wire 	[3:0] 	ws_r_idle = 0; 
	wire 	[3:0] 	ws_r_rbufchk = 1; 	//	Check read buffer. 
	wire 	[3:0] 	ws_r_rreq = 2; 
	wire 	[3:0] 	ws_r_rinc = 3; 
	wire 	[3:0] 	ws_r_wait = 4; 
	wire 	[3:0] 	ws_r_chk = 5; 
	
	//	Input Trigger on VSYNC_F. 
	reg 	[1:0] 	r_rframe_vsync = 0; 
	
	always @(posedge axi_clk or posedge axi_reset) begin
		if(axi_reset) begin
			rc_r_ptr <= 0; 
			axi_arvalid <= 0; 
			r_r_eof <= 0; 
			
			rs_r <= 0; 
			
			r_rframe_vsync <= 0; 
			
			r_rframe_inc <= 0; 
			
		end else begin
			r_rframe_vsync <= {r_rframe_vsync, rframe_vsync}; 
			
			r_rframe_inc <= 0; 
			
			r_r_eof <= (rc_r_ptr >= C_RD_END_ADDR); 
			
			case (rs_r)
				ws_r_idle: begin
						rc_r_ptr <= 0; 
						r_r_eof <= 1; 
						
						if(r_rframe_vsync == 2'b10) begin
							//	Allocate new frame buffer. 
							//r_rframe_inc <= 1; 
							
							r_r_eof <= 0; 
							rs_r <= ws_r_rbufchk; 
						end else begin
						end
						
					end
				ws_r_rbufchk: begin
						//	Wait until rc_rframe_index != r_wframe_index_last. 
						//	In this case we can safely acquire a new frame. Otherwise halt. 
						//if(rc_rframe_index != r_wframe_index_last) begin
						r_rframe_inc <= 1; 
						rs_r <= ws_r_rreq; 
						//end else begin
						//end
					end
				ws_r_rreq: begin
						//	Raise ARVALID when ~r_rframe_inc. This ensures address pointer to be updated correctly. 
						axi_arvalid <= (r_rframe_inc == 0); 
						
						if(axi_arvalid && axi_arready) begin
							axi_arvalid <= 0; 
							rs_r <= ws_r_rinc; 
						end else begin
						end
					end
				ws_r_rinc: begin
						rc_r_ptr <= rc_r_ptr + C_ADDR_INC; 
						rs_r <= ws_r_wait; 
					end
				ws_r_wait: begin
						//	Wait until read finished. 
						if(axi_rvalid && axi_rlast) begin
							rs_r <= ws_r_chk; 
						end else begin
						end
					end
				ws_r_chk: begin
						//	When FIFO full, wait. When EOF, exit. 
						if(r_r_eof) begin
							rs_r <= ws_r_idle; 
							
						end else if(w_rfifo_wfull) begin
							//	Halt 
							
						end else begin
							rs_r <= ws_r_rreq; 
							
						end
					end
			endcase
		end
	end
	assign axi_araddr = C_BASE_ADDR + {rc_rframe_index, rc_r_ptr};
	assign rframe_idle = r_r_eof; 
	
	
	////////////////////////////////////////////////////////////////
	//	AXI Read FIFO
	wire 				w_rfifo_rst = (r_rframe_vsync == 2'b10); 		//	Reset FIFO on START pulse. 

	wire 				w_rfifo_aempty;
	wire 				w_rfifo_empty; 

	wire 				w_rframe_data_en_fifo, w_rframe_data_en_load; 	
	wire 	[C_DATA_LEN-1:0] 	w_rframe_data_gen; 	
	W0_FIFO_128 u_R0_FIFO_128
	(
		.wr_clk_i		(axi_clk),
		.a_rst_i	 	(w_rfifo_rst), 
		.wr_en_i		(axi_rvalid && axi_rready),
		.wdata		(axi_rdata),
		.full_o 		(), 
		.prog_full_o	(w_rfifo_wfull),
		
		.rd_clk_i		(rframe_pclk),
		//.rd_rst		(w_rfifo_rst), 
		.rd_en_i		(w_rframe_data_en_fifo),
		.rdata		(w_rframe_data_gen),
		.empty_o		(w_rfifo_empty),
		.prog_empty_o	(w_rfifo_aempty)
	);
	
	//	Assert DV when ~empty. 
	assign rframe_data_valid = ~w_rfifo_empty; 
	
	//	Assert RD only when ~empty. 
	wire 				w_rframe_data_en = rframe_data_en & rframe_data_valid; 
	
	
	//	The FIFO must be FWFT type. Load data on first cycle. 
	localparam RFIFO_CNT_SIZE = (C_R_WIDTH == 8) ? 4 : (((C_R_WIDTH == 16) || (C_R_WIDTH == 24)) ? 3 : ((C_R_WIDTH == 32) ? 2 : 1)); 
	reg 	[RFIFO_CNT_SIZE-1:0] 	rc_rfifo_rd = 0; 
	wire 	[RFIFO_CNT_SIZE-1:0] 	w_rfifo_rend = {RFIFO_CNT_SIZE{1'b1}}; 
	always @(posedge rframe_pclk or posedge w_rfifo_rst) begin
		if(w_rfifo_rst) begin
			rc_rfifo_rd <= 0; 
		end else begin
			if(w_rframe_data_en) begin
				if(C_R_WIDTH == 24) begin
					if(rc_rfifo_rd >= 4)
						rc_rfifo_rd <= 0; 
					else
						rc_rfifo_rd <= rc_rfifo_rd + 1; 
				end else begin
					rc_rfifo_rd <= rc_rfifo_rd + 1; 
				end
			end
		end
	end
	
	//	Load data from FIFO on first cycle. 
	assign w_rframe_data_en_load = w_rframe_data_en && (rc_rfifo_rd == 0); 
	//	Read FIFO data on last cycle. 
	assign w_rframe_data_en_fifo = w_rframe_data_en && (rc_rfifo_rd == ((C_R_WIDTH == 24) ? 4 : w_rfifo_rend));  
	
	reg 	[C_DATA_LEN-1:0] 	r_rframe_data_gen = 0; 
	always @(posedge rframe_pclk) begin
		if(w_rframe_data_en_load) begin
			r_rframe_data_gen <= w_rframe_data_gen; 
		end else if(w_rframe_data_en) begin
			r_rframe_data_gen <= r_rframe_data_gen >> C_R_WIDTH; 
		end else begin
		end
	end
	assign rframe_data = r_rframe_data_gen; 
	
	
	
	
	
	
	
	
	
endmodule
