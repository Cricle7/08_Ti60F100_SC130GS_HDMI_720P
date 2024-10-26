/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// command_state.v
//
// Description:
// Command State - user will send RW command in Design Example. Command state module  
// will process all the valid command and give proper response.
// Support Format : 
// ! (hex 21 ) - indicate write command...
// @ (hex 40)  - indicate read commmand...
//
// Terminal :
// <ADDRESS[15:0] , Write "!", WriteData[15:0]>
// <ADDRESS[15:0] , Read  "@", Return Read Data>
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

  module command_state
    #(parameter BYTE = 4)
    (
		      							//outputs
		       output reg rw,                            	//RW command
		       output wire rd_en,                   		//read enable flag.
		       output reg [((BYTE*8)/2)-1:0] reg_wr_data,   	//Write Data.
		       output reg reg_wr_valid,                    	//Valid
		                                                	//Write Data.
		       output reg [(BYTE*8)-1:0] tx_data_out, 	//tx data out in ascii
		       output wire tx_data_valid,                     	//Valid Read Data.
		       output reg [(`ADDR_WIDTH)-1:0] addr,        	//Addressing..
		       
		     
		                                                 
		       //inputs
		       input clk,                   			//System Clock
		       input reset,                      		//System reset.
		       input [7:0] data_1_byte,          		//1 byte read data from receiver.
		       input valid_data_1_byte,                    	//data_1_byte from receiver is valid.
		       input baud_x16_ce,                  		//Baud TICK X16.
		       input [((BYTE*8)/2)-1:0] tx_data,			//write TX data into register.
		       input tx_data_en                    		//write TX data enable
		       );
   //Local Parameters
   localparam IDLE = 0,     //IDLE state.
	      ADDRESS = 1,  //Process address commmand.
	      RW = 2,       //Process RW command.
	      WRITEDATA = 3,//Writing data...
	      READDATA = 4; //Reading data...
   
   //Internal Registers
   reg [4:0]  present_state,next_state;
   reg 	      valid_wr_en,valid_rd_en;
   reg 	      new_addr;
   reg 	      rw_command;
   reg [23:0] valid_read_shift;
   reg 	      cnt_byte_en;
   reg [1:0]  cnt_byte;
   reg 	      wr_en;
   reg 	      received_rd_cmd;
   reg 	      tx_data_en0;
   wire [3:0] hex_out;
   reg [3:0]   read_timer;
   wire        read_timed_out;
   reg 	       cmd_clr;
   wire [31:0] tx_data_in_ascii;

   always @(posedge clk)
     if (reset | cmd_clr)
       tx_data_en0 <= 1'b0;
     else if (tx_data_en)
       tx_data_en0 <= 1'b1;
     else if (baud_x16_ce)
       tx_data_en0 <= 1'b0;
   
   always @(posedge clk)
     if (reset)
       present_state <= 4'b0001;
     else if (baud_x16_ce)
       present_state <= next_state;

   //_state Machine.
   always @(*)
     begin
	new_addr = 1'b0;
	next_state = 5'h0;
	valid_wr_en = 1'b0;
	valid_rd_en = 1'b0;
	rw_command = 1'b1;
	cnt_byte_en = 1'b0;
	wr_en = 1'b0;
	cmd_clr = 1'b0;
	
	case (1'b1)
	  present_state[IDLE] : begin
	     if (valid_data_1_byte)
	       begin
		  cnt_byte_en = 1;

		  if (valid_data_1_byte & data_1_byte==`ASCII_LF )
		    begin
		       next_state[IDLE] = 1'b1;
		       cmd_clr = 1'b1;
		    end
		  else if (cnt_byte ==2'b11)
		    begin
		       next_state[ADDRESS] = 1'b1;
		       new_addr = 1'b1;
		     
		    end
		  else
		    begin
		       next_state[IDLE] = 1'b1;
		       new_addr = 1'b1;
		    end
		  
	       end
	     else
	       begin
		  next_state[IDLE] = 1'b1;
	       end
	  end // case: present_state[IDLE]

	  present_state[ADDRESS] : begin
	     if (valid_data_1_byte & data_1_byte==`ASCII_LF )
	       begin
		  next_state[IDLE] = 1'b1;
		  cmd_clr = 1'b1;
	       end
             else if ( tx_data_en0)
	       begin
		  next_state[IDLE] = 1'b1;
		  rw_command = 1'b1;
		  valid_rd_en = 1'b1;
	       end
	     
	     else if (read_timed_out)
	       next_state[IDLE] = 1'b1;
	     
	     else if (valid_data_1_byte & data_1_byte==`WRITE_COMMAND)
	       begin
		  next_state[WRITEDATA] = 1'b1;
		  rw_command = 1'b0;
	       end
	     
	     
	     else
	       next_state[ADDRESS] = 1'b1;
	  end


   
	  present_state[WRITEDATA] : begin
	     
	     if (valid_data_1_byte & data_1_byte==`ASCII_LF )
	       begin
		  next_state[IDLE] = 1'b1;
		  cmd_clr = 1'b1;
	       end
	     else if (valid_data_1_byte)
	       begin
		  cnt_byte_en = 1;
		  if (cnt_byte==2'b11)
		    begin
		       valid_wr_en = 1'b1;
		       wr_en = 1'b1;
		       next_state[IDLE] = 1'b1;
		       rw_command = 1'b0;
		       wr_en = 1'b1;
		    end
		  
		  else
		    begin
		       valid_wr_en = 1'b0;
		       wr_en = 1'b1;
		       next_state[WRITEDATA] = 1'b1;
		       rw_command = 1'b0;
		    end // else: !if(byteCnt)
		  
	       end
	     else
	       next_state[WRITEDATA] = 1'b1;
	  end

	   
	endcase // case(present_state)
     end // always @ (*)


   	  
   always @(posedge clk)
     if (reset | !received_rd_cmd | cmd_clr)
       read_timer <= 4'h0;
     else if (received_rd_cmd & baud_x16_ce)
       read_timer <= read_timer + 1;
   
   assign read_timed_out = (&read_timer)? 1'b1 : 1'b0;

   reg 	  valid0;
   
   always @(posedge clk)
     valid0 <= valid_data_1_byte;
   
   always @(posedge clk)
     if (reset | tx_data_en | cmd_clr)
       received_rd_cmd <= 1'b0;
     else if ((valid_data_1_byte & !valid0) & data_1_byte==`READ_COMMAND)
       received_rd_cmd <= 1'b1;
     else if (present_state[IDLE])
       received_rd_cmd <= 1'b0;

   assign rd_en = received_rd_cmd;
   
   encoder u_encoder(
			// Outputs
			.hex_out	(hex_out),
			// Inputs
			.ascii_in	(data_1_byte));
   
   
   always @(posedge clk)
     if (reset | cmd_clr)
       addr <= {`ADDR_WIDTH{1'b0} };
     else if (new_addr & baud_x16_ce)
       addr <= {addr[(`ADDR_WIDTH)-1-4:0],hex_out};

   always @(posedge clk)
     if (reset | cmd_clr)
       cnt_byte <= 2'b0;
     else if (cnt_byte_en & baud_x16_ce)
       cnt_byte <= cnt_byte + 1;
   
   always @(posedge clk)
     if (reset | cmd_clr)
       begin
          reg_wr_valid <= 1'b0;
       end

     else if (baud_x16_ce)
       begin

          if (valid_wr_en)
            begin
               reg_wr_valid <= 1'b1;
            end
          else
            reg_wr_valid <= 1'b0;
       end

genvar i;
generate
if(BYTE > 1) begin
   always @(posedge clk)
     if (reset | cmd_clr)
       begin
          reg_wr_data <= 'h0;
       end

     else if (baud_x16_ce)
       begin
          if (wr_en)
            reg_wr_data <= {reg_wr_data[((BYTE*8)/2)-1-4:0],hex_out};
       end
end
else begin
   always @(posedge clk)
     if (reset | cmd_clr)
       begin
          reg_wr_data <= 'h0;
       end

     else if (baud_x16_ce)
       begin
          if (wr_en)
            reg_wr_data <= hex_out;
       end
 end

for (i=0; i<BYTE ; i=i+1)
begin:decoder_block
   
	decoder u_decoder(
		      // Outputs
		      .ascii_out	(tx_data_in_ascii[i*8+7 -: 8]),
		      // Inputs
		      .hex_in		(tx_data[i*4+3 -: 4]));
end
endgenerate
   
  always @(posedge clk)
     if (reset | cmd_clr)
       begin
	  valid_read_shift <= 24'h0;
	  tx_data_out <= 'h0;
       end
     else if (baud_x16_ce)
       begin
	  if (valid_rd_en)
	    begin 
	       valid_read_shift <= 24'hff_ff_ff;
	    end
	  else
	    valid_read_shift <= valid_read_shift<<1;

	  if (tx_data_en0)
	      tx_data_out <= tx_data_in_ascii;
       end

   assign tx_data_valid = valid_read_shift[23];
   

   always @(posedge clk)
     if (reset | cmd_clr)
       rw <= 1'b1;
     else if (baud_x16_ce)
       if (rw_command)
	 rw <= 1'b1;
       else
	 rw <= 1'b0;
   

endmodule // command_state

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
