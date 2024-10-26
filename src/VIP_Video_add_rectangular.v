module VIP_Video_add_rectangular (

    //ȫ��ʱ���ź�
    input       clk,      //CMOS��Ƶ����ʱ��
    input       rst_n,    //ȫ�ָ�λ
	
	input       per_frame_vsync,
	input       per_frame_href,
	input       per_frame_clken,
	input [7:0]      per_img_red,
	input [7:0]      per_img_green,
	input [7:0]      per_img_blue,

    //׼���õ�ͼ����������
    input [42:0] 	target_pos_out1,// {Flag,ymax[41:32],xmax[31:21],ymin[20:11],xmin[10:0]}
    input [42:0] 	target_pos_out2,
    //���ο��������


    //������ͼ���������
    output reg post_frame_vsync,    //�����ͼ������VSYNC��Ч�ź�
    output reg post_frame_href,     //�����ͼ������HREF��Ч�ź�
    output reg post_frame_clken,    //�����ͼ���������/����ʹ��ʱ��
    output reg [7:0] post_img_red,  //������������
    output reg [7:0] post_img_green,//������������
    output reg [7:0] post_img_blue  //����������
);

//1280*720�ֱ���
parameter [10:0] IMG_HDISP = 11'd1280;
parameter [9:0] IMG_VDISP = 10'd720;
	
wire [9:0] 	rectangular_up1;    	//���ο��ϱ߽�����
wire [9:0] 	rectangular_up2;
wire [9:0] 	rectangular_down1;    	//���ο��±߽�����
wire [9:0] 	rectangular_down2;
wire [10:0] rectangular_left1;    	//���ο���߽�����
wire [10:0] rectangular_left2;
wire [10:0] rectangular_right1;		//���ο��ұ߽�����
wire [10:0] rectangular_right2;
wire       	rectangular_flag1;		//��־�Ƿ�����˶�Ŀ��
wire       	rectangular_flag2;


assign rectangular_flag1 	= 	target_pos_out1[42];
assign rectangular_down1 	= 	target_pos_out1[41:32];
assign rectangular_right1 	= 	target_pos_out1[31:21];
assign rectangular_up1 		= 	target_pos_out1[20:11];
assign rectangular_left1	= 	target_pos_out1[10:0];	

assign rectangular_flag2 	= 	target_pos_out2[42];
assign rectangular_down2 	= 	target_pos_out2[41:32];
assign rectangular_right2 	= 	target_pos_out2[31:21];
assign rectangular_up2	 	= 	target_pos_out2[20:11];
assign rectangular_left2	= 	target_pos_out2[10:0];		

	
reg [10:0] x_cnt;
reg [9:0] y_cnt;
 

//����������ؽ��С���/��������������õ����ݺ�����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		x_cnt <= 11'd0;
		y_cnt <= 10'd0;
	end
	else begin
		if(!per_frame_vsync)begin
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
end

wire [9:0] 	up1;    	//���ο��ϱ߽�����
wire [9:0] 	up2;
wire [9:0] 	down1;    	//���ο��±߽�����
wire [9:0] 	down2;
wire [10:0] left1;    	//���ο���߽�����
wire [10:0] left2;
wire [10:0] right1;		//���ο��ұ߽�����
wire [10:0] right2;

assign up1 = (rectangular_up1 > 5'd20) ? (rectangular_up1 - 5'd20) : 10'd0;
assign up2 = (rectangular_up2 > 5'd20) ? (rectangular_up2 - 5'd20) : 10'd0;

assign down1 = (rectangular_down1 < 10'd699) ? (rectangular_down1 + 5'd20) : 10'd719;
assign down2 = (rectangular_down2 < 10'd699) ? (rectangular_down2 + 5'd20) : 10'd719;

assign left1 = (rectangular_left1 > 6'd50) ? (rectangular_left1 - 6'd50) : 11'd0;
assign left2 = (rectangular_left2 > 6'd50) ? (rectangular_left2 - 6'd50) : 11'd0;

assign right1 = (rectangular_right1 < 11'd1229) ? (rectangular_right1 + 6'd50) : 11'd1279;
assign right2 = (rectangular_right2 < 11'd1229) ? (rectangular_right2 + 6'd50) : 11'd1279;


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		post_frame_vsync <= 'd0; 
		post_frame_href <= 'd0; 
		post_frame_clken <= 'd0; 
		post_img_red <= 8'd0; 
		post_img_green <= 8'd0; 
		post_img_blue <= 8'd0; 
	end
	else begin
		post_frame_vsync <= per_frame_vsync;
		post_frame_href <= per_frame_href;
		post_frame_clken <= per_frame_clken;
		if((rectangular_flag1 || rectangular_flag2) && post_frame_clken) begin //��⵽�˶�Ŀ��
			if(((x_cnt >   left1) && (x_cnt <   right1) && ((y_cnt ==   up1) || (y_cnt ==   down1)) && rectangular_flag1) ||
			((x_cnt >   left2) && (x_cnt <   right2) && ((y_cnt ==   up2) || (y_cnt ==   down2)) && rectangular_flag2))begin //�������±߽�
				post_img_red 	<= 8'd255;
				post_img_green 	<= 8'd0;
				post_img_blue 	<= 8'd0;
			end
			else if(((y_cnt >   up1) && (y_cnt <   down1) && ((x_cnt ==   left1) || (x_cnt ==   right1)) && rectangular_flag1)||
				   ((y_cnt >   up2) && (y_cnt <   down2) && ((x_cnt ==   left2) || (x_cnt ==   right2)) && rectangular_flag2))begin 
				   //�������ұ߽�
				post_img_red 	<= 8'd255;
				post_img_green 	<= 8'd0;
				post_img_blue 	<= 8'd0;
			end
			else begin
				post_img_red 	<= per_img_red ; 
				post_img_green 	<= per_img_green;
				post_img_blue 	<= per_img_blue ;
			end
        end
		else begin
			post_img_red 	<= per_img_red ; 
			post_img_green 	<= per_img_green;
			post_img_blue 	<= per_img_blue ;
		end
    end		
end

endmodule