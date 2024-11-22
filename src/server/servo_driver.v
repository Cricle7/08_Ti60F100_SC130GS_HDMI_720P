module servo_driver
(
    input               clk,        // 时钟信号，假设为 50MHz
    input               rst_n,      // 复位信号，低电平有效
    input   [7:0]       angle_in,   // 输入角度，范围 0~180
    output  reg         pwm         // PWM 输出信号
);

// 参数定义
parameter       TIME_20MS   = 1_000_000;  // 20ms 对应的计数值，50MHz 时钟下 20ms = 1,000,000 个周期
parameter       PULSE_MIN   = 25_000;     // 最小脉宽对应计数值（0.5ms），0.5ms * 50MHz = 25,000
parameter       PULSE_MAX   = 125_000;    // 最大脉宽对应计数值（2.5ms），2.5ms * 50MHz = 125,000

// 预先计算增量，每度对应的计数值增量
parameter       DELTA_PULSE = 555;        // (PULSE_MAX - PULSE_MIN) / 180 ≈ 555.55，取整数555

// 内部信号
reg [19:0]  cnt;            // 主计数器，计数 20ms 周期
reg [19:0]  cnt_pwm;        // PWM 高电平计数值，根据输入角度计算
wire        add_cnt;
wire        end_cnt;

// 主计数器，实现 20ms 周期计数
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= 0;
    else if (add_cnt) begin
        if (end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

assign add_cnt = 1'b1;
assign end_cnt = add_cnt && (cnt == TIME_20MS - 1);

// 根据输入角度计算 PWM 高电平计数值，避免使用除法
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt_pwm <= 0;
    else
        cnt_pwm <= PULSE_MIN + angle_in * DELTA_PULSE;
end

// PWM 波形生成
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pwm <= 1'b0;
    else if (cnt < cnt_pwm)
        pwm <= 1'b1;
    else
        pwm <= 1'b0;
end

endmodule

