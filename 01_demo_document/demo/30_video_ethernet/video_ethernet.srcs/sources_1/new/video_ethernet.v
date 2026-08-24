//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: lhj                                                                 //
//                                                                              //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2019/08/20     lhj          1.0         Original
//*******************************************************************************/
module video_ethernet
(
input                       sys_clk,            //system clock 50Mhz on board
input                       rst_n,              //reset ,low active
input                       key,                //change camera
inout                       cmos1_scl,          //cmos i2c clock
inout                       cmos1_sda,          //cmos i2c data
input                       cmos1_vsync,        //cmos vsync
input                       cmos1_href,         //cmos hsync refrence,data valid
input                       cmos1_pclk,         //cmos pxiel clock
input   [9:0]               cmos1_db,           //cmos data
output                      cmos1_rst_n,        //cmos reset    
inout                       cmos2_scl,          //cmos i2c clock
inout                       cmos2_sda,          //cmos i2c data
input                       cmos2_vsync,        //cmos vsync
input                       cmos2_href,         //cmos hsync refrence,data valid
input                       cmos2_pclk,         //cmos pxiel clock
input   [9:0]               cmos2_db,           //cmos data
output                      cmos2_rst_n,        //cmos reset
output                      e_reset,            //phy reset
output                      e_mdc,              //phy emdio clock
inout                       e_mdio,             //phy emdio data
output[3:0]                 rgmii_txd,          //phy data send
output                      rgmii_txctl,        //phy data send control
output                      rgmii_txc,          //Clock for sending data
input[3:0]                  rgmii_rxd,          //recieve data
input                       rgmii_rxctl,        //Control signal for receiving data
input                       rgmii_rxc           //Clock for recieving data    
    );
wire[9:0]                   cmos1_lut_index;
wire[31:0]                  cmos1_lut_data;
wire[9:0]                   cmos2_lut_index;
wire[31:0]                  cmos2_lut_data; 
    
wire   [ 7:0]              gmii_txd;
wire                       gmii_tx_en;
wire                       gmii_tx_er;
wire                       gmii_tx_clk;
wire                       gmii_crs;
wire                       gmii_col;
wire   [ 7:0]              gmii_rxd;
wire                       gmii_rx_dv;
wire                       gmii_rx_er;
wire                       gmii_rx_clk;
wire  [ 1:0]               speed_selection; // 1x gigabit, 01 100Mbps, 00 10mbps
wire                       duplex_mode;     // 1 full, 0 half

assign cmos1_rst_n = 1'b1;
assign cmos2_rst_n = 1'b1;
wire                       reg_conf_done_coms1;
wire                       reg_conf_done_coms2;
wire                       reg_conf_done;

wire                        ref_200m ;

