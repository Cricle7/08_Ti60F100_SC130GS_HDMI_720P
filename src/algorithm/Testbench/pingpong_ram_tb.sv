`timescale 1ns/1ps

module ping_pong_ram_tb;

    reg clk;
    reg reset;
    reg line_end;
    reg we;
    reg [10:0] write_addr;
    reg [7:0] write_data;
    reg re;
    reg [10:0] read_addr;
    wire [7:0] read_data;

    // 实例化乒乓RAM模块
    ping_pong_ram uut (
        .clk(clk),
        .reset(reset),
        .line_end(line_end),
        .we(we),
        .write_addr(write_addr),
        .write_data(write_data),
        .re(re),
        .read_addr(read_addr),
        .read_data(read_data)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz 时钟
    end

    // 测试刺激
    initial begin
        reset = 1;
        line_end = 0;
        we = 0;
        write_addr = 11'd1;  // 避免使用地址0
        write_data = 0;
        re = 0;
        read_addr = 11'd1;   // 避免使用地址0

        #20;
        reset = 0;

        // 第一次写入数据，同时开始读取上一行数据（由于是初始状态，读取的数据可能不确定）
        @(posedge clk);
        we = 1;
        re = 1;
        write_addr = 11'd1;
        write_data = 8'hAA;
        read_addr = 11'd1;
        @(posedge clk);
        write_addr = 11'd2;
        write_data = 8'hBB;
        read_addr = 11'd2;
        @(posedge clk);
        write_addr = 11'd3;
        write_data = 8'hCC;
        read_addr = 11'd3;
        @(posedge clk);
        write_addr = 11'd4;
        write_data = 8'hDD;
        read_addr = 11'd4;
        @(posedge clk);
        we = 0;
        re = 0;
        line_end = 1; // 切换乒乓缓冲
        @(posedge clk);
        line_end = 0;

        // 第二次写入，同时读取上一行的数据
        @(posedge clk);
        we = 1;
        re = 1;
        write_addr = 11'd1;
        write_data = 8'h11;
        read_addr = 11'd1;
        @(posedge clk);
        write_addr = 11'd2;
        write_data = 8'h22;
        read_addr = 11'd2;
        @(posedge clk);
        write_addr = 11'd3;
        write_data = 8'h33;
        read_addr = 11'd3;
        @(posedge clk);
        write_addr = 11'd4;
        write_data = 8'h44;
        read_addr = 11'd4;
        @(posedge clk);
        we = 0;
        re = 0;
        @(posedge clk);
        line_end = 1; // 切换乒乓缓冲
        @(posedge clk);
        line_end = 0;

        // 第三次写入，同时读取上一行的数据
        @(posedge clk);
        we = 1;
        re = 1;
        write_addr = 11'd1;
        write_data = 8'h55;
        read_addr = 11'd1;
        @(posedge clk);
        write_addr = 11'd2;
        write_data = 8'h66;
        read_addr = 11'd2;
        @(posedge clk);
        write_addr = 11'd3;
        write_data = 8'h77;
        read_addr = 11'd3;
        @(posedge clk);
        write_addr = 11'd4;
        write_data = 8'h88;
        read_addr = 11'd4;
        @(posedge clk);
        we = 0;
        re = 0;
        @(posedge clk);
        line_end = 1; // 切换乒乓缓冲
        @(posedge clk);
        line_end = 0;

        #100;
        $finish;
    end

endmodule
