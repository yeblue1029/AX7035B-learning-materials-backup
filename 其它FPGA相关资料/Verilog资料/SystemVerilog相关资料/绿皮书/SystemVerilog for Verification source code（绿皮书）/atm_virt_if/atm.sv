//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from Synopsys Inc. In the event of publication,
// the following notice is applicable:
//
// (C) COPYRIGHT 2006 Chris Spear and Synopsys Inc.  All rights reserved
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------------
// Defintions for ATM example
//-----------------------------------------------------------------------------

`ifndef INC_ATM_VRI
`define INC_ATM_VRI

parameter ATM_HEADER_SIZE = 5,
  ATM_PAYLOAD_SIZE = 48,
  ATM_CELL_SIZE = (ATM_HEADER_SIZE + ATM_PAYLOAD_SIZE);

parameter NPORTS = 4;

parameter TIMEOUT_CYCLES = 10_000,
          NS_PER_CYCLE = 100,
          TIMEOUT_DELAY = (TIMEOUT_CYCLES * NS_PER_CYCLE);

`endif // INC_ATM_VRI
