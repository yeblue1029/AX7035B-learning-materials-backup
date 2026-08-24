//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// Monitor class for ATM example
//-----------------------------------------------------------------------------

class Monitor;
    int     stream_id;
    mailbox rcv_mbx;
    vTx_t   Tx;

function new(mailbox rcv_mbx,
             int     stream_id,
             vTx_t   Tx);
    this.rcv_mbx = rcv_mbx;
    this.stream_id = stream_id;
    this.Tx = Tx;
endfunction // new


task run();
    ATM_Cell ac;

    fork begin

      // Initialize output signals
      Tx.cb.clav <= 0;                 // Not ready to receive
      @Tx.cb;
    
      $display("@%0d: Monitor::run[%0d] starting", $time, stream_id);
      forever begin
        receive_cell(ac);
        ac = null;
      end
    end // fork begin
    join_none
  endtask // run


task receive_cell(inout ATM_Cell ac);
    bit [7:0] bytes[];

    bytes = new[ATM_CELL_SIZE];
    ac = new();                // Is this the best way to initialize the cell?

    @Tx.cb;
    
    Tx.cb.clav <= 1;              // Assert ready to receive
    while (Tx.cb.soc !== 1'b1)    // Wait for Start of Cell
      @Tx.cb;

    foreach (bytes[i]) begin
      while (Tx.cb.en != 0)         // Wait if enable goes away
        @Tx.cb;

      bytes[i] = Tx.cb.data;
      @Tx.cb;
      Tx.cb.clav <= 0;               // deassert flow control
    end

    ac.byte_unpack(bytes);
    $display("@%0d: Monitor::run(%0d) received cell vci=%h", 
             $time, stream_id, ac.vci);

    // Send cell to scoreboard
    rcv_mbx.put(ac);
endtask // receive_cell

endclass // class Monitor
