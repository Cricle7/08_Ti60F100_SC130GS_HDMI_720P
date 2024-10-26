/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// uart_defines.v
//
//
// *******************************
// Revisions:
// 1.0 Initial rev
//
// *******************************
/////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////
// User Configurable Global Defines
////////////////////////////////////////////
//`define BYTE 4
//`define CLOCK_FREQ 50000000
//`define BAUD 115200
//`define ENABLE_PARITY 0
//`define PARITY_MODE 0
//`define BOOTUP_CHECK 0

///////////////////////////////////////////////////////////////////////////////////////////////
//Standard Configuration. Do not modify
///////////////////////////////////////////////////////////////////////////////////////////////
//Baud Rate Calculation 
//`define BAUD_GEN_INC ((BAUD<<(BAUD_GEN_ACC_WIDTH-4))+(CLOCK_FREQ>>5))/(CLOCK_FREQ>>4)
//`define BAUD_GEN_INC_X16 (( (BAUD*8)<<(BAUD_GEN_ACC_WIDTH-4))+(CLOCK_FREQ>>5))/(CLOCK_FREQ>>4)*2

//Example Design define.
`define ADDR_WIDTH 16
`define WRITE_COMMAND 8'h21 //"!"
`define READ_COMMAND 8'h40  //"@"

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
