module union_find #(
    parameter N = 256,                 // 元素数量
    parameter ADDR_WIDTH = 8           // 地址宽度
)(
    input clk,
    input reset,                       // 高电平同步复位
    input frame_start,                 // 帧开始信号，高电平表示新的一帧开始
    input [1:0] op,                    // 操作码：00 - idle，01 - union, 10 - find
    input [ADDR_WIDTH-1:0] node1,
    input [ADDR_WIDTH-1:0] node2,
    output reg [ADDR_WIDTH-1:0] result, // find操作的结果
    output reg done,                    // 操作完成标志
    output wire idle                    // 当前是否处于空闲状态
);

    // 使用单端口 RAM 存储 parent 和 rank
    reg [ADDR_WIDTH-1:0] parent_ram [0:N-1];
    reg [ADDR_WIDTH-1:0] rank_ram   [0:N-1];

    // parent RAM 的端口信号
    reg [ADDR_WIDTH-1:0] parent_addr;
    reg [ADDR_WIDTH-1:0] parent_din;
    reg parent_we;
    reg [ADDR_WIDTH-1:0] parent_dout;  // 同步读

    // rank RAM 的端口信号
    reg [ADDR_WIDTH-1:0] rank_addr;
    reg [ADDR_WIDTH-1:0] rank_din;
    reg rank_we;
    reg [ADDR_WIDTH-1:0] rank_dout;    // 同步读

    reg [5:0] state; 
    localparam IDLE              = 6'd0;
    localparam INIT_LOOP         = 6'd1;
    localparam FIND_START        = 6'd2;
    localparam FIND_READ         = 6'd3;
    localparam FIND_CHECK        = 6'd4;
    localparam FIND_UPDATE       = 6'd5;
    localparam UNION_START       = 6'd6;
    localparam UNION_FIND_X      = 6'd7;
    localparam UNION_READ_X      = 6'd8;
    localparam UNION_CHECK_X     = 6'd9;
    localparam UNION_UPDATE_X    = 6'd10;
    localparam UNION_FIND_Y      = 6'd11;
    localparam UNION_READ_Y      = 6'd12;
    localparam UNION_CHECK_Y     = 6'd13;
    localparam UNION_UPDATE_Y    = 6'd14;
    localparam UNION_MERGE       = 6'd15;
    localparam UNION_READ_RANK_X = 6'd16;
    localparam UNION_READ_RANK_Y = 6'd17;
    localparam UNION_PERFORM_MERGE = 6'd18;
    localparam DONE              = 6'd19;

    // 临时变量
    reg [ADDR_WIDTH-1:0] x_curr, y_curr;
    reg [ADDR_WIDTH-1:0] parent_x_curr, parent_y_curr;
    reg [ADDR_WIDTH-1:0] x_root, y_root;
    reg [ADDR_WIDTH-1:0] rank_x_root, rank_y_root;
    reg [11:0] init_counter; // 初始化计数器

    assign idle = (state == IDLE);

    // parent RAM 的读写操作（同步读）
    always @(posedge clk) begin
        if (parent_we)
            parent_ram[parent_addr] <= parent_din;
        parent_dout <= parent_ram[parent_addr];
    end

    // rank RAM 的读写操作（同步读）
    always @(posedge clk) begin
        if (rank_we)
            rank_ram[rank_addr] <= rank_din;
        rank_dout <= rank_ram[rank_addr];
    end

    // 状态机
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            result <= 0;
            // 复位 RAM 写使能信号
            parent_we <= 0;
            rank_we <= 0;
            init_counter <= 0;
        end else begin
            // 默认 RAM 控制信号
            parent_we <= 0;
            rank_we <= 0;
            case (state)
                IDLE: begin
                    done <= 0;
                    if (frame_start) begin
                        // 开始初始化 RAM
                        init_counter <= 0;
                        state <= INIT_LOOP;
                    end else if (op == 2'b10) begin // FIND 操作
                        x_curr <= node1;
                        state <= FIND_START;
                    end else if (op == 2'b01) begin // UNION 操作
                        x_curr <= node1;
                        y_curr <= node2;
                        state <= UNION_START;
                    end
                end
                INIT_LOOP: begin
                    if (init_counter < N) begin
                        // 初始化 parent[init_counter] = init_counter 和 rank[init_counter] = 0
                        parent_addr <= init_counter;
                        parent_din  <= init_counter;
                        parent_we   <= 1;
                        rank_addr   <= init_counter;
                        rank_din    <= 0;
                        rank_we     <= 1;
                        init_counter  <= init_counter + 1;
                    end else begin
                        state <= IDLE;
                    end
                end
                // FIND 操作状态
                FIND_START: begin
                    parent_addr <= x_curr;
                    state <= FIND_READ;
                end
                FIND_READ: begin
                    // 等待 parent_dout 有效
                    state <= FIND_CHECK;
                end
                FIND_CHECK: begin
                    parent_x_curr <= parent_dout;
                    if (parent_dout == x_curr) begin
                        result <= x_curr;
                        done <= 1;
                        state <= IDLE;
                    end else begin
                        // 路径压缩
                        parent_addr <= parent_dout;
                        state <= FIND_UPDATE;
                    end
                end
                FIND_UPDATE: begin
                    // 等待 parent_dout 有效
                    state <= FIND_START;  // 下一状态将继续
                    // 更新 parent[x_curr] <= parent[parent_x_curr]
                    parent_din  <= parent_dout;
                    parent_we   <= 1;
                    parent_addr <= x_curr;
                    x_curr      <= parent_x_curr;
                end
                // UNION 操作状态
                UNION_START: begin
                    state <= UNION_FIND_X;
                end
                // 寻找 x 的根节点
                UNION_FIND_X: begin
                    parent_addr <= x_curr;
                    state <= UNION_READ_X;
                end
                UNION_READ_X: begin
                    // 等待 parent_dout 有效
                    state <= UNION_CHECK_X;
                end
                UNION_CHECK_X: begin
                    parent_x_curr <= parent_dout;
                    if (parent_dout == x_curr) begin
                        x_root <= x_curr;
                        state <= UNION_FIND_Y;
                    end else begin
                        parent_addr <= parent_dout;
                        state <= UNION_UPDATE_X;
                    end
                end
                UNION_UPDATE_X: begin
                    // 等待 parent_dout 有效
                    state <= UNION_FIND_X;  // 下一状态将继续
                    // x 的路径压缩
                    parent_din  <= parent_dout;
                    parent_we   <= 1;
                    parent_addr <= x_curr;
                    x_curr      <= parent_x_curr;
                end
                // 寻找 y 的根节点
                UNION_FIND_Y: begin
                    parent_addr <= y_curr;
                    state <= UNION_READ_Y;
                end
                UNION_READ_Y: begin
                    // 等待 parent_dout 有效
                    state <= UNION_CHECK_Y;
                end
                UNION_CHECK_Y: begin
                    parent_y_curr <= parent_dout;
                    if (parent_dout == y_curr) begin
                        y_root <= y_curr;
                        state <= UNION_MERGE;
                    end else begin
                        parent_addr <= parent_dout;
                        state <= UNION_UPDATE_Y;
                    end
                end
                UNION_UPDATE_Y: begin
                    // 等待 parent_dout 有效
                    state <= UNION_FIND_Y;  // 下一状态将继续
                    // y 的路径压缩
                    parent_din  <= parent_dout;
                    parent_we   <= 1;
                    parent_addr <= y_curr;
                    y_curr      <= parent_y_curr;
                end
                // 合并集合
                UNION_MERGE: begin
                    if (x_root != y_root) begin
                        // 读取 x_root 的 rank
                        rank_addr <= x_root;
                        state <= UNION_READ_RANK_X;
                    end else begin
                        done <= 1;
                        state <= IDLE;
                    end
                end
                UNION_READ_RANK_X: begin
                    // 等待 rank_dout 有效
                    rank_x_root <= rank_dout;
                    // 读取 y_root 的 rank
                    rank_addr <= y_root;
                    state <= UNION_READ_RANK_Y;
                end
                UNION_READ_RANK_Y: begin
                    // 等待 rank_dout 有效
                    rank_y_root <= rank_dout;
                    state <= UNION_PERFORM_MERGE;
                end
                UNION_PERFORM_MERGE: begin
                    if (rank_x_root < rank_y_root) begin
                        // 将 x_root 挂在 y_root 下
                        parent_addr <= x_root;
                        parent_din  <= y_root;
                        parent_we   <= 1;
                    end else if (rank_x_root > rank_y_root) begin
                        // 将 y_root 挂在 x_root 下
                        parent_addr <= y_root;
                        parent_din  <= x_root;
                        parent_we   <= 1;
                    end else begin
                        // 将 y_root 挂在 x_root 下，并增加 x_root 的 rank
                        parent_addr <= y_root;
                        parent_din  <= x_root;
                        parent_we   <= 1;
                        // 增加 x_root 的 rank
                        rank_addr   <= x_root;
                        rank_din    <= rank_x_root + 1;
                        rank_we     <= 1;
                    end
                    state <= DONE;
                end
                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
