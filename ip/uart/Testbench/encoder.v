/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// encoder.v
//
// Description:
// ASCII to Hex Converter.
// It supports ASCII 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F.
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
  


  module encoder
    (
     //output
     output reg [3:0] hex_out, 	//4-bit hexadecimal output after encode from 8-bit
                              	//ASCII.
     
     //input
     input [7:0] ascii_in      	//8-bit ASCII input.
     );



   // Convert ASCII code to 4-bit hexadecimal.
   always @(*)
     case (ascii_in[7:0])
       `ASCII_0 : hex_out = 4'h0;
       `ASCII_1: hex_out = 4'h1;
       `ASCII_2: hex_out = 4'h2;
       `ASCII_3: hex_out = 4'h3;
       `ASCII_4: hex_out = 4'h4;
       `ASCII_5: hex_out = 4'h5;
       `ASCII_6: hex_out = 4'h6;
       `ASCII_7: hex_out = 4'h7;
       `ASCII_8: hex_out = 4'h8;
       `ASCII_9: hex_out = 4'h9;
       `ASCII_a: hex_out = 4'hA;
       `ASCII_b: hex_out = 4'hB;
       `ASCII_c: hex_out = 4'hC;
       `ASCII_d: hex_out = 4'hD;
       `ASCII_e: hex_out = 4'hE;
       `ASCII_f: hex_out = 4'hF;
       default : hex_out = 4'h0;
     endcase // case(ascii_in[7:0])
   
   
endmodule // encoder

 

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