//MDIO config
assign speed_selection = 2'b10;
assign duplex_mode = 1'b1;

  clk_wiz_0 clk_wiz_0
   (
    // Clock out ports
    .clk_out1(ref_200m),     // output clk_out1
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1
    
    (* IODELAY_GROUP = "rgmii_rx_delay" *) 
IDELAYCTRL  IDELAYCTRL_inst (
    .RDY(),                      // 1-bit output: Ready output
    .REFCLK(ref_200m),         // 1-bit input: Reference clock input
    .RST(1'b0)                   // 1-bit input: Active high reset input
);
/*************************************************************************
MDIO register configuration
****************************************************************************/
//miim_top miim_top_m0
//(
//.reset_i                        (1'b0                    ),
//.miim_clock_i                   (gmii_tx_clk             ),
//.mdc_o                          (e_mdc                   ),
//.mdio_io                        (e_mdio                  ),
//.link_up_o                      (                        ),             //link status
//.speed_o                        (                        ),             //link speed
//.speed_override_i               (2'b11                   )              //11: autonegoation
//);
/*************************************************************************
GMII and RGMII data conversion
****************************************************************************/
util_gmii_to_rgmii util_gmii_to_rgmii_m0
(
.reset                          (1'b0                   ),
.rgmii_td                       (rgmii_txd              ),
.rgmii_tx_ctl                   (rgmii_txctl            ),
.rgmii_txc                      (rgmii_txc              ),
.rgmii_rd                       (rgmii_rxd              ),
.rgmii_rx_ctl                   (rgmii_rxctl            ),
.gmii_rx_clk                    (gmii_rx_clk            ),
.gmii_txd                       (gmii_txd               ),
.gmii_tx_en                     (gmii_tx_en             ),
.gmii_tx_er                     (1'b0                   ),
.gmii_tx_clk                    (gmii_tx_clk            ),
.gmii_crs                       (gmii_crs               ),
.gmii_col                       (gmii_col               ),
.gmii_rxd                       (gmii_rxd               ),
.rgmii_rxc                      (rgmii_rxc              ),//add
.gmii_rx_dv                     (gmii_rx_dv             ),
.gmii_rx_er                     (gmii_rx_er             ),
.speed_selection                (speed_selection        ),
.duplex_mode                    (duplex_mode            )
);

//I2C master controller
i2c_config i2c_config_m0
(
.rst                        (~rst_n                   ),
.clk                        (sys_clk                  ),
.clk_div_cnt                (16'd500                  ),
.i2c_addr_2byte             (1'b1                     ),
.lut_index                  (cmos1_lut_index          ),
.lut_dev_addr               (cmos1_lut_data[31:24]    ),
.lut_reg_addr               (cmos1_lut_data[23:8]     ),
.lut_reg_data               (cmos1_lut_data[7:0]      ),
.error                      (                         ),
.done                       (                         ),
.i2c_scl                    (cmos1_scl                ),
.i2c_sda                    (cmos1_sda                )
);
//configure look-up table
lut_ov5640_rgb565_800_600 lut_ov5640_rgb565_800_600_m0
(
.lut_index                  (cmos1_lut_index          ),
.lut_data                   (cmos1_lut_data           )
);

//I2C master controller
i2c_config i2c_config_m1
( 
.rst                        (~rst_n                   ),
.clk                        (sys_clk                  ),
.clk_div_cnt                (16'd500                  ),
.i2c_addr_2byte             (1'b1                     ),
.lut_index                  (cmos2_lut_index          ),
.lut_dev_addr               (cmos2_lut_data[31:24]    ),
.lut_reg_addr               (cmos2_lut_data[23:8]     ),
.lut_reg_data               (cmos2_lut_data[7:0]      ),
.error                      (                         ),
.done                       (                         ),
.i2c_scl                    (cmos2_scl                ),
.i2c_sda                    (cmos2_sda                )
);
//configure look-up table
lut_ov5640_rgb565_800_600 lut_ov5640_rgb565_800_600_m1
(
.lut_index                  (cmos2_lut_index           ),
.lut_data                   (cmos2_lut_data            )
);


//CMOS Í¼ÏñÐÅºÅ°´¼üÇÐ»»
wire                        cmos_pclk;
wire                        cmos_vsync;
wire                        cmos_href;
wire [7:0]                  cmos_db;
wire                        cmos1_pclk_g;
wire                        cmos2_pclk_g;
cmos_select	cmos_select_inst
(
.clk                        (sys_clk                   ),
.reset_n                    (rst_n                     ),	
.key1                       (key                       ),

.cmos_pclk                  (cmos_pclk                 ),
.cmos_vsync                 (cmos_vsync                ),        
.cmos_href                  (cmos_href                 ),
.cmos_d                     (cmos_db                   ),	

.cmos1_pclk                 (cmos1_pclk                ),
.cmos1_vsync                (cmos1_vsync               ),        
.cmos1_href                 (cmos1_href                ),
.cmos1_d                    (cmos1_db[9:2]             ),
    
.cmos2_pclk                 (cmos2_pclk                ),
.cmos2_vsync                (cmos2_vsync               ),		
.cmos2_href                 (cmos2_href                ),
.cmos2_d                    (cmos2_db[9:2]             )
);

wire                        cmos_vsync_delay;
wire                        cmos_href_delay;
wire [7:0]                  cmos_data_delay;


camera_delay camera_delay_inst
(
.cmos_pclk                  (cmos_pclk                  ),              //cmos pxiel clock
.cmos_href                  (cmos_href                  ),              //cmos hsync refrence
.cmos_vsync                 (cmos_vsync                 ),              //cmos vsync
.cmos_data                  (cmos_db                    ),              //cmos data

.cmos_href_delay            (cmos_href_delay            ),              //cmos hsync refrence
.cmos_vsync_delay           (cmos_vsync_delay           ),              //cmos vsync
.cmos_data_delay            (cmos_data_delay            )               //cmos data
) ;

wire [10 : 0]               fifo_data_count;
wire [7:0]                  fifo_data;
wire                        fifo_rd_en;

camera_fifo camera_fifo_inst 
(
.rst                        (cmos_vsync                 ),               // input rst
.wr_clk                     (cmos_pclk                  ),               // input wr_clk
.din                        (cmos_data_delay            ),               // input [7 : 0] din
.wr_en                      (cmos_href_delay            ),               // input wr_en

.rd_clk                     (gmii_rx_clk                ),                // input rd_clk
.rd_en                      (fifo_rd_en                 ),                // input rd_en
.dout                       (fifo_data                  ),                // output [7 : 0] dout
.full                       (                           ),                // output full
.empty                      (                           ),                // output empty
.rd_data_count              (fifo_data_count            )                 // output [10 : 0] rd_data_count
);

mac_test mac_test0
(
.gmii_tx_clk                (gmii_tx_clk                ),
.gmii_rx_clk                (gmii_rx_clk                ) ,
.rst_n                      (rst_n                      ),

.cmos_vsync                 (cmos_vsync                 ),
.cmos_href                  (cmos_href                  ),
.reg_conf_done              (reg_conf_done              ),
.fifo_data                  (fifo_data                  ),         
.fifo_data_count            (fifo_data_count            ),     
.fifo_rd_en                 (fifo_rd_en                 ),          


.udp_send_data_length       (16'd1024                   ), 
.gmii_rx_dv                 (gmii_rx_dv                 ),
.gmii_rxd                   (gmii_rxd                   ),
.gmii_tx_en                 (gmii_tx_en                 ),
.gmii_txd                   (gmii_txd                   )
);	
endmodule
