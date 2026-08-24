//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: lhj                                                                 //
//                                                                              //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.com/                                               //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//2019/08/16                    1.0          Original
//*******************************************************************************/
module ad9767_test
(
input                            sys_clk,                 //system clock 50Mhz on board
output                           da1_clk,                 //AD9767 CH1 clock
output                           da1_wrt,                 //AD9767 CH1 enable
output [13:0]                    da1_data,                //AD9767 CH1 data output
output                           da2_clk,                 //AD9767 CH2 clock
output                           da2_wrt,	              //AD9767 CH2 enable
output [13:0]                    da2_data                 //AD9767 CH2 data output
);
reg [9:0]                        rom_addr;               //Store the ROM address of the DA data
wire [13:0]                      rom_data;               //ROM data of DA 
wire                             clk_125M;               //clock for DA data processing

assign da1_clk=clk_125M;
assign da1_wrt=clk_125M;
assign da1_data=rom_data;

assign da2_clk=clk_125M;
assign da2_wrt=clk_125M;
assign da2_data=rom_data;
/*************************************************************************
Generate the frequency of DA
****************************************************************************/
always @(negedge clk_125M)
begin
 rom_addr <= rom_addr + 1'b1 ;                             //The output sine wave frequency is 122Khz
 // rom_addr <= rom_addr + 4 ;                             //The output sine wave frequency is 488Khz
 // rom_addr <= rom_addr + 128 ;                           //The output sine wave frequency is 15.6Mhz								
end 
/*************************************************************************
Read sine wave data in ROM
****************************************************************************/
ROM ROM_inst
(
.clka                           (clk_125M                ), 
.addra                          (rom_addr                ), 
.douta                          (rom_data                ) 
);
/*************************************************************************
Generate the clock  required for DA
****************************************************************************/
PLL PLL_inst
(
.clk_in1                        (sys_clk                 ),     
.clk_out1                       (                        ),      
.clk_out2                       (clk_125M                ),    
.reset                          (1'b0                    ),   
.locked                         (                        )
);      
endmodule
