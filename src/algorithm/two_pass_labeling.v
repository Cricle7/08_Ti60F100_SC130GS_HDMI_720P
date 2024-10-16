// Main Module for Two-pass Connected Component Labeling with Perimeter and Area Calculation
module two_pass_labeling #(
    parameter IMG_HDISP = 1280,      // Image width
    parameter IMG_VDISP = 720,       // Image height
    parameter MAX_LABELS = 512,     // Maximum number of labels
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
    output              post_frame_vsync,
    output              post_frame_href,
    output      [31:0]  post_label          // Output label (0 for background)
    
);

    // Internal signal declarations
    wire                matrix_frame_vsync;
    wire                matrix_frame_href;
    wire        [7:0]   matrix_p11, matrix_p12, matrix_p13;
    wire        [7:0]   matrix_p21, matrix_p22, matrix_p23;
    wire        [7:0]   matrix_p31, matrix_p32, matrix_p33;

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
    wire [ADDR_WIDTH-1:0] label_a, label_b;
    wire                  find_en;
    wire [ADDR_WIDTH-1:0] find_label_in;
    wire [ADDR_WIDTH-1:0] find_label_out;
    wire                  invalidate_en;
    wire [ADDR_WIDTH-1:0] invalidate_label;
    wire                  valid_out;
   
   
   
    wire fifo_full;
    wire fifo_empty;
    wire rst_busy;
    wire [8:0] data_count_o;
    wire rst_busy;
    wire [ADDR_WIDTH*2 + 2 - 1:0]find_union_req_wfifo;
    wire [ADDR_WIDTH*2 + 2 - 1:0]find_union_req_rfifo;

    wire [1:0] op                       ;
    wire [ADDR_WIDTH-1:0]node1          ;
    wire [ADDR_WIDTH-1:0]node2          ;

    reg  [1:0] find_op                  ;
    reg  [ADDR_WIDTH-1:0]find_node1     ;

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
        .datacount_o    ( datacount_o                       ),
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

    // Combinational logic for Labeling Process
    reg [ADDR_WIDTH-1:0]    current_label;
    reg [ADDR_WIDTH-1:0]    label_image      [0:IMG_HDISP-1];
    reg [ADDR_WIDTH-1:0]    prev_label_image [0:IMG_HDISP-1];//previous hor
    wire [ADDR_WIDTH-1:0]   prev_valid       [0:IMG_HDISP-1];

    reg [13:0]              x;
    reg [ADDR_WIDTH-1:0]    label_count;
    reg [ADDR_WIDTH-1:0]    find_label_count;
    //label information
    reg [LABEL_INF_WIDTH-1:0]   area             [0:MAX_LABELS-1];// Area for each label
    reg [LABEL_INF_WIDTH-1:0]   perimeter        [0:MAX_LABELS-1];// Perimeter for each label
    reg                         valid            [0:MAX_LABELS-1];// Validity of each label

    wire [41:0] target_pos;// {ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}
    wire [41:0] updated_pos;// {ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}

    reg [9:0]                   bottom           [MAX_LABELS];       // 底部边界数组
    reg [10:0]                  letf             [MAX_LABELS];       // 边界数组
    reg [10:0]                  right            [MAX_LABELS];       // 右边界数组
    reg [9:0]                   top              [MAX_LABELS];          // 顶部边界数组

    reg [LABEL_INF_WIDTH-1:0]   merged_area      [0:MAX_LABELS-1];// Area for each label
    reg [LABEL_INF_WIDTH-1:0]   merged_perimeter [0:MAX_LABELS-1];// Perimeter for each label
    reg                         merged_valid     [0:MAX_LABELS-1];// Validity of each label
    reg                         merged           [0:MAX_LABELS-1];// Whether the label is merged
    reg [9:0]                   merged_bottom    [MAX_LABELS];       // 底部边界数组
    reg [10:0]                  merged_letf      [MAX_LABELS];       // 边界数组
    reg [10:0]                  merged_right     [MAX_LABELS];       // 右边界数组
    reg [9:0]                   merged_top       [MAX_LABELS];       // 顶部边界数组


    wire [ADDR_WIDTH-1:0]       left_label = (x == 0) ? 0 : label_image[x - 1];
    wire [ADDR_WIDTH-1:0]       above_label = prev_label_image[x];
    wire [ADDR_WIDTH-1:0]       next_label;


    wire [LABEL_INF_WIDTH-1:0]  updated_area;
    wire [LABEL_INF_WIDTH-1:0]  updated_perimeter;
    wire                        new_valid;

    wire surrounded_by_invalid_label;
    assign prev_valid[x] = valid[label_image[x]];
    assign surrounded_by_invalid_label =    (x == 0) ? 
                                            (prev_valid[x] & prev_valid[x+1] ? 0 : 1) : 
                                            (x == 1) ? 
                                            (prev_valid[x-1] & prev_valid[x] & vaild[x-1] ? 0 : 1) : 
                                            (x == IMG_VDISP-1) ? 
                                            (prev_valid[x-1] & prev_valid[x] & vaild[x-1] ? 0 : 1) : 
                                            (prev_valid[x-1] & prev_valid[x] & prev_valid[x+1] & vaild[x-1] ? 0 : 1);

    assign next_label = (left_label == 0 && above_label == 0) ? label_count + !surrounded_by_invalid_label :
                        (left_label != 0 && above_label == 0) ? left_label :
                        (left_label == 0 && above_label != 0) ? above_label :
                        (left_label < above_label) ? left_label : above_label;

    assign updated_area = area[next_label] + 1;
    assign updated_perimeter = perimeter[next_label] + perimeter_out;

    assign new_valid = (next_label == 1) ? 0 :
                       (updated_area > MAX_AREA || updated_area < MIN_AREA) ? 0 : 1;

    // Sequential logic for updating connected component features and label count
    always @(posedge clk) begin
        if (rst_fifo) begin
            integer i;
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

    always @(posedge clk or negedge rst_n) begin
        // 初始化各运动目标的边界为0
        if (!rst_n) begin
            target_pos1 <= {1'b0, 10'd0, 11'd0, 10'd0, 11'd0};
            target_pos2 <= {1'b0, 10'd0, 11'd0, 10'd0, 11'd0};
            new_target_flag <= 2'd0;
            target_cnt <= 1'd0;
        end
    
        // 在一帧开始进行初始化
        else if(vsync_pos_flag) begin
            target_pos1 <= {1'b0, 10'd0, 11'd0, 10'd0, 11'd0};
            target_pos2 <= {1'b0, 10'd0, 11'd0, 10'd0, 11'd0};
		    new_target_flag <= 2'd0;
		    target_cnt <= 1'd0;
        end
        else begin
            // 第一个时钟周期，找出标记为运动目标的像素点，由运动目标列表中的元素进行投票，判断是否为全新的运动目标
            if(per_frame_clken && per_img_Bit ) begin
			    if(target_flag[0] == 1'b0)			// 运动目标列表中的数据无效，则该元素投认定输入的灰度为新的最大值
				    new_target_flag[0] <= 1'b1;
			    else begin							// 运动目标列表中的数据有效，则判断当前像素是否落在该元素临域里
				    if((x_cnt < target_left1 || x_cnt > target_right1 || y_cnt < target_top1 || y_cnt > target_bottom1))	//坐标距离超出目标临域范围，投票认定为新的目标
					    new_target_flag[0] <= 1'b1;
				    else
					    new_target_flag[0] <= 1'b0;                
		        end
			
			    if(target_flag[1] == 1'b0)			// 运动目标列表中的数据无效，则该元素投认定输入的灰度为新的最大值
				    new_target_flag[1] <= 1'b1;
			    else begin							// 运动目标列表中的数据有效，则判断当前像素是否落在该元素临域里
				    if((x_cnt < target_left2 || x_cnt > target_right2 || y_cnt < target_top2 || y_cnt > target_bottom2))	//坐标距离超出目标临域范围，投票认定为新的目标
					    new_target_flag[1] <= 1'b1;
				    else
					    new_target_flag[1] <= 1'b0;                
		        end
            end
            else begin
			    new_target_flag <= 2'b0;
            end

		
            // 第二个时钟周期，根据投票结果，将候选数据更新到运动目标列表中
            if(per_frame_clken_r && per_img_Bit_r) begin
                if(new_target_flag == 2'b11) begin 	// 全票通过，标志着出现新的运动目标
                    if(target_cnt == 1'b0)begin
                        target_cnt <= target_cnt + 1'd1;
                        target_pos1 <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
                    end				
                    else if(target_cnt == 1'b1 && target_pos2[42] != 1'b1)begin
                        target_pos2 <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
                    end
                end
                
                else if (new_target_flag > 2'd0 && new_target_flag != 2'b11) begin // 出现被标记为运动目标的像素点，但是落在运动目标列表中某个元素的临域内
                    if(new_target_flag[0] == 1'b0) begin // 未投票认定新目标的元素，表示当前像素位于它的临域内
                    
                        target_pos1[42] <= 1'b1;

                        if(x_cnt_r < target_pos1[10: 0]) 	// 若X坐标小于左边界，则将其X坐标扩展为左边界
                            target_pos1[10: 0] <= x_cnt_r;
                        if(x_cnt_r > target_pos1[31:21]) 	// 若X坐标大于右边界，则将其X坐标扩展为右边界
                            target_pos1[31:21] <= x_cnt_r;
                        if(y_cnt_r < target_pos1[20:11]) 	// 若Y坐标小于上边界，则将其Y坐标扩展为上边界
                            target_pos1[20:11] <= y_cnt_r;
                        if(y_cnt_r > target_pos1[41:32]) 	// 若Y坐标大于下边界，则将其Y坐标扩展为下边界
                            target_pos1[41:32] <= y_cnt_r;
                    end
                    else if(new_target_flag[1] == 1'b0) begin // 未投票认定新目标的元素，表示当前像素位于它的临域内
                    
                        target_pos2[42] <= 1'b1;

                        if(x_cnt_r < target_pos2[10: 0]) 	// 若X坐标小于左边界，则将其X坐标扩展为左边界
                            target_pos2[10: 0] <= x_cnt_r;
                        if(x_cnt_r > target_pos2[31:21]) 	// 若X坐标大于右边界，则将其X坐标扩展为右边界
                            target_pos2[31:21] <= x_cnt_r;
                        if(y_cnt_r < target_pos2[20:11]) 	// 若Y坐标小于上边界，则将其Y坐标扩展为上边界
                            target_pos2[20:11] <= y_cnt_r;
                        if(y_cnt_r > target_pos2[41:32]) 	// 若Y坐标大于下边界，则将其Y坐标扩展为下边界
                            target_pos2[41:32] <= y_cnt_r;
                    end
                end
            end
        end
    end

    always @(*) begin
        if (matrix_frame_href) begin
            if (matrix_p22 == 8'd255) begin // Only label foreground pixels
                label_image[x] = next_label;
            end else begin
                label_image[x] = 0; // Background pixels have no label
            end
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
            integer i;
            for (i = 0; i < IMG_HDISP; i = i + 1) begin
                prev_label_image[i] <= 0;
            end
        end 
        else if (~matrix_frame_href) begin
            x <= 0;
            // Update previous line labels
            integer i;
            for (i = 0; i < IMG_HDISP; i = i + 1) begin
                prev_label_image[i] <= label_image[i];
            end
        end else begin
            x <= x + 1;
        end
    end

    wire [3:0] merge_stop   = 0;
    wire [3:0] merge_start  = 1;
    wire [3:0] merge_idle   = 2;
    wire [3:0] merge_req    = 3;
    wire [3:0] merge_prog   = 5;
    wire [3:0] merge_done   = 6;

    reg [3:0] merge_state ;
    reg [3:0] merge_next_state ;

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
        endcase;
    end

    always @(posedge clk) begin
        if (rst_fifo) begin
            post_label <= 0;
            find_en <= 0;
            find_label_count <= 0;
        end else if (!matrix_frame_vsync) begin//merge labels and its information
            if (merge_state = merge_stop ) begin
               find_label_count <= 0; 
            end else if (merge_state = merge_idle) begin
                find_label_count = find_label_count + 1;
                merged_area     [find_label_out]    <= area         [find_label_out];
                merged_perimeter[find_label_out]    <= perimeter    [find_label_out];
                merged_valid    [find_label_out]    <= valid        [find_label_out];
            end else if (merge_state = merge_done) begin
                if (find_label_count != find_label_out) begin
                    merged_area     [find_label_out]    <= merged_area      [find_label_out] + merged_area      [find_label_count];
                    merged_perimeter[find_label_out]    <= updated_perimeter[find_label_out] + updated_perimeter[find_label_count];
                    merged_valid    [find_label_out]    <= merged_valid     [find_label_out] + merged_valid     [find_label_count];
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