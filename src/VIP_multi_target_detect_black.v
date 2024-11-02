module VIP_multi_target_detect_black
(
	input clk, //cmos video pixel clock
	input rst_n, //global reset

	//Image data prepared to be processed
	input per_frame_vsync, //Prepared Image data vsync valid signal
	input per_frame_clken, //Prepared Image data output/capture enable clock
	input per_img_Bit,
	input    	[42:0] 	target_pos_in,//{Flag,ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}

	output reg 	[42:0] 	target_pos_out,//{Flag,ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}	
	output  	[11:0] 	target_pos_diff//{y[11:6],x[5:0]}	
);

parameter	[10:0] IMG_HDISP = 11'd1280;
parameter	[9:0]  IMG_VDISP = 10'd720;

//场下降沿
reg 	per_frame_vsync_r;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
		per_frame_vsync_r 	<= 0;
	else 	
		per_frame_vsync_r  	<= per_frame_vsync ;
end

wire vsync_neg_flag;//场同步信号下降沿

assign vsync_neg_flag = !(per_frame_vsync) & per_frame_vsync_r;

reg [10:0] x_cnt;
reg [9:0] y_cnt;

reg [9:0] up_reg ;
reg [9:0] down_reg ;
reg [10:0] left_reg ;
reg [10:0] right_reg;
reg flag_reg;

wire [11:0] sum_x ;
wire [10:0] sum_y ;
reg [12:0] diff_x ;
reg [11:0] diff_y ;
assign sum_y = up_reg + down_reg;
assign sum_x = left_reg + right_reg;
assign target_pos_diff = {diff_y[5:0],diff_x[5:0]};
//对输入的像素进行“行/场”方向计数，得到其纵横坐标
always@(posedge clk or negedge rst_n)
begin
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
end

//在已经框定的区域内标记
reg flag_black;

always@(posedge clk or negedge rst_n)
	if(!rst_n)
		flag_black <= 1'b0;
	else if(!per_frame_vsync)
		flag_black <= 1'b0;
	else if(target_pos_in[42] && per_frame_clken && y_cnt < target_pos_in[41:32] + 5'd20 && x_cnt < target_pos_in[31:21] + 5'd20 && y_cnt > target_pos_in[20:11] - 6'd32 && x_cnt > target_pos_in[10:0] - 5'd20)
		flag_black <= 1'b1;
	else
		flag_black <= 1'b0;




//标定眼黑
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        up_reg <= target_pos_in[41:32] + 5'd20;
        down_reg <= 10'd0;
        left_reg <= target_pos_in[31:21] + 5'd20;
        right_reg <= 10'd0;
        flag_reg <= 1'b0;
    end 
    else if(!per_frame_vsync)begin
        up_reg <= target_pos_in[41:32] + 5'd20;
        down_reg <= 10'd0;
        left_reg <= target_pos_in[31:21] + 5'd20;
        right_reg <= 11'd0;
        flag_reg <= 1'b0;
    end
    else if (per_frame_clken && per_img_Bit && flag_black) begin
		flag_reg <= 1'b1;

		if (x_cnt < left_reg)
			left_reg <= x_cnt; //左边界
		else
			left_reg <= left_reg;

		if (x_cnt > right_reg)
			right_reg <= x_cnt; //右边界
		else
			right_reg <= right_reg;

		if (y_cnt < up_reg)
			up_reg <= y_cnt; //上边界
		else
			up_reg <= up_reg;

		if (y_cnt > down_reg)
			down_reg <= y_cnt; //下边界
		else
			down_reg <= down_reg;
	end
end
	
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        target_pos_out <= {1'd0,10'd0,11'd0,10'd0,11'd0};
    end 
	else if (vsync_neg_flag) begin
        target_pos_out <= {flag_reg,down_reg,right_reg,up_reg,left_reg};
        diff_y <= sum_x[11:1] +20 - target_pos_in[10:0]; 
        diff_x <= sum_y[10:1] + 32 - target_pos_in[20:11];
    end
end

endmodule