module pingpong_ram_tb();

// 参数定义
parameter ADDR_WIDTH = 4;  // 地址宽度（小位宽用于测试）
parameter DATA_WIDTH = 8;  // 数据宽度

// 信号定义
reg clk;
reg reset;
reg we;                    // 写使能
reg re;                    // 读使能
reg [DATA_WIDTH-1:0] wdata; // 写入数据
wire [DATA_WIDTH-1:0] rdata; // 读取数据

// 实例化被测试模块
pingpong_ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) uut (
    .clk(clk),
    .reset(reset),
    .we(we),
    .re(re),
    .wdata(wdata),
    .rdata(rdata)
);

// 时钟生成
always #5 clk = ~clk;  // 10ns周期时钟

// 测试例程
initial begin
    // 初始化
    clk = 0;
    we = 0;
    re = 0;
    wdata = 0;
    reset = 1;

    // 复位
    #10 reset = 0;  // 释放复位信号

    // 写入一行数据
    we = 1;
    for (int i = 0; i < 8; i = i + 1) begin
        wdata = i[DATA_WIDTH-1:0];  // 写入从0到7的数值
        #10;
    end
    we = 0;

    // 读取上一行数据
    re = 1;
    for (int i = 0; i < 8; i = i + 1) begin
        #10;
        $display("Address %d: Read Data = %h", i, rdata);  // 打印读取到的数据
    end
    re = 0;

    // 结束仿真
    $finish;
end

endmodule
