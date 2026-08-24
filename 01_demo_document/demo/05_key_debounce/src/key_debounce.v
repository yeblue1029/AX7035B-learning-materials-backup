//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: lhj                                                                 //
//                                                                              //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
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

//===============================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//-------------------------------------------------------------------------------
//  2018/01/03    lhj        1.0         Original
//*******************************************************************************/
module key_debounce
(
input        sys_clk,       //system clock 50Mhz on board
input        rst_n,         //reset ,low active
input        key,           //user key on board
output [3:0] led            //user leds on board
);
wire        button_negedge; //Key falling edge
/*************************************************************************
Only one pulse is generated when a key is pressed to meet requirements
****************************************************************************/
ax_debounce ax_debounce_m0
(
.clk             (sys_clk       ),
.rst             (~rst_n        ),
.button_in       (key           ),
.button_posedge  (              ),
.button_negedge  (button_negedge),
.button_out      (              )
);

wire[3:0]   count;
wire        t0;
/*************************************************************************
Decimal counts when button_negedge changes
****************************************************************************/
count_m10 count10_m0
(
.clk             (sys_clk       ),
.rst_n           (rst_n         ),
.en              (button_negedge),
.clr             (1'b0          ),
.data            (count         ),
.t               (t0            )
);
assign led = ~count;
endmodule 