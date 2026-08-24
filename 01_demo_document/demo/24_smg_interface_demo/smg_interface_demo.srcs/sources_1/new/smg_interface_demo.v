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
//2019/08/16           lhj         1.0          Original
/*******************************************************************************/
module smg_interface_demo(
input                   sys_clk,            //system clock 50Mhz on board
input                   rst_n,              //reset ,low active
output [7:0]            SMG_Data,           //Digital tube segment control line 
output [5:0]            Scan_Sig            //Bit selection 
);
wire [23:0]            Number_Sig;
/*****************************************************************************
6-digit decimal count every 100ms
*****************************************************************************/
demo_control_module U1
(
.sys_clk               ( sys_clk            ),
.rst_n                 ( rst_n              ),
.Number_Sig            ( Number_Sig         )      // output - to U2
);
/*****************************************************************************
Scan and encode 6-digit digital tubes
*****************************************************************************/
smg_interface U2
(
.sys_clk                ( sys_clk           ),
.rst_n                  ( rst_n             ),
.Number_Sig             ( Number_Sig        ),     // input - from U1
.SMG_Data               ( SMG_Data          ),     // output - to top
.Scan_Sig               ( Scan_Sig          )      // output - to top
);
endmodule
