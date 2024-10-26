/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// tb_uart.v
//
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
  
  module tb_uart;
  	  
 `include "uart_define.vh"

   //PARAMETERS.
   parameter PERIOD_SYSCLK = 1000000000/CLOCK_FREQ;
   parameter PERIOD_BAUD   = 1000000000/BAUD;

   //Internal Signals.
   reg 	     clk50MHz;   //SYSTEM CLOCK.
   reg 	     clk_baud_Hz;//BAUD RATE - 115200Hz.
   reg 	     initialreset;

   reg 	     rxData;
   wire      txData;
   reg 	     txData0,txData1;
   reg [2:0] cnt8,cnt8_0;
   reg 	     start,start0;
   reg [7:0] serial2parallel;
   integer   i;
   wire [2:0] baud_rate;
   
    assign baud_rate = (BAUD == 115200) ? 0 :
                      (BAUD == 57600) ? 1 :
                      (BAUD == 38400) ? 2 :	  
                      (BAUD == 19200) ? 3 :	 
                      (BAUD == 9600) ? 4 :
                      (BAUD == 4800) ? 5 :	  
                      (BAUD == 2400) ? 6 : 7;
   
   //DUT 
   uart_demo_top dut(
		     // Outputs
		     .tx_o		(txData),
		     .led_tr		(),
		     .led_ti		(),
		     .pll_rst_n		(),
		     // Inputs
		     .clk		(clk50MHz),
		     .rst_n		(initialreset),
		     .pll_locked	(),
		     .baud_rate     (baud_rate),
		     .rx_i		(rxData));
   

   function [7:0] hex2ascii;
      input [3:0] hexIn;
      begin
	 case (hexIn)
	   4'h0: hex2ascii = `ASCII_0;
	   4'h1: hex2ascii = `ASCII_1;
	   4'h2: hex2ascii = `ASCII_2;
	   4'h3: hex2ascii = `ASCII_3;
	   4'h4: hex2ascii = `ASCII_4;
	   4'h5: hex2ascii = `ASCII_5;
	   4'h6: hex2ascii = `ASCII_6;
	   4'h7: hex2ascii = `ASCII_7;
	   4'h8: hex2ascii = `ASCII_8;
	   4'h9: hex2ascii = `ASCII_9;
	   4'hA: hex2ascii = `ASCII_a;
	   4'hB: hex2ascii = `ASCII_b;
	   4'hC: hex2ascii = `ASCII_c;
	   4'hD: hex2ascii = `ASCII_d;
	   4'hE: hex2ascii = `ASCII_e;
	   4'hF: hex2ascii = `ASCII_f;
	 endcase // case(hexIn)
      end
   endfunction // hex2ascii
   

    function [7:0] ascii2hex;
      input [7:0] asciiIn;
      begin
	 case (asciiIn[7:0])
	   `ASCII_0 : ascii2hex = 4'h0;
	   `ASCII_1 : ascii2hex = 4'h1;
	   `ASCII_2 : ascii2hex = 4'h2;
	   `ASCII_3 : ascii2hex = 4'h3;
	   `ASCII_4 : ascii2hex = 4'h4;
	   `ASCII_5 : ascii2hex = 4'h5;
	   `ASCII_6 : ascii2hex = 4'h6;
	   `ASCII_7 : ascii2hex = 4'h7;
	   `ASCII_8 : ascii2hex = 4'h8;
	   `ASCII_9 : ascii2hex = 4'h9;
	   `ASCII_a : ascii2hex = 4'hA;
	   `ASCII_b : ascii2hex = 4'hB;
	   `ASCII_c : ascii2hex = 4'hC;
	   `ASCII_d : ascii2hex = 4'hD;
	   `ASCII_e : ascii2hex = 4'hE;
	   `ASCII_f : ascii2hex = 4'hF;
	   `ASCII_O : ascii2hex = 8'h4F;
	   `ASCII_K : ascii2hex = 8'h4B;
	   default : ascii2hex = 4'h0;
	 endcase // case(asciiIn[7:0])
      end
   endfunction // hex2ascii
   //Task.


   //Send LF
   task SEND_LF;
      reg [7:0] symbol_lf;
      
      begin
	 symbol_lf = `ASCII_LF;
	 
	 @(posedge clk_baud_Hz);
	 rxData = 1'b0; //start bit.
	 repeat (8) @(posedge clk_baud_Hz)
	   begin
	      rxData = symbol_lf[0];
	      symbol_lf = symbol_lf >>1;
	   end
	 repeat (2) @(posedge clk_baud_Hz)
	   rxData = 1'b1; //Stop bits + IDLE
      end
   endtask // SEND_LF
   
   /*
    * --------------------------------
    * Send data.
    * --------------------------------
    */

   task SendData;
      input [15:0] addr;
      input rw;
      input [15:0] data;
      reg [31:0] dataASCII;
      reg [31:0] addrSend;
      integer i,j,k;
      reg [7:0] cmd;
      begin
	 dataASCII = {hex2ascii(data[3:0]),hex2ascii(data[7:4]),hex2ascii(data[11:8]),hex2ascii(data[15:12])};
	 addrSend      = {hex2ascii(addr[3:0]),hex2ascii(addr[7:4]),hex2ascii(addr[11:8]),hex2ascii(addr[15:12])};

	 if (!rw)
	   cmd = `WRITE_COMMAND;
	 else
	   cmd = `READ_COMMAND;

	 ///////////////////////
	 //Sending 16-bits ADDR
	 //in ASCII
	 ///////////////////////
	 for (j=0;j<4;j=j+1)
	   begin
	      @(posedge clk_baud_Hz);
	      rxData = 1'b0; //start bit.
	     repeat (8) @(posedge clk_baud_Hz)
	       begin
		  rxData = addrSend[0];
		  addrSend = addrSend >>1;
	       end
	      repeat (2) @(posedge clk_baud_Hz)
		rxData = 1'b1; //Stop bits + IDLE
	   end


	 ////////////////////////////
	 //WRITE COMMAND
	 ////////////////////////////
	 if (!rw)
	   begin
	      //Sending Write Command.
	      @(posedge clk_baud_Hz);
	      rxData = 1'b0; //start bit.
	      
	      repeat (8) @(posedge clk_baud_Hz)
		begin
		   rxData = cmd[0];
		   cmd = cmd >>1;
		end
	      repeat (2) @(posedge clk_baud_Hz)
		rxData = 1'b1; //stop bit.
	      
	 /////////////////////////
	 //WRITE DATA
	 /////////////////////////
	      //Sending data.
	      for (i=0;i<4;i=i+1)
		begin
		   
		   @(posedge clk_baud_Hz);
		   rxData = 1'b0; //start bit.
		   repeat (8) @(posedge clk_baud_Hz)
		     begin
			rxData = dataASCII[0];
			dataASCII = dataASCII >>1;
		     end
		   repeat (2) @(posedge clk_baud_Hz)
		     rxData = 1'b1; //stop bit
		   
		end // for (i=0;i<4;i=i+1)
	      
	   end // if (!rw)

	 ////////////////////////////////////
	 //READ COMMAND
	 ////////////////////////////////////
	 else
	   begin
	      
	      //Sending READ Command.
	      @(posedge clk_baud_Hz);
	      rxData = 1'b0; //start bit.
	      
	      repeat (8) @(posedge clk_baud_Hz)
		begin
		   rxData = cmd[0];
		   cmd = cmd >>1;
		end
	      @(posedge clk_baud_Hz);
	      rxData = 1'b1; //stop bit.

	      repeat (10) @(posedge clk_baud_Hz);
	      
	   end // else: !if(!rw)
	 
	 
	 #10000;
	 SEND_LF();
      end
   endtask // SendData
   
   
   
   //Clock Generation.
   initial
     begin
	clk50MHz = 0;
	forever #(PERIOD_SYSCLK/2) clk50MHz <= ~clk50MHz;
     end
   
   initial
     begin
	clk_baud_Hz = 0;
	forever #(PERIOD_BAUD/2) clk_baud_Hz <= ~clk_baud_Hz;
     end

   //Reset.
   //glbl glbl();

   initial
     begin
	initialreset = 0;
	$display ("Initial Reset.....");	
	#PERIOD_BAUD initialreset = 1;
	$display ("Deassert Reset....");
	
     end

   always @(posedge clk_baud_Hz)
     begin
	txData0 <= txData;
	txData1 <= txData0;
     end
   


   
   always @(posedge clk_baud_Hz)
     begin

	if (cnt8==3'b111)
	  start <= 0;
	else if (txData1 & !txData0)
	  start <= 1;

	if (start)
	  begin
	     serial2parallel <= {txData0,serial2parallel[7:1]};
	     cnt8 <= cnt8 + 1;
	  end

	cnt8_0 <= cnt8;
	
	if (cnt8_0==3'b111 & cnt8==3'b000)
	  if (ascii2hex(serial2parallel)== 8'h4f)
	    $display($time,"\t Received Data : O ");
	  else if (ascii2hex(serial2parallel)== 8'h4b)
	    $display($time,"\t Received Data : K ");
	  else  
	    $display ($time,"\t Received Data %h",ascii2hex(serial2parallel));	
	
	
     end // always @ (posedge clk_baud_Hz)


   initial
     begin
	cnt8 = 0;
	rxData = 1;
	start = 0;
	txData0 = 1;
	txData1 = 1;
	
	#100000;
	SendData(16'h0000,1'b0,16'h5555);	
	SendData(16'h0001,1'b0,16'hAAAA);
	SendData(16'h0002,1'b0,16'h5555);
	SendData(16'h0003,1'b0,16'hAAAA);
	SendData(16'h0004,1'b0,16'h5555);
	SendData(16'h0005,1'b0,16'hAAAA);
	SendData(16'h0006,1'b0,16'h5555);
	SendData(16'h0007,1'b0,16'hAAAA);
	SendData(16'h0008,1'b0,16'h5555);
	SendData(16'h0009,1'b0,16'hAAAA);
	SendData(16'h000A,1'b0,16'h5555);
	SendData(16'h000B,1'b0,16'hAAAA);
	SendData(16'h000C,1'b0,16'h5555);
	SendData(16'h000D,1'b0,16'hAAAA);
	SendData(16'h000E,1'b0,16'h5555);
	SendData(16'h000F,1'b0,16'hAAAA);

	SendData(16'h0000,1'b1,16'h0);
	SendData(16'h0001,1'b1,16'h0);
	SendData(16'h0002,1'b1,16'h0);
	SendData(16'h0003,1'b1,16'h0);
	SendData(16'h0004,1'b1,16'h0);
	SendData(16'h0005,1'b1,16'h0);
	SendData(16'h0006,1'b1,16'h0);
	SendData(16'h0007,1'b1,16'h0);
	SendData(16'h0008,1'b1,16'h0);
	SendData(16'h0009,1'b1,16'h0);
	SendData(16'h000A,1'b1,16'h0);
	SendData(16'h000B,1'b1,16'h0);
	SendData(16'h000C,1'b1,16'h0);
	SendData(16'h000D,1'b1,16'h0);
	SendData(16'h000E,1'b1,16'h0);
	SendData(16'h000F,1'b1,16'h0);
	repeat (100) @(posedge clk_baud_Hz);
	
	for (i=0;i<16;i=i+1)
	  if ( (i % 2 ) == 0 & dut.u_user_register.usr_data[i]== {BYTE{4'h5}}) 
	    $display ("PASSED: Address %h , DATA %h",i,dut.u_user_register.usr_data[i]);
	  else if ( (i % 2 ) != 0 & dut.u_user_register.usr_data[i]== {BYTE{4'hA}}) 
	    $display ("PASSED: Address %h , DATA %h",i,dut.u_user_register.usr_data[i]);
	  //else if ( i==15 & dut.u_user_register.usr_data[i]== 16'h2AAA) 
	  //$display ("PASSED: Address %h , DATA %h",i,dut.u_user_register.usr_data[i]);
	  else
	    $display ("FAILED: Address %h , DATA %h",i,dut.u_user_register.usr_data[i]);
	#1000;
	$finish;
	
     end

   initial begin
     $shm_open("tb_uart.shm");
     $shm_probe(tb_uart,"ACMTF");
      //$dumpfile("tb_uart.vcd");
      //$dumpvars(0, tb_uart);
   end
   
  
   
endmodule // tb_uart
// Local Variables:
// verilog-library-directories:("../src/")
// End:



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
////////////////////////////////////////////////////////////////////////////


