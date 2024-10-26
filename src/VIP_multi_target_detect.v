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
    //input 				disp_sel  //δ֪�ô�
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

wire vsync_pos_flag;//��ͬ���ź�������
wire vsync_neg_flag;//��ͬ���ź��½���

assign vsync_pos_flag = per_frame_vsync & (!per_frame_vsync_r);
assign vsync_neg_flag = !(per_frame_vsync) & per_frame_vsync_r;

//////////////////////////////////////////////////////////////
//����������ؽ���"��/��"����������õ����ݺ�����
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


// �Ĵ�����
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

// �Ĵ�����˶�Ŀ��ı߽�
reg [42:0] target_pos1;
reg [42:0] target_pos2;
// ��Ŀ�����Ч��־
wire [1:0]target_flag;
// ��Ŀ�����/��/��/������
wire [10:0] target_left1 	;
wire [10:0] target_right1 	;
wire [9:0] target_top1 		;
wire [9:0] target_bottom1 	;

wire [10:0] target_left2 	;
wire [10:0] target_right2 	;
wire [9:0] target_top2		;
wire [9:0] target_bottom2 	;

/* // ��Ŀ�����/��/���±߽�
wire [10:0] target_boarder_left1 	;
wire [10:0] target_boarder_right1 	;
wire [9:0] target_boarder_top1 		;
wire [9:0] target_boarder_bottom1 	;

wire [10:0] target_boarder_left2 	;
wire [10:0] target_boarder_right2 	;
wire [9:0] target_boarder_top2 		;
wire [9:0] target_boarder_bottom2 	; */

//����Χ

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


/* assign target_boarder_bottom1	= target_pos1[41:32]; //�±߽���������
assign target_boarder_right1	= target_pos1[31:21]; //�ұ߽���������
assign target_boarder_top1  		= target_pos1[20:11]; //�ϱ߽���������
assign target_boarder_left1  	= target_pos1[10: 0]; //��߽���������

assign target_boarder_bottom2	= target_pos2[41:32]; //�±߽���������
assign target_boarder_right2	= target_pos2[31:21]; //�ұ߽���������
assign target_boarder_top2  		= target_pos2[20:11]; //�ϱ߽���������
assign target_boarder_left2  	= target_pos2[10: 0]; //��߽��������� */


// ��Ⲣ���Ŀ����Ҫ��������ʱ��
reg  target_cnt;
reg [1:0] new_target_flag; //��⵽��Ŀ���ͶƱ��

