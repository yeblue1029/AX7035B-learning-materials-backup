`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module fifo_test
(
input clk,		          //system clock 50Mhz on board
input rst_n	              //reset ,low active
);

//-----------------------------------------------------------
localparam      W_IDLE      = 1;
localparam      W_FIFO     = 2; 
localparam      R_IDLE      = 1;
localparam      R_FIFO     = 2; 

reg[2:0]  write_state;
reg[2:0]  next_write_state;
reg[2:0]  read_state;
reg[2:0]  next_read_state;

reg[15:0] w_data;	   //write fifo data
wire      wr_en;	   //Fifo writing Enables
wire      rd_en;	   //Fifo reading Enables
wire[15:0] r_data;	//Read fifo data
wire       full;  	//fifo full  flag
wire       empty;  	//fifo empty flag
wire[8:0]  rd_data_count;  	
wire[8:0]  wr_data_count;  	

always@(posedge clk or negedge rst_n)
begin 
	if(rst_n == 1'b0)
		write_state <= W_IDLE;
	else
		write_state <= next_write_state;
end
/*************************************************************************
Generating Write Fifo State Machine
****************************************************************************/ 
always@(*)
begin
	case(write_state)
		W_IDLE:
			if(empty == 1'b1)               //FIFO is empty£¬ start writing FIFO
				next_write_state <= W_FIFO;
			else
				next_write_state <= W_IDLE;
		W_FIFO:
			if(full == 1'b1)                //FIFO is full
				next_write_state <= W_IDLE;
			else
				next_write_state <= W_FIFO;
		default:
			next_write_state <= W_IDLE;
	endcase
end

assign wr_en = (next_write_state == W_FIFO) ? 1'b1 : 1'b0; 

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		w_data <= 16'd0;
	else
	   if (wr_en == 1'b1)
		    w_data <= w_data + 1'b1;
		else
          w_data <= 16'd0;		
end



always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		read_state <= R_IDLE;
	else
		read_state <= next_read_state;
end
/*************************************************************************
Generating read fifo State Machine
****************************************************************************/ 
always@(*)
begin
	case(read_state)
		R_IDLE:
			if(full == 1'b1)               //FIFO is full, starting read FIFO
				next_read_state <= R_FIFO;
			else
				next_read_state <= R_IDLE;
		R_FIFO:
			if(empty == 1'b1)              //FIFO is  empty
				next_read_state <= R_IDLE;
			else
				next_read_state <= R_FIFO;
		default:
			next_read_state <= R_IDLE;
	endcase
end

assign rd_en = (next_read_state == R_FIFO) ? 1'b1 : 1'b0; 
/*************************************************************************
call xilinx fifo IP
****************************************************************************/ 
fifo_ip fifo_ip_inst (
.rst            (~rst_n       ),   // input rst
.wr_clk         (clk          ),   // input wr_clk
.rd_clk         (clk          ),   // input rd_clk
.din            (w_data       ),   // input [15 : 0] din
.wr_en          (wr_en        ),   // input wr_en
.rd_en          (rd_en        ),   // input rd_en
.dout           (r_data       ),   // output [15 : 0] dout
.full           (full         ),   // output full
.empty          (empty        ),   // output empty
.rd_data_count  (rd_data_count),   // output [8 : 0] rd_data_count
.wr_data_count  (wr_data_count)    // output [8 : 0] wr_data_count
);
/*************************************************************************
Analyze data from user defined ports for the xilinx ila module
****************************************************************************/
ila_m0 ila_fifo (
.clk(clk), // input wire clk
.probe0(w_data), // input wire [15:0]  probe0  
.probe1(wr_en), // input wire [0:0]  probe1 
.probe2(r_data), // input wire [15:0]  probe2 
.probe3(rd_en), // input wire [0:0]  probe3 
.probe4(full), // input wire [0:0]  probe4 
.probe5(empty), // input wire [0:0]  probe5 
.probe6(rd_data_count), // input wire [8:0]  probe6 
.probe7(wr_data_count) // input wire [8:0]  probe7
); 	
endmodule

