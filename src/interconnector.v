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
	
	localparam S_PORTS    = 4;    // Number of Slave Ports
	localparam DATA_WIDTH = 128;  // Data Width for AXI interfaces
	localparam ADDR_WIDTH = 32;   // Address Width for AXI interfaces
	localparam M_PORTS    = 1;    // Number of Master Ports
	localparam ID_WIDTH   = 8;    // ID Width for transactions
	localparam USER_WIDTH = 3;    // User signal width (optional for AXI)


	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	HyperRAM Controller
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//	General AXI Interface 
	wire	[3:0] 	w_hbram_awid;
	wire	[31:0]	w_hbram_awaddr;
	wire	[7:0]		w_hbram_awlen;
	wire			w_hbram_awvalid;
	wire			w_hbram_awready;

	wire	[3:0] 	cmos_aw_id = 0;
	wire	[31:0]	cmos_aw_addr;
	wire	[7:0]	cmos_aw_len;
	wire			cmos_aw_valid;
	wire			cmos_aw_ready;
		
	wire	[3:0] 	dsamp_aw_id = 0;
	wire	[31:0]	dsamp_aw_addr = 0;
	wire	[7:0]	dsamp_aw_len = 0;
	wire			dsamp_aw_valid = 0;
	wire			dsamp_aw_ready;
	
	wire	[3:0] 	blur_aw_id = 0;
	wire	[31:0]	blur_aw_addr = 0;
	wire	[7:0]	blur_aw_len = 0;
	wire			blur_aw_valid = 0;
	wire			blur_aw_ready;
	
	wire	[3:0] 	lcd_aw_id = 0;
	wire	[31:0]	lcd_aw_addr = 0;
	wire	[7:0]	lcd_aw_len = 0;
	wire			lcd_aw_valid = 0;
	wire			lcd_aw_ready;
	
	wire 	[3:0]  	w_hbram_wid;
	wire 	[127:0] 	w_hbram_wdata;
	wire 	[15:0]	w_hbram_wstrb;
	wire			w_hbram_wlast;
	wire			w_hbram_wvalid;
	wire			w_hbram_wready;

	wire 	[3:0]  	cmos_w_id = 0;
	wire 	[127:0] cmos_w_data;
	wire 	[15:0]	cmos_w_strb;
	wire			cmos_w_last;
	wire			cmos_w_valid;
	wire			cmos_w_ready;


	wire 	[3:0]  	dsamp_w_id		=0;
	wire 	[127:0] dsamp_w_data=0;
	wire 	[15:0]	dsamp_w_strb = 16'hFFFF;
	wire			dsamp_w_last	=0;
	wire			dsamp_w_valid	=0;
	wire			dsamp_w_ready	;

	wire 	[3:0]  	blur_w_id		=0;
	wire 	[127:0] blur_w_data=0;
	wire 	[15:0]	blur_w_strb = 16'hFFFF;
	wire			blur_w_last	=0;
	wire			blur_w_valid	=0;
	wire			blur_w_ready	;

	wire 	[3:0]  	lcd_w_id		=0;
	wire 	[127:0] lcd_w_data	=0;
	wire 	[15:0]	lcd_w_strb = 16'hFFFF;
	wire			lcd_w_last		=0;
	wire			lcd_w_valid	=0;
	wire			lcd_w_ready	;
	
	wire 	[3:0] 	w_hbram_bid;
	wire 	[1:0] 	w_hbram_bresp;
	wire			w_hbram_bvalid;
	wire			w_hbram_bready;
	
	wire	[3:0] 	w_hbram_arid;
	wire	[31:0]	w_hbram_araddr;
	wire	[7:0]		w_hbram_arlen;
	wire			w_hbram_arvalid;
	wire			w_hbram_arready;

	wire	[3:0] 	cmos_ar_id;
	wire	[31:0]	cmos_ar_addr;
	wire	[7:0]	cmos_ar_len;
	wire			cmos_ar_valid;
	wire			cmos_ar_ready;
		
	wire	[3:0] 	dsamp_ar_id = 0;
	wire	[31:0]	dsamp_ar_addr = 0;
	wire	[7:0]	dsamp_ar_len = 0;
	wire			dsamp_ar_valid = 0;
	wire			dsamp_ar_ready;
	
	wire	[3:0] 	blur_ar_id = 0;
	wire	[31:0]	blur_ar_addr = 0;
	wire	[7:0]	blur_ar_len = 0;
	wire			blur_ar_valid = 0;
	wire			blur_ar_ready;
	
	wire	[3:0] 	lcd_ar_id = 0;
	wire	[31:0]	lcd_ar_addr = 0;
	wire	[7:0]	lcd_ar_len = 0;
	wire			lcd_ar_valid = 0;
	wire			lcd_ar_ready;
	
	wire 	[3:0] 	w_hbram_rid;
	wire 	[127:0] 	w_hbram_rdata;
	wire			w_hbram_rlast;
	wire			w_hbram_rvalid;
	wire			w_hbram_rready;
	wire 	[1:0] 	w_hbram_rresp;

	wire 	[3:0] 	cmos_r_id;
	wire 	[127:0] cmos_r_data;
	wire			cmos_r_last;
	wire			cmos_r_valid;
	wire			cmos_r_ready;
	wire 	[1:0] 	cmos_r_resp;
	
	wire 	[3:0] 	dsamp_r_id;
	wire 	[127:0] dsamp_r_data;
	wire			dsamp_r_last;
	wire			dsamp_r_valid;
	wire			dsamp_r_ready = 0;
	wire 	[1:0] 	dsamp_r_resp;

	wire 	[3:0] 	blur_r_id;
	wire 	[127:0] blur_r_data;
	wire			blur_r_last;
	wire			blur_r_valid;
	wire			blur_r_ready = 0;
	wire 	[1:0] 	blur_r_resp;

	wire 	[3:0] 	lcd_r_id;
	wire 	[127:0] lcd_r_data;
	wire			lcd_r_last;
	wire			lcd_r_valid;
	wire			lcd_r_ready = 0;
	wire 	[1:0] 	lcd_r_resp;
	
	//	AXI Interface Request
	wire 	[3:0] 	w_hbram_aid;
	wire 	[31:0] 	w_hbram_aaddr;
	wire 	[7:0]  	w_hbram_alen;
	wire 	[2:0]  	w_hbram_asize;
	wire 	[2:0]  	w_hbram_awsize;
	wire 	[2:0]  	w_hbram_arsize;
	wire 	[1:0]  	w_hbram_aburst;
	wire 	[1:0]  	w_hbram_alock;
	wire			w_hbram_avalid;
	wire			w_hbram_aready;
	wire			w_hbram_atype;
	
	wire 			w_hbram_cal_pass; 
	wire 			w_hbram_cal_done = w_hbram_cal_pass; 
	wire 	[15:0] 	w_hbram_cal_dbg; 
	
	assign w_dev_rdata_i = {w_hbram_cal_dbg, 15'h0, w_hbram_cal_pass}; 

	wire [S_PORTS-1:0]              s_axi_awvalid   ; // 写地址有效信号
	wire [S_PORTS*ADDR_WIDTH-1:0]   s_axi_awaddr    ; // 写地址
	wire [S_PORTS*2-1:0]            s_axi_awlock    ; // 锁信号
	wire [S_PORTS-1:0]              s_axi_awready   ; // 写地址准备好信号
	wire [S_PORTS*ID_WIDTH-1:0]     s_axi_awid      ; // 写请求ID
	wire [S_PORTS*2-1:0]            s_axi_awburst   ; // 突发类型
	wire [S_PORTS*3-1:0]            s_axi_awsize    ; // 突发传输大小
	wire [S_PORTS*ID_WIDTH-1:0]     s_axi_awlen     ; // 突发传输长度

	wire [S_PORTS-1:0]              s_axi_wvalid    ; // 写数据有效信号
	wire [S_PORTS-1:0]              s_axi_wlast     ; // 最后一次写数据信号
	wire [S_PORTS*ID_WIDTH-1:0]     s_axi_wid       ; // 写数据ID
	wire [S_PORTS*DATA_WIDTH-1:0] 	s_axi_wdata     ; // 写入的数据
	wire [S_PORTS*DATA_WIDTH/8-1:0] s_axi_wstrb     ; // 字节选通
	wire [S_PORTS-1:0]              s_axi_wready    ; // 写数据准备好信号

	wire [S_PORTS-1:0]              s_axi_bvalid    ; // 写响应有效信号
	wire [S_PORTS-1:0]              s_axi_bready    ; // 写响应准备好信号
	wire [S_PORTS*ID_WIDTH-1:0]     s_axi_bid       ; // 写响应ID
	wire [S_PORTS*2-1:0]            s_axi_bresp     ; // 写响应

	wire [S_PORTS-1:0]              s_axi_arvalid   ; // 读地址有效信号
	wire [S_PORTS*ADDR_WIDTH-1:0]   s_axi_araddr    ; // 读地址
	wire [S_PORTS*2-1:0]            s_axi_arlock    ; // 锁信号
	wire [S_PORTS-1:0]              s_axi_arready   ; // 读地址准备好信号
	wire [S_PORTS*ID_WIDTH-1:0]     s_axi_arid      ; // 读请求ID
	wire [S_PORTS*2-1:0]            s_axi_arburst   ; // 突发类型
	wire [S_PORTS*3-1:0]            s_axi_arsize    ; // 突发传输大小
	wire [S_PORTS*8-1:0]     		s_axi_arlen     ; // 突发传输长度

	wire [S_PORTS-1:0]              s_axi_rvalid    ; // 读数据有效信号
	wire [S_PORTS-1:0]              s_axi_rlast     ; // 最后一次读数据信号
	wire [S_PORTS-1:0]              s_axi_rready    ; // 读数据准备好信号
	wire [S_PORTS*ID_WIDTH-1:0]     s_axi_rid       ; // 读数据ID
	wire [S_PORTS*DATA_WIDTH*4-1:0] s_axi_rdata     ; // 读取的数据
	wire [S_PORTS*2-1:0]            s_axi_rresp     ; // 读响应

	wire [M_PORTS*2-1:0]            m_axi_awlock    ; // 锁信号
	wire [M_PORTS*4-1:0]            m_axi_awprot    ; // 保护类型

	wire [M_PORTS-1:0]              m_axi_bvalid    ; // 写响应有效信号
	wire [M_PORTS-1:0]              m_axi_bready    ; // 写响应准备好信号
	wire [M_PORTS*ID_WIDTH-1:0]     m_axi_bid       ; // 写响应ID
	wire [M_PORTS*2-1:0]            m_axi_bresp     ; // 写响应

	wire [M_PORTS*2-1:0]            m_axi_arlock    ; // 锁信号
	wire [M_PORTS*4-1:0]            m_axi_arprot    ; // 保护类型

	assign s_axi_wid  = {lcd_w_id,blur_w_id,dsamp_w_id,cmos_w_id};
	assign {lcd_w_ready,blur_w_ready,dsamp_w_ready,cmos_w_ready} = s_axi_wready;
	assign s_axi_wvalid = {lcd_w_valid,blur_w_valid,dsamp_w_valid,cmos_w_valid};
	assign s_axi_wdata  = {lcd_w_data,blur_w_data,dsamp_w_data,cmos_w_data};
	assign s_axi_wlast  = {lcd_w_last,blur_w_last,dsamp_w_last,cmos_w_last};
	assign s_axi_wstrb  = {lcd_w_strb,blur_w_strb,dsamp_w_strb,cmos_w_strb};
	
	assign {lcd_r_valid,blur_r_valid,dsamp_r_valid,cmos_r_valid} = s_axi_rvalid  ;
	assign {lcd_r_data,blur_r_data,dsamp_r_data,cmos_r_data} = s_axi_rdata   ;
	assign {lcd_r_last,blur_r_last,dsamp_r_last,cmos_r_last} = s_axi_rlast   ;
	assign s_axi_rready = {lcd_r_ready,blur_r_ready,dsamp_r_ready,cmos_r_ready};
	assign {lcd_r_resp,blur_r_resp,dsamp_r_resp,cmos_r_resp}  = s_axi_rresp;
	assign {lcd_r_id,blur_r_id,dsamp_r_id,cmos_r_id}  = s_axi_rid;
	
	assign s_axi_awid = {lcd_aw_id,blur_aw_id,dsamp_aw_id,cmos_aw_id};
	assign {lcd_aw_ready,blur_aw_ready,dsamp_aw_ready,cmos_aw_ready} = s_axi_awready;
	assign s_axi_awvalid = {lcd_aw_valid,blur_aw_valid,dsamp_aw_valid,cmos_aw_valid};
	assign s_axi_awaddr  = {lcd_aw_addr,blur_aw_addr,dsamp_aw_addr,cmos_aw_addr};
	assign s_axi_awlen  = {lcd_aw_len,blur_aw_len,dsamp_aw_len,cmos_aw_len};
	
	assign s_axi_arid 	 = {lcd_ar_id,blur_ar_id,dsamp_ar_id,cmos_ar_id};
	assign s_axi_arvalid = {lcd_ar_valid,blur_ar_valid,dsamp_ar_valid,cmos_ar_valid};
	assign s_axi_araddr  = {lcd_ar_addr,blur_ar_addr,dsamp_ar_addr,cmos_ar_addr};
	assign s_axi_arlen  = {lcd_ar_len,blur_ar_len,dsamp_ar_len,cmos_ar_len};
	assign {lcd_ar_ready,blur_ar_ready,dsamp_ar_ready,cmos_ar_ready} = s_axi_arready;

	assign m_axi_bresp   = 0;
	assign s_axi_bready  = 1'b1;
	assign s_axi_awlock  = 0;
	assign s_axi_arlock  = 0;
	assign s_axi_awsize  = 4; 		//	Fixed 128 bits (16 bytes, size = 4) 
	assign s_axi_arsize  = 4; 		//	Fixed 128 bits (16 bytes, size = 4) 
	assign s_axi_awburst = 1'b1;
	assign s_axi_arburst = 1'b1;
	assign w_hbram_asize = (w_hbram_atype)?w_hbram_awsize:w_hbram_arsize;
	assign w_hbram_alock = (w_hbram_atype)?m_axi_awlock:m_axi_arlock;

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

	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DDR R/W Control
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	
	axi4_ctrl #(.C_RD_END_ADDR(1280 * 720), .C_W_WIDTH(CSI_DATA_WIDTH), .C_R_WIDTH(8), .C_ID_LEN(4)) u_axi4_ctrl (
	//axi4_ctrl #(.C_RD_END_ADDR(1920 * 1080), .C_W_WIDTH(CSI_DATA_WIDTH), .C_R_WIDTH(8), .C_ID_LEN(4)) u_axi4_ctrl (

		.axi_clk        (sys_clk_i       ),
		.axi_reset      (w_sys_rst       ),

		.axi_awaddr     (cmos_aw_addr       ),
		.axi_awlen      (cmos_aw_len        ),
		.axi_awvalid    (cmos_aw_valid      ),
		.axi_awready    (cmos_aw_ready      ),

		.axi_wdata      (cmos_w_data        ),
		.axi_wstrb      (cmos_w_strb        ),
		.axi_wlast      (cmos_w_last        ),
		.axi_wvalid     (cmos_w_valid       ),
		.axi_wready     (cmos_w_ready       ),

		.axi_bid        (0          ),
		.axi_bresp      (0        ),
		.axi_bvalid     (1       ),

		.axi_arid       (cmos_ar_id         ),
		.axi_araddr     (cmos_ar_addr       ),
		.axi_arlen      (cmos_ar_len        ),
		.axi_arvalid    (cmos_ar_valid      ),
		.axi_arready    (cmos_ar_ready      ),

		.axi_rid        (cmos_r_id          ),
		.axi_rdata      (cmos_r_data        ),
		.axi_rresp      (cmos_r_resp        ),
		.axi_rlast      (cmos_r_last        ),
		.axi_rvalid     (cmos_r_valid       ),
		.axi_rready     (cmos_r_ready		  ),

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

	hbram_interconnect  u_hbram_interconnect (
    	.rst_n           ( ~w_sys_rst       ),
    	.clk             ( sys_clk_i        ),

    	// Slave AXI Interface (s_axi)
    	// Write Address Channel (AW)
    	.s_axi_awvalid   ( s_axi_awvalid    ),
    	.s_axi_awaddr    ( s_axi_awaddr     ),
    	.s_axi_awlock    ( s_axi_awlock     ),
    	.s_axi_awready   ( s_axi_awready    ),
    	.s_axi_awid      ( s_axi_awid       ),
    	.s_axi_awburst   ( s_axi_awburst    ),
    	.s_axi_awsize    ( s_axi_awsize     ),
    	.s_axi_awlen     ( s_axi_awlen      ),

    	// Write Data Channel (W)
    	.s_axi_wvalid    ( s_axi_wvalid     ),
    	.s_axi_wlast     ( s_axi_wlast      ),
    	.s_axi_wid       ( s_axi_wid        ),
    	.s_axi_wdata     ( s_axi_wdata      ),
    	.s_axi_wstrb     ( s_axi_wstrb      ),
    	.s_axi_wready    ( s_axi_wready     ),

    	// Write Response Channel (B)
    	.s_axi_bvalid    ( s_axi_bvalid     ),//
    	.s_axi_bready    ( s_axi_bready     ),
    	.s_axi_bid       ( s_axi_bid        ),//
    	.s_axi_bresp     ( s_axi_bresp      ),//

    	// Read Address Channel (AR)
    	.s_axi_arvalid   ( s_axi_arvalid    ),
    	.s_axi_araddr    ( s_axi_araddr     ),
    	.s_axi_arlock    ( s_axi_arlock     ),
    	.s_axi_arready   ( s_axi_arready    ),
    	.s_axi_arid      ( s_axi_arid       ),
    	.s_axi_arburst   ( s_axi_arburst    ),//
    	.s_axi_arsize    ( s_axi_arsize     ),//后续需要改成动态的
    	.s_axi_arlen     ( s_axi_arlen      ),//

    	// Read Data Channel (R)
    	.s_axi_rvalid    ( s_axi_rvalid     ),
    	.s_axi_rlast     ( s_axi_rlast      ),
    	.s_axi_rready    ( s_axi_rready     ),
    	.s_axi_rid       ( s_axi_rid        ),
    	.s_axi_rdata     ( s_axi_rdata      ),
    	.s_axi_rresp     ( s_axi_rresp      ),

    	// Master AXI Interface (m_axi)
    	// Write Address Channel (AW)
    	.m_axi_awvalid   ( w_hbram_awvalid  ),
    	.m_axi_awaddr    ( w_hbram_awaddr   ),
    	.m_axi_awlock    ( m_axi_awlock     ),
    	.m_axi_awready   ( w_hbram_awready  ),
    	.m_axi_awid      ( w_hbram_awid	    ),
    	.m_axi_awburst   ( w_hbram_aburst   ),
    	.m_axi_awsize    ( w_hbram_awsize    ),
    	.m_axi_awlen     ( w_hbram_awlen    ),
    	.m_axi_awprot    ( m_axi_awprot     ),//优先级

    	// Write Data Channel (W)
    	.m_axi_wvalid    ( w_hbram_wvalid   ),
    	.m_axi_wlast     ( w_hbram_wlast    ),
    	.m_axi_wid       ( w_hbram_wid      ),
    	.m_axi_wdata     ( w_hbram_wdata    ),
    	.m_axi_wstrb     ( w_hbram_wstrb    ),
    	.m_axi_wready    ( w_hbram_wready   ),

    	// Write Response Channel (B)
    	.m_axi_bvalid    ( w_hbram_bvalid   ),
    	.m_axi_bready    ( w_hbram_bready   ),
    	.m_axi_bid       ( w_hbram_bid      ),
    	.m_axi_bresp     ( m_axi_bresp      ),

    	// Read Address Channel (AR)
    	.m_axi_arvalid   ( w_hbram_arvalid  ),
    	.m_axi_araddr    ( w_hbram_araddr   ),
    	.m_axi_arlock    ( m_axi_arlock     ),
    	.m_axi_arready   ( w_hbram_arready  ),
    	.m_axi_arid      ( w_hbram_arid     ),
    	.m_axi_arburst   ( w_hbram_aburst   ),
    	.m_axi_arsize    ( w_hbram_arsize     ),
    	.m_axi_arlen     ( w_hbram_arlen    ),
    	.m_axi_arprot    ( m_axi_arprot     ),

    	// Read Data Channel (R)
    	.m_axi_rvalid    ( w_hbram_rvalid     ),
    	.m_axi_rlast     ( w_hbram_rlast      ),
    	.m_axi_rready    ( w_hbram_rready     ),
    	.m_axi_rid       ( w_hbram_rid        ),
    	.m_axi_rdata     ( w_hbram_rdata      ),
    	.m_axi_rresp     ( w_hbram_rresp      )
	);

endmodule