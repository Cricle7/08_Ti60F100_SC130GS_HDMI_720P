`timescale 1ns/1ps

module tb_servo_driver;

    reg clk;
    reg rst_n;
    reg [7:0] angle;
    wire servo_pwm;

    // FPGA工作频率参数
    parameter CLK_FREQ = 50_000_000; // 50MHz

    // 实例化舵机驱动模块
    servo_driver #(
        .CLK_FREQ(CLK_FREQ)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .angle(angle),
        .servo_pwm(servo_pwm)
    );

    // 生成50MHz时钟信号
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 时钟周期为20ns，即50MHz
    end

    // 测试过程
    initial begin
        // 初始化信号
        rst_n = 0;
        angle = 8'd0;

        // 释放复位
        #100 rst_n = 1;

        // 测试不同角度
        #100_000_0000 angle = 8'd0;    // 0度，对应脉宽0.5ms
        #200_000_0000 angle = 8'd45;   // 45度，对应脉宽1.0ms
        #200_000_0000 angle = 8'd90;   // 90度，对应脉宽1.5ms
        #200_000_0000 angle = 8'd135;  // 135度，对应脉宽2.0ms
        #200_000_0000 angle = 8'd180;  // 180度，对应脉宽2.5ms

        // 结束仿真
        #200_000_000 $stop;
    end

endmodule