always @(posedge clk or negedge rst_n) begin
    // ��ʼ�����˶�Ŀ��ı߽�Ϊ0
    if (!rst_n) begin
        target_pos1 <= {1'b0, 10'd0, 11'd0, 10'd0, 11'd0};
        target_pos2 <= {1'b0, 10'd0, 11'd0, 10'd0, 11'd0};
        new_target_flag <= 2'd0;
        target_cnt <= 1'd0;
    end
    
    // ��һ֡��ʼ���г�ʼ��
    else if(vsync_pos_flag) begin
         target_pos1 <= {1'b0, 10'd0, 11'd0, 10'd0, 11'd0};
         target_pos2 <= {1'b0, 10'd0, 11'd0, 10'd0, 11'd0};
		new_target_flag <= 2'd0;
		target_cnt <= 1'd0;
    end
    else begin
        // ��һ��ʱ�����ڣ��ҳ����Ϊ�˶�Ŀ������ص㣬���˶�Ŀ���б��е�Ԫ�ؽ���ͶƱ���ж��Ƿ�Ϊȫ�µ��˶�Ŀ��
        if(per_frame_clken && per_img_Bit ) begin
			if(target_flag[0] == 1'b0)			// �˶�Ŀ���б��е�������Ч�����Ԫ��Ͷ�϶�����ĻҶ�Ϊ�µ����ֵ
				new_target_flag[0] <= 1'b1;
			else begin							// �˶�Ŀ���б��е�������Ч�����жϵ�ǰ�����Ƿ����ڸ�Ԫ��������
				if((x_cnt < target_left1 || x_cnt > target_right1 || y_cnt < target_top1 || y_cnt > target_bottom1))	//������볬��Ŀ������Χ��ͶƱ�϶�Ϊ�µ�Ŀ��
					new_target_flag[0] <= 1'b1;
				else
					new_target_flag[0] <= 1'b0;                
		    end
			
			if(target_flag[1] == 1'b0)			// �˶�Ŀ���б��е�������Ч�����Ԫ��Ͷ�϶�����ĻҶ�Ϊ�µ����ֵ
				new_target_flag[1] <= 1'b1;
			else begin							// �˶�Ŀ���б��е�������Ч�����жϵ�ǰ�����Ƿ����ڸ�Ԫ��������
				if((x_cnt < target_left2 || x_cnt > target_right2 || y_cnt < target_top2 || y_cnt > target_bottom2))	//������볬��Ŀ������Χ��ͶƱ�϶�Ϊ�µ�Ŀ��
					new_target_flag[1] <= 1'b1;
				else
					new_target_flag[1] <= 1'b0;                
		    end
        end
        else begin
			new_target_flag <= 2'b0;
        end

//     ?�������������֮����ô��

		
        // �ڶ���ʱ�����ڣ�����ͶƱ���������ѡ���ݸ��µ��˶�Ŀ���б���
        if(per_frame_clken_r && per_img_Bit_r) begin
			if(new_target_flag == 2'b11) begin 	// ȫƱͨ������־�ų����µ��˶�Ŀ��
				if(target_cnt == 1'b0)begin
					target_cnt <=1'd1;
					target_pos1 <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
				end				
				else if(target_cnt == 1'b1 && target_pos2[42] != 1'b1 && (x_cnt_r < target_left1 || x_cnt_r > target_right1 || y_cnt_r < target_top1 || y_cnt_r > target_bottom1))begin
					target_pos2 <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
					target_cnt <=1'd1;
				end
			end
			
			else if (new_target_flag > 2'd0 && new_target_flag != 2'b11) begin // ���ֱ����Ϊ�˶�Ŀ������ص㣬���������˶�Ŀ���б���ĳ��Ԫ�ص�������
				if(new_target_flag[0] == 1'b0) begin // δͶƱ�϶���Ŀ���Ԫ�أ���ʾ��ǰ����λ������������
				
					target_pos1[42] <= 1'b1;

					if(x_cnt_r < target_pos1[10: 0]) 	// ��X����С����߽磬����X������չΪ��߽�
						target_pos1[10: 0] <= x_cnt_r;
					if(x_cnt_r > target_pos1[31:21]) 	// ��X��������ұ߽磬����X������չΪ�ұ߽�
						target_pos1[31:21] <= x_cnt_r;
					if(y_cnt_r < target_pos1[20:11]) 	// ��Y����С���ϱ߽磬����Y������չΪ�ϱ߽�
						target_pos1[20:11] <= y_cnt_r;
					if(y_cnt_r > target_pos1[41:32]) 	// ��Y��������±߽磬����Y������չΪ�±߽�
						target_pos1[41:32] <= y_cnt_r;
				end
				else if(new_target_flag[1] == 1'b0) begin // δͶƱ�϶���Ŀ���Ԫ�أ���ʾ��ǰ����λ������������
				
					target_pos2[42] <= 1'b1;

					if(x_cnt_r < target_pos2[10: 0]) 	// ��X����С����߽磬����X������չΪ��߽�
						target_pos2[10: 0] <= x_cnt_r;
					if(x_cnt_r > target_pos2[31:21]) 	// ��X��������ұ߽磬����X������չΪ�ұ߽�
						target_pos2[31:21] <= x_cnt_r;
					if(y_cnt_r < target_pos2[20:11]) 	// ��Y����С���ϱ߽磬����Y������չΪ�ϱ߽�
						target_pos2[20:11] <= y_cnt_r;
					if(y_cnt_r > target_pos2[41:32]) 	// ��Y��������±߽磬����Y������չΪ�±߽�
						target_pos2[41:32] <= y_cnt_r;
				end
			end
		end
	end
end

//һ֡ͳ�ƽ����󣬼Ĵ�������

always @(posedge clk or negedge rst_n)
	if(!rst_n) begin
		target_pos_out1 <= {1'd0,10'd0,11'd0,10'd0,11'd0};
		target_pos_out2 <= {1'd0,10'd0,11'd0,10'd0,11'd0};		//��λʱ����
    end
    else if(vsync_neg_flag) 	begin //һ֡ͳ�ƽ���֮�󣬼Ĵ�������
		target_pos_out1 <= target_pos1;
		target_pos_out2 <= target_pos2;
    end


endmodule