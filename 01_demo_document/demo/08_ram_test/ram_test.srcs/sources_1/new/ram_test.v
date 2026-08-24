//*************************************************************************\
//Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd,All rights reserved
//
//                   File Name  :  i2c_eeprom_test.v
//                Project Name  :  
//                      Author  : lhj 
//                       Email  :  
//                     Company  :  ALINX(shanghai) Technology Co.,Ltd
//                         WEB  :  http://www.alinx.cn/
//==========================================================================
//   Description:   
//
//   
//==========================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------
//  2018/01/04    lhj         1.0         Original
//*************************************************************************/
module ram_test
(
input            clk,           //system clock 50Mhz on board
input            rst_n          //reset ,low active
);
//-----------------------------------------------------------
reg[8:0]        w_addr;	        //Write RAM address
reg[15:0]       w_data;	        //Write RAM data
reg             wea;	        //RAM porta enable
reg[8:0]        r_addr;         //read RAM address
wire[15:0]      r_data;	         //read RAM data
/*************************************************************************
Generate RAM read address
****************************************************************************/
always @(posedge clk or negedge rst_n)
  if(rst_n==1'b0) 
	   r_addr <= 9'd0;
  else 
      r_addr <= r_addr+1'b1;
/*************************************************************************
Generate RAM write address and data
****************************************************************************/
always@(posedge clk or negedge rst_n)
begin	
  if(rst_n==1'b0) begin
  	  wea <= 1'b0;
     w_addr <= 9'd0;
	  w_data <= 16'd0;
  end
  else begin
     if(w_addr==511) begin    //write ram end
        wea <= 1'b0;                 
     end
     else begin                    
        wea<=1'b1;              //write ram enable
		  w_addr <= w_addr + 1'b1;
		  w_data <= w_data + 1'b1;
	  end
  end 
end 
/*************************************************************************
calling xilinx ram IP
****************************************************************************/ 
ram_ip ram_ip_inst 
(
.clka      (clk          ),     // input clka
.wea       (wea          ),     // input [0 : 0] wea
.addra     (w_addr       ),     // input [8 : 0] addra
.dina      (w_data       ),     // input [15 : 0] dina
.clkb      (clk          ),     // input clkb
.addrb     (r_addr       ),     // input [8 : 0] addrb
.doutb     (r_data       )      // output [15 : 0] doutb
);

/*************************************************************************
Analyze data from user defined ports for the xilinx ila module
****************************************************************************/
ila_0 ila_0_inst 
(
.clk(clk), 
.probe0(r_data), 
.probe1(r_addr) 
);	
endmodule
