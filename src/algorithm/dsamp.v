module VIP_multi_target_detect (
    input                clk,
    input                rst_n,
    input                per_frame_vsync,
    input                per_frame_href,
    input                per_frame_clken,
    input                per_img_Bit,
    output reg [42:0]    target_pos_out1, // {Flag, ymax[41:32], xmax[31:21], ymin[20:11], xmin[10:0]}
    output reg [42:0]    target_pos_out2,
    input      [9:0]     MIN_DIST
    // input               disp_sel // 未知用处
);

    // 参数定义
    parameter [10:0] IMG_HDISP = 11'd1280;
    parameter [9:0]  IMG_VDISP = 10'd720;

    // 信号同步（延迟一个时钟周期）
    reg per_frame_vsync_r;
    reg per_frame_href_r;
    reg per_frame_clken_r;
    reg per_img_Bit_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_frame_vsync_r  <= 1'b0;
            per_frame_href_r   <= 1'b0;
            per_frame_clken_r  <= 1'b0;
            per_img_Bit_r      <= 1'b0;
        end else begin
            per_frame_vsync_r  <= per_frame_vsync;
            per_frame_href_r   <= per_frame_href;
            per_frame_clken_r  <= per_frame_clken;
            per_img_Bit_r      <= per_img_Bit;
        end
    end

    // vsync 上升沿和下降沿检测
    wire vsync_pos_flag = per_frame_vsync & ~per_frame_vsync_r;
    wire vsync_neg_flag = ~per_frame_vsync & per_frame_vsync_r;

    // 纵横坐标计数器
    reg [10:0] x_cnt;
    reg [9:0]  y_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_cnt <= 11'd0;
            y_cnt <= 10'd0;
        end
        else if (!per_frame_vsync) begin
            x_cnt <= 11'd0;
            y_cnt <= 10'd0;
        end
        else if (per_frame_clken) begin
            if (x_cnt < IMG_HDISP - 1) begin
                x_cnt <= x_cnt + 1'b1;
            end else begin
                x_cnt <= 11'd0;
                y_cnt <= y_cnt + 1'b1;
            end
        end
    end

    // 寄存当前计数值
    reg [10:0] x_cnt_r;
    reg [9:0]  y_cnt_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_cnt_r <= 11'd0;
            y_cnt_r <= 10'd0;
        end else begin
            x_cnt_r <= x_cnt;
            y_cnt_r <= y_cnt;
        end
    end

    // 目标位置寄存器
    reg [42:0] target_pos1;
    reg [42:0] target_pos2;

    // 目标有效标志
    wire [1:0] target_flag = {target_pos2[42], target_pos1[42]};

    // 计算目标的领域范围
    wire [10:0] target_left1    = (target_pos1[10:0] > MIN_DIST) ? (target_pos1[10:0] - MIN_DIST) : 11'd0;
    wire [10:0] target_right1   = (target_pos1[31:21] < IMG_HDISP - 1 - MIN_DIST) ? (target_pos1[31:21] + MIN_DIST) : IMG_HDISP - 1;
    wire [9:0]  target_top1     = (target_pos1[20:11] > MIN_DIST) ? (target_pos1[20:11] - MIN_DIST) : 10'd0;
    wire [9:0]  target_bottom1  = (target_pos1[41:32] < IMG_VDISP - 1 - MIN_DIST) ? (target_pos1[41:32] + MIN_DIST) : IMG_VDISP - 1;

    wire [10:0] target_left2    = (target_pos2[10:0] > MIN_DIST) ? (target_pos2[10:0] - MIN_DIST) : 11'd0;
    wire [10:0] target_right2   = (target_pos2[31:21] < IMG_HDISP - 1 - MIN_DIST) ? (target_pos2[31:21] + MIN_DIST) : IMG_HDISP - 1;
    wire [9:0]  target_top2     = (target_pos2[20:11] > MIN_DIST) ? (target_pos2[20:11] - MIN_DIST) : 10'd0;
    wire [9:0]  target_bottom2  = (target_pos2[41:32] < IMG_VDISP - 1 - MIN_DIST) ? (target_pos2[41:32] + MIN_DIST) : IMG_VDISP - 1;

    // 新目标检测逻辑
    reg [1:0] new_target_flag;
    reg target_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            target_pos1      <= 43'd0;
            target_pos2      <= 43'd0;
            new_target_flag  <= 2'd0;
            target_cnt       <= 1'd0;
        end
        else if (vsync_pos_flag) begin
            // 一帧开始时初始化
            target_pos1      <= 43'd0;
            target_pos2      <= 43'd0;
            new_target_flag  <= 2'd0;
            target_cnt       <= 1'd0;
        end
        else if (per_frame_clken_r && per_img_Bit_r) begin
            // 检测新目标标志
            new_target_flag[0] <= (~target_flag[0]) || 
                                   (x_cnt < target_left1 || x_cnt > target_right1 || y_cnt < target_top1 || y_cnt > target_bottom1);
            new_target_flag[1] <= (~target_flag[1]) || 
                                   (x_cnt < target_left2 || x_cnt > target_right2 || y_cnt < target_top2 || y_cnt > target_bottom2);
            
            // 更新目标列表
            if (new_target_flag == 2'b11) begin
                if (target_cnt == 1'b0) begin
                    target_pos1 <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
                    target_cnt  <= target_cnt + 1'd1;
                end
                else if (target_cnt == 1'b1 && ~target_pos2[42]) begin
                    target_pos2 <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
                end
            end
            else if (|new_target_flag) begin
                if (~new_target_flag[0]) begin
                    // 更新 target_pos1 的边界
                    target_pos1[10:0]  <= (x_cnt_r < target_pos1[10:0]) ? x_cnt_r : target_pos1[10:0];
                    target_pos1[31:21] <= (x_cnt_r > target_pos1[31:21]) ? x_cnt_r : target_pos1[31:21];
                    target_pos1[20:11] <= (y_cnt_r < target_pos1[20:11]) ? y_cnt_r : target_pos1[20:11];
                    target_pos1[41:32] <= (y_cnt_r > target_pos1[41:32]) ? y_cnt_r : target_pos1[41:32];
                end
                if (~new_target_flag[1]) begin
                    // 更新 target_pos2 的边界
                    target_pos2[10:0]  <= (x_cnt_r < target_pos2[10:0]) ? x_cnt_r : target_pos2[10:0];
                    target_pos2[31:21] <= (x_cnt_r > target_pos2[31:21]) ? x_cnt_r : target_pos2[31:21];
                    target_pos2[20:11] <= (y_cnt_r < target_pos2[20:11]) ? y_cnt_r : target_pos2[20:11];
                    target_pos2[41:32] <= (y_cnt_r > target_pos2[41:32]) ? y_cnt_r : target_pos2[41:32];
                end
            end
        end
    end

    // 输出结果寄存
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            target_pos_out1 <= 43'd0;
            target_pos_out2 <= 43'd0;
        end
        else if (vsync_neg_flag) begin
            target_pos_out1 <= target_pos1;
            target_pos_out2 <= target_pos2;
        end
    end

endmodule
