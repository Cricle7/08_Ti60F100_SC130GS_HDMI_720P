//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           binarization
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        ͼ��Ķ�ֵ������
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module binarization
#(
    parameter   [7:0]  O = 180    //��ֵ
)
(
    //module clock
    input               clk             ,   // ʱ���ź�
    input               rst_n           ,   // ��λ�źţ�����Ч��

    //ͼ����ǰ�����ݽӿ�
    input               ycbcr_vsync     ,   // vsync�ź�
    input               ycbcr_href      ,   // href�ź�
    input               ycbcr_de        ,   // data enable�ź�
    input   [7:0]       luminance       ,

    //ͼ���������ݽӿ�
    output   reg        post_vsync      ,   // vsync�ź�
    output   reg        post_href       ,   // href�ź�
    output   reg        post_de         ,   // data enable�ź�
    output   reg        monoc               // monochrome��1=�ף�0=�ڣ�
);

//reg define
reg    ycbcr_vsync_d;
reg    ycbcr_href_d ;
reg    ycbcr_de_d   ;

wire  [7:0] try = 8'd220;//��ֵ

//**************************************************s***
//**                    main code
//*****************************************************


//��ֵ��
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        monoc <= 1'b0;
    else if(ycbcr_vsync)begin  //��ֵ
		if (luminance > try)
			monoc <= 1'b1;
		else
			monoc <= 1'b0;
	end		
    else
        monoc <= 1'b0;
end

//��ʱ1����ͬ��ʱ���ź�
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        post_vsync <= 1'd0;
        post_href <= 1'd0;
        post_de    <= 1'd0;
    end
    else begin
        post_vsync <= ycbcr_vsync;
        post_href  <= ycbcr_href ;
        post_de    <= ycbcr_de   ;
    end
end

endmodule 