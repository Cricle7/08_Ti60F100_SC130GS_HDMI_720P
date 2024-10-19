// Main Module for Two-pass Connected Component Labeling with Perimeter and Area Calculation
module two_pass_labeling #(
    parameter IMG_HDISP = 1280,      // Image width
    parameter IMG_VDISP = 720,       // Image height
    parameter MAX_LABELS = 50,     // Maximum number of labels
    parameter MAX_AREA  = 2500,     // Maximum number of labels
    parameter MAX_PERIMETER_CALC = 1024,     // Maximum number of labels
    parameter ADDR_WIDTH = 8,        // Address width for labels
    parameter LABEL_INF_WIDTH = 32
) (
    input               clk,
    input               rst_n,
    // Input binary image signals
    input               per_frame_vsync,    // Frame sync
    input               per_frame_href,     // Line sync
    input       [7:0]   per_img_Y,          // Input pixel (0 or 255)

    // Output labeled image
    output  reg         post_frame_vsync,
    output  reg         post_frame_href

    //output              merged_area     ,// Area for each label
    //output              merged_perimeter,// Perimeter for each label
    //output              merged_valid    ,// Validity of each label
    //output              merged   ,        // Whether the label is merged
    //output              merged_pos  // {ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}


);
    // Internal signal declarations
    wire                matrix_frame_vsync;
    wire                matrix_frame_href;
    wire        [7:0]   matrix_p11, matrix_p12, matrix_p13;
    wire        [7:0]   matrix_p21, matrix_p22, matrix_p23;
    wire        [7:0]   matrix_p31, matrix_p32, matrix_p33;

    wire [3:0] merge_stop   = 0;
    wire [3:0] merge_start  = 1;
    wire [3:0] merge_idle   = 2;
    wire [3:0] merge_req    = 3;
    wire [3:0] merge_prog   = 5;
    wire [3:0] merge_done   = 6;

    reg [3:0] merge_state ;
    reg [3:0] merge_next_state ;

    // Combinational logic for Labeling Process
    //reg [ADDR_WIDTH-1:0]    current_label;
    //reg [ADDR_WIDTH-1:0]    label_image         [0:IMG_HDISP-1];
    wire prev_valid_x;
    reg prev_valid_x_1;

    reg [10:0]              x;
    reg [9:0]               y;
    reg [ADDR_WIDTH-1:0]    label_count;
    reg [ADDR_WIDTH-1:0]    find_label_count;
    //label information
    reg [LABEL_INF_WIDTH-1:0]   area             [0:MAX_LABELS-1];// Area for each label
    reg [LABEL_INF_WIDTH-1:0]   perimeter        [0:MAX_LABELS-1];// Perimeter for each label
    reg [MAX_LABELS-1:0]        valid            ;// Validity of each label

    reg [41:0]  target_pos[0:MAX_LABELS-1];// {ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}

    reg [LABEL_INF_WIDTH-1:0]   merged_area      [0:MAX_LABELS-1];// Area for each label
    reg [LABEL_INF_WIDTH-1:0]   merged_perimeter [0:MAX_LABELS-1];// Perimeter for each label
    reg                         merged_valid     [0:MAX_LABELS-1];// Validity of each label
    reg [MAX_LABELS-1:0]        merged           ;// Whether the label is merged
    reg [41:0]                  merged_pos       [0:MAX_LABELS-1];// {ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}


    reg [ADDR_WIDTH-1:0]        left_label;
    wire [ADDR_WIDTH-1:0]       above_label_reg;
    wire [ADDR_WIDTH-1:0]       above_label = (y ==0 || y == 1) ? 0 : above_label_reg;
    wire [ADDR_WIDTH-1:0]       next_label;


    wire [LABEL_INF_WIDTH-1:0]  updated_area;
    wire [LABEL_INF_WIDTH-1:0]  updated_perimeter;
    wire [9:0]                  update_bottom          ;       // 底部边界数组
    wire [10:0]                 update_left            ;       // 边界数组
    wire [10:0]                 update_right           ;       // 右边界数组
    wire [9:0]                  update_top             ;       // 顶部边界数组
    wire                        new_valid;

    reg surrounded_by_invalid_label;

    always @(posedge clk) begin
        post_frame_vsync <= matrix_frame_vsync;
        post_frame_href <= matrix_frame_href;
    end

    // Instantiate 3x3 Matrix Generator Module
    VIP_Matrix_Generate_3X3_8Bit #(
        .IMG_HDISP(IMG_HDISP),
        .IMG_VDISP(IMG_VDISP)
    ) u_VIP_Matrix_Generate_3X3_8Bit (
        .clk                (clk),
        .rst_n              (rst_n),
        .per_frame_vsync    (per_frame_vsync),
        .per_frame_href     (per_frame_href),
        .per_img_Y          (per_img_Y),
        .matrix_frame_vsync (matrix_frame_vsync),
        .matrix_frame_href  (matrix_frame_href),
        .matrix_p11         (matrix_p11),
        .matrix_p12         (matrix_p12),
        .matrix_p13         (matrix_p13),
        .matrix_p21         (matrix_p21),
        .matrix_p22         (matrix_p22),
        .matrix_p23         (matrix_p23),
        .matrix_p31         (matrix_p31),
        .matrix_p32         (matrix_p32),
        .matrix_p33         (matrix_p33)
    );

    // Instantiate Union-Find Module
    reg [ADDR_WIDTH-1:0] label_a, label_b;
    reg                  find_en;
    reg                  union_en;
    wire [ADDR_WIDTH-1:0] find_label_out;
    wire                  valid_out;
   
   
   
    wire fifo_full;
    wire fifo_empty;
    wire rst_busy;
    wire [ADDR_WIDTH*2 + 2 - 1:0]find_union_req_wfifo;
    wire [ADDR_WIDTH*2 + 2 - 1:0]find_union_req_rfifo;

    wire [1:0] op                       ;
    wire [ADDR_WIDTH-1:0]node1          ;
    wire [ADDR_WIDTH-1:0]node2          ;

    wire  [1:0] find_op                  ;
    wire  [ADDR_WIDTH-1:0]find_node1     ;

    assign op = (merge_state == merge_stop) ?find_union_req_rfifo[ADDR_WIDTH*2 + 2 - 1:ADDR_WIDTH*2]    : find_op;
    assign node1 = (merge_state == merge_stop) ?find_union_req_rfifo[ADDR_WIDTH*2 - 1:ADDR_WIDTH]       : find_node1;
    assign node2 =find_union_req_rfifo[ADDR_WIDTH - 1:0];

    assign find_node1 = find_label_count;
    assign find_op = {(merge_state == merge_req),0};


    union_find #(
        .N(MAX_LABELS),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_union_find (
        .clk              (clk              ),
        .reset            (rst_fifo         ),
        .op               (op               ),
        .node1            (node1            ),
        .node2            (node2            ),
        .result           (find_label_out   ),
        .done             (valid_out        ),
        .idle             (union_find_idle  )
    );

	reg 	[1:0] 	r_vsync_i = 0; 
	always @(posedge clk) begin
		r_vsync_i <= {r_vsync_i, matrix_frame_vsync}; 
	end

	reg 	[1:0] 	r_href_i = 0; 
    always @(posedge clk) begin
		r_href_i <= {r_href_i, matrix_frame_href}; 
        if (rst_fifo) begin
            y <= 0;
        end else if (r_href_i == 1) begin
            y <= y + 1;
        end
    end
    assign rst_fifo = !rst_n || (r_vsync_i == 2'b01);
    assign find_union_req_wfifo = {find_en,union_en, label_a, label_b};

    wire [1:0] rfifo_en_idle = 2'b00;
    wire [1:0] rfifo_en_req = 2'b01;
    wire [1:0] rfifo_en_prog = 2'b10;

    reg [1:0] rfifo_en_state;
    reg [1:0] rfifo_en_next_state;

    always @(posedge clk) begin
        if(!rst_n)
            rfifo_en_state <= rfifo_en_idle;
        else begin
            rfifo_en_state <= rfifo_en_next_state;
        end
    end

    always @(*) begin
        case(rfifo_en_state)
            rfifo_en_idle:rfifo_en_next_state = fifo_empty ? rfifo_en_idle : rfifo_en_req;
            rfifo_en_req:rfifo_en_next_state = rfifo_en_prog;
            rfifo_en_prog:rfifo_en_next_state = valid_out ? rfifo_en_idle : rfifo_en_prog;
        endcase
    end
    find_union_fifo_512  u_find_union_fifo_512(
        .full_o ( fifo_full ),
        .empty_o        ( fifo_empty                        ),
        .clk_i          ( clk                               ),
        .wr_en_i        ( find_en | union_en                ),
        .rd_en_i        ( rfifo_en_state == rfifo_en_req    ),
        .wdata          ( find_union_req_wfifo              ),
        .datacount_o    (                        ),
        .rst_busy       ( rst_busy                          ),
        .rdata          ( find_union_req_rfifo              ),
        .a_rst_i        ( rst_fifo                          )
    );
    // Instantiate Perimeter Calculation Module
    wire [3:0] perimeter_out;

    perimeter_calc u_perimeter_calc (
        .p11            (matrix_p11),
        .p12            (matrix_p12),
        .p13            (matrix_p13),
        .p21            (matrix_p21),
        .p22            (matrix_p22),
        .p23            (matrix_p23),
        .p31            (matrix_p31),
        .p32            (matrix_p32),
        .p33            (matrix_p33),
        .perimeter_out  (perimeter_out)
    );


//    always @(*) begin
        //surrounded_by_invalid_label =    (x == 0) ? 
                                            //(prev_valid[x] & prev_valid[x+1] ? 0 : 1) : 
                                            //(x == 1) ? 
                                            //(prev_valid[x-1] & prev_valid[x] & valid[left_label] ? 0 : 1) : 
                                            //(x == IMG_VDISP-1) ? 
                                            //(prev_valid[x-1] & prev_valid[x] & valid[left_label] ? 0 : 1) : 
                                            //(prev_valid[x-1] & prev_valid[x] & prev_valid[x+1] & valid[left_label] ? 0 : 1);
    //end

    always @(*) begin
        surrounded_by_invalid_label =    (x == 0) ? 
                                            (prev_valid_x ? 0 : 1) : 
                                            (prev_valid_x_1 & prev_valid_x & valid[left_label] ? 0 : 1);
    end   

//    assign next_label = (left_label == 0 && above_label == 0) ? label_count + !surrounded_by_invalid_label :
                        //(left_label != 0 && above_label == 0) ? left_label :
                        //(left_label == 0 && above_label != 0) ? above_label :
                        //(left_label < above_label) ? left_label : above_label;

    assign next_label = (left_label == 0 && above_label == 0) ? label_count + 1 :
                        (left_label != 0 && above_label == 0) ? left_label :
                        (left_label == 0 && above_label != 0) ? above_label :
                        (left_label < above_label) ? left_label : above_label;

    assign updated_area = area[next_label] + 1;
    assign updated_perimeter = perimeter[next_label] + perimeter_out;

    assign update_bo2ttom = y;       // 底部边界数组
    assign update_left = (left_label == 0 && above_label == 0) ? x : target_pos [next_label][10: 0];       // 边界数组
    assign update_right = (x > target_pos [next_label][31:21]) ? x : target_pos [next_label][31:21];       // 右边界数组
    assign update_top = (left_label == 0 && above_label == 0)? y : target_pos [next_label][20:11]           ;       // 顶部边界数组

    assign new_valid = (next_label == 1) ? 0 :
                       (updated_area > MAX_AREA) ? 0 : 1;

    // Sequential logic for updating connected component features and label count
    integer i;
    always @(posedge clk) begin
        if (rst_fifo) begin
            area[0] <= 0;
            perimeter[0] <= 0;
            valid[0] <= 0;
            for (i = 1; i < MAX_LABELS; i = i + 1) begin
                area[i] <= 0;
                perimeter[i] <= 0;
                valid[i] <= 1;
            end
            label_count <= 0;
        //mark labels
        end else if(matrix_frame_href && matrix_p22 == 8'd255) begin
            if (surrounded_by_invalid_label) begin
                valid[next_label] <= 0;
            end else begin
                area[next_label] <= updated_area;
                perimeter[next_label] <= updated_perimeter;
                valid[next_label] <= new_valid;
                if (left_label == 0 && above_label == 0) begin
                    label_count <= label_count + 1;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (rst_fifo) left_label <= 0;
        left_label <= next_label;
    end

    integer j;
    always @(posedge clk) begin
        // 初始化各运动目标的边界为0
        if (rst_fifo) begin
            for (j = 1; j < MAX_LABELS; j = j + 1) begin
                target_pos[j] <= 0;
            end
        end else begin
            if(matrix_frame_href && matrix_p22 == 8'd255) begin
                target_pos[next_label] <= {update_bottom,update_right,update_top,update_left};
            end
        end
    end

//    integer k;
    //always @(posedge clk) begin
        //if (rst_fifo) begin
            //for (k = 1; k < MAX_LABELS; k = k + 1) begin
                //label_image[k] = 0;
            //end
        //end else if (matrix_frame_href) begin
            //if (matrix_p22 == 8'd255) begin // Only label foreground pixels
                //label_image[x] = next_label;
            //end else begin
                //label_image[x] = 0; // Background pixels have no label
            //end
        //end
    //end
    always @(*) begin
        if (matrix_frame_href) begin
            if (left_label != above_label && left_label != 0 && above_label != 0) begin
                union_en = 1;
                label_a = left_label;
                label_b = above_label;
            end else begin
                union_en = 0;
            end
        end else begin
            union_en = 0;
        end
    end

    always @(posedge clk) begin
        if (rst_fifo) begin
            x <= 0;
        end 
        else if (r_href_i == 2) begin
            x <= 0;
            // Update previous line labels
        end else begin
            x <= x + 1;
        end
    end

    Line_Shift_RAM_8Bit #(
        .DATA_WIDTH (ADDR_WIDTH ),
        .ADDR_WIDTH (11         ),
        .DATA_DEPTH (IMG_HDISP  ),
        .DELAY_NUM  (0          )
    ) prev_image_label (
        .clk        (clk        ),
        .rst_n      (rst_n      ),
        .clken      (matrix_frame_href),
        .din        (next_label ),
        .dout       (above_label_reg)
    );

    Line_Shift_RAM_8Bit #(
        .DATA_WIDTH (1          ),
        .ADDR_WIDTH (11         ),
        .DATA_DEPTH (IMG_HDISP  ),
        .DELAY_NUM  (0          )
    ) prev_image_valid (
        .clk        (clk        ),
        .rst_n      (rst_n      ),
        .clken      (matrix_frame_href),
        .din        (valid[next_label]),
        .dout       (prev_valid_x)
    );

    always @(posedge clk) begin
        if (matrix_frame_href) begin
            prev_valid_x_1 <= prev_valid_x;
        end
    end


    always @(posedge clk) begin
        if (rst_fifo) begin
            merge_state <= merge_stop;
        end else begin
            merge_state <= merge_next_state;
        end
    end

    always @(*) begin
        case (merge_state) 
            merge_stop  : merge_next_state  = (!matrix_frame_vsync) ? merge_idle : merge_stop; 
            merge_idle  : merge_next_state  = (fifo_empty | union_find_idle) ? merge_req : merge_idle; 
            merge_req   : merge_next_state  = ((find_label_count == label_count + 1)|| matrix_frame_vsync ) ? merge_stop : merge_prog; 
            merge_prog  : merge_next_state  = (valid_out)? merge_done : merge_stop; 
            merge_done  : merge_next_state  = merge_idle; 
            default: merge_next_state       = merge_stop;
        endcase
    end

    integer ii;
    always @(posedge clk) begin
        if (rst_fifo) begin
            find_en <= 0;
            find_label_count <= 0;
            for (ii = 1; ii < MAX_LABELS; ii = ii + 1) begin
                merged <= 0;
            end
        end else if (!matrix_frame_vsync) begin//merge labels and its information
            if (merge_state == merge_stop ) begin
               find_label_count <= 0; 
            end else if (merge_state == merge_idle) begin
                find_label_count = find_label_count + 1;
            end else if (merge_state == merge_done) begin
                if (find_label_count != find_label_out) begin
                    merged_area     [find_label_out]    <= merged_area      [find_label_out] + merged_area      [find_label_count];
                    merged_perimeter[find_label_out]    <= updated_perimeter[find_label_out] + updated_perimeter[find_label_count];
                    merged_valid    [find_label_out]    <= merged_valid     [find_label_out] | merged_valid     [find_label_count];
                    merged     [find_label_count] <= 1'b1;
                    if ( merged_area[find_label_out] + merged_area[find_label_count] > MAX_AREA) begin
                        merged_valid    [find_label_out] <= 1'b0;
                    end
					if(target_pos[find_label_count][10: 0] > target_pos[find_label_out][10: 0]) 	// 左边界
                        merged_pos[find_label_count][10: 0] <= target_pos[find_label_out][10: 0];
                    else 
                        merged_pos[find_label_count][10: 0] <= target_pos[find_label_out][10: 0];
					if(target_pos[find_label_count][20:11] > target_pos[find_label_out][20:11]) 	//  上边界
                        merged_pos[find_label_count][20:11] <= target_pos[find_label_out][20:11];
                    else 
                        merged_pos[find_label_count][20:11] <= target_pos[find_label_out][20:11];
					if(target_pos[find_label_count][31:21] < target_pos[find_label_out][31:21]) 	// 右边界
                        merged_pos[find_label_count][31:21] <= target_pos[find_label_out][31:21];
                    else 
                        merged_pos[find_label_count][31:21] <= target_pos[find_label_out][31:21];
					if(target_pos[find_label_count][41:32] < target_pos[find_label_out][41:32]) 	// 下边界
                        merged_pos[find_label_count][41:32] <= target_pos[find_label_out][41:32];
                    else 
                        merged_pos[find_label_count][41:32] <= target_pos[find_label_out][41:32];
                end else begin
                    merged_area     [find_label_out]    <= area         [find_label_out];
                    merged_perimeter[find_label_out]    <= perimeter    [find_label_out];
                    merged_valid    [find_label_out]    <= valid        [find_label_out];
                    merged_pos      [find_label_out]    <= target_pos   [find_label_out];// {ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}
                end
            end
        end
    end

//    always @(posedge clk) begin
        //if (rst_fifo) begin
            //post_label <= 0;
            //find_en <= 0;
            //find_label_count <= 0;
        //end 
        //else if (!per_frame_vsync) begin // Perform union at the end of each frame
            //// Find and update current pixel's label immediately
            //if (label_image[find_label_count] != 0) begin
                //find_en <= 1;
                //find_label_in <= label_image[find_label_count];
                //post_label <= find_label_out;
                //if (!valid_out) begin
                    //post_label <= 0;
                //end
            //end else begin
                //find_en <= 0;
                //post_label <= 0;
            //end
        //end else begin
            //post_label <= 0;
        //end
    //end
endmodule

module perimeter_calc (
    input       [7:0]   p11, p12, p13,
    input       [7:0]   p21, p22, p23,
    input       [7:0]   p31, p32, p33,
    output reg  [3:0]   perimeter_out  // Perimeter increment, range 0-4
);
    always @(*) begin
        perimeter_out = 0;
        if (p12 != 8'd255) perimeter_out = perimeter_out + 1; // Left
        if (p32 != 8'd255) perimeter_out = perimeter_out + 1; // Right
        if (p21 != 8'd255) perimeter_out = perimeter_out + 1; // Top
        if (p23 != 8'd255) perimeter_out = perimeter_out + 1; // Bottom
    end
endmodule

module ping_pong_ram #(
    parameter DATA_WIDTH = 8,   // 数据宽度
    parameter IMG_HDISP = 640   // 一行的像素数
)(
    input wire clk,
    input wire rst,
    input wire wr_en,           // 写使能信号
    input wire [DATA_WIDTH-1:0] data_in, // 当前行的数据输入
    input wire [$clog2(IMG_HDISP)-1:0] addr_in, // 地址输入 (范围从 0 到 IMG_HDISP-1)
    output wire [DATA_WIDTH-1:0] data_out // 上一行的数据输出
);

    // 定义两个 RAM
    reg [DATA_WIDTH-1:0] ram0 [0:IMG_HDISP-1]; // RAM 0
    reg [DATA_WIDTH-1:0] ram1 [0:IMG_HDISP-1]; // RAM 1

    reg select; // 用于选择当前使用的 RAM

    // 写入当前行数据
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            select <= 1'b0; // 复位时，选择RAM0作为初始写入
        end else begin
            if (wr_en) begin
                if (select == 1'b0) begin
                    ram0[addr_in] <= data_in; // 将当前行数据写入 RAM 0
                end else begin
                    ram1[addr_in] <= data_in; // 将当前行数据写入 RAM 1
                end
            end
        end
    end

    // 读取上一行数据
    assign data_out = (select == 1'b0) ? ram1[addr_in] : ram0[addr_in];

    // 在每一行结束后切换 RAM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            select <= 1'b0; // 复位时选择RAM0
        end else begin
            if (addr_in == IMG_HDISP - 1) begin
                select <= ~select; // 每一行结束时切换 RAM
            end
        end
    end

endmodule
