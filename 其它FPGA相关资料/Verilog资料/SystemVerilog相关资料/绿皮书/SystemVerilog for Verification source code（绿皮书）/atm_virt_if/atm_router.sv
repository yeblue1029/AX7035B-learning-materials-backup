//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// DUT for ATM example
//-----------------------------------------------------------------------------
// Very simple router - outputs get inputs

`timescale 1ns/1ns 

module atm_router(Rx_if.DUT Rx0, Rx1, Rx2, Rx3, 
                  Tx_if.DUT Tx0, Tx1, Tx2, Tx3,
	          input logic clk, rst);

  assign Rx0.rclk = clk;
  assign Rx1.rclk = clk;
  assign Rx2.rclk = clk;
  assign Rx3.rclk = clk;

  assign Rx0.en = 1'b0;
  assign Rx1.en = 1'b0;
  assign Rx2.en = 1'b0;
  assign Rx3.en = 1'b0; 

  assign Tx0.tclk = clk; 
  assign Tx1.tclk = clk;
  assign Tx2.tclk = clk;
  assign Tx3.tclk = clk;

  assign Tx0.data = Rx0.data;
  assign Tx1.data = Rx1.data;
  assign Tx2.data = Rx2.data;
  assign Tx3.data = Rx3.data;

  assign Tx0.soc = Rx0.soc;
  assign Tx1.soc = Rx1.soc;
  assign Tx2.soc = Rx2.soc;
  assign Tx3.soc = Rx3.soc;

  assign Tx0.en = 1'b0;
  assign Tx1.en = 1'b0;
  assign Tx2.en = 1'b0;
  assign Tx3.en = 1'b0; 

endmodule
