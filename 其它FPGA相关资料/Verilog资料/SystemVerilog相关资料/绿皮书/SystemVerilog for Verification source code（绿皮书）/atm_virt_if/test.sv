//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// Testbench for ATM example
//-----------------------------------------------------------------------------

program automatic test(Rx_if.TB Rx[4],
		       Tx_if.TB Tx[4],
                       output logic rst);

   Driver drv[4];
   Monitor mon[4];
   Scoreboard scb[4];
   event driver_done;

   initial begin
      vRx_t vRx[4] = Rx;
      vTx_t vTx[4] = Tx;
      for (int i=0; i<4; i++) begin
         scb[i] = new(i);
         drv[i] = new(scb[i].exp_mbx, i, vRx[i]);
         mon[i] = new(scb[i].rcv_mbx, i, vTx[i]);
      end

      rst <= 1;
      repeat (10) @Rx[0].cb;
      rst <= 0;
      for (int i=0; i<4; i++) begin
        drv[i].run(5, driver_done);
        mon[i].run();
        scb[i].run();
      end

      // Wait for driver to finish
      @driver_done;

      // Wait for monitor and scoreboard to finish
      #1000;
      
      // Generate scoreboard report
      for (int i=0; i<4; i++)
        scb[i].report();
      
    end

endprogram : test
