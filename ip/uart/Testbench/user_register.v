/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// user_register.v
//
// Description:
// User Register Mapping. 
//
// *******************************
// Revisions:
// 1.0 Initial rev
//
// *******************************
/////////////////////////////////////////////////////////////////////////////



`resetall
`timescale 1ns/10ps
`include "uart_defines.v"

  module user_register
    #(parameter BYTE=4)
    (
     //outputs
     output reg reg_rd_valid,
     output reg [((BYTE*8)/2)-1:0] reg_rd_data, 

     //inputs
     input clk,
     input reset,
     input [(`ADDR_WIDTH)-1:0] addr,
     input [((BYTE*8)/2)-1:0] reg_wr_data,
     input reg_wr_valid, 
     input rw,
     input rd_en,
     input rx_error
     );

   //Internal signals
   reg [((BYTE*8)/2)-1:0] usr_data [(`ADDR_WIDTH)-1:0];
   reg 	      rd_en0;
   


   always @(posedge clk)
     if (reset)
       begin
	  usr_data[0]  <= 'h0;
	  usr_data[1]  <= 'h0;
	  usr_data[2]  <= 'h0;
	  usr_data[3]  <= 'h0;
	  usr_data[4]  <= 'h0;
	  usr_data[5]  <= 'h0;
	  usr_data[6]  <= 'h0;
	  usr_data[7]  <= 'h0;
	  usr_data[8]  <= 'h0;
	  usr_data[9]  <= 'h0;
	  usr_data[10] <= 'h0;
	  usr_data[11] <= 'h0;
	  usr_data[12] <= 'h0;
	  usr_data[13] <= 'h0;
	  usr_data[14] <= 'h0;
	  usr_data[15] <= 'h0;
	  reg_rd_data  <= 'h0;
	  
       end // if (reset)

     //Write to user registers
     else if (reg_wr_valid & ~rw)
       case (addr)
	 16'h0000 : usr_data[0] <= reg_wr_data;
	 16'h0001 : usr_data[1] <= reg_wr_data;
	 16'h0002 : usr_data[2] <= reg_wr_data;
	 16'h0003 : usr_data[3] <= reg_wr_data;
	 16'h0004 : usr_data[4] <= reg_wr_data;
	 16'h0005 : usr_data[5] <= reg_wr_data;
	 16'h0006 : usr_data[6] <= reg_wr_data;
	 16'h0007 : usr_data[7] <= reg_wr_data;
	 16'h0008 : usr_data[8] <= reg_wr_data;
	 16'h0009 : usr_data[9] <= reg_wr_data;
	 16'h000A : usr_data[10] <= reg_wr_data;
	 16'h000B : usr_data[11] <= reg_wr_data;
	 16'h000C : usr_data[12] <= reg_wr_data;
	 16'h000D : usr_data[13] <= reg_wr_data;
	 16'h000E : usr_data[14] <= reg_wr_data;
	 16'h000F : usr_data[15] <= reg_wr_data;
       endcase // case(addr)

     //Read from user registers.
     else if (rd_en)
       case (addr)
	 16'h0000 : reg_rd_data <= usr_data[0];
	 16'h0001 : reg_rd_data <= usr_data[1];
	 16'h0002 : reg_rd_data <= usr_data[2];
	 16'h0003 : reg_rd_data <= usr_data[3];
	 16'h0004 : reg_rd_data <= usr_data[4];
	 16'h0005 : reg_rd_data <= usr_data[5];
	 16'h0006 : reg_rd_data <= usr_data[6];
	 16'h0007 : reg_rd_data <= usr_data[7];
	 16'h0008 : reg_rd_data <= usr_data[8];
	 16'h0009 : reg_rd_data <= usr_data[9];
	 16'h000A : reg_rd_data <= usr_data[10];
	 16'h000B : reg_rd_data <= usr_data[11];
	 16'h000C : reg_rd_data <= usr_data[12];
	 16'h000D : reg_rd_data <= usr_data[13];
	 16'h000E : reg_rd_data <= usr_data[14];
	 16'h000F : reg_rd_data <= usr_data[15];
       endcase // case(addr)


   always @(posedge clk)
     if (reset)
       begin
	  rd_en0 <= 1'b0;
	  reg_rd_valid <= 1'b0;
       end
     else
       begin
	  rd_en0 <= rd_en;
	  
	  if (!rd_en0 & rd_en)
	    reg_rd_valid <= 1'b1;
	  else
	    reg_rd_valid <= 1'b0;
       end // else: !if(reset)
   
endmodule // user_register

//////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// This   document  contains  proprietary information  which   is
// protected by  copyright. All rights  are reserved.  This notice
// refers to original work by Efinix, Inc. which may be derivitive
// of other work distributed under license of the authors.  In the
// case of derivative work, nothing in this notice overrides the
// original author's license agreement.  Where applicable, the 
// original license agreement is included in it's original 
// unmodified form immediately below this header.
//
// WARRANTY DISCLAIMER.  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND 
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH 
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES, 
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF 
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR 
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED 
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.
//
// LIMITATION OF LIABILITY.  
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY 
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT 
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY 
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT, 
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY 
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR 
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN 
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER 
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR 
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT 
//     APPLY TO LICENSEE.
//
/////////////////////////////////////////////////////////////////////////////
