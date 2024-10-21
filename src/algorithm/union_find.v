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

    // 使用双端口RAM存储parent和rank
    reg [ADDR_WIDTH-1:0] parent_ram [0:N-1];
    reg [ADDR_WIDTH-1:0] rank_ram   [0:N-1];

    // parent RAM的端口信号
    reg [ADDR_WIDTH-1:0] parent_addr_a, parent_addr_b;
    reg [ADDR_WIDTH-1:0] parent_din_a,  parent_din_b;
    reg parent_we_a, parent_we_b;
    wire [ADDR_WIDTH-1:0] parent_dout_a, parent_dout_b;

    // rank RAM的端口信号
    reg [ADDR_WIDTH-1:0] rank_addr_a, rank_addr_b;
    reg [ADDR_WIDTH-1:0] rank_din_a,  rank_din_b;
    reg rank_we_a, rank_we_b;
    wire [ADDR_WIDTH-1:0] rank_dout_a, rank_dout_b;

    // 状态机状态
    reg [4:0] state;
    localparam IDLE              = 5'd0;
    localparam INIT              = 5'd1;
    localparam INIT_LOOP         = 5'd2;
    localparam FIND_START        = 5'd3;
    localparam FIND_CHECK        = 5'd5;
    localparam FIND_UPDATE       = 5'd6;
    localparam UNION_START       = 5'd7;
    localparam UNION_FIND_X      = 5'd8;
    localparam UNION_CHECK_X     = 5'd9;
    localparam UNION_UPDATE_X    = 5'd10;
    localparam UNION_FIND_Y      = 5'd11;
    localparam UNION_CHECK_Y     = 5'd12;
    localparam UNION_UPDATE_Y    = 5'd13;
    localparam UNION_MERGE       = 5'd14;
    localparam UNION_READ_RANKS  = 5'd15;
    localparam UNION_PERFORM_MERGE = 5'd16;
    localparam DONE              = 5'd17;

    // 临时变量
    reg [ADDR_WIDTH-1:0] x_curr, y_curr;
    reg [ADDR_WIDTH-1:0] parent_x_curr, parent_y_curr;
    reg [ADDR_WIDTH-1:0] x_root, y_root;
    reg [ADDR_WIDTH-1:0] rank_x_root, rank_y_root;
    reg [ADDR_WIDTH-1:0] init_counter; // 初始化计数器

    assign idle = (state == IDLE);

    // parent RAM的读写操作
    always @(posedge clk) begin
        if (parent_we_a)
            parent_ram[parent_addr_a] <= parent_din_a;
    end
    assign parent_dout_a = parent_ram[parent_addr_a];

    always @(posedge clk) begin
        if (parent_we_b)
            parent_ram[parent_addr_b] <= parent_din_b;
    end
    assign parent_dout_b = parent_ram[parent_addr_b];

    // rank RAM的读写操作
    always @(posedge clk) begin
        if (rank_we_a)
            rank_ram[rank_addr_a] <= rank_din_a;
    end
    assign rank_dout_a = rank_ram[rank_addr_a];

    always @(posedge clk) begin
        if (rank_we_b)
            rank_ram[rank_addr_b] <= rank_din_b;
    end
    assign rank_dout_b = rank_ram[rank_addr_b];

    // 状态机
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            result <= 0;
            // 复位RAM写使能信号
            parent_we_a <= 0; parent_we_b <= 0;
            rank_we_a <= 0;   rank_we_b <= 0;
            init_counter <= 0;
        end else begin
            // 默认RAM控制信号
            parent_we_a <= 0; parent_we_b <= 0;
            rank_we_a <= 0;   rank_we_b <= 0;
            case (state)
                IDLE: begin
                    done <= 0;
                    if (frame_start) begin
                        // 开始初始化RAM
                        init_counter <= 0;
                        state <= INIT_LOOP;
                    end else if (op == 2'b10) begin // FIND操作
                        x_curr <= node1;
                        state <= FIND_START;
                    end else if (op == 2'b01) begin // UNION操作
                        x_curr <= node1;
                        y_curr <= node2;
                        state <= UNION_START;
                    end
                end
                INIT_LOOP: begin
                    if (init_counter < N) begin
                        // 初始化 parent[init_counter] = init_counter 和 rank[init_counter] = 0
                        parent_addr_a <= init_counter;
                        parent_din_a  <= init_counter;
                        parent_we_a   <= 1;
                        rank_addr_a   <= init_counter;
                        rank_din_a    <= 0;
                        rank_we_a     <= 1;
                        init_counter  <= init_counter + 1;
                    end else begin
                        state <= IDLE;
                    end
                end
                // FIND操作状态
                FIND_START: begin
                    parent_addr_a <= x_curr;
                    state <= FIND_CHECK;
                end
                FIND_CHECK: begin
                    parent_x_curr <= parent_dout_a;
                    if (parent_x_curr == x_curr) begin
                        result <= x_curr;
                        done <= 1;
                        state <= IDLE;
                    end else begin
                        // 路径压缩
                        parent_addr_a <= parent_x_curr;
                        state <= FIND_UPDATE;
                    end
                end
                FIND_UPDATE: begin
                    // 更新 parent[x_curr] <= parent[parent_x_curr]
                    parent_din_a  <= parent_dout_a;
                    parent_we_a   <= 1;
                    x_curr        <= parent_x_curr;
                    state <= FIND_START;
                end
                // UNION操作状态
                UNION_START: begin
                    state <= UNION_FIND_X;
                end
                // 寻找x的根节点
                UNION_FIND_X: begin
                    parent_addr_a <= x_curr;
                    state <= UNION_CHECK_X;
                end
                UNION_CHECK_X: begin
                    parent_x_curr <= parent_dout_a;
                    if (parent_x_curr == x_curr) begin
                        x_root <= x_curr;
                        state <= UNION_FIND_Y;
                    end else begin
                        parent_addr_a <= parent_x_curr;
                        state <= UNION_UPDATE_X;
                    end
                end
                UNION_UPDATE_X: begin
                    // x的路径压缩
                    parent_din_a  <= parent_dout_a;
                    parent_we_a   <= 1;
                    x_curr        <= parent_x_curr;
                    state <= UNION_FIND_X;
                end
                // 寻找y的根节点
                UNION_FIND_Y: begin
                    parent_addr_a <= y_curr;
                    state <= UNION_CHECK_Y;
                end
                UNION_CHECK_Y: begin
                    parent_y_curr <= parent_dout_a;
                    if (parent_y_curr == y_curr) begin
                        y_root <= y_curr;
                        state <= UNION_MERGE;
                    end else begin
                        parent_addr_a <= parent_y_curr;
                        state <= UNION_UPDATE_Y;
                    end
                end
                UNION_UPDATE_Y: begin
                    // y的路径压缩
                    parent_din_a  <= parent_dout_a;
                    parent_we_a   <= 1;
                    y_curr        <= parent_y_curr;
                    state <= UNION_FIND_Y;
                end
                // 合并集合
                UNION_MERGE: begin
                    if (x_root != y_root) begin
                        // 读取 x_root 和 y_root 的 rank
                        rank_addr_a <= x_root;
                        rank_addr_b <= y_root;
                        state <= UNION_READ_RANKS;
                    end else begin
                        done <= 1;
                        state <= IDLE;
                    end
                end
                UNION_READ_RANKS: begin
                    rank_x_root <= rank_dout_a;
                    rank_y_root <= rank_dout_b;
                    state <= UNION_PERFORM_MERGE;
                end
                UNION_PERFORM_MERGE: begin
                    if (rank_x_root < rank_y_root) begin
                        // 将 x_root 挂在 y_root 下
                        parent_addr_a <= x_root;
                        parent_din_a  <= y_root;
                        parent_we_a   <= 1;
                    end else if (rank_x_root > rank_y_root) begin
                        // 将 y_root 挂在 x_root 下
                        parent_addr_a <= y_root;
                        parent_din_a  <= x_root;
                        parent_we_a   <= 1;
                    end else begin
                        // 将 y_root 挂在 x_root 下，并增加 x_root 的 rank
                        parent_addr_a <= y_root;
                        parent_din_a  <= x_root;
                        parent_we_a   <= 1;
                        rank_addr_a   <= x_root;
                        rank_din_a    <= rank_x_root + 1;
                        rank_we_a     <= 1;
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
