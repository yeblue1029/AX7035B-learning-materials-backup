//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// Interface for ATM example
//-----------------------------------------------------------------------------

// Testbench clocking block, connects to Rx port
interface Rx_if (input logic clk);
    logic [7:0] data;
    logic soc, en, clav, rclk;

    clocking cb @(posedge clk);
      output data, soc, clav;
      input  en;
    endclocking : cb

    modport DUT (output en, rclk,
                input  data, soc, clav);

    modport TB (clocking cb);
endinterface : Rx_if

typedef virtual Rx_if.TB vRx_t;


// Testbench clocking block, connects to Tx port
interface Tx_if (input logic clk);
    logic [7:0] data;
    logic soc, en, clav, tclk;

    clocking cb @(posedge clk);
      input  data, soc, en;
      output clav;
    endclocking : cb

    modport DUT (output data, soc, en, tclk,
                input  clav);

    modport TB (clocking cb);
endinterface : Tx_if

typedef virtual Tx_if.TB vTx_t;
