// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Mon Jul 29 09:31:32 2019
// Host        : PC-201805041311 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               I:/ax7035_2019.1/demo/09_fifo_test/fifo_test.srcs/sources_1/ip/ila_m0/ila_m0_stub.v
// Design      : ila_m0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2019.1" *)
module ila_m0(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[15:0],probe1[0:0],probe2[15:0],probe3[0:0],probe4[0:0],probe5[0:0],probe6[8:0],probe7[8:0]" */;
  input clk;
  input [15:0]probe0;
  input [0:0]probe1;
  input [15:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
  input [0:0]probe5;
  input [8:0]probe6;
  input [8:0]probe7;
endmodule
