module servo_driver #(
    parameter CLK_FREQ = 50_000_000  // FPGA工作频率，默认50MHz，可从外部传入
)(
    input wire clk,          // 时钟信号
    input wire rst_n,        // 复位信号，低电平有效
    input wire [7:0] angle,  // 目标角度，0~180
    output reg servo_pwm     // 输出给舵机的PWM信号
);

    // 参数定义
    parameter PWM_PERIOD = 20_000;   // PWM周期20ms，单位us
    parameter TOTAL_COUNT = 10_000;  // PWM计数总数，对应10000，方便计算占空比

    // 计算每次计数的时钟周期数
    localparam integer COUNT_PER_TICK = (CLK_FREQ * PWM_PERIOD / 1_000_000) / TOTAL_COUNT;

    reg [31:0] tick_cnt;      // 时钟计数器，用于产生PWM计数时钟
    reg [13:0] pwm_cnt;       // PWM计数器，范围0~9999

    reg [13:0] pulse_width;   // 脉宽计数值，对应占空比

    // 生成PWM计数时钟
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_cnt <= 32'd0;
        end else begin
            if (tick_cnt < COUNT_PER_TICK - 1)
                tick_cnt <= tick_cnt + 1;
            else
                tick_cnt <= 32'd0;
        end
    end

    // PWM计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_cnt <= 14'd0;
        end else begin
            if (tick_cnt == COUNT_PER_TICK - 1) begin
                if (pwm_cnt < TOTAL_COUNT - 1)
                    pwm_cnt <= pwm_cnt + 1;
                else
                    pwm_cnt <= 14'd0;
            end
        end
    end

    // 生成PWM信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            servo_pwm <= 1'b0;
        end else begin
            if (pwm_cnt < pulse_width)
                servo_pwm <= 1'b1;
            else
                servo_pwm <= 1'b0;
        end
    end

    // 根据角度计算脉宽（占空比计数值）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_width <= 14'd250;  // 对应0度，脉宽0.5ms，占空比2.5%
        end else begin
            // 计算公式：pulse_width = 250 + (angle * (1250 - 250) / 180)
            pulse_width <= 14'd250 + (angle * 1000) / 180;
        end
    end

endmodule
