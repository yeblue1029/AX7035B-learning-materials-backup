This is an example of a 4-port ATM switch using a SystemVerilog
testbench with virtual interfaces.  

top.v		Top level Verilog netlist
atm_if.v	Interface definitions
test.v		SV program block
driver.vh	Driver class - sends cells into design
monitor.vh	Monitor class - receives cells from design
scoreboard.vh	Scoreboard class - matches expected with received
atm_router.v	Design under test
atm.vh		Macros / constants
atm_cell.vh	ATM_Cell class

Run the design with:
	> make

The test.v spawns 4 drivers, monitors, and scoreboards.  The driver
randomizes the ATM-cell and sends it into the DUT with virtual ports,
and the scoreboard through a mailbox.  The monitors listen for cells,
and send the cells to the scoreboard.  The scoreboard just compares
the currently received cell to the expected cell.

