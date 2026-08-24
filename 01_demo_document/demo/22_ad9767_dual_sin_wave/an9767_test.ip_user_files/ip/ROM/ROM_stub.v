// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Thu Aug 15 15:58:02 2019
// Host        : PC-201805041311 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               I:/ax7035_2019.1/demo/22_ad9767_dual_sin_wave/ad9767_dual_sin_wave/an9767_test.srcs/sources_1/ip/ROM/ROM_stub.v
// Design      : ROM
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tfgg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_3,Vivado 2019.1" *)
module ROM(clka, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[9:0],douta[13:0]" */;
  input clka;
  input [9:0]addra;
  output [13:0]douta;
endmodule
