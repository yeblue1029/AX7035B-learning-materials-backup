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
//  2019/08/16     meisq         1.0         Original
//*******************************************************************************/
module top
(
input               sys_clk,                //system clock 50Mhz on board
input               rst_n,                  //reset ,low active
input               ft_clk,                 //ft232 clock
input               ft_rxf_n,               //Read FT232 FIFO data available or invalid  flag 
input               ft_txe_n,               //Write FT232 FIFO data available or invalid flag
output              ft_oe_n,                //FT232 output enable
output              ft_rd_n,                //FT232 read data enable
output              ft_wr_n,                //FT232 write data enable
output              ft_siwu_n,              //send immediate/wake up
inout[7:0]          ft_data                 //FT232 data
);
assign ft_siwu_n = 1'b1;
ft232h ft232h_m0
(
.sys_clk            (sys_clk        ),
.ft_clk             (ft_clk         ), 
.rst                (~rst_n         ), 
.ft_rxf_n           (ft_rxf_n       ), 
.ft_txe_n           (ft_txe_n       ), 
.ft_oe_n            (ft_oe_n        ), 
.ft_rd_n            (ft_rd_n        ), 
.ft_wr_n            (ft_wr_n        ), 
.ft_data            (ft_data        )
);
endmodule