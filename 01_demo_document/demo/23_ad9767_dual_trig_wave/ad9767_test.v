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
/*******************************************************************************
Two tri wave outputs£º -10V ~ +10V
/*******************************************************************************/
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
reg  [15:0]                      trig_data;               //Triangle wave DA data
wire                             clk_125M;                //DA clock

assign da1_clk=clk_125M;
assign da1_wrt=clk_125M;
assign da1_data=trig_data;

assign da2_clk=clk_125M;
assign da2_wrt=clk_125M;
assign da2_data=trig_data;

/*************************************************************************
Generate wave data and frequency of DA
****************************************************************************/
//DA output sin waveform
always @(negedge clk_125M)
begin
     if (trig_data == 14'h3fff)
	     trig_data <= 0 ; 
     else		  
        trig_data <= trig_data + 1'b1 ;              							
end 
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
