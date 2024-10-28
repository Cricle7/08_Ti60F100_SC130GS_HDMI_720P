`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:Meyesemi 
// Engineer: Will
// 
// Create Date: 2023-01-29 20:31  
// Design Name:  
// Module Name: 
// Project Name: 
// Target Devices: Pango
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define UD #1

module uart_top(
    //input ports
    input         clk,
    input         reset,
    input         uart_rx,
    input   [1:0] r_vsync_i,
    input   [42:0] target_pos_out1,
    input   [42:0] target_pos_out2,

    
    //output ports
    output  [7:0] led,
    output        uart_tx
);

   parameter      BPS_NUM = 645;
   //  设置波特率为4800时，  bit位宽时钟周期个数:50MHz set 10417  40MHz set 8333
   //  设置波特率为9600时，  bit位宽时钟周期个数:50MHz set 5208   40MHz set 4167
   //  设置波特率为115200时，bit位宽时钟周期个数:50MHz set 434    40MHz set 347 12M set 104
   

//==========================================================================
//wire and reg in the module
//==========================================================================

    wire           tx_busy;         //transmitter is free.
    wire           rx_finish;       //receiver is free.
    wire    [7:0]  rx_data;         //the data receive from uart_rx.
                                    
    wire    [7:0]  tx_data;         
                                    
    wire           tx_en;           //enable transmit.

//==========================================================================
//logic
//==========================================================================
    wire rx_en;

//==========================================================================
//instance
//==========================================================================
    reg  [7:0] receive_data;
    always @(posedge clk)  receive_data <= led;
    uart_data_gen uart_data_gen(
        .clk                  (  clk      ),//input             clk,
        .reset                (  reset        ),//input             clk,
        .r_vsync_i            (  r_vsync_i    ),//input             clk,
        .read_data            (  receive_data ),//input      [7:0]  read_data,
        .tx_busy              (  tx_busy      ),//input             tx_busy,
        .write_max_num        (  11            ),//input      [7:0]  write_max_num,
        .write_data           (  tx_data      ),//output reg [7:0]  write_data
        .write_en             (  tx_en        ) //output reg        write_en
    );
    
    //uart transmit data module.
    uart_tx #(
         .BPS_NUM            (  BPS_NUM       ) //parameter         BPS_NUM  =    16'd434
     )
     u_uart_tx(
        .clk                 (  clk         ),// input            clk,               
        .tx_data             (  tx_data       ),// input [7:0]      tx_data,           
        .tx_pluse            (  tx_en         ),// input            tx_pluse,          
        .uart_tx             (  uart_tx       ),// output reg       uart_tx,                                  
        .tx_busy             (  tx_busy       ) // output           tx_busy            
    );                                             
                                               
    //Uart receive data module.                
    uart_rx #(
         .BPS_NUM            (  BPS_NUM       ) //parameter          BPS_NUM  =    16'd434
     )
     u_uart_rx (                        
        .clk                 (  clk           ),// input             clk,                              
        .uart_rx             (  uart_rx       ),// input             uart_rx,            
        .rx_data             (  rx_data       ),// output reg [7:0]  rx_data,                                   
        .rx_en               (  rx_en         ),// output reg        rx_en,                          
        .rx_finish           (  rx_finish     ) // output            rx_finish           
    );                                            
                                                  
    assign led = rx_data;
    
endmodule
