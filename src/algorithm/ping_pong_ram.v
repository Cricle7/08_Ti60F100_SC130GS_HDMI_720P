// 乒乓RAM模块，写数据打一拍并延长写使能
module ping_pong_ram(
    input clk,
    input reset,
    input line_end, // 行结束信号，用于切换乒乓缓冲
    input we,
    input [10:0] write_addr,
    input [7:0] write_data,
    input re,
    input [10:0] read_addr,
    output [7:0] read_data
);

    reg ping_pong_flag;  // 乒乓标志位

    // 在行结束时切换乒乓标志位
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ping_pong_flag <= 0;
        end else if (line_end) begin
            ping_pong_flag <= ~ping_pong_flag;
        end
    end

    // 写数据打一拍，并延长写使能
    reg [7:0] write_data_d;
    reg we_d;
    reg [10:0] write_addr_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_data_d <= 8'd0;
            we_d <= 1'b0;
            write_addr_d <= 11'd0;
        end else begin
            write_data_d <= write_data;
            we_d <= we ;
            write_addr_d <= write_addr;
        end
    end

    // RAM0和RAM1的控制信号和地址
    wire we_ram0 = (we | we_d) & (~ping_pong_flag);
    wire we_ram1 = (we | we_d) & ping_pong_flag;
    wire re_ram0 = re & ping_pong_flag;
    wire re_ram1 = re & (~ping_pong_flag);

    wire [10:0] addr_ram0 = we_ram0 ? write_addr_d : read_addr;
    wire [10:0] addr_ram1 = we_ram1 ? write_addr_d : read_addr;
    wire [7:0] wdata_ram0 = write_data_d;
    wire [7:0] wdata_ram1 = write_data_d;
    wire [7:0] rdata_ram0;
    wire [7:0] rdata_ram1;

    // 实例化RAM0
    hor_ram_2048 u_ram0 (
        .clk(clk),
        //.reset(reset),
        .we(we_ram0),
        .re(re_ram0),
        .addr(addr_ram0),
        .wdata_a(wdata_ram0),
        .rdata_a(rdata_ram0)
    );

    // 实例化RAM1
    hor_ram_2048 u_ram1 (
        .clk(clk),
        //.reset(reset),
        .we(we_ram1),
        .re(re_ram1),
        .addr(addr_ram1),
        .wdata_a(wdata_ram1),
        .rdata_a(rdata_ram1)
    );

    // 根据乒乓标志位选择输出数据（组合逻辑）
    assign read_data = (ping_pong_flag) ? rdata_ram0 : rdata_ram1;

endmodule
