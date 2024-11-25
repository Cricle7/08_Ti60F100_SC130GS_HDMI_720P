/*-----------------------------------------------------------------------
								 \\\|///
							   \\  - -  //
								(  @ @  )
+-----------------------------oOOo-(_)-oOOo-----------------------------+
CONFIDENTIAL IN CONFIDENCE
This confidential and proprietary software may be only used as authorized
by a licensing agreement from CrazyBingo (Thereturnofbingo).
In the event of publication, the following notice is applicable:
Copyright (C) 2013-20xx CrazyBingo Corporation
The entire notice above must be reproduced on all authorized copies.
Author				:		CrazyBingo
Technology blogs 	: 		www.crazyfpga.com
Email Address 		: 		crazyfpga@vip.qq.com
Filename			:		lcd_para.v
Date				:		2012-02-18
Description			:		LCD/VGA driver parameter.
Modification History	:
Date			By			Version			Change Description
=========================================================================
12/02/18		CrazyBingo	1.0				Original
12/03/19		CrazyBingo	1.1				Modification
12/03/21		CrazyBingo	1.2				Modification
12/05/13		CrazyBingo	1.3				Modification
13/11/07		CrazyBingo	2.1				Modification
17/04/02		CrazyBingo	3.0				Modify for 720P & 1080P & 800*480
-------------------------------------------------------------------------
|                                     Oooo								|
+------------------------------oooO--(   )-----------------------------+
                              (   )   ) /
                               \ (   (_/
                                \_)
----------------------------------------------------------------------*/

`timescale 1ns/1ps

//-----------------------------------------------------------------------
//Define the color parameter RGB--8|8|8
//define colors RGB--8|8|8
`define RED		24'hFF0000   /*11111111,00000000,00000000	*/
`define GREEN	24'h00FF00   /*00000000,11111111,00000000	*/
`define BLUE  	24'h0000FF   /*00000000,00000000,11111111	*/
`define WHITE 	24'hFFFFFF   /*11111111,11111111,11111111	*/
`define BLACK 	24'h000000   /*00000000,00000000,00000000	*/
`define YELLOW	24'hFFFF00   /*11111111,11111111,00000000	*/
`define CYAN  	24'hFF00FF   /*11111111,00000000,11111111	*/
`define ROYAL 	24'h00FFFF   /*00000000,11111111,11111111	*/ 

//---------------------------------
`define	SYNC_POLARITY 1'b0

//------------------------------------
//vga parameter define
//`define VGA_854_480_60FPS_30MHz
//`define	VGA_640_480_60FPS_25MHz
//`define 	VGA_800_480_30FPS_16MHz
//`define	VGA_800_600_60FPS_40MHz
`define	VGA_1280_720_60FPS_74_25MHz
//`define	VGA_1920_1080_60FPS_148_5MHz
//`define   VGA_1024_600_60FPS_50MHz
//`define	DSI_1024_600_60FPS_50MHz
//`define	HDMI_1600_1200_30FPS_81MHz

//---------------------------------
//	854 * 480
`ifdef	VGA_854_480_60FPS_30MHz
`define	H_FRONT	50
`define	H_SYNC 	16  
`define	H_BACK 	40  
`define	H_DISP	854 
`define	H_TOTAL	960 	
 				
`define	V_FRONT	30  
`define	V_SYNC 	3  
`define	V_BACK 	12 
`define	V_DISP 	480   
`define	V_TOTAL	525
`endif


//---------------------------------
//	640 * 480
`ifdef	VGA_640_480_60FPS_25MHz
`define	H_FRONT	16
`define	H_SYNC 	96  
`define	H_BACK 	48  
`define	H_DISP	640 
`define	H_TOTAL	800 	
 				
`define	V_FRONT	10  
`define	V_SYNC 	2   
`define	V_BACK 	33 
`define	V_DISP 	480   
`define	V_TOTAL	525
`endif

//---------------------------------
//	800 * 600
`ifdef VGA_800_600_60FPS_40MHz 
`define	H_FRONT	40
`define	H_SYNC 	128  
`define	H_BACK 	88  
`define	H_DISP 	800
`define	H_TOTAL	1056 
				
`define	V_FRONT	1 
`define	V_SYNC 	4   
`define	V_BACK 	23  
`define	V_DISP 	600  
`define	V_TOTAL	628
`endif


//---------------------------------
//	1024*600 DSI (Dual Output)
`ifdef	DSI_1024_600_60FPS_50MHz
`define	H_FRONT	151
`define	H_SYNC 	1
`define	H_BACK 	1
`define	H_DISP	512
`define	H_TOTAL	1330
 				
`define	V_FRONT	32
`define	V_SYNC 	5   
`define	V_BACK 	8 
`define	V_DISP 	600   
`define	V_TOTAL	645
`endif


//---------------------------------
//	1280 * 720
`ifdef	VGA_1280_720_60FPS_74_25MHz
`define	H_FRONT	110
`define	H_SYNC 	40
`define	H_BACK 	220
`define	H_DISP	1280
`define	H_DISP_REQ	1280
`define	H_TOTAL	1650
 				
`define	V_FRONT	5
`define	V_SYNC 	5   
`define	V_BACK 	20 
`define	V_DISP 	720   
`define	V_DISP_REQ 	720  
`define	V_TOTAL	750
`endif


//---------------------------------
//	1920 * 1080
`ifdef	VGA_1920_1080_60FPS_148_5MHz
`define	H_FRONT	88
`define	H_SYNC 	44
`define	H_BACK 	148
`define	H_DISP	1920
`define	H_TOTAL	2200
 					
`define	V_FRONT	4
`define	V_SYNC 	5   
`define	V_BACK 	36
//`define	V_FRONT	3
//`define	V_SYNC 	2
//`define	V_BACK 	3
`define	V_DISP 	1080 
`define	V_TOTAL	1125
//`define	V_TOTAL	1088
`endif


//---------------------------------
//	1024 * 600
`ifdef	VGA_1024_600_60FPS_50MHz
`define	H_FRONT	160
`define	H_SYNC 	40
`define	H_BACK 	120
`define	H_DISP	1024
`define	H_TOTAL	1344
 					
`define	V_FRONT	12 
`define	V_SYNC 	3   
`define	V_BACK 	20 
`define	V_DISP 	600   
`define	V_TOTAL	635
`endif


`ifdef	VGA_800_480_30FPS_16MHz
`define	H_FRONT	80
`define	H_SYNC 	32
`define	H_BACK 	48
`define	H_DISP	800
`define	H_TOTAL	960
 					
`define	V_FRONT	12 
`define	V_SYNC 	3   
`define	V_BACK 	5
`define	V_DISP 	480
`define	V_TOTAL	500
`endif


`ifdef	HDMI_1600_1200_30FPS_81MHz
`define	H_FRONT	64
`define	H_SYNC 	192
`define	H_BACK 	304
`define	H_DISP	1600
`define	H_TOTAL	2160
 					
`define	V_FRONT	1
`define	V_SYNC 	3   
`define	V_BACK 	46
`define	V_DISP 	1200
`define	V_TOTAL	1250
`endif


