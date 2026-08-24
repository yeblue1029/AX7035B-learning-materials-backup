//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// Top level module for ATM example
//-----------------------------------------------------------------------------

`timescale 1ns/1ns
module top;
  logic clk, rst;

   Rx_if Rx[4] (clk);
   Tx_if Tx[4] (clk);

  atm_router a1 (Rx[0], Rx[1], Rx[2], Rx[3], Tx[0], Tx[1], Tx[2], Tx[3], clk, rst);

  test       t1 (Rx, Tx, rst);

  initial begin
    clk = 0;
    forever #20 clk = !clk;
    end

endmodule : top
