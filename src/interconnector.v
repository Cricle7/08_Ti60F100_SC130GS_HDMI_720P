module inter_connector # (
    parameter                   TOP_DBW = 16,
    parameter                   CSI_DATA_WIDTH = 64
)(
// =============== Global Reset ============================
    input  wire                 w_sys_rst,
// =============== PLL Phase Settings ======================
    input  wire                 sys_clk_i,
    input  wire                 hbramClk,
    input  wire                 hbramClk_Cal,
// =============== PLL Phase Settings ======================
    output wire [2:0]           hbramClk_shift,
    output wire [4:0]           hbramClk_shift_sel,
    output wire                 hbramClk_shift_ena,
// =============== HBRAM Related Signals ===================
    output wire                 hbram_RST_N,
    output wire                 hbram_CS_N,
    output wire                 hbram_CK_P_HI,
    output wire                 hbram_CK_P_LO,
    output wire                 hbram_CK_N_HI,
    output wire                 hbram_CK_N_LO,
    output wire [TOP_DBW/8-1:0] hbram_RWDS_OUT_HI,
    output wire [TOP_DBW/8-1:0] hbram_RWDS_OUT_LO,
    input  wire [TOP_DBW/8-1:0] hbram_RWDS_IN_HI,
    input  wire [TOP_DBW/8-1:0] hbram_RWDS_IN_LO,
    input  wire [TOP_DBW-1:0]   hbram_DQ_IN_LO,
    input  wire [TOP_DBW-1:0]   hbram_DQ_IN_HI,
    output wire [TOP_DBW/8-1:0] hbram_RWDS_OE,
    output wire [TOP_DBW-1:0]   hbram_DQ_OUT_HI,
    output wire [TOP_DBW-1:0]   hbram_DQ_OUT_LO,
    output wire [TOP_DBW-1:0]   hbram_DQ_OE,
// =============== input and outut Signal ===================
    output wire [31:0]          w_dev_rdata_i,
    input  wire                 w_csi_rx_clk,
    input  wire                 cmos_frame_vsync,
    input  wire                 cmos_frame_href,
    input  wire [63:0]          cmos_frame_Gray,
    input  wire                 w_pixel_clk,
    input  wire                 lcd_vs,
    input  wire                 lcd_request,
    output wire [15:0]          lcd_data 
);
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	HyperRAM Controller
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//	General AXI Interface 
	wire	[3:0] 	w_hbram_awid;
	wire	[31:0]	w_hbram_awaddr;
	wire	[7:0]		w_hbram_awlen;
	wire			w_hbram_awvalid;
	wire			w_hbram_awready;
	
	wire 	[3:0]  	w_hbram_wid;
	wire 	[127:0] 	w_hbram_wdata;
	wire 	[15:0]	w_hbram_wstrb;
	wire			w_hbram_wlast;
	wire			w_hbram_wvalid;
	wire			w_hbram_wready;
	
	wire 	[3:0] 	w_hbram_bid;
	wire 	[1:0] 	w_hbram_bresp;
	wire			w_hbram_bvalid;
	wire			w_hbram_bready;
	
	wire	[3:0] 	w_hbram_arid;
	wire	[31:0]	w_hbram_araddr;
	wire	[7:0]		w_hbram_arlen;
	wire			w_hbram_arvalid;
	wire			w_hbram_arready;
	
	wire 	[3:0] 	w_hbram_rid;
	wire 	[127:0] 	w_hbram_rdata;
	wire			w_hbram_rlast;
	wire			w_hbram_rvalid;
	wire			w_hbram_rready;
	wire 	[1:0] 	w_hbram_rresp;
	
	//	AXI Interface Request
	wire 	[3:0] 	w_hbram_aid;
	wire 	[31:0] 	w_hbram_aaddr;
	wire 	[7:0]  	w_hbram_alen;
	wire 	[2:0]  	w_hbram_asize;
	wire 	[1:0]  	w_hbram_aburst;
	wire 	[1:0]  	w_hbram_alock;
	wire			w_hbram_avalid;
	wire			w_hbram_aready;
	wire			w_hbram_atype;
	
	wire 			w_hbram_cal_pass; 
	wire 			w_hbram_cal_done = w_hbram_cal_pass; 
	wire 	[15:0] 	w_hbram_cal_dbg; 
	
	assign w_dev_rdata_i = {w_hbram_cal_dbg, 15'h0, w_hbram_cal_pass}; 
	
	hbram u_hbram (		
		.ram_clk			(hbramClk),			//	input ram_clk,
		.ram_clk_cal		(hbramClk_Cal),		//	input ram_clk_cal,
		.io_axi_clk			(sys_clk_i),		//	input io_axi_clk,
		.rst				(w_sys_rst),	//	input rst,
		
		.hbc_cal_SHIFT_SEL	(hbramClk_shift_sel),	//	output [4:0] hbc_cal_SHIFT_SEL,
		.hbc_cal_SHIFT		(hbramClk_shift),		//	output [2:0] hbc_cal_SHIFT,
		.hbc_cal_SHIFT_ENA	(hbramClk_shift_ena),	//	output hbc_cal_SHIFT_ENA,
		.hbc_cal_debug_info	(w_hbram_cal_dbg),		//	output [15:0] hbc_cal_debug_info,
		.hbc_cal_pass		(w_hbram_cal_pass),	//	output hbc_cal_pass,
		
		.dyn_pll_phase_sel	(0),				//	input [2:0] dyn_pll_phase_sel,
		.dyn_pll_phase_en		(0),				//	input dyn_pll_phase_en,
		
		.io_arw_payload_addr	(w_hbram_aaddr),		//	input [31:0] io_arw_payload_addr,
		.io_arw_payload_id	(w_hbram_aid),		//	input [7:0] io_arw_payload_id,
		.io_arw_payload_len	(w_hbram_alen),		//	input [7:0] io_arw_payload_len,
		.io_arw_payload_size	(w_hbram_asize),		//	input [2:0] io_arw_payload_size,
		.io_arw_payload_burst	(w_hbram_aburst),		//	input [1:0] io_arw_payload_burst,
		.io_arw_payload_lock	(w_hbram_alock),		//	input [1:0] io_arw_payload_lock,
		.io_arw_payload_write	(w_hbram_atype),		//	input io_arw_payload_write, 		//	0:Read. 1:Write
		.io_arw_valid		(w_hbram_avalid),		//	input io_arw_valid,
		.io_arw_ready		(w_hbram_aready),		//	output io_arw_ready,
			
		.io_w_payload_id		(w_hbram_wid),		//	input [7:0] io_w_payload_id,
		.io_w_payload_data	(w_hbram_wdata),		//	input [127:0] io_w_payload_data,
		.io_w_payload_strb	(w_hbram_wstrb),		//	input [15:0] io_w_payload_strb,
		.io_w_payload_last 	(w_hbram_wlast),		//	input io_w_payload_last,	
		.io_w_valid			(w_hbram_wvalid),		//	input io_w_valid,
		.io_w_ready			(w_hbram_wready),		//	output io_w_ready,
		
		.io_b_payload_id		(w_hbram_bid),		//	output [7:0] io_b_payload_id,
		.io_b_valid			(w_hbram_bvalid),		//	output io_b_valid,
		.io_b_ready			(w_hbram_bready),		//	input io_b_ready,

		.io_r_payload_id		(w_hbram_rid),		//	output [7:0] io_r_payload_id,
		.io_r_payload_data	(w_hbram_rdata),		//	output [127:0] io_r_payload_data,
		.io_r_payload_last	(w_hbram_rlast),		//	output io_r_payload_last,
		.io_r_payload_resp	(w_hbram_rresp),		//	output [1:0] io_r_payload_resp
		.io_r_valid			(w_hbram_rvalid),		//	output io_r_valid,
		.io_r_ready			(w_hbram_rready),		//	input io_r_ready,
		
		.hbc_ck_p_HI		(hbram_CK_P_HI),		//	output hbc_ck_p_HI,
		.hbc_ck_p_LO		(hbram_CK_P_LO),		//	output hbc_ck_p_LO,
		.hbc_ck_n_HI		(hbram_CK_N_HI),		//	output hbc_ck_n_HI,
		.hbc_ck_n_LO		(hbram_CK_N_LO),		//	output hbc_ck_n_LO,
		.hbc_cs_n			(hbram_CS_N),		//	output hbc_cs_n,
		.hbc_rst_n			(hbram_RST_N),		//outtput hbc_rst_n,

		.hbc_dq_OUT_HI		(hbram_DQ_OUT_HI),	//	output [15:0] hbc_dq_OUT_HI,
		.hbc_dq_OUT_LO		(hbram_DQ_OUT_LO),	//	output [15:0] hbc_dq_OUT_LO,
		.hbc_dq_OE			(hbram_DQ_OE),		//	output [15:0] hbc_dq_OE,
		.hbc_dq_IN_HI		(hbram_DQ_IN_HI),		//	input [15:0] hbc_dq_IN_HI,
		.hbc_dq_IN_LO		(hbram_DQ_IN_LO),		//	input [15:0] hbc_dq_IN_LO,
		
		.hbc_rwds_OUT_HI		(hbram_RWDS_OUT_HI),	//	output [1:0] hbc_rwds_OUT_HI,
		.hbc_rwds_OUT_LO		(hbram_RWDS_OUT_LO),	//	output [1:0] hbc_rwds_OUT_LO,
		.hbc_rwds_OE		(hbram_RWDS_OE),		//	output [1:0] hbc_rwds_OE,
		.hbc_rwds_IN_HI		(hbram_RWDS_IN_HI),	//	input [1:0] hbc_rwds_IN_HI,
		.hbc_rwds_IN_LO		(hbram_RWDS_IN_LO)	//	input [1:0] hbc_rwds_IN_LO,
	);
	assign w_hbram_bready = 1'b1; 
	

	AXI4_AWARMux #(.AID_LEN(4), .AADDR_LEN(32)) axi4_awar_mux (
		.aclk_i			(sys_clk_i), 
		.arst_i			(w_sys_rst), 
		
		.awid_i			(w_hbram_awid),
		.awaddr_i			(w_hbram_awaddr),
		.awlen_i			(w_hbram_awlen),
		//.awvalid_i			(w_hbram_awvalid && w_hbram_cal_pass),
		.awvalid_i			(w_hbram_awvalid ),
		.awready_o			(w_hbram_awready),
		
		.arid_i			(w_hbram_arid),
		.araddr_i			(w_hbram_araddr),
		.arlen_i			(w_hbram_arlen),
		//.arvalid_i			(w_hbram_arvalid && w_hbram_cal_pass),
		.arvalid_i			(w_hbram_arvalid ),
		.arready_o			(w_hbram_arready),
		
		.aid_o			(w_hbram_aid),
		.aaddr_o			(w_hbram_aaddr),
		.alen_o			(w_hbram_alen),
		.atype_o			(w_hbram_atype),
		.avalid_o			(w_hbram_avalid),
		.aready_i			(w_hbram_aready)
	);

	assign w_hbram_asize = 4; 		//	Fixed 128 bits (16 bytes, size = 4)
	assign w_hbram_aburst = 1; 
	assign w_hbram_alock = 0; 
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DDR R/W Control
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	
	axi4_ctrl #(.C_RD_END_ADDR(1280 * 720), .C_W_WIDTH(CSI_DATA_WIDTH), .C_R_WIDTH(8), .C_ID_LEN(4)) u_axi4_ctrl (
	//axi4_ctrl #(.C_RD_END_ADDR(1920 * 1080), .C_W_WIDTH(CSI_DATA_WIDTH), .C_R_WIDTH(8), .C_ID_LEN(4)) u_axi4_ctrl (

		.axi_clk        (sys_clk_i       ),
		.axi_reset      (w_sys_rst       ),

		.axi_awaddr     (w_hbram_awaddr       ),
		.axi_awlen      (w_hbram_awlen        ),
		.axi_awvalid    (w_hbram_awvalid      ),
		.axi_awready    (w_hbram_awready      ),

		.axi_wdata      (w_hbram_wdata        ),
		.axi_wstrb      (w_hbram_wstrb        ),
		.axi_wlast      (w_hbram_wlast        ),
		.axi_wvalid     (w_hbram_wvalid       ),
		.axi_wready     (w_hbram_wready       ),

		.axi_bid        (0          ),
		.axi_bresp      (0        ),
		.axi_bvalid     (1       ),

		.axi_arid       (w_hbram_arid         ),
		.axi_araddr     (w_hbram_araddr       ),
		.axi_arlen      (w_hbram_arlen        ),
		.axi_arvalid    (w_hbram_arvalid      ),
		.axi_arready    (w_hbram_arready      ),

		.axi_rid        (w_hbram_rid          ),
		.axi_rdata      (w_hbram_rdata        ),
		.axi_rresp      (0        ),
		.axi_rlast      (w_hbram_rlast        ),
		.axi_rvalid     (w_hbram_rvalid       ),
		.axi_rready     (w_hbram_rready		  ),

		.wframe_pclk    (w_csi_rx_clk          ),
		.wframe_vsync   (cmos_frame_vsync), 	//w_wframe_vsync   ),		//	Writter VSync. Flush on rising edge. Connect to EOF. 
		.wframe_data_en (cmos_frame_href   ),
		.wframe_data    (cmos_frame_Gray),
		
		.rframe_pclk    (w_pixel_clk            ),
		//.rframe_vsync   (lcd_vs             ),		//	Reader VSync. Flush on rising edge. Connect to ~EOF. 
		.rframe_vsync   (lcd_vs             ),		//	Reader VSync. Flush on rising edge. Connect to ~EOF.
		.rframe_data_en (lcd_request             ),
		.rframe_data    (lcd_data           ),
		
		.tp_o 		()
	);
	assign w_hbram_awid = 0; 
	assign w_hbram_wid = 0; 

endmodule