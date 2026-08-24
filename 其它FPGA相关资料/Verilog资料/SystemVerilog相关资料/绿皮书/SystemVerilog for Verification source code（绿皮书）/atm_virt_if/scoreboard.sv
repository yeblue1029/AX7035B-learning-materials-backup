//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// Scoreboard class for ATM example
//-----------------------------------------------------------------------------

class Scoreboard;
    int       stream_id;
    ATM_Cell exp_ac, rcv_ac;
    mailbox exp_mbx, rcv_mbx;
    int rcv_cells, exp_cells, matched, mismatched;
    

function new(int stream_id);
    this.stream_id = stream_id;
    exp_mbx = new();
    rcv_mbx = new();
endfunction // new


// Run forever, get expected cell and receive, and compare
task run();
    fork 
    forever begin
      exp_mbx.get(exp_ac);
      exp_cells++;
      
      rcv_mbx.get(rcv_ac);
      rcv_cells++;
      
      if (exp_ac.compare(rcv_ac)) 
        matched++;
      else
        mismatched++;
      
    end // forever begin
    join_none

endtask // run


// Report on how things went
task report;
    $display("\n@%0d: Scoreboard[%0d] %0d expect cells, %0d received cells",
             $time, stream_id, exp_cells, rcv_cells);
    $display("\t%0d matches, %0d mismatches", matched, mismatched);
endtask // report;

endclass // Scoreboard
