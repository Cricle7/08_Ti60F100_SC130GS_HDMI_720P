`timescale 1ns/1ns

module testbench;

    // Inputs
    reg               clk;
    reg               rst_n;
    reg               per_frame_vsync;
    reg               per_frame_href;
    reg               per_frame_hsync;
    reg       [7:0]   per_img_Y;

    // Outputs
    wire              matrix_frame_vsync;
    wire              matrix_frame_href;
    wire              matrix_frame_hsync;
    wire      [7:0]   matrix_p11, matrix_p12, matrix_p13;
    wire      [7:0]   matrix_p21, matrix_p22, matrix_p23;
    wire      [7:0]   matrix_p31, matrix_p32, matrix_p33;

    // Instantiate the Unit Under Test (UUT)
    VIP_Matrix_Generate_3X3_8Bit uut (
        .clk(clk),
        .rst_n(rst_n),
        .per_frame_vsync(per_frame_vsync),
        .per_frame_href(per_frame_href),
        .per_frame_hsync(per_frame_hsync),
        .per_img_Y(per_img_Y),
        .matrix_frame_vsync(matrix_frame_vsync),
        .matrix_frame_href(matrix_frame_href),
        .matrix_frame_hsync(matrix_frame_hsync),
        .matrix_p11(matrix_p11), .matrix_p12(matrix_p12), .matrix_p13(matrix_p13),
        .matrix_p21(matrix_p21), .matrix_p22(matrix_p22), .matrix_p23(matrix_p23),
        .matrix_p31(matrix_p31), .matrix_p32(matrix_p32), .matrix_p33(matrix_p33)
    );

    // Include the Line_Shift_RAM_8Bit module
    // 请确保您在仿真中包含了之前提供的 Line_Shift_RAM_8Bit 模块，并根据需要调整参数。

    // Parameters for image size
    localparam IMG_HDISP = 1280;  // 每行像素数量
    localparam IMG_VDISP = 6;   // 行数

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
        per_frame_hsync = 0;
        per_img_Y = 0;
        line = 0;
        pixel = 0;
        start_of_frame = 1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_frame_vsync <= 0;
            per_frame_href <= 0;
            per_frame_hsync <= 0;
            per_img_Y <= 0;
            line <= 0;
            pixel <= 0;
            start_of_frame <= 1;
        end else begin
            // Start of frame
            if (start_of_frame) begin
                per_frame_vsync <= 1;
                start_of_frame <= 0;
                line <= 0;
                pixel <= 0;
            end else begin
                per_frame_vsync <= 0;
            end

            // Line processing
            if (line < IMG_VDISP) begin
                if (pixel == 0) begin
                    // Start of line
                    per_frame_hsync <= 1;
                end

                if (pixel < IMG_HDISP) begin
                    per_frame_href <= 1;
                    per_img_Y <= pixel_data[line * IMG_HDISP + pixel];
                    pixel <= pixel + 1;
                end else begin
                    per_frame_href <= 0;
                    per_img_Y <= 0;
                    pixel <= 0;
                    line <= line + 1;
                    // End of line
                    per_frame_hsync <= 0;
                end
            end else begin
                // End of frame after all lines
                per_frame_href <= 0;
                per_frame_hsync <= 0;
                per_img_Y <= 0;
                #50; // Optional delay before stopping
            end
        end
    end

    // Optional: Monitor outputs
    initial begin
        $monitor("Time=%0t ns, Line=%0d, Pixel=%0d, hsync=%b, href=%b, vsync=%b, per_img_Y=%h, matrix_p22=%h",
                 $time, line, pixel, per_frame_hsync, per_frame_href, per_frame_vsync, per_img_Y, matrix_p22);
    end

endmodule
