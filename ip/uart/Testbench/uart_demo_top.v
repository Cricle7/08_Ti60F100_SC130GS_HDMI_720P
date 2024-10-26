/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// uart_demo_top.v
//
// Description:
// Top Level of Example Design. 
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

//To overwrite the BOOTUP_CHECK for example design.   
`define BOOTUP_CHECK 1
  module uart_demo_top
    (
     //Outputs.
     output tx_o,               //UART TX
     output [3:0] led_tr,     //LED T20
     output [3:0] led_ti,     //LED Ti60
     output pll_rst_n,          //PLL Active Low Rest. (EFINIX PLL)

     //Inputs.
     input clk,                 //system clock
     input rst_n,               //active low reset. 
     input pll_locked,          //PLL Lock (EFINIX PLL)
     input [2:0] baud_rate,
     input rx_i                 //UART RX
     );

  `include "uart_define.vh"
   
   //Internal Signals
   wire    reset;
   wire [7:0] rx_data;
   wire       rx_data_valid;  
   wire       tx_busy;
   wire       rx_error;
   wire       rx_parity_error;
   wire       rx_busy;
   wire [((BYTE*8))-1:0] tx_data_out;
   wire 		 tx_en;
   wire 		 baud_x16_ce;
   wire 		 rw;
   wire 		 rd_en;
   wire 		 reg_wr_valid;
   wire [((BYTE*8)/2)-1:0] reg_wr_data;
   wire 		   reg_rd_valid;
   wire [((BYTE*8)/2)-1 : 0] reg_rd_data;
   wire [(`ADDR_WIDTH)-1 : 0] addr;
   wire [7:0] led_o;
   
   assign led_tr = ~led_o[3:0];
   assign led_ti = led_o[3:0];
                      	  
//Reset Generation
   resets u_resets
     (
      // Outputs
      .reset				(reset),
      // Inputs
      .clk				(clk),
      .rst_n				(rst_n));
   
//LED Control
   led_ctl #(.BYTE(BYTE))
   u_led_ctl
     (
      // Outputs
      .LED				(led_o[7:0]),
      // Inputs
      .clk				(clk),
      .reset				(reset),
      .write_valid			(reg_wr_valid),
      .write_data			(reg_wr_data[((BYTE*8)/2)-1:0]));
   

   assign pll_rst_n = 1'b1;

   

   //User Register Map
   user_register #(.BYTE(BYTE))
   u_user_register
     (
      // Outputs
      .reg_rd_valid			(reg_rd_valid),
      .reg_rd_data			(reg_rd_data),
      // Inputs
      .clk				    (clk),
      .reset				(reset),
      .addr				    (addr[(`ADDR_WIDTH)-1:0]),
      .reg_wr_data			(reg_wr_data[((BYTE*8)/2)-1:0]),
      .reg_wr_valid			(reg_wr_valid),
      .rw				    (rw),
      .rd_en				(rd_en),
      .rx_error				(rx_error));
   

 
   
   
 //Command Decoding FSM.
   command_state  #(.BYTE(BYTE))
   u_command_state
     (
      // Outputs
      .rw				    (rw),
      .rd_en				(rd_en),
      .reg_wr_data			(reg_wr_data[((BYTE*8)/2)-1:0]),
      .reg_wr_valid			(reg_wr_valid),
      .tx_data_out			(tx_data_out[(BYTE*8)-1:0]),
      .tx_data_valid		(tx_en),
      .addr				    (addr[(`ADDR_WIDTH)-1:0]),
      // Inputs
      .clk				    (clk),
      .reset				(reset),
      .data_1_byte			(rx_data[7:0]),
      .valid_data_1_byte	(rx_data_valid),
      .baud_x16_ce			(baud_x16_ce),
      .tx_data				(reg_rd_data),
      .tx_data_en			(reg_rd_valid));
   
 
   
 //UART Controller
   uart u_top_uart  
     (
      // Outputs
      .tx_o				    (tx_o),
      .tx_busy				(tx_busy),
      .rx_data				(rx_data[7:0]),
      .rx_data_valid        (rx_data_valid),
      .rx_error				(rx_error),
      .rx_parity_error      (rx_parity_error), 
      .rx_busy				(rx_busy),
      .baud_x16_ce          (baud_x16_ce),
      // Inputs
      .rx_i				    (rx_i),
      .clk				    (clk),
      .reset				(reset),
      .tx_data				(tx_data_out[(BYTE*8)-1:0]),
      .baud_rate            (baud_rate),
      .tx_en				(tx_en));
   
 
endmodule // uart_demo_top


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
 


