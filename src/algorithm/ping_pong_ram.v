module ping_pong_ram (
    input wire clk,                  // 时钟信号
    input wire reset,                // 高电平复位信号
    input wire we,                   // 写使能信号
    input wire re,                   // 读使能信号
    input wire [10:0] waddr,         // 写地址（11位）
    input wire [7:0] wdata,          // 写数据（8位）
    input wire [10:0] raddr,         // 读地址（11位）
    output wire [7:0] rdata_out       // 读数据输出（8位）
);

    // 控制信号，用于切换当前写入和读取的 RAM
    reg toggle;

    // 用于检测 we 信号的下降沿
    reg we_prev;

    // 读取数据线
    wire [7:0] rdata0;
    wire [7:0] rdata1;

    // 边沿检测和 toggle 逻辑
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            we_prev <= 1'b0;
            toggle <= 1'b0;
        end else begin
            we_prev <= we;
            // 检测到 we 从高到低的变化
            if (we_prev & ~we) begin
                toggle <= ~toggle;
            end
        end
    end

    // 根据 toggle 信号决定哪个 RAM 用于写入，哪个用于读取
    wire we0 = we & ~toggle;
    wire re0 = re & toggle;

    wire we1 = we & toggle;
    wire re1 = re & ~toggle;

    // 实例化 RAM0
    hor_dual_ram_2048 u_ram0 (
        .re(re0),
        .we(we0),
        .waddr(waddr),
        .wdata_a(wdata),
        .rdata_b(rdata0),
        .raddr(raddr),
        .clk(clk)
    );

    // 实例化 RAM1
    hor_dual_ram_2048 u_ram1 (
        .re(re1),
        .we(we1),
        .waddr(waddr),
        .wdata_a(wdata),
        .rdata_b(rdata1),
        .raddr(raddr),
        .clk(clk)
    );

    // 选择读取的数据
    assign rdata_out = toggle ? rdata0 : rdata1;

endmodule
