`timescale 1ns/1ns

module testbench;

    // Inputs
    reg               clk;
    reg               rst_n;
    reg               per_frame_vsync;
    reg               per_frame_href;
    reg       [7:0]   per_img_Y;

    // Outputs
    wire              dsamp_out_vsync;
    wire              dsamp_out_href;
    wire      [7:0]   dsamp_out_pixel;

    // Instantiate the Unit Under Test (UUT)
    dsamp #(
        .DATA_WIDTH(8),
        .LINE_WIDTH(1280),
        .FRAME_LINES(720)
    ) uut (
        .dsamp_clk        (clk),
        .dsamp_rst_n      (rst_n),
        .dsamp_in_vsync   (per_frame_vsync),
        .dsamp_in_href    (per_frame_href),
        .dsamp_in_pixel   (per_img_Y),
        .dsamp_out_vsync  (dsamp_out_vsync),
        .dsamp_out_href   (dsamp_out_href),
        .dsamp_out_pixel  (dsamp_out_pixel)
    );

    // Parameters for image size
    localparam IMG_HDISP = 1280;  // 每行像素数量
    localparam IMG_VDISP = 720;   // 行数

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Reset
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    // Generate test pattern data
    reg [7:0] pixel_data [0:IMG_HDISP*IMG_VDISP-1];
    integer i;
    initial begin
        for (i = 0; i < IMG_HDISP*IMG_VDISP; i = i + 1) begin
            pixel_data[i] = i % 256; // 测试图案
        end
    end

    // Stimulus generation
    integer line;
    integer pixel;
    reg start_of_frame;

    initial begin
        // Initialize inputs
        per_frame_vsync = 0;
        per_frame_href = 0;
        per_img_Y = 0;
        line = 0;
        pixel = 0;
        start_of_frame = 1;

        #25; // 等待复位信号稳定
        start_of_frame = 1; // 开始帧传输
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_frame_vsync <= 0;
            per_frame_href <= 0;
            per_img_Y <= 0;
            line <= 0;
            pixel <= 0;
            start_of_frame <= 1;
        end else begin
            if (start_of_frame) begin
                // 帧开始
                per_frame_vsync <= 1;
                start_of_frame <= 0;
                line <= 0;
                pixel <= 0;
            end else if (line < IMG_VDISP) begin
                per_frame_vsync <= 0;

                if (pixel == 0) begin
                    // 行开始
                    per_frame_href <= 1;
                end

                if (pixel < IMG_HDISP) begin
                    // 像素数据输出
                    per_img_Y <= pixel_data[line * IMG_HDISP + pixel];
                    pixel <= pixel + 1;
                end else begin
                    // 行结束
                    per_frame_href <= 0;
                    per_img_Y <= 0;
                    pixel <= 0;
                    line <= line + 1;
                end
            end else begin
                // 帧结束
                per_frame_vsync <= 0;
                per_frame_href <= 0;
                per_img_Y <= 0;
                // 可以在此处添加延迟，或者重新开始下一帧
                #100;
                start_of_frame <= 1; // 开始下一帧
            end
        end
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t ns, Line=%0d, Pixel=%0d, href=%b, vsync=%b, per_img_Y=%h, dsamp_out_pixel=%h, dsamp_out_href=%b",
                 $time, line, pixel, per_frame_href, per_frame_vsync, per_img_Y, dsamp_out_pixel, dsamp_out_href);
    end

endmodule