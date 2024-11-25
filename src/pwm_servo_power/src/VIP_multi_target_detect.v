module VIP_multi_target_detect
(	
    input 				clk,
    input 				rst_n,

    input 				per_frame_vsync,
    input 				per_frame_href,
    input 				per_frame_clken,
    input 				per_img_Bit,

    output reg 	[42:0] 	target_pos_out1, // {Flag,ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}
    output reg 	[42:0] 	target_pos_out2,
	
    input	   	[ 9:0] 	MIN_DIST
    //input 				disp_sel  //未知用处
);

parameter	[10:0] IMG_HDISP = 11'd1280;
parameter	[9:0]  IMG_VDISP = 10'd720;

//lag 1 clocks signal sync
reg 	per_frame_vsync_r;
reg 	per_frame_href_r;
reg 	per_frame_clken_r;
reg 	per_img_Bit_r;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            per_frame_vsync_r 	<= 0;
            per_frame_href_r 		<= 0;
            per_frame_clken_r 	<= 0;
            per_img_Bit_r 		<= 0;
        end
	else 	
		begin
		per_frame_vsync_r  	<= per_frame_vsync ;
		per_frame_href_r  	<= per_frame_href ;
		per_frame_clken_r  	<= per_frame_clken ;
		per_img_Bit_r  		<= per_img_Bit ;
		end
end

wire vsync_pos_flag;//场同步信号上升沿
wire vsync_neg_flag;//场同步信号下降沿

assign vsync_pos_flag = per_frame_vsync & (!per_frame_vsync_r);
assign vsync_neg_flag = !(per_frame_vsync) & per_frame_vsync_r;

//////////////////////////////////////////////////////////////
//对输入的像素进行"行/场"方向计数，得到其纵横坐标
reg [10:0] x_cnt;
reg [9:0] y_cnt;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        x_cnt <= 11'd0;
        y_cnt <= 10'd0;
    end
    else if(!per_frame_vsync) begin
        x_cnt <= 11'd0;
        y_cnt <= 10'd0;
    end
    else if(per_frame_clken) begin
		if(x_cnt < IMG_HDISP - 1) begin
            x_cnt <= x_cnt + 1'b1;
            y_cnt <= y_cnt;
		end
		else begin
			x_cnt <= 11'd0;
			y_cnt <= y_cnt + 1'b1;
		 end
    end
	else begin
		x_cnt <= 11'd0;
		y_cnt <= y_cnt;
	end
end


// 寄存坐标
reg [10:0] x_cnt_r;
reg [9:0] y_cnt_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        x_cnt_r <= 11'd0;
    else
        x_cnt_r <= x_cnt;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        y_cnt_r <= 10'd0;
    else
        y_cnt_r <= y_cnt;
end

// 寄存各个运动目标的边界
reg [42:0] target_pos1;
reg [42:0] target_pos2;
// 各目标的有效标志
wire [1:0]target_flag;
// 各目标的左/右/上/下领域
wire [10:0] target_left1 	;
wire [10:0] target_right1 	;
wire [9:0] target_top1 		;
wire [9:0] target_bottom1 	;

wire [10:0] target_left2 	;
wire [10:0] target_right2 	;
wire [9:0] target_top2		;
wire [9:0] target_bottom2 	;

/* // 各目标的左/右/上下边界
wire [10:0] target_boarder_left1 	;
wire [10:0] target_boarder_right1 	;
wire [9:0] target_boarder_top1 		;
wire [9:0] target_boarder_bottom1 	;

wire [10:0] target_boarder_left2 	;
wire [10:0] target_boarder_right2 	;
wire [9:0] target_boarder_top2 		;
wire [9:0] target_boarder_bottom2 	; */

//领域范围

assign target_flag[0] 	= 	target_pos1[42];

assign target_bottom1 	= 	(target_pos1[41:32] < IMG_VDISP-1 	- MIN_DIST ) ? (target_pos1[41:32]	+MIN_DIST) : IMG_VDISP-1;
assign target_right1 	= 	(target_pos1[31:21] < IMG_HDISP-1 	- MIN_DIST ) ? (target_pos1[31:21]	+MIN_DIST) : IMG_HDISP-1;
assign target_top1   	= 	(target_pos1[20:11] > 10'd0 		+ MIN_DIST ) ? (target_pos1[20:11]	-MIN_DIST) : 10'd0;
assign target_left1		=	(target_pos1[10: 0] > 11'd0 		+ MIN_DIST ) ? (target_pos1[10: 0]	-MIN_DIST) : 11'd0;

assign target_flag[1] 	= 	target_pos2[42];

assign target_bottom2 	= 	(target_pos2[41:32] < IMG_VDISP-1 	- MIN_DIST ) ? (target_pos2[41:32]	+MIN_DIST) : IMG_VDISP-1;
assign target_right2 	= 	(target_pos2[31:21] < IMG_HDISP-1 	- MIN_DIST ) ? (target_pos2[31:21]	+MIN_DIST) : IMG_HDISP-1;
assign target_top2   	= 	(target_pos2[20:11] > 10'd0 		+ MIN_DIST ) ? (target_pos2[20:11]	-MIN_DIST) : 10'd0;
assign target_left2		=	(target_pos2[10: 0] > 11'd0 		+ MIN_DIST ) ? (target_pos2[10: 0]	-MIN_DIST) : 11'd0;


/* assign target_boarder_bottom1	= target_pos1[41:32]; //下边界像素坐标
assign target_boarder_right1	= target_pos1[31:21]; //右边界像素坐标
assign target_boarder_top1  		= target_pos1[20:11]; //上边界像素坐标
assign target_boarder_left1  	= target_pos1[10: 0]; //左边界像素坐标

assign target_boarder_bottom2	= target_pos2[41:32]; //下边界像素坐标
assign target_boarder_right2	= target_pos2[31:21]; //右边界像素坐标
assign target_boarder_top2  		= target_pos2[20:11]; //上边界像素坐标
assign target_boarder_left2  	= target_pos2[10: 0]; //左边界像素坐标 */


// 检测并标记目标需要两个像素时钟
reg  target_cnt;
reg [1:0] new_target_flag; //检测到新目标的投票箱

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

//     ?如果在两个领域之间怎么办

		
        // 第二个时钟周期，根据投票结果，将候选数据更新到运动目标列表中
        if(per_frame_clken_r && per_img_Bit_r) begin
			if(new_target_flag == 2'b11) begin 	// 全票通过，标志着出现新的运动目标
				if(target_cnt == 1'b0)begin
					target_cnt <=1'd1;
					target_pos1 <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
				end				
				else if(target_cnt == 1'b1 && target_pos2[42] != 1'b1 && (x_cnt_r < target_left1 || x_cnt_r > target_right1 || y_cnt_r < target_top1 || y_cnt_r > target_bottom1))begin
					target_pos2 <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
					target_cnt <=1'd1;
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

//一帧统计结束后，寄存输出结果

always @(posedge clk or negedge rst_n)
	if(!rst_n) begin
		target_pos_out1 <= {1'd0,10'd0,11'd0,10'd0,11'd0};
		target_pos_out2 <= {1'd0,10'd0,11'd0,10'd0,11'd0};		//复位时清零
    end
    else if(vsync_neg_flag) 	begin //一帧统计结束之后，寄存输出结果
		target_pos_out1 <= target_pos1;
		target_pos_out2 <= target_pos2;
    end


endmodule