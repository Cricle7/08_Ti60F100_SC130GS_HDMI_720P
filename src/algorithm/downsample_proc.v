module dsamp #(
    parameter DATA_WIDTH = 8,       // 输入数据的位宽
              LINE_WIDTH = 1280,    // 每行的像素数
              FRAME_LINES = 720     // 每帧的行数
)(
    input  wire                    dsamp_clk,
    input  wire                    dsamp_rst_n,
    
    // 输入像素接口
    input  wire                    dsamp_in_vsync,
    input  wire                    dsamp_in_href,
    input  wire  [DATA_WIDTH-1:0]  dsamp_in_pixel,
    
    // 输出像素接口
    output reg                     dsamp_out_vsync,
    output reg                     dsamp_out_href,
    output reg   [DATA_WIDTH-1:0]  dsamp_out_pixel
);
    // FIFO 信号
    wire fifo_full;
    wire fifo_empty;
    wire [DATA_WIDTH-1:0] fifo_rdata;
    wire wr_en_i;
    wire rd_en_i;
    wire [11:0] datacount_o; // 根据 DEPTH=1024 需要至少 10 位计数，取 12 位以防
    wire rst_busy;

    // FIFO 实例化
    hor_fifo_1024 u_hor_fifo_1024 (
        .full_o      (fifo_full),
        .empty_o     (fifo_empty),
        .clk_i       (dsamp_clk),
        .wr_en_i     (wr_en_i),
        .rd_en_i     (rd_en_i),
        .wdata       (dsamp_in_pixel),
        .datacount_o (datacount_o),
        .rst_busy    (rst_busy),
        .rdata       (fifo_rdata),
        .a_rst_i     (~dsamp_rst_n)
    );

    // 输出图像参数
    localparam OUTPUT_LINE_WIDTH = LINE_WIDTH / 4;
    localparam OUTPUT_FRAME_LINES = FRAME_LINES / 4;

    // 垂直降采样控制
    reg [1:0] line_count;
    reg dsamp_in_href_d;
    reg dsamp_in_vsync_d;

    // 水平降采样计数器
    reg [1:0] wr_count;
    assign wr_en_i = dsamp_in_href && (line_count == 2'b00) && (wr_count == 2'b11) && !fifo_full;

    always @(posedge dsamp_clk or negedge dsamp_rst_n) begin
        if (!dsamp_rst_n) begin
            wr_count <= 0;
            line_count <= 0;
            dsamp_in_href_d <= 0;
            dsamp_in_vsync_d <= 0;
        end else begin
            // 捕获输入同步信号的延迟版本
            dsamp_in_href_d <= dsamp_in_href;
            dsamp_in_vsync_d <= dsamp_in_vsync;
            
            // 检测帧开始（vsync 上升沿）
            if (!dsamp_in_vsync_d && dsamp_in_vsync) begin
                line_count <= 0;
            end 
            // 检测行结束（href 下降沿）
            else if (dsamp_in_href_d && !dsamp_in_href) begin
                line_count <= line_count + 1;
            end

            // 水平方向降采样计数
            if (dsamp_in_href && (line_count == 2'b00)) begin
                if (wr_count < 2'b11) begin
                    wr_count <= wr_count + 1;
                end else begin
                    wr_count <= 0;
                end
            end else begin
                wr_count <= 0; // 行结束时重置
            end
        end
    end

    // 读取控制逻辑
    reg [10:0] rd_pixel_count;
    reg [10:0] read_line_count;
    reg reading_line;

    assign rd_en_i = reading_line && !fifo_empty;

    always @(posedge dsamp_clk or negedge dsamp_rst_n) begin
        if (!dsamp_rst_n) begin
            reading_line     <= 0;
            rd_pixel_count   <= 0;
            read_line_count  <= 0;
            dsamp_out_pixel  <= 0;
        end else begin
            if (!reading_line && read_line_count < OUTPUT_FRAME_LINES && !fifo_empty) begin
                // 开始读取新的一行
                reading_line    <= 1;
                rd_pixel_count  <= 0;
            end else if (reading_line) begin
                if (!fifo_empty) begin
                    dsamp_out_pixel <= fifo_rdata;
                    rd_pixel_count  <= rd_pixel_count + 1;
                    if (rd_pixel_count == OUTPUT_LINE_WIDTH - 1) begin
                        // 当前行读取结束
                        reading_line    <= 0;
                        read_line_count  <= read_line_count + 1;
                    end
                end else begin
                    // FIFO 空时停止读取
                    reading_line <= 0;
                end
            end
        end
    end

    // 输出控制信号的生成
    always @(posedge dsamp_clk or negedge dsamp_rst_n) begin
        if (!dsamp_rst_n) begin
            dsamp_out_vsync <= 0;
            dsamp_out_href  <= 0;
        end else begin
            // 生成 dsamp_out_vsync 信号
            if (read_line_count == 0 && reading_line && rd_pixel_count == 0) begin
                dsamp_out_vsync <= 1;
            end else if (read_line_count == OUTPUT_FRAME_LINES && !reading_line) begin
                dsamp_out_vsync <= 0;
            end else begin
                dsamp_out_vsync <= 0; // 仅在帧开始时拉高
            end

            // 生成 dsamp_out_href 信号
            if (reading_line) begin
                dsamp_out_href <= 1;
            end else begin
                dsamp_out_href <= 0;
            end
        end
    end

endmodule
