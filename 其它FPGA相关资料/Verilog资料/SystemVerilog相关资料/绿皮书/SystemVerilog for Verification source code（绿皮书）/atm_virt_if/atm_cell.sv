//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// ATM cell definition for ATM example
//-----------------------------------------------------------------------------

class ATM_Cell;

    // Physical data
    rand bit [ 3:0] gfc = 0;
    rand bit [ 7:0] vpi = 0;
    rand bit [15:0] vci = 0;
    rand bit [ 2:0] pt  = 0;
    rand bit        clp = 0;
    rand bit [ 7:0] hec = 1;     // ON = good, OFF = bad
    int w_good_hec = 100;     // % of cells with good hec
    rand bit [ 7:0] payload[ATM_PAYLOAD_SIZE];
    
    // Meta-data
    bit corrupted = 0;
    bit eot_cell  = 0;	// True: end of transmission cell, w/o valid data

    rand int delay;
    
    constraint c_hec 
      {
       hec dist {1:=w_good_hec, 0:=(100-w_good_hec)};
       w_good_hec inside {[0:100]};  // range checking
       delay inside {[1:50]};
       }



  task display(string prefix);
    $display("%sgfc vpi7:4       %h%h | %b %b\tvpi=%h",
             prefix, gfc, vpi[7:4], gfc, vpi[7:4], vpi);
    $display("%svpi3:0 vci15:12  %h%h | %b %b\tvci=%h",
             prefix, vpi[3:0], vci[15:12], vpi[3:0], vci[15:12], vci);
    $display("%svci11:4          %h | %b", prefix, vci[11:4], vci[11:4]);
    $display("%svci3:0 clp pt    %h | %b %b %b", prefix, {vci[3:0], clp, pt}, vci[3:0], clp, pt);
    $display("%shec              %h | %s", prefix, hec, hec?"Good":"Bad");
    /*
    foreach (payload, i) {
      if (i>=count) break;
     $display("%spayload[%2d]   %h | %b", prefix, i, payload[i], payload[i]));
    }
    */
endtask // display



function int byte_pack(ref bit [7:0] bytes[]);
    if (bytes.size() == 0)
      bytes = new[ATM_CELL_SIZE];
    else if (bytes.size() != ATM_CELL_SIZE) begin
      $display("byte_pack: bytes.size=%0d, should be %0d", bytes.size(), ATM_CELL_SIZE);
      return 0;
      end

    bytes[0] = {gfc, vpi[7:4]};
    bytes[1] = {vpi[3:0], vci[15:12]};
    bytes[2] = vci[11:4];
    bytes[3] = {vci[3:0], clp, pt};
    bytes[4] = hec;
    for (int i=0; i<ATM_PAYLOAD_SIZE; i++)
      bytes[i+ATM_HEADER_SIZE] = payload[i];
    byte_pack = ATM_CELL_SIZE;
endfunction // byte_pack


function int byte_unpack(ref bit [7:0] bytes[]);
    bit [7:0] b;
  
    if (bytes.size() != ATM_CELL_SIZE) begin
      $display("byte_unpack: bytes.size=%0d, should be %0d", bytes.size(), ATM_CELL_SIZE);
      return 0;
      end

    b          = bytes[0];
    gfc        = b[7:4];
    vpi[7:4]   = b[3:0];
    b          = bytes[1];
    vpi[3:0]   = b[7:4];
    vci[15:12] = b[3:0];
    vci[11:4]  = bytes[2];
    b          = bytes[3];
    vci[3:0]   = b[7:4];
    clp        = b[3];
    pt         = b[2:0];
    hec        = bytes[4];
    for (int i=0; i<ATM_PAYLOAD_SIZE; i++)
      payload[i] = bytes[i+ATM_HEADER_SIZE];

endfunction // byte_unpack

function int compare(ref ATM_Cell ac);
    if (ac.gfc != this.gfc) begin
      $display("gfc mismatch ac=%0h, this=%0h", ac.gfc, this.gfc);
      return 0;
    end

    if (ac.vpi != this.vpi) begin
      $display("vpi mismatch ac=%0h, this=%0h", ac.vpi, this.vpi);
      return 0;
    end

    if (ac.vci != this.vci) begin
      $display("vci mismatch ac=%0h, this=%0h", ac.vci, this.vci);
      return 0;
    end

    if (ac.pt != this.pt) begin
      $display("pt mismatch ac=%0h, this=%0h", ac.pt, this.pt);
      return 0;
    end

    if (ac.clp != this.clp) begin
      $display("clp mismatch ac=%0h, this=%0h", ac.clp, this.clp);
      return 0;
    end

    if (ac.hec != this.hec) begin
      $display("hec mismatch ac=%0h, this=%0h", ac.hec, this.hec);
      return 0;
    end

    for (int i=0; i<ATM_PAYLOAD_SIZE; i++) begin
      if (ac.payload[i] != this.payload[i]) begin
        $display("payload[%0d] mismatch ac=%0h, this=%0h", 
                 i, ac.payload[i], this.payload[i]);
        return 0;
      end
    end

    return 1;

endfunction // compare

endclass : ATM_Cell
