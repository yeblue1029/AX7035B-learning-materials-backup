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
module rom_test
(
input            sys_clk,       //system clock 50Mhz on board
input            rst_n          //reset ,low active
);
wire [7:0]      rom_data;
reg[4:0]        rom_addr;      //5 bits rom address
/*************************************************************************
Generate ROM address
****************************************************************************/ 
always @ (posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
         rom_addr <= 10'd0;
     else
         rom_addr <= rom_addr+1'b1;
end
/*************************************************************************
calling xilinx rom IP
****************************************************************************/ 
rom_ip rom_ip_inst
(
.clka   (sys_clk    ),      //inoput clka
.addra  (rom_addr   ),      //input [4:0] addra
.douta  (rom_data   )       //output [7:0] douta
);
/*************************************************************************
Analyze data from user defined ports for the xilinx ila module
****************************************************************************/
ila_0 ila_m0
(
.clk    (sys_clk),
.probe0 (rom_data)
);
endmodule