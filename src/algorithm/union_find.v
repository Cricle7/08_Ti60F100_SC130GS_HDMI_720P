module union_find #(
    parameter N = 256,                 // 元素数量
    parameter ADDR_WIDTH = 8           // 地址宽度
)(
    input clk,
    input reset,
    input [1:0] op,                    // 操作码：00 - idle，01 - union , 10 - find
    input [ADDR_WIDTH-1:0] node1,
    input [ADDR_WIDTH-1:0] node2,
    output reg [ADDR_WIDTH-1:0] result, // find操作的结果
    output reg done,                    // 操作完成标志
    output wire idle                    // operation in idle state
);

    // 父节点和秩的存储
    reg [ADDR_WIDTH-1:0] parent [0:N-1];
    reg [ADDR_WIDTH-1:0] rank   [0:N-1];

    // 状态机状态
    reg [2:0] state;
    wire [2:0] IDLE        = 3'd0;
    wire [2:0] FIND        = 3'd1;
    wire [2:0] UNION_FIND  = 3'd2;
    wire [2:0] UNION_MERGE = 3'd3;

    // 临时变量
    reg [ADDR_WIDTH-1:0] x_root, y_root;
    reg [ADDR_WIDTH-1:0] x_curr, y_curr;
    reg x_done, y_done;

    assign idle = (state == IDLE);
    integer i;

    // 初始化
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < N; i = i + 1) begin
                parent[i] <= i[ADDR_WIDTH-1:0];
                rank[i]   <= 0;
            end
            state   <= IDLE;
            done    <= 0;
            result  <= 0;
            x_done  <= 0;
            y_done  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done   <= 0;
                    x_done <= 0;
                    y_done <= 0;
                    if (op == 2'b10) begin // FIND操作
                        x_curr <= node1;
                        state  <= FIND;
                    end else if (op == 2'b01) begin // UNION操作
                        x_curr <= node1;
                        y_curr <= node2;
                        state  <= UNION_FIND;
                    end
                end
                FIND: begin
                    if (parent[x_curr] == x_curr) begin
                        result <= x_curr;
                        done   <= 1;
                        state  <= IDLE;
                    end else begin
                        parent[x_curr] <= parent[parent[x_curr]]; // 路径压缩
                        x_curr         <= parent[x_curr];
                    end
                end
                UNION_FIND: begin
                    // 同时寻找 x 和 y 的根节点
                    if (!x_done) begin
                        if (parent[x_curr] == x_curr) begin
                            x_root <= x_curr;
                            x_done <= 1;
                        end else begin
                            parent[x_curr] <= parent[parent[x_curr]]; // 路径压缩
                            x_curr         <= parent[x_curr];
                        end
                    end
                    if (!y_done) begin
                        if (parent[y_curr] == y_curr) begin
                            y_root <= y_curr;
                            y_done <= 1;
                        end else begin
                            parent[y_curr] <= parent[parent[y_curr]]; // 路径压缩
                            y_curr         <= parent[y_curr];
                        end
                    end
                    if (x_done && y_done) begin
                        state <= UNION_MERGE;
                    end
                end
                UNION_MERGE: begin
                    // 合并操作
                    if (x_root != y_root) begin
                        if (rank[x_root] < rank[y_root]) begin
                            parent[x_root] <= y_root;
                        end else if (rank[x_root] > rank[y_root]) begin
                            parent[y_root] <= x_root;
                        end else begin
                            parent[y_root] <= x_root;
                            rank[x_root]   <= rank[x_root] + 1;
                        end
                    end
                    done  <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
