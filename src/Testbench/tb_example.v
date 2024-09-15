`timescale 1ns/1ps

module tb_example_top;

    // Testbench signals
    reg hbramClk;
    reg hbramClk90;
    reg hbramClk_Cal;
    reg hbramClk_pll_lock;
    reg hdmi_pixel_10x;
    reg hdmi_pixel;
    reg sensor_xclk_i;
    reg sys_clk_i;
    reg hdmi_pll_lock;
    reg dsi_serclk_i;
    reg dsi_txcclk_i;
    reg dsi_byteclk_i;
    reg dsi_fb_i;
    reg dsi_pll_lock;
    reg uart_rx_i;
    reg spi_mosi_d0_i;
    reg spi_miso_d1_i;
    reg spi_wpn_d2_i;
    reg spi_holdn_d3_i;
    reg csi_trig_i;
    reg csi2_sda_i;
    reg csi_rxc_lp_p_i;
    reg csi_rxc_lp_n_i;
    reg csi_rxc_i;
    reg csi_rxd0_lp_p_i;
    reg csi_rxd0_lp_n_i;
    reg [7:0] csi_rxd0_hs_i;
    reg csi_rxd1_lp_p_i;
    reg csi_rxd1_lp_n_i;
    reg [7:0] csi_rxd1_hs_i;
    reg csi_rxd2_lp_p_i;
    reg csi_rxd2_lp_n_i;
    reg [7:0] csi_rxd2_hs_i;
    reg csi_rxd3_lp_p_i;
    reg csi_rxd3_lp_n_i;
    reg [7:0] csi_rxd3_hs_i;
    reg csi2_rxc_lp_p_i;
    reg csi2_rxc_lp_n_i;
    reg csi2_rxc_i;
    reg csi2_rxd0_lp_p_i;
    reg csi2_rxd0_lp_n_i;
    reg [7:0] csi2_rxd0_hs_i;
    reg csi2_rxd1_lp_p_i;
    reg csi2_rxd1_lp_n_i;
    reg [7:0] csi2_rxd1_hs_i;
    reg csi2_rxd2_lp_p_i;
    reg csi2_rxd2_lp_n_i;
    reg [7:0] csi2_rxd2_hs_i;
    reg csi2_rxd3_lp_p_i;
    reg csi2_rxd3_lp_n_i;
    reg [7:0] csi2_rxd3_hs_i;
    reg dsi_txd0_lp_p_i;
    reg dsi_txd0_lp_n_i;
    reg dsi_txd1_lp_p_i;
    reg dsi_txd1_lp_n_i;
    reg dsi_txd2_lp_p_i;
    reg dsi_txd2_lp_n_i;
    reg dsi_txd3_lp_p_i;
    reg dsi_txd3_lp_n_i;
    reg csi_tx_scl_i;
    reg csi_tx_sda_i;
    reg csi_txd0_lp_p_i;
    reg csi_txd0_lp_n_i;
    reg csi_txd1_lp_p_i;
    reg csi_txd1_lp_n_i;
    reg csi_txd2_lp_p_i;
    reg csi_txd2_lp_n_i;
    reg csi_txd3_lp_p_i;
    reg csi_txd3_lp_n_i;
    reg [15:0] hbram_DQ_IN_HI;
    reg [15:0] hbram_DQ_IN_LO;
    reg [1:0] hbram_RWDS_IN_HI;
    reg [1:0] hbram_RWDS_IN_LO;

    // Instantiate the DUT (Design Under Test)
    example_top dut (
        .hbramClk_pll_rstn_o(),
        .hbramClk(hbramClk),
        .hbramClk90(hbramClk90),
        .hbramClk_Cal(hbramClk_Cal),
        .hbramClk_pll_lock(hbramClk_pll_lock),
        .hbramClk_shift(),
        .hbramClk_shift_ena(),
        .hbramClk_shift_sel(),
        .hdmi_pll_rstn_o(),
        .hdmi_pixel_10x(hdmi_pixel_10x),
        .hdmi_pixel(hdmi_pixel),
        .sensor_xclk_i(sensor_xclk_i),
        .sys_clk_i(sys_clk_i),
        .hdmi_pll_lock(hdmi_pll_lock),
        .dsi_pll_rstn_o(),
        .dsi_serclk_i(dsi_serclk_i),
        .dsi_txcclk_i(dsi_txcclk_i),
        .dsi_byteclk_i(dsi_byteclk_i),
        .dsi_fb_i(dsi_fb_i),
        .dsi_pll_lock(dsi_pll_lock),
        .uart_rx_i(uart_rx_i),
        .uart_tx_o(),
        .led_o(),
        .spi_cs_o(),
        .spi_cs_oe(),
        .spi_sck_o(),
        .spi_sck_oe(),
        .spi_mosi_d0_i(spi_mosi_d0_i),
        .spi_mosi_d0_o(),
        .spi_mosi_d0_oe(),
        .spi_miso_d1_i(spi_miso_d1_i),
        .spi_miso_d1_o(),
        .spi_miso_d1_oe(),
        .spi_wpn_d2_i(spi_wpn_d2_i),
        .spi_wpn_d2_o(),
        .spi_wpn_d2_oe(),
        .spi_holdn_d3_i(spi_holdn_d3_i),
        .spi_holdn_d3_o(),
        .spi_holdn_d3_oe(),
        .csi_trig_i(csi_trig_i),
        .csi_trig_o(),
        .csi_trig_oe(),
        .csi2_sda_i(csi2_sda_i),
        .csi2_sda_o(),
        .csi2_sda_oe(),
        .csi_rxc_lp_p_i(csi_rxc_lp_p_i),
        .csi_rxc_lp_n_i(csi_rxc_lp_n_i),
        .csi_rxc_hs_en_o(),
        .csi_rxc_hs_term_en_o(),
        .csi_rxc_i(csi_rxc_i),
        .csi_rxd0_rst_o(),
        .csi_rxd0_hs_en_o(),
        .csi_rxd0_hs_term_en_o(),
        .csi_rxd0_lp_p_i(csi_rxd0_lp_p_i),
        .csi_rxd0_lp_n_i(csi_rxd0_lp_n_i),
        .csi_rxd0_hs_i(csi_rxd0_hs_i),
        .csi_rxd1_rst_o(),
        .csi_rxd1_hs_en_o(),
        .csi_rxd1_hs_term_en_o(),
        .csi_rxd1_lp_p_i(csi_rxd1_lp_p_i),
        .csi_rxd1_lp_n_i(csi_rxd1_lp_n_i),
        .csi_rxd1_hs_i(csi_rxd1_hs_i),
        .csi_rxd2_rst_o(),
        .csi_rxd2_hs_en_o(),
        .csi_rxd2_hs_term_en_o(),
        .csi_rxd2_lp_p_i(csi_rxd2_lp_p_i),
        .csi_rxd2_lp_n_i(csi_rxd2_lp_n_i),
        .csi_rxd2_hs_i(csi_rxd2_hs_i),
        .csi_rxd3_rst_o(),
        .csi_rxd3_hs_en_o(),
        .csi_rxd3_hs_term_en_o(),
        .csi_rxd3_lp_p_i(csi_rxd3_lp_p_i),
        .csi_rxd3_lp_n_i(csi_rxd3_lp_n_i),
        .csi_rxd3_hs_i(csi_rxd3_hs_i),
        .csi2_rxc_lp_p_i(csi2_rxc_lp_p_i),
        .csi2_rxc_lp_n_i(csi2_rxc_lp_n_i),
        .csi2_rxc_hs_en_o(),
        .csi2_rxc_hs_term_en_o(),
        .csi2_rxc_i(csi2_rxc_i),
        .csi2_rxd0_rst_o(),
        .csi2_rxd0_hs_en_o(),
        .csi2_rxd0_hs_term_en_o(),
        .csi2_rxd0_lp_p_i(csi2_rxd0_lp_p_i),
        .csi2_rxd0_lp_n_i(csi2_rxd0_lp_n_i),
        .csi2_rxd0_hs_i(csi2_rxd0_hs_i),
        .csi2_rxd1_rst_o(),
        .csi2_rxd1_hs_en_o(),
        .csi2_rxd1_hs_term_en_o(),
        .csi2_rxd1_lp_p_i(csi2_rxd1_lp_p_i),
        .csi2_rxd1_lp_n_i(csi2_rxd1_lp_n_i),
        .csi2_rxd1_hs_i(csi2_rxd1_hs_i),
        .csi2_rxd2_rst_o(),
        .csi2_rxd2_hs_en_o(),
        .csi2_rxd2_hs_term_en_o(),
        .csi2_rxd2_lp_p_i(csi2_rxd2_lp_p_i),
        .csi2_rxd2_lp_n_i(csi2_rxd2_lp_n_i),
        .csi2_rxd2_hs_i(csi2_rxd2_hs_i),
        .csi2_rxd3_rst_o(),
        .csi2_rxd3_hs_en_o(),
        .csi2_rxd3_hs_term_en_o(),
        .csi2_rxd3_lp_p_i(csi2_rxd3_lp_p_i),
        .csi2_rxd3_lp_n_i(csi2_rxd3_lp_n_i),
        .csi2_rxd3_hs_i(csi2_rxd3_hs_i),
        .dsi_pwm_o(),
        .dsi_txc_rst_o(),
        .dsi_txc_lp_p_oe(),
        .dsi_txc_lp_p_o(),
        .dsi_txc_lp_n_oe(),
        .dsi_txc_lp_n_o(),
        .dsi_txc_hs_oe(),
        .dsi_txc_hs_o(),
        .dsi_txd0_rst_o(),
        .dsi_txd0_hs_oe(),
        .dsi_txd0_hs_o(),
        .dsi_txd0_lp_p_oe(),
        .dsi_txd0_lp_p_o(),
        .dsi_txd0_lp_n_oe(),
        .dsi_txd0_lp_n_o(),
        .dsi_txd1_rst_o(),
        .dsi_txd1_lp_p_oe(),
        .dsi_txd1_lp_p_o(),
        .dsi_txd1_lp_n_oe(),
        .dsi_txd1_lp_n_o(),
        .dsi_txd1_hs_oe(),
        .dsi_txd1_hs_o(),
        .dsi_txd2_rst_o(),
        .dsi_txd2_lp_p_oe(),
        .dsi_txd2_lp_p_o(),
        .dsi_txd2_lp_n_oe(),
        .dsi_txd2_lp_n_o(),
        .dsi_txd2_hs_oe(),
        .dsi_txd2_hs_o(),
        .dsi_txd3_rst_o(),
        .dsi_txd3_lp_p_oe(),
        .dsi_txd3_lp_p_o(),
        .dsi_txd3_lp_n_oe(),
        .dsi_txd3_lp_n_o(),
        .dsi_txd3_hs_oe(),
        .dsi_txd3_hs_o(),
        .dsi_txd0_lp_p_i(dsi_txd0_lp_p_i),
        .dsi_txd0_lp_n_i(dsi_txd0_lp_n_i),
        .dsi_txd1_lp_p_i(dsi_txd1_lp_p_i),
        .dsi_txd1_lp_n_i(dsi_txd1_lp_n_i),
        .dsi_txd2_lp_p_i(dsi_txd2_lp_p_i),
        .dsi_txd2_lp_n_i(dsi_txd2_lp_n_i),
        .dsi_txd3_lp_p_i(dsi_txd3_lp_p_i),
        .dsi_txd3_lp_n_i(dsi_txd3_lp_n_i),
        .csi_tx_scl_i(csi_tx_scl_i),
        .csi_tx_scl_o(),
        .csi_tx_scl_oe(),
        .csi_tx_sda_i(csi_tx_sda_i),
        .csi_tx_sda_o(),
        .csi_tx_sda_oe(),
        .csi_txc_rst_o(),
        .csi_txc_lp_p_oe(),
        .csi_txc_lp_p_o(),
        .csi_txc_lp_n_oe(),
        .csi_txc_lp_n_o(),
        .csi_txc_hs_oe(),
        .csi_txc_hs_o(),
        .csi_txd0_rst_o(),
        .csi_txd0_hs_oe(),
        .csi_txd0_hs_o(),
        .csi_txd0_lp_p_oe(),
        .csi_txd0_lp_p_o(),
        .csi_txd0_lp_n_oe(),
        .csi_txd0_lp_n_o(),
        .csi_txd1_rst_o(),
        .csi_txd1_lp_p_oe(),
        .csi_txd1_lp_p_o(),
        .csi_txd1_lp_n_oe(),
        .csi_txd1_lp_n_o(),
        .csi_txd1_hs_oe(),
        .csi_txd1_hs_o(),
        .csi_txd2_rst_o(),
        .csi_txd2_lp_p_oe(),
        .csi_txd2_lp_p_o(),
        .csi_txd2_lp_n_oe(),
        .csi_txd2_lp_n_o(),
        .csi_txd2_hs_oe(),
        .csi_txd2_hs_o(),
        .csi_txd3_rst_o(),
        .csi_txd3_lp_p_oe(),
        .csi_txd3_lp_p_o(),
        .csi_txd3_lp_n_oe(),
        .csi_txd3_lp_n_o(),
        .csi_txd3_hs_oe(),
        .csi_txd3_hs_o(),
        .hbram_CK_P_HI(),
        .hbram_CK_P_LO(),
        .hbram_CK_N_HI(),
        .hbram_CK_N_LO(),
        .hbram_CS_N(),
        .hbram_RST_N(),
        .hbram_DQ_OUT_HI(),
        .hbram_DQ_OUT_LO(),
        .hbram_DQ_OE(),
        .hbram_DQ_IN_HI(hbram_DQ_IN_HI),
        .hbram_DQ_IN_LO(hbram_DQ_IN_LO),
        .hbram_RWDS_OUT_HI(),
        .hbram_RWDS_OUT_LO(),
        .hbram_RWDS_OE(),
        .hbram_RWDS_IN_HI(hbram_RWDS_IN_HI),
        .hbram_RWDS_IN_LO(hbram_RWDS_IN_LO)
    );


    // Clock generation for hbramClk (247.5MHz)
    initial begin
        hbramClk = 0;
        forever #2.0202 hbramClk = ~hbramClk; // 周期约为4.0404ns
    end

    // Clock generation for hbramClk90 (90度相移)
    initial begin
        hbramClk90 = 0;
        #1.0101; // 相移90度
        forever #2.0202 hbramClk90 = ~hbramClk90;
    end

    // Clock generation for hdmi_pixel_10x (742.5MHz)
    initial begin
        hdmi_pixel_10x = 0;
        forever #0.6734 hdmi_pixel_10x = ~hdmi_pixel_10x; // 周期约为1.3468ns
    end

    // Clock generation for hdmi_pixel (148.5MHz)
    initial begin
        hdmi_pixel = 0;
        forever #3.367 hdmi_pixel = ~hdmi_pixel; // 周期约为6.734ns
    end

    // Clock generation for sensor_xclk_i (27MHz)
    initial begin
        sensor_xclk_i = 0;
        forever #18.5185 sensor_xclk_i = ~sensor_xclk_i; // 周期约为37.037ns
    end

    // Clock generation for sys_clk_i (123.75MHz)
    initial begin
        sys_clk_i = 0;
        forever #4.0404 sys_clk_i = ~sys_clk_i; // 周期约为8.0808ns
    end

    initial begin
        // Initialize all inputs
        hbramClk_Cal = 0;
        hbramClk_pll_lock = 0;
        hdmi_pixel_10x = 0;
        hdmi_pixel = 0;
        sensor_xclk_i = 0;
        hdmi_pll_lock = 0;
        dsi_serclk_i = 0;
        dsi_txcclk_i = 0;
        dsi_byteclk_i = 0;
        dsi_fb_i = 0;
        dsi_pll_lock = 0;
        uart_rx_i = 0;
        spi_mosi_d0_i = 0;
        spi_miso_d1_i = 0;
        spi_wpn_d2_i = 0;
        spi_holdn_d3_i = 0;
        csi_trig_i = 0;
        csi2_sda_i = 0;
        csi_rxc_lp_p_i = 0;
        csi_rxc_lp_n_i = 0;
        csi_rxc_i = 0;
        csi_rxd0_lp_p_i = 0;
        csi_rxd0_lp_n_i = 0;
        csi_rxd0_hs_i = 0;
        csi_rxd1_lp_p_i = 0;
        csi_rxd1_lp_n_i = 0;
        csi_rxd1_hs_i = 0;
        csi_rxd2_lp_p_i = 0;
        csi_rxd2_lp_n_i = 0;
        csi_rxd2_hs_i = 0;
        csi_rxd3_lp_p_i = 0;
        csi_rxd3_lp_n_i = 0;
        csi_rxd3_hs_i = 0;
        csi2_rxc_lp_p_i = 0;
        csi2_rxc_lp_n_i = 0;
        csi2_rxc_i = 0;
        csi2_rxd0_lp_p_i = 0;
        csi2_rxd0_lp_n_i = 0;
        csi2_rxd0_hs_i = 0;
        csi2_rxd1_lp_p_i = 0;
        csi2_rxd1_lp_n_i = 0;
        csi2_rxd1_hs_i = 0;
        csi2_rxd2_lp_p_i = 0;
        csi2_rxd2_lp_n_i = 0;
        csi2_rxd2_hs_i = 0;
        csi2_rxd3_lp_p_i = 0;
        csi2_rxd3_lp_n_i = 0;
        csi2_rxd3_hs_i = 0;
        dsi_txd0_lp_p_i = 0;
        dsi_txd0_lp_n_i = 0;
        dsi_txd1_lp_p_i = 0;
        dsi_txd1_lp_n_i = 0;
        dsi_txd2_lp_p_i = 0;
        dsi_txd2_lp_n_i = 0;
        dsi_txd3_lp_p_i = 0;
        dsi_txd3_lp_n_i = 0;
        csi_tx_scl_i = 0;
        csi_tx_sda_i = 0;
        csi_txd0_lp_p_i = 0;
        csi_txd0_lp_n_i = 0;
        csi_txd1_lp_p_i = 0;
        csi_txd1_lp_n_i = 0;
        csi_txd2_lp_p_i = 0;
        csi_txd2_lp_n_i = 0;
        csi_txd3_lp_p_i = 0;
        csi_txd3_lp_n_i = 0;
        hbram_DQ_IN_HI = 0;
        hbram_DQ_IN_LO = 0;
        hbram_RWDS_IN_HI = 0;
        hbram_RWDS_IN_LO = 0;

        // Apply reset
        #10;
        hbramClk_pll_lock = 1;
        hdmi_pll_lock = 1;
        dsi_pll_lock = 1;

        // Monitor changes
        $monitor("At time %t, Outputs: led_o=%b, uart_tx_o=%b", $time, dut.led_o, dut.uart_tx_o);

        // End simulation after some time
        #1000;
        $finish;
    end

endmodule
