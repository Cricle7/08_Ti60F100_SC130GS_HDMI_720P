// =============================================================================
// Generated by efx_ipmgr
// Version: 2023.2.307
// IP Version: 5.0
// =============================================================================

////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2023 Efinix Inc. All rights reserved.              
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
////////////////////////////////////////////////////////////////////////////////

`define IP_UUID _732a88da6edf48f388cd1ddde30fdb1f
`define IP_NAME_CONCAT(a,b) a``b
`define IP_MODULE_NAME(name) `IP_NAME_CONCAT(name,`IP_UUID)
module uart (
output tx_o,
input rx_i,
output tx_busy,
output [7:0] rx_data,
output rx_data_valid,
output rx_error,
output rx_parity_error,
output rx_busy,
output baud_x16_ce,
input clk,
input reset,
input [2:0] baud_rate,
input tx_en,
input [31:0] tx_data
);
`IP_MODULE_NAME(top_uart) #(
.BYTE (4),
.CLOCK_FREQ (25000000),
.BAUD (115200),
.ENABLE_PARITY (1'b0),
.FIX_BAUDRATE (1'b1),
.PARITY_MODE (1'b0),
.BOOTUP_CHECK (1'b0)
) u_top_uart(
.tx_o ( tx_o ),
.rx_i ( rx_i ),
.tx_busy ( tx_busy ),
.rx_data ( rx_data ),
.rx_data_valid ( rx_data_valid ),
.rx_error ( rx_error ),
.rx_parity_error ( rx_parity_error ),
.rx_busy ( rx_busy ),
.baud_x16_ce ( baud_x16_ce ),
.clk ( clk ),
.reset ( reset ),
.baud_rate ( baud_rate ),
.tx_en ( tx_en ),
.tx_data ( tx_data )
);

endmodule

/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// baud_generator.v
//
// Description:
// Baud Generator generates up to 115.2KHz baud rate.
// common Baud Rate - 4800/9600/19200/57600/115200Hz
//
// *******************************
// Revisions:
// 1.0 Initial rev
//
// *******************************
/////////////////////////////////////////////////////////////////////////////


`resetall
`timescale 1ns/10ps    

  module `IP_MODULE_NAME(baud_generator)
    #(parameter CLOCK_FREQ = 50000000,
                FIX_BAUDRATE = 1,
                BAUD = 115200)
   
    (
     output wire baud_ce,
     output wire baud_x16_ce,
     
     //inputs
     input clk,     
     input [2:0] baud_rate,
     input reset              
     );

   //Baud Rate Calculation 
   parameter BAUD_GEN_ACC_WIDTH = 16;
   
   localparam [BAUD_GEN_ACC_WIDTH-1:0] BAUD_GEN_INC = CLOCK_FREQ/BAUD;
   localparam [BAUD_GEN_ACC_WIDTH-1:0] BAUD_GEN_INC_X16 = (CLOCK_FREQ/BAUD) >> 4;
   
   localparam BAUD_GEN_INC_0 = CLOCK_FREQ/115200;
   localparam BAUD_GEN_INC_1 = CLOCK_FREQ/57600;
   localparam BAUD_GEN_INC_2 = CLOCK_FREQ/38400;
   localparam BAUD_GEN_INC_3 = CLOCK_FREQ/19200;
   localparam BAUD_GEN_INC_4 = CLOCK_FREQ/9600;
   localparam BAUD_GEN_INC_5 = CLOCK_FREQ/4800;
   localparam BAUD_GEN_INC_6 = CLOCK_FREQ/2400;
   localparam BAUD_GEN_INC_7 = CLOCK_FREQ/1200;
   
   //internal registers
   reg [BAUD_GEN_ACC_WIDTH:0] baud_cnt ;
   reg [BAUD_GEN_ACC_WIDTH:0] baud_cnt_x16 ;
   //Baud Rate <1%.
   
    always @(posedge clk) begin
        if (reset) begin
            baud_cnt <= 'h0;
        end
        else begin
            if(baud_ce) begin
    	        baud_cnt <= 'h0; 
    	    end
            else begin
       	        baud_cnt <= baud_cnt[BAUD_GEN_ACC_WIDTH-1:0] + 1'b1;
       	    end
       	end
    end  
    
    always @(posedge clk) begin
        if (reset) begin
          baud_cnt_x16 <= 'h0;
        end
        else begin
            if(baud_ce || baud_x16_ce) begin
                baud_cnt_x16 <= 'h0;
            end
            else begin
                baud_cnt_x16 <= baud_cnt_x16[BAUD_GEN_ACC_WIDTH-1:0] + 1'b1;
            end
        end
    end

   
    generate if (FIX_BAUDRATE) begin
        assign baud_ce = (baud_cnt == BAUD_GEN_INC-1'b1);
        assign baud_x16_ce = (baud_cnt_x16 == BAUD_GEN_INC_X16 - 1'b1);
    end
    else begin
        assign baud_ce = (baud_rate == 1) ? (baud_cnt == BAUD_GEN_INC_1-1'b1) :
                         (baud_rate == 2) ? (baud_cnt == BAUD_GEN_INC_2-1'b1) :
                         (baud_rate == 3) ? (baud_cnt == BAUD_GEN_INC_3-1'b1) :
                         (baud_rate == 4) ? (baud_cnt == BAUD_GEN_INC_4-1'b1) :
                         (baud_rate == 5) ? (baud_cnt == BAUD_GEN_INC_5-1'b1) :
                         (baud_rate == 6) ? (baud_cnt == BAUD_GEN_INC_6-1'b1) :
                         (baud_rate == 7) ? (baud_cnt == BAUD_GEN_INC_7-1'b1) :
                         (baud_cnt == BAUD_GEN_INC_0-1'b1);
        assign baud_x16_ce = (baud_rate == 1) ? (baud_cnt_x16 == (BAUD_GEN_INC_1 >> 4)-1'b1) :
                             (baud_rate == 2) ? (baud_cnt_x16 == (BAUD_GEN_INC_2 >> 4)-1'b1) :
                             (baud_rate == 3) ? (baud_cnt_x16 == (BAUD_GEN_INC_3 >> 4)-1'b1) :
                             (baud_rate == 4) ? (baud_cnt_x16 == (BAUD_GEN_INC_4 >> 4)-1'b1) :
                             (baud_rate == 5) ? (baud_cnt_x16 == (BAUD_GEN_INC_5 >> 4)-1'b1) :
                             (baud_rate == 6) ? (baud_cnt_x16 == (BAUD_GEN_INC_6 >> 4)-1'b1) :
                             (baud_rate == 7) ? (baud_cnt_x16 == (BAUD_GEN_INC_7 >> 4)-1'b1) :
                             (baud_cnt_x16 == (BAUD_GEN_INC_0 >> 4)-1'b1);
    end
    endgenerate

   
endmodule

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


/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// receiver.v
//
// Description:
// process the RX data from UART Peripherals
//
// *******************************
// Revisions:
// 1.0 Initial rev
//
// *******************************
/////////////////////////////////////////////////////////////////////////////


`resetall
`timescale 1ns/10ps       

  module `IP_MODULE_NAME(receiver)
    #( parameter PARITY_MODE = 0)
   (
    //outputs
    output wire [7:0] data_1_byte, 	//One bye of data.
    output reg valid,     		//Valid for data_1_byte.
    output reg error,                   //Framing Error.
    output reg parity_error,            //Parity Error. 
    output reg rx_busy,                 //rx busy 
    //inputs
    input clk,             		//System Clock.
    input reset,                	//system reset.
    input baud_x16_ce,        		//BaudX16 Enable Signal
    input rx_i,                		//RX data from PC.
    input en_parity                     //Enable Parity 
    );

   //Parameters
   localparam IDLE = 0,
	      START = 1,
	      DATA = 2,
	      STOP = 3,
	      ERROR = 4,
              PARITY = 5;

   localparam IDLE_ST  	= 6'b00_0001,
              START_ST 	= 6'b00_0010,
              DATA_ST  	= 6'b00_0100,
              STOP_ST  	= 6'b00_1000,
              ERROR_ST 	= 6'b01_0000,
             PARITY_ST 	= 6'b10_0000;
   
                                 
   
   //internal signals
   reg 	      rx_data0,rx_data1,rx_data2;
   reg [5:0]  present_state,next_state;
   reg [3:0]  count_x16;
   wire       start;
   reg 	      shift_en;
   reg [15:0] shift_rx_data [7:0];
   reg 	      load_data;
   reg [7:0]  parallel_data;
   reg 	      count_en;
   reg 	      valid_en;
   reg [7:0]  count_8bit;
   integer    i;
   reg [2:0]  rx_data_sync;
   reg 	      parity_en;
   reg [15:0] parity_data;
   wire       parity_bit;
  
   wire       expected_parity_bit;
   
   //synchronize the rx_i.
   always @(posedge clk)
     if (reset)
       rx_data_sync <= 3'b111;
     else
       rx_data_sync <= {rx_data_sync[1:0],rx_i};
   
   
   //synchronize the incoming rx_i... 
   always @(posedge clk)
     if (reset)
       begin
	  rx_data0 <= 1'b1;
	  rx_data1 <= 1'b1;
	  rx_data2 <= 1'b1;
       end
     else if (baud_x16_ce)
       begin  
	  rx_data0 <= rx_data_sync[2];
	  rx_data1 <= rx_data0;
	  rx_data2 <= rx_data1;
       end

   assign start = !rx_data1 & rx_data2;
 

   always @(posedge clk)
     if (reset)
       present_state <= 6'h1;
     else if (baud_x16_ce)
       present_state <= next_state;

   //State Machine for Receiver to process the RXDATA and generate the parallel data...
   always @(*)
     begin
	load_data = 0;
	shift_en= 0;
	valid_en = 0;
	count_en = 0;
	parity_en = 0;
	
	case (present_state)
	  IDLE_ST: begin
	     if (start)
	       next_state = START_ST;
	     else
	       next_state = IDLE_ST;
	  end
	  
	 START_ST: begin
	    count_en = 1'b1;
	  
	     if (&count_x16)
	       next_state = DATA_ST;
	     else if (rx_data2)
	       next_state = ERROR_ST;
	     else
	       next_state = START_ST;
	  end
	  
	  DATA_ST : begin
	     shift_en = 1'b1;
	     if (count_8bit[7] && &count_x16)
	       begin
		  load_data = 1'b1;
		  if (en_parity)
		    next_state = PARITY_ST;
		  else 
		    next_state= STOP_ST;
		
	       end
	     else
	       begin
		
		  next_state = DATA_ST;
	       end
	  end 

	  PARITY_ST : begin
	     count_en = 1'b1;
	     parity_en = 1'b1;
	     if (&count_x16)
	       begin
		  next_state = STOP_ST;
	       end
	     
	     else
	       begin
		  next_state = PARITY_ST;  
	       end
	  end
	  
	  
	  STOP_ST : begin
	     count_en=1'b1;
	     
	     if (!rx_data1)
	       next_state = ERROR_ST;
	     else if (count_8bit[0] & &count_x16)
	       begin
		  valid_en = 1'b1;
		  if (start)
		    next_state = START_ST;
		  else 
		    next_state = IDLE_ST;
	       end
	     
	     else
	       begin
		  next_state = STOP_ST;
	
	       end
	  end // case: present_state[STOP]
	  
	  ERROR_ST : begin
	     next_state = IDLE_ST;
	  end
	  
	  
	  default: next_state = IDLE_ST;
	  
	endcase // case(current_state)
	
	
     end // always @ (*)
   

   always @(posedge clk)
     if (reset)
       count_x16 <= 4'b0;
     else if (baud_x16_ce)
       begin
	  if (count_en |  shift_en)
	    count_x16 <= count_x16 + 1;
	  else if (present_state[IDLE])
	    count_x16 <= 4'h0;
       end
   
   always @(posedge clk)
     begin
	if (reset)
	  count_8bit <= 8'h01;
	else if (baud_x16_ce)
	  begin
	     if ( present_state[DATA]  &&  &count_x16  )
	       count_8bit <= {count_8bit[6:0],count_8bit[7]};
	     else if (present_state[IDLE])
	       count_8bit <= 8'h01;
	  end

       
     end // always @ (posedge clk)


   

   always @(posedge clk)
     if (reset | present_state[IDLE])
       begin
	  for (i=0; i<8;i=i+1)
	    shift_rx_data[i] <= 16'h0;
       end

     else if (baud_x16_ce & shift_en)
       case (1'b1)
	 count_8bit[0]:
	   shift_rx_data[0] <= shift_rx_data[0]<<1 | rx_data2;
	 count_8bit[1]:
	   shift_rx_data[1] <= shift_rx_data[1]<<1 | rx_data2;
	 count_8bit[2]:
	   shift_rx_data[2] <= shift_rx_data[2]<<1 | rx_data2;
	 count_8bit[3]:
	   shift_rx_data[3] <= shift_rx_data[3]<<1 | rx_data2;
	 count_8bit[4]:
	   shift_rx_data[4] <= shift_rx_data[4]<<1 | rx_data2;
	 count_8bit[5]:
	   shift_rx_data[5] <= shift_rx_data[5]<<1 | rx_data2;
	 count_8bit[6]:
	   shift_rx_data[6] <= shift_rx_data[6]<<1 | rx_data2;
	 count_8bit[7]:
	   shift_rx_data[7] <= shift_rx_data[7]<<1 | rx_data2;
	endcase

   
   
   always @(posedge clk)
     if (reset)
       begin
	  parallel_data <= 8'h0;

       end
     else if (load_data & baud_x16_ce)
       parallel_data <= { &shift_rx_data[7][8:7], &shift_rx_data[6][8:7],
			 &shift_rx_data[5][8:7], &shift_rx_data[4][8:7],
			 &shift_rx_data[3][8:7], &shift_rx_data[2][8:7],
			 &shift_rx_data[1][8:7], &shift_rx_data[0][8:7]
			 };

   assign data_1_byte = parallel_data;
   
   always @(posedge clk)
	if (reset )
       valid <= 1'b0;
     else if (baud_x16_ce) begin
	if (valid_en)
	  valid <= 1'b1;
	else
	  valid <= 1'b0;
     end


 
   
   
    always @(posedge clk)
     if (reset | present_state[IDLE])
       parity_data <= 16'h0;
     else if (baud_x16_ce & parity_en)
       parity_data <= parity_data<<1 | rx_data2;
   

   assign parity_bit = &parity_data[8:7];
   generate 
      if (PARITY_MODE==1)
	assign expected_parity_bit = ~(^parallel_data);
      else
	assign expected_parity_bit = ^parallel_data;
   endgenerate
   
   //Update the parity status bit. 
   always @(posedge clk)
     if (reset)
       parity_error <= 1'b0;
     else if (present_state[STOP])
       parity_error <= (expected_parity_bit !=  parity_bit);

  
     

   //Error in transmission...
   //This is unused register in this design. I only need to use it
   //during verification.
   //TO-DO: You may add this feature to let firmware read the error.
   always @(posedge clk)
     if (reset)
       error <= 1'b0;
     else if (present_state[ERROR])
       error <= 1'b1;
     else if (present_state[STOP])
       error <= 1'b0;
   

   
   always @(posedge clk)
     if (reset)
       rx_busy <= 1'b0;
     else if (present_state[IDLE])
       rx_busy <= 1'b0;
     else
       rx_busy <= 1'b1;
   
endmodule // receiver

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




/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// top_uart.v
//
// Description:
// UART Controller
//
// *******************************
// Revisions:
// 1.0 Initial rev
//
// *******************************
/////////////////////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps       
//`include "uart_defines.v"

  module `IP_MODULE_NAME(top_uart)(
   tx_o,                        
   rx_i,                        
   tx_busy,            		
   rx_data,   	        
   rx_data_valid,      		
   rx_error,           		
   rx_parity_error,              
   rx_busy,            		 
   baud_x16_ce,
   clk,                  	
   reset,                		
   tx_data,
   baud_rate,
   tx_en           
   );

   parameter BYTE = 4;
   parameter DATA_WIDTH = BYTE*8;
   parameter CLOCK_FREQ = 50000000;
   parameter FIX_BAUDRATE = 0;
   parameter BAUD = 115200;
   parameter ENABLE_PARITY = 0;
   parameter PARITY_MODE  = 0;
   parameter BOOTUP_CHECK = 0;
   ////////////////////
   //UART interface
   output tx_o;                       //UART TX
   input  rx_i;                        //UART RX

   ////////////////////
   //User Interface
   //outputs
   output tx_busy;            		//transmitting the tx data.
   output [7:0] rx_data;   	        //rx_data to user logic
   output rx_data_valid;      		//valid flag for rx_data.
   output rx_error;           		//a start bit, parity bit, or stop bit error was detected during the last received data.
   output rx_parity_error;              //Indicate receive data contain parity error. 
   output rx_busy;            		//Receiving the rx data. 
   output baud_x16_ce;
   //inputs
   input clk;                  		//system clock
   input reset;                		//active high reset
   input [BYTE*8-1:0] tx_data;     //Data to transmit.
   input tx_en;                 		//Latches tx_data and initiate transmit
   input [2:0] baud_rate;  //0-115200, 1-57600, 2-38400, 3-19200, 4-9600, 5-4800, 6-2400, 7-1200
//Internal Signals
   wire  baud_ce;
   wire  en_parity;
   
   //UART Format 
   /*   _______         ______                        _______________
    *   IDLE   \_Start_/ Bit0 -----Bit1 -> Bit 7(MSB)/PARITY \/STOP IDLE           
    *   Refer to waveform above, the start is start bit (1'b0).
    *   Meanwhile, the stop is stop bit (1'b1)
    */

   
   `IP_MODULE_NAME(baud_generator) #(.CLOCK_FREQ(CLOCK_FREQ),
            .FIX_BAUDRATE(FIX_BAUDRATE),
		    .BAUD(BAUD)
		    )
   u_baud_generator
     (
      // Outputs
      .baud_ce				(baud_ce),
      .baud_x16_ce			(baud_x16_ce),
      // Inputs
      .clk                  (clk),
      .baud_rate            (baud_rate),
      .reset				(reset));
   

   `IP_MODULE_NAME(transmitter) #(
		 .ENABLE_PARITY(ENABLE_PARITY),
		 .PARITY_MODE(PARITY_MODE),
		 .DATA_WIDTH(DATA_WIDTH),
		 .BOOTUP_CHECK(BOOTUP_CHECK)
		 )
   u_transmitter
     (
      // Outputs
      .tx_o				(tx_o),
      .tx_busy                          (tx_busy), 
      // Inputs
      .clk				(clk),
      .reset				(reset),
      .baud_ce				(baud_ce),
      .tx_data				(tx_data[DATA_WIDTH-1:0]),
      .tx_en				(tx_en));
   

   `IP_MODULE_NAME(receiver) #(
	      .PARITY_MODE(PARITY_MODE)
	      )
   u_receiver
     (
      // Outputs
      .data_1_byte			(rx_data),
      .valid				(rx_data_valid),
      .error				(rx_error),
      .parity_error                     (rx_parity_error), 
      .rx_busy                          (rx_busy),
      // Inputs
      .clk				(clk),
      .reset				(reset),
      .baud_x16_ce			(baud_x16_ce),
      .en_parity                        (en_parity),
      .rx_i				(rx_i));

   assign en_parity =  ENABLE_PARITY;
   

endmodule // top_uart

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



/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// transmitter.v
//
// Description:
// Transmit the TX data to UART Peripheral
//
// *******************************
// Revisions:
// 1.0 Initial rev
//
// *******************************
/////////////////////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps       

  module `IP_MODULE_NAME(transmitter)
    #(parameter ENABLE_PARITY = 0,
                PARITY_MODE   = 0,
                DATA_WIDTH    = 32,
                BOOTUP_CHECK  = 0)
    (
     //outputs
     output wire tx_o,   		//TX data to UART peripheral.
     output reg tx_busy,                //tx busy flag. 
     //input
     input clk,       			//system clock
     input reset,          		//system reset.
     input baud_ce,        		//baud tick
     input [DATA_WIDTH-1:0] tx_data, 	//8-bit read data...
     input tx_en        		//Valid read data...Ready to send it...
     );
     
//ASCII 
`define ASCII_0 8'h30
`define ASCII_1 8'h31
`define ASCII_2 8'h32
`define ASCII_3 8'h33
`define ASCII_4 8'h34
`define ASCII_5 8'h35
`define ASCII_6 8'h36
`define ASCII_7 8'h37
`define ASCII_8 8'h38
`define ASCII_9 8'h39

`define ASCII_a 8'h61
`define ASCII_b 8'h62
`define ASCII_c 8'h63
`define ASCII_d 8'h64
`define ASCII_e 8'h65
`define ASCII_f 8'h66


`define ASCII_A 8'h41
`define ASCII_B 8'h42
`define ASCII_C 8'h43
`define ASCII_D 8'h44
`define ASCII_E 8'h45
`define ASCII_F 8'h46

`define ASCII_O 8'h4F
`define ASCII_K 8'h4B
`define ASCII_LF 8'h0A

//START & STOP BIT
`define STOP_BIT 1'b1
`define START_BIT 1'b0

   //internal signals.
   reg [46:0] shift_tx_data;
   wire [46:0] xmit_data_p,  xmit_data;
   reg 	       tx_en0,tx_en1,tx_en2;
   reg [5:0]   tx_count;
   wire        ascii_k_parity;
   wire        ascii_o_parity;
   

   always @(posedge clk)
     if (reset)
       begin
	  tx_en0 <= 1'b0;
	  tx_en1 <= 1'b0;
	  tx_en2 <= 1'b0;
       end
   else if (baud_ce)
     begin
	tx_en0 <= tx_en;
	tx_en1 <= tx_en0;
	tx_en2 <= tx_en1;
     end

  generate
     if (PARITY_MODE==1) begin  //odd
	assign ascii_k_parity = ~(^(`ASCII_K));
	assign ascii_o_parity = ~(^(`ASCII_O));
     end
     else begin                 //even
	assign ascii_k_parity = ^(`ASCII_K);
	assign ascii_o_parity = ^(`ASCII_O);
     end
  endgenerate
   
   generate
      if (DATA_WIDTH == 32)
	if (PARITY_MODE==1) begin
	   assign xmit_data_p =  {`STOP_BIT, ~(^tx_data[7:0])  , tx_data[7:0]   , `START_BIT, 1'b1, 
				  `STOP_BIT, ~(^tx_data[15:8]) , tx_data[15:8]  , `START_BIT, 1'b1,
				  `STOP_BIT, ~(^tx_data[23:16]), tx_data[23:16] , `START_BIT, 1'b1,
				  `STOP_BIT, ~(^tx_data[31:24]), tx_data[31:24] , `START_BIT 
				  };

	end

	else begin
	   assign xmit_data_p =  {`STOP_BIT, ^tx_data[7:0]  , tx_data[7:0]   , `START_BIT, 1'b1, 
				  `STOP_BIT, ^tx_data[15:8] , tx_data[15:8]  , `START_BIT, 1'b1,
				  `STOP_BIT, ^tx_data[23:16], tx_data[23:16] , `START_BIT, 1'b1,
				  `STOP_BIT, ^tx_data[31:24], tx_data[31:24] , `START_BIT 
				  };

	end
      
    
      
      else if (DATA_WIDTH == 24)
	if (PARITY_MODE==1) begin 
	   assign xmit_data_p =  {11'h7ff,
				  `STOP_BIT, ~(^tx_data[7:0]), tx_data[7:0]   , `START_BIT, 1'b1, 
				  `STOP_BIT, ~(^tx_data[15:8]), tx_data[15:8]  , `START_BIT, 1'b1,
				  `STOP_BIT, ~(^tx_data[23:16]), tx_data[23:16] , `START_BIT, 1'b1
				  };
	end
	else begin
	   assign xmit_data_p =  {11'h7ff,
				  `STOP_BIT, ^tx_data[7:0]  , tx_data[7:0]   , `START_BIT, 1'b1, 
				  `STOP_BIT, ^tx_data[15:8] , tx_data[15:8]  , `START_BIT, 1'b1,
				  `STOP_BIT, ^tx_data[23:16], tx_data[23:16] , `START_BIT, 1'b1
				  };
	end
      
      else if (DATA_WIDTH == 16)
	if (PARITY_MODE==1) begin 
	   assign xmit_data_p =  {23'h7f_ffff,
				  `STOP_BIT, ~(^tx_data[7:0])  , tx_data[7:0]   , `START_BIT, 1'b1, 
				  `STOP_BIT, ~(^tx_data[15:8]) , tx_data[15:8]  , `START_BIT, 1'b1
				  };
	end
	else begin
	   assign xmit_data_p =  {23'h7f_ffff,
				  `STOP_BIT, ^tx_data[7:0]  , tx_data[7:0]   , `START_BIT, 1'b1, 
				  `STOP_BIT, ^tx_data[15:8] , tx_data[15:8]  , `START_BIT, 1'b1
				  };
	end
      
      
      else if (DATA_WIDTH == 8)
	if (PARITY_MODE==1) begin 
	   assign xmit_data_p =  {35'h7_ffff_ffff,
				  `STOP_BIT, ~(^tx_data[7:0])  , tx_data[7:0]   , `START_BIT, 1'b1 
				  };
	   
	end
	else begin
	   assign xmit_data_p =  {35'h7_ffff_ffff,
				  `STOP_BIT, ^tx_data[7:0]  , tx_data[7:0]   , `START_BIT, 1'b1 
				  };
	end
      

      else
	if (PARITY_MODE==1) begin 
	   assign xmit_data_p =  {35'h7_ffff_ffff,
				  `STOP_BIT, ~(^tx_data[7:0]) , tx_data[7:0]   , `START_BIT, 1'b1 
				  };
	end
	else begin
	   assign xmit_data_p =  {35'h7_ffff_ffff,
				  `STOP_BIT, ^tx_data[7:0]  , tx_data[7:0]   , `START_BIT, 1'b1 
				  };
	end
      
   endgenerate


   generate
      if (DATA_WIDTH == 32)
	assign xmit_data =  {  4'hf,
			       `STOP_BIT,  tx_data[7:0]   , `START_BIT, 1'b1, 
			       `STOP_BIT,  tx_data[15:8]  , `START_BIT, 1'b1,
			       `STOP_BIT,  tx_data[23:16] , `START_BIT, 1'b1,
			       `STOP_BIT,  tx_data[31:24] , `START_BIT 
			       };
      
      else if (DATA_WIDTH == 24)
	assign xmit_data =  {  14'h3fff,
			       `STOP_BIT,  tx_data[7:0]   , `START_BIT, 1'b1, 
			       `STOP_BIT,  tx_data[15:8]  , `START_BIT, 1'b1,
			       `STOP_BIT,  tx_data[23:16] , `START_BIT, 1'b1
			       };
      else  if (DATA_WIDTH == 16)
	assign xmit_data =  {  25'h1ff_ffff,
			       `STOP_BIT,  tx_data[7:0]   , `START_BIT, 1'b1, 
			       `STOP_BIT,  tx_data[15:8]  , `START_BIT, 1'b1
			       };
      
      else  if (DATA_WIDTH == 8)
	assign xmit_data =  {  36'hf_ffff_ffff,
			       `STOP_BIT,  tx_data[7:0]   , `START_BIT, 1'b1 
			       };
      
      else
	assign xmit_data =  {  36'hf_ffff_ffff,
			       `STOP_BIT,  tx_data[7:0]   , `START_BIT, 1'b1 
			       };
   endgenerate
   
   
   generate
      if (BOOTUP_CHECK) begin
	 if (ENABLE_PARITY) begin 
	    //Generates OK flag after reset.
	    always @(posedge clk)
	      if (reset)
		shift_tx_data <= { 12'hfff, 
				   `STOP_BIT, ascii_k_parity, `ASCII_K, `START_BIT,
				   4'hf,
				   `STOP_BIT, ascii_o_parity, `ASCII_O, `START_BIT,
				   8'hff, 1'b1
				   };
	    
	      else if (baud_ce)
		begin
		   if (tx_en1 & !tx_en2)
		     shift_tx_data <= xmit_data_p;
		   else
		     shift_tx_data <= {1'b1, shift_tx_data[DATA_WIDTH-1+15:1] } ;
		end
	    
	 end // if (ENABLE_PARITY)
	 
	 else begin 
	    //Generates OK flag after reset.
	    always @(posedge clk)
	      if (reset)
		shift_tx_data <= { 1'b1, 8'hff, 1'b1,
				   `STOP_BIT, `ASCII_K, `START_BIT,
				   8'hff,
				   `STOP_BIT, `ASCII_O, `START_BIT,
				   8'hff, 1'b1
				   };
	    
	      else if (baud_ce)
		begin
		   if (tx_en1 & !tx_en2)
		     shift_tx_data <= xmit_data;
		   else
		     shift_tx_data <= {1'b1, shift_tx_data[DATA_WIDTH-1+15:1] } ;
		end
	 end // else: !if(ENABLE_PARITY)
	 
      end // if (BOOTUP_CHECK)
      else begin
	 if (ENABLE_PARITY) begin 
	    //Generates OK flag after reset.
	    always @(posedge clk)
	      if (reset)
		shift_tx_data <= {47{1'b1}};
	    
	    
	      else if (baud_ce)
		begin
		   if (tx_en1 & !tx_en2)
		     shift_tx_data <= xmit_data_p;
		   else
		     shift_tx_data <= {1'b1, shift_tx_data[DATA_WIDTH-1+15:1] } ;
		end
	    
	 end // if (ENABLE_PARITY)
	 
	 else begin 
	    //Generates OK flag after reset.
	    always @(posedge clk)
	      if (reset)
		shift_tx_data <= {47{1'b1}};
	    
	      else if (baud_ce)
		begin
		   if (tx_en1 & !tx_en2)
		     shift_tx_data <= xmit_data;
		   else
		     shift_tx_data <= {1'b1, shift_tx_data[DATA_WIDTH-1+15:1] } ;
		end
	 end // else: !if(ENABLE_PARITY)

      end // else: !if(BOOTUP_CHECK)
      
   endgenerate
   
   
   
   
   always @(posedge clk)
     if (reset)
       tx_count <= 6'd0;
     else if (baud_ce)
       if (tx_en1 & !tx_en2)
	 tx_count <= 6'd0;
       else if (tx_count < (DATA_WIDTH+11 + 1) )
	 tx_count <= tx_count + 1;

   always @(posedge clk)
     if (reset)
       tx_busy <= 1'b0;
     else if (baud_ce)
       if (tx_en1 & !tx_en2)
	 tx_busy <= 1'b1;
       else if (tx_count == (DATA_WIDTH+11 ) )
	 tx_busy <= 1'b0;
   
   assign 		 tx_o = shift_tx_data[0];
   

endmodule // transmitter


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

`undef IP_UUID
`undef IP_NAME_CONCAT
`undef IP_MODULE_NAME
