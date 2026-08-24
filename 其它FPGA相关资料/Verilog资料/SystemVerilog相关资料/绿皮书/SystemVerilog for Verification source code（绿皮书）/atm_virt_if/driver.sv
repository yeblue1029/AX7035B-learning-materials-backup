//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// Driver class for ATM example
//-----------------------------------------------------------------------------


class Driver;
    int stream_id;
    mailbox exp_mbx;
    vRx_t Rx;

function new(mailbox exp_mbx,
                     int stream_id,
                     vRx_t Rx);
    this.exp_mbx = exp_mbx;
    this.stream_id = stream_id;
    this.Rx = Rx;
endfunction  //  new


task initialize();
    $display("@%0d: Driver::run[%0d] started", $time, stream_id);
    // Initialize output signals
    Rx.cb.clav <= 0;
    Rx.cb.soc <= 0;
    @Rx.cb;
endtask


task run(int ncells, event driver_done);

    ATM_Cell ac;

    fork begin

      initialize();

      // Drive cells until the last one is sent
      repeat (ncells) begin
        ac = new();
        if (!ac.randomize()) begin
          $display("ATM_Cell::randomize failed");
          $finish;
        end
        if (ac.eot_cell) break;     // End of transmission, no data left
        drive_cell(ac);
      end

      // The driver has now left the building
      $display("@%0d: Driver::run Driver[%0d] is done", $time, stream_id);
      -> driver_done;

    end // fork begin
    join_none
endtask // run


task drive_cell(ATM_Cell ac);
    bit [7:0] bytes[];

    #ac.delay;
    ac.byte_pack(bytes);

    $display("@%0d: Driver::drive_cell(%0d) start vci=%h",
             $time, stream_id, ac.vci);

    // Wait to start on a new cycle
    @Rx.cb;  
    Rx.cb.clav <= 1;            // Assert that cell is ready to transfer
    do
      @Rx.cb;			// Wait a cycle
    while (Rx.cb.en != 0);      // Wait for enable to go low

    Rx.cb.soc <= 1;             // Start of cell
    Rx.cb.data <= bytes[0];     // Drive first byte
    @Rx.cb;  Rx.cb.soc <= 0;    // No longer start of cell
    Rx.cb.data <= bytes[1];     // Drive first byte

    for (int i=2; i<ATM_CELL_SIZE; i++) begin
      @Rx.cb;
      Rx.cb.data <= bytes[i];
    end

    @Rx.cb;
    Rx.cb.soc <= 1'bz;          // SOC goes tristate at end of transfer
    Rx.cb.clav <= 0;            // No cell left to transfer
    Rx.cb.data <= 8'bz;         // Clear data lines
    $display("@%0d: Driver::drive_cell(%0d) finish vci=%h",
             $time, stream_id, ac.vci);

    // Send cell to scoreboard
    exp_mbx.put(ac);

endtask // drive_cell

endclass // Driver
