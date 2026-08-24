//////////////////////////////////////////////////////////////////////////////////
//  hdmi_input_loopback_ddr                                                     //
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
//  2018/01/11    lhj         1.0         Original
//*******************************************************************************/

`timescale 1ps/1ps

module top
(
    //system clocks
    input                              sys_clk,
    inout                              hdmi_ddc_scl_io,//HDMIIN
    inout                              hdmi_ddc_sda_io,
    output                             hdmi_hdmi_in_hpd,
    output[0:0]                        HDMI_hdmi_in_OEN,
    input                              TMDS_clk_hdmi_in_n,
    input                              TMDS_clk_hdmi_in_p,
    input[2:0]                         TMDS_data_hdmi_in_n,
    input[2:0]                         TMDS_data_hdmi_in_p,
    
    output [0:0]                       HDMI_hdmi_out_OEN,//HDMIOUT       
    output                             TMDS_clk_hdmi_out_n,
    output                             TMDS_clk_hdmi_out_p,
    output [2:0]                       TMDS_data_hdmi_out_n,
    output [2:0]                       TMDS_data_hdmi_out_p,
    

	inout [15:0]                       ddr3_dq,
	inout [1:0]                        ddr3_dqs_n,
	inout [1:0]                        ddr3_dqs_p,
	output [13:0]                      ddr3_addr,
	output [2:0]                       ddr3_ba,
	output                             ddr3_ras_n,
	output                             ddr3_cas_n,
	output                             ddr3_we_n,
	output                             ddr3_reset_n,
	output [0:0]                       ddr3_ck_p,
	output [0:0]                       ddr3_ck_n,
	output [0:0]                       ddr3_cke,
	output [0:0]                       ddr3_cs_n,
	output [1:0]                       ddr3_dm,
	output [0:0]                       ddr3_odt
   );

wire hdmi_ddc_scl_i;
wire hdmi_ddc_scl_o;
wire hdmi_ddc_scl_t;
wire hdmi_ddc_sda_i;
wire hdmi_ddc_sda_o;
wire hdmi_ddc_sda_t;
wire[23:0] vid_pData;
wire vid_pVDE;
wire vid_pHSync;
wire vid_pVSync;

reg[23:0] vid_pData_d0;
reg vid_pVDE_d0;
reg vid_pHSync_d0;
reg vid_pVSync_d0;


reg[23:0] vid_pData_d1;
reg vid_pVDE_d1;
reg vid_pHSync_d1;
reg vid_pVSync_d1;


wire PixelClk;
wire peripheral_aresetn;
wire SerialClk;
reg hdmi_hpd_r;
wire vid_io_in_reset;
wire aPixelClkLckd;
wire clk_200MHz;
wire rst_n;
assign HDMI_hdmi_in_OEN = 1'b0;
assign hdmi_hdmi_in_hpd = hdmi_hpd_r;

always@(posedge clk_200MHz or negedge rst_n)
begin
    if( rst_n == 1'b0)
        hdmi_hpd_r <= 1'b0;
    else
        hdmi_hpd_r <= 1'b1;
end
IOBUF hdmi_ddc_scl_iobuf
(
	.I(hdmi_ddc_scl_o),
	.IO(hdmi_ddc_scl_io),
	.O(hdmi_ddc_scl_i),
	.T(hdmi_ddc_scl_t)
);
IOBUF hdmi_ddc_sda_iobuf
(
	.I(hdmi_ddc_sda_o),
	.IO(hdmi_ddc_sda_io),
	.O(hdmi_ddc_sda_i),
	.T(hdmi_ddc_sda_t)
); 
dvi2rgb
#(
	.kEmulateDDC(1'b1),
	.kRstActiveHigh(1'b0),
	.kAddBUFG(1'b1),
	.kClkRange(1),
	.kEdidFileName("720p_edid.txt"),
	.kIDLY_TapValuePs(78),
	.kIDLY_TapWidth(5)
)
dvi2rgb_m0(
	.TMDS_Clk_p(TMDS_clk_hdmi_in_p),
	.TMDS_Clk_n(TMDS_clk_hdmi_in_n),
	.TMDS_Data_p(TMDS_data_hdmi_in_p),
	.TMDS_Data_n(TMDS_data_hdmi_in_n),
	
	.RefClk(clk_200MHz),
	.aRst(1'b0),
	.aRst_n(rst_n),
	
	.vid_pData(vid_pData),
	.vid_pVDE(vid_pVDE), 
	.vid_pHSync(vid_pHSync), 
	.vid_pVSync(vid_pVSync), 
	.PixelClk(PixelClk),
	
	.SerialClk(SerialClk),
	.aPixelClkLckd(aPixelClkLckd),
	
	.DDC_SDA_I(hdmi_ddc_sda_i),
	.DDC_SDA_O(hdmi_ddc_sda_o), 
	.DDC_SDA_T(hdmi_ddc_sda_t), 
	.DDC_SCL_I(hdmi_ddc_scl_i),
	.DDC_SCL_O(hdmi_ddc_scl_o),  
	.DDC_SCL_T(hdmi_ddc_scl_t), 
	
	.pRst(1'b0),
	.pRst_n(rst_n)
  );

always@(posedge PixelClk)
 begin
    vid_pData_d0 <= vid_pData;
    vid_pVDE_d0 <= vid_pVDE;
    vid_pHSync_d0 <= vid_pHSync;
    vid_pVSync_d0 <= vid_pVSync;
 end 
assign HDMI_hdmi_out_OEN = 1'b1;
        

 
localparam nCK_PER_CLK                 = 4;
localparam ADDR_WIDTH                  = 23;
localparam PAYLOAD_WIDTH               = 16;
localparam APP_DATA_WIDTH              = 64;
localparam APP_MASK_WIDTH              = APP_DATA_WIDTH / 8;
wire M_AXI_ACLK;
// Master Write Address
wire [0:0]  s00_axi_awid;
wire [31:0] s00_axi_awaddr;
wire [7:0]  s00_axi_awlen;    // burst length: 0-255
wire [2:0]  s00_axi_awsize;   // burst size: fixed 2'b011
wire [1:0]  s00_axi_awburst;  // burst type: fixed 2'b01(incremental burst)
wire        s00_axi_awlock;   // lock: fixed 2'b00
wire [3:0]  s00_axi_awcache;  // cache: fiex 2'b0011
wire [2:0]  s00_axi_awprot;   // protect: fixed 2'b000
wire [3:0]  s00_axi_awqos;    // qos: fixed 2'b0000
wire [0:0]  s00_axi_awuser;   // user: fixed 32'd0
wire        s00_axi_awvalid;
wire        s00_axi_awready;

// master write data
wire [63:0] s00_axi_wdata;
wire [7:0]  s00_axi_wstrb;
wire        s00_axi_wlast;
wire [0:0]  s00_axi_wuser;
wire        s00_axi_wvalid;
wire        s00_axi_wready;
// master write response
wire [0:0]   s00_axi_bid;
wire [1:0]   s00_axi_bresp;
wire [0:0]   s00_axi_buser;
wire         s00_axi_bvalid;
wire         s00_axi_bready;

// master read address
wire [0:0]  s00_axi_arid;
wire [31:0] s00_axi_araddr;
wire [7:0]  s00_axi_arlen;
wire [2:0]  s00_axi_arsize;
wire [1:0]  s00_axi_arburst;
wire [1:0]  s00_axi_arlock;
wire [3:0]  s00_axi_arcache;
wire [2:0]  s00_axi_arprot;
wire [3:0]  s00_axi_arqos;
wire [0:0]  s00_axi_aruser;
wire        s00_axi_arvalid;
wire        s00_axi_arready;

// master read data
wire [0:0]   s00_axi_rid;
wire [63:0]  s00_axi_rdata;
wire [1:0]   s00_axi_rresp;
wire         s00_axi_rlast;
wire [0:0]   s00_axi_ruser;
wire         s00_axi_rvalid;
wire         s00_axi_rready;


wire [3 : 0] m_axi_awid                   ;
wire [31 : 0] m_axi_awaddr                ;
wire [7 : 0] m_axi_awlen                  ;
wire [2 : 0] m_axi_awsize                 ;
wire [1 : 0] m_axi_awburst                ;
wire m_axi_awlock                         ;
wire [3 : 0] m_axi_awcache                ;
wire [2 : 0] m_axi_awprot                 ;
wire [3 : 0] m_axi_awqos                  ;
wire m_axi_awvalid                        ;
wire m_axi_awready                        ;
wire [255 : 0] m_axi_wdata                ;
wire [31 : 0] m_axi_wstrb                 ;
wire m_axi_wlast                          ;
wire m_axi_wvalid                         ;
wire m_axi_wready                         ;
wire [3 : 0] m_axi_bid                    ;
wire [1 : 0] m_axi_bresp                  ;
wire m_axi_bvalid                         ;
wire m_axi_bready                         ;
wire [3 : 0] m_axi_arid                   ;
wire [31 : 0] m_axi_araddr                ;
wire [7 : 0] m_axi_arlen                  ;
wire [2 : 0] m_axi_arsize                 ;
wire [1 : 0] m_axi_arburst                ;
wire m_axi_arlock                         ;
wire [3 : 0] m_axi_arcache                ;
wire [2 : 0] m_axi_arprot                 ;
wire [3 : 0] m_axi_arqos                  ;
wire m_axi_arvalid                        ;
wire m_axi_arready                        ;
wire [3 : 0] m_axi_rid                    ;
wire [255 : 0] m_axi_rdata                ;
wire [1 : 0] m_axi_rresp                  ;
wire m_axi_rlast                          ;
wire m_axi_rvalid                         ;
wire m_axi_rready                         ;

wire                                   ui_clk;
wire                                   ui_clk_sync_rst;
wire                                   init_calib_complete;
wire                                   done;
wire                                   error;
wire                                   heartbeat;

wire                                   wr_burst_data_req;
wire                                   wr_burst_finish;
wire                                   rd_burst_finish;
wire                                   rd_burst_req;
wire                                   wr_burst_req;
wire[9:0]                              rd_burst_len;
wire[9:0]                              wr_burst_len;
wire[ADDR_WIDTH - 1:0]                 rd_burst_addr;
wire[ADDR_WIDTH - 1:0]                 wr_burst_addr;
wire                                   rd_burst_data_valid;
wire[APP_DATA_WIDTH - 1 : 0]           rd_burst_data;
wire[APP_DATA_WIDTH - 1 : 0]           wr_burst_data;

wire                                   read_req;
wire                                   read_req_ack;
wire                                   read_en;
wire[31:0]                             read_data;
wire                                   write_en;
wire[31:0]                             write_data;
wire                                   write_req;
wire                                   write_req_ack;
wire                                   ext_mem_clk;       //external memory clock
wire                                   video_clk;         //video pixel clock
reg                                    vin_de_d0;
reg[23:0]                              vin_data_d0;

wire[1:0]                              write_addr_index;
wire[1:0]                              read_addr_index;
wire[9:0]                              lut_index;
wire[31:0]                             lut_data;
wire                                   locked;
wire                                   s00_axi_aclk;
wire                                   video_clk5x;

assign ext_mem_clk = s00_axi_aclk;
//assign s00_axi_aclk = video_clk;
assign s00_axi_aclk = ui_clk ;

assign write_en = vid_pVDE_d0;
assign write_data = vid_pData_d0;
assign rst_n = locked;

wire                            hs;
wire                            vs;
wire                            de;
wire                            hdmi_hs;
wire                            hdmi_vs;
wire                            hdmi_de;
wire[7:0]                       hdmi_r;
wire[7:0]                       hdmi_g;
wire[7:0]                       hdmi_b;
wire[31:0]                      vout_data;
assign  hdmi_hs    = hs;
assign  hdmi_vs    = vs;
assign  hdmi_de    = de;
assign hdmi_r      = vout_data[23:16];
assign hdmi_b      = vout_data[15:8];
assign hdmi_g      = vout_data[7:0];


  rgb2dvi
    #(
     .kGenerateSerialClk(1'b0),
     .kClkRange(1),     
     .kRstActiveHigh(1'b1)
   )
   rgb2dvi_m0 (
     // DVI 1.0 TMDS video interface
     .TMDS_Clk_p(TMDS_clk_hdmi_out_p),
     .TMDS_Clk_n(TMDS_clk_hdmi_out_n),
     .TMDS_Data_p(TMDS_data_hdmi_out_p),
     .TMDS_Data_n(TMDS_data_hdmi_out_n),
          
     //Auxiliary signals 
     .aRst(1'b0), //asynchronous reset; must be reset when RefClk is not within spec
     .aRst_n(1'b1), //-asynchronous reset; must be reset when RefClk is not within spec
      
     // Video in
     .vid_pData({hdmi_r,hdmi_b,hdmi_g}),
     .vid_pVDE(de),
     .vid_pHSync(hs),
     .vid_pVSync(vs),
     .PixelClk(video_clk),
    
     .SerialClk(video_clk5x)// 5x PixelClk
    );
    /*rgb2dvi
     #(
      .kGenerateSerialClk(1'b1),
      .kClkRange(1),     
      .kRstActiveHigh(1'b1)
    )
    rgb2dvi_m0 (
      // DVI 1.0 TMDS video interface
      .TMDS_Clk_p(TMDS_clk_hdmi_out_p),
      .TMDS_Clk_n(TMDS_clk_hdmi_out_n),
      .TMDS_Data_p(TMDS_data_hdmi_out_p),
      .TMDS_Data_n(TMDS_data_hdmi_out_n),
           
      //Auxiliary signals 
      .aRst(1'b0), //asynchronous reset; must be reset when RefClk is not within spec
      .aRst_n(1'b1), //-asynchronous reset; must be reset when RefClk is not within spec
       
      // Video in
      .vid_pData({hdmi_r,hdmi_b,hdmi_g}),
      .vid_pVDE(de),
      .vid_pHSync(hs),
      .vid_pVSync(vs),
      .PixelClk(PixelClk),
     
      .SerialClk(SerialClk)// 5x PixelClk
     );*/
/*dvi_encoder dvi_encoder_m0
 (
     .pixelclk      (video_clk          ),// system clock
     .pixelclk5x    (video_clk5x        ),// system clock x5
     .rstin         (~rst_n             ),// reset
     .blue_din      (hdmi_b            ),// Blue data in
     .green_din     (hdmi_g            ),// Green data in
     .red_din       (hdmi_r            ),// Red data in
     .hsync         (hdmi_hs           ),// hsync data
     .vsync         (hdmi_vs           ),// vsync data
     .de            (hdmi_de            ),// data enable
     .tmds_clk_p    (TMDS_clk_hdmi_out_p),
     .tmds_clk_n    (TMDS_clk_hdmi_out_n),
     .tmds_data_p   (TMDS_data_hdmi_out_p),//rgb
     .tmds_data_n   (TMDS_data_hdmi_out_n) //rgb
 );*/
  sys_pll sys_pll_m0
(
    .clk_in1                (sys_clk    ),
    .clk_out1               (clk_200MHz ),
    .clk_out2               (video_clk  ),
    .clk_out3               (video_clk5x),
  // .clk_out2              (           ),
 //  .clk_out3               (           ),
     .reset                  (1'b0       ),
     .locked                 (locked     )
);
//IBUFG clk_piex
//(
//.I(PixelClk),
//.O(video_clk)
//);
//IBUFG clk_serclk
//(
//.I(SerialClk),
//.O(video_clk5x)
//);
//assign video_clk=PixelClk;
//assign video_clk5x=SerialClk;
ddr3 u_ddr3 (
	// Memory interface ports
	.ddr3_addr                      (ddr3_addr), 
	.ddr3_ba                        (ddr3_ba), 
	.ddr3_cas_n                     (ddr3_cas_n), 
	.ddr3_ck_n                      (ddr3_ck_n), 
	.ddr3_ck_p                      (ddr3_ck_p),
	.ddr3_cke                       (ddr3_cke),  
	.ddr3_ras_n                     (ddr3_ras_n), 
	.ddr3_reset_n                   (ddr3_reset_n), 
	.ddr3_we_n                      (ddr3_we_n),  
	.ddr3_dq                        (ddr3_dq),  
	.ddr3_dqs_n                     (ddr3_dqs_n),  
	.ddr3_dqs_p                     (ddr3_dqs_p),  
	.init_calib_complete            (init_calib_complete),  
	 
	.ddr3_cs_n                      (ddr3_cs_n),  
	.ddr3_dm                        (ddr3_dm),  
	.ddr3_odt                       (ddr3_odt),  
	// Application interface ports
	.ui_clk                         (ui_clk), 
	.ui_clk_sync_rst                (ui_clk_sync_rst),  // output			ui_clk_sync_rst
	.mmcm_locked                    (),  // output			mmcm_locked
	.aresetn                        (1'b1),  // input			aresetn
	.app_sr_req                     (1'b0),  // input			app_sr_req
	.app_ref_req                    (1'b0),  // input			app_ref_req
	.app_zq_req                     (1'b0),  // input			app_zq_req
	.app_sr_active                  (),  // output			app_sr_active
	.app_ref_ack                    (),  // output			app_ref_ack
	.app_zq_ack                     (),  // output			app_zq_ack
	// Slave Interface Write Address Ports
	.s_axi_awid                     (m_axi_awid),  // input [0:0]			s_axi_awid
	.s_axi_awaddr                   (m_axi_awaddr),  // input [29:0]			s_axi_awaddr
	.s_axi_awlen                    (m_axi_awlen),  // input [7:0]			s_axi_awlen
	.s_axi_awsize                   (m_axi_awsize),  // input [2:0]			s_axi_awsize
	.s_axi_awburst                  (m_axi_awburst),  // input [1:0]			s_axi_awburst
	.s_axi_awlock                   (m_axi_awlock),  // input [0:0]			s_axi_awlock
	.s_axi_awcache                  (m_axi_awcache),  // input [3:0]			s_axi_awcache
	.s_axi_awprot                   (m_axi_awprot),  // input [2:0]			s_axi_awprot
	.s_axi_awqos                    (m_axi_awqos),  // input [3:0]			s_axi_awqos
	.s_axi_awvalid                  (m_axi_awvalid),  // input			s_axi_awvalid
	.s_axi_awready                  (m_axi_awready),  // output			s_axi_awready
	// Slave Interface Write Data Ports
	.s_axi_wdata                    (m_axi_wdata),  // input [63:0]			s_axi_wdata
	.s_axi_wstrb                    (m_axi_wstrb),  // input [7:0]			s_axi_wstrb
	.s_axi_wlast                    (m_axi_wlast),  // input			s_axi_wlast
	.s_axi_wvalid                   (m_axi_wvalid),  // input			s_axi_wvalid
	.s_axi_wready                   (m_axi_wready),  // output			s_axi_wready
	// Slave Interface Write Response Ports
	.s_axi_bid                      (m_axi_bid),  // output [0:0]			s_axi_bid
	.s_axi_bresp                    (m_axi_bresp),  // output [1:0]			s_axi_bresp
	.s_axi_bvalid                   (m_axi_bvalid),  // output			s_axi_bvalid
	.s_axi_bready                   (m_axi_bready),  // input			s_axi_bready
	// Slave Interface Read Address Ports
	.s_axi_arid                     (m_axi_arid),  // input [0:0]			s_axi_arid
	.s_axi_araddr                   (m_axi_araddr),  // input [29:0]			s_axi_araddr
	.s_axi_arlen                    (m_axi_arlen),  // input [7:0]			s_axi_arlen
	.s_axi_arsize                   (m_axi_arsize),  // input [2:0]			s_axi_arsize
	.s_axi_arburst                  (m_axi_arburst),  // input [1:0]			s_axi_arburst
	.s_axi_arlock                   (m_axi_arlock),  // input [0:0]			s_axi_arlock
	.s_axi_arcache                  (m_axi_arcache),  // input [3:0]			s_axi_arcache
	.s_axi_arprot                   (m_axi_arprot),  // input [2:0]			s_axi_arprot
	.s_axi_arqos                    (m_axi_arqos),  // input [3:0]			s_axi_arqos
	.s_axi_arvalid                  (m_axi_arvalid),  // input			s_axi_arvalid
	.s_axi_arready                  (m_axi_arready),  // output			s_axi_arready
	// Slave Interface Read Data Ports
	.s_axi_rid                      (m_axi_rid),  // output [0:0]			s_axi_rid
	.s_axi_rdata                    (m_axi_rdata),  // output [63:0]			s_axi_rdata
	.s_axi_rresp                    (m_axi_rresp),  // output [1:0]			s_axi_rresp
	.s_axi_rlast                    (m_axi_rlast),  // output			s_axi_rlast
	.s_axi_rvalid                   (m_axi_rvalid),  // output			s_axi_rvalid
	.s_axi_rready                   (m_axi_rready),  // input			s_axi_rready
	// System Clock Ports
	.sys_clk_i                      (clk_200MHz),
	//.sys_rst                        (sys_rst) // input sys_rst
	.sys_rst                        (rst_n) // input sys_rst
);

axi_interconnect axi_interconnect_m0 
(
	.INTERCONNECT_ACLK               (s00_axi_aclk                         ),
	.INTERCONNECT_ARESETN            (~ui_clk_sync_rst                     ),
	.S00_AXI_ARESET_OUT_N            (                                     ),
	.S00_AXI_ACLK                    (s00_axi_aclk                         ),
	.S00_AXI_AWID                    (s00_axi_awid                         ),
	.S00_AXI_AWADDR                  (s00_axi_awaddr                       ),
	.S00_AXI_AWLEN                   (s00_axi_awlen                        ),
	.S00_AXI_AWSIZE                  (s00_axi_awsize                       ),
	.S00_AXI_AWBURST                 (s00_axi_awburst                      ),
	.S00_AXI_AWLOCK                  (s00_axi_awlock                       ),
	.S00_AXI_AWCACHE                 (s00_axi_awcache                      ),
	.S00_AXI_AWPROT                  (s00_axi_awprot                       ),
	.S00_AXI_AWQOS                   (s00_axi_awqos                        ),
	.S00_AXI_AWVALID                 (s00_axi_awvalid                      ),
	.S00_AXI_AWREADY                 (s00_axi_awready                      ),
	.S00_AXI_WDATA                   (s00_axi_wdata                        ),
	.S00_AXI_WSTRB                   (s00_axi_wstrb                        ),
	.S00_AXI_WLAST                   (s00_axi_wlast                        ),
	.S00_AXI_WVALID                  (s00_axi_wvalid                       ),
	.S00_AXI_WREADY                  (s00_axi_wready                       ),
	.S00_AXI_BID                     (s00_axi_bid                          ),
	.S00_AXI_BRESP                   (s00_axi_bresp                        ),
	.S00_AXI_BVALID                  (s00_axi_bvalid                       ),
	.S00_AXI_BREADY                  (s00_axi_bready                       ),
	.S00_AXI_ARID                    (s00_axi_arid                         ),
	.S00_AXI_ARADDR                  (s00_axi_araddr                       ),
	.S00_AXI_ARLEN                   (s00_axi_arlen                        ),
	.S00_AXI_ARSIZE                  (s00_axi_arsize                       ),
	.S00_AXI_ARBURST                 (s00_axi_arburst                      ),
	.S00_AXI_ARLOCK                  (s00_axi_arlock                       ),
	.S00_AXI_ARCACHE                 (s00_axi_arcache                      ),
	.S00_AXI_ARPROT                  (s00_axi_arprot                       ),
	.S00_AXI_ARQOS                   (s00_axi_arqos                        ),
	.S00_AXI_ARVALID                 (s00_axi_arvalid                      ),
	.S00_AXI_ARREADY                 (s00_axi_arready                      ),
	.S00_AXI_RID                     (s00_axi_rid                          ),
	.S00_AXI_RDATA                   (s00_axi_rdata                        ),
	.S00_AXI_RRESP                   (s00_axi_rresp                        ),
	.S00_AXI_RLAST                   (s00_axi_rlast                        ),
	.S00_AXI_RVALID                  (s00_axi_rvalid                       ),
	.S00_AXI_RREADY                  (s00_axi_rready                       ),
	
	.M00_AXI_ARESET_OUT_N            (                                     ),
	.M00_AXI_ACLK                    (ui_clk                               ),
	.M00_AXI_AWID                    (m_axi_awid                           ),
	.M00_AXI_AWADDR                  (m_axi_awaddr                         ),
	.M00_AXI_AWLEN                   (m_axi_awlen                          ),
	.M00_AXI_AWSIZE                  (m_axi_awsize                         ),
	.M00_AXI_AWBURST                 (m_axi_awburst                        ),
	.M00_AXI_AWLOCK                  (m_axi_awlock                         ),
	.M00_AXI_AWCACHE                 (m_axi_awcache                        ),
	.M00_AXI_AWPROT                  (m_axi_awprot                         ),
	.M00_AXI_AWQOS                   (m_axi_awqos                          ),
	.M00_AXI_AWVALID                 (m_axi_awvalid                        ),
	.M00_AXI_AWREADY                 (m_axi_awready                        ),
	.M00_AXI_WDATA                   (m_axi_wdata                          ),
	.M00_AXI_WSTRB                   (m_axi_wstrb                          ),
	.M00_AXI_WLAST                   (m_axi_wlast                          ),
	.M00_AXI_WVALID                  (m_axi_wvalid                         ),
	.M00_AXI_WREADY                  (m_axi_wready                         ),
	.M00_AXI_BID                     (m_axi_bid                            ),
	.M00_AXI_BRESP                   (m_axi_bresp                          ),
	.M00_AXI_BVALID                  (m_axi_bvalid                         ),
	.M00_AXI_BREADY                  (m_axi_bready                         ),
	.M00_AXI_ARID                    (m_axi_arid                           ),
	.M00_AXI_ARADDR                  (m_axi_araddr                         ),
	.M00_AXI_ARLEN                   (m_axi_arlen                          ),
	.M00_AXI_ARSIZE                  (m_axi_arsize                         ),
	.M00_AXI_ARBURST                 (m_axi_arburst                        ),
	.M00_AXI_ARLOCK                  (m_axi_arlock                         ),
	.M00_AXI_ARCACHE                 (m_axi_arcache                        ),
	.M00_AXI_ARPROT                  (m_axi_arprot                         ),
	.M00_AXI_ARQOS                   (m_axi_arqos                          ),
	.M00_AXI_ARVALID                 (m_axi_arvalid                        ),
	.M00_AXI_ARREADY                 (m_axi_arready                        ),
	.M00_AXI_RID                     (m_axi_rid                            ),
	.M00_AXI_RDATA                   (m_axi_rdata                          ),
	.M00_AXI_RRESP                   (m_axi_rresp                          ),
	.M00_AXI_RLAST                   (m_axi_rlast                          ),
	.M00_AXI_RVALID                  (m_axi_rvalid                         ),
	.M00_AXI_RREADY                  (m_axi_rready                         )
);

aq_axi_master u_aq_axi_master
	(
	  .ARESETN                     (~ui_clk_sync_rst                          ),
	  .ACLK                        (s00_axi_aclk                              ),
	  .M_AXI_AWID                  (s00_axi_awid                              ),
	  .M_AXI_AWADDR                (s00_axi_awaddr                            ),
	  .M_AXI_AWLEN                 (s00_axi_awlen                             ),
	  .M_AXI_AWSIZE                (s00_axi_awsize                            ),
	  .M_AXI_AWBURST               (s00_axi_awburst                           ),
	  .M_AXI_AWLOCK                (s00_axi_awlock                            ),
	  .M_AXI_AWCACHE               (s00_axi_awcache                           ),
	  .M_AXI_AWPROT                (s00_axi_awprot                            ),
	  .M_AXI_AWQOS                 (s00_axi_awqos                             ),
	  .M_AXI_AWUSER                (s00_axi_awuser                            ),
	  .M_AXI_AWVALID               (s00_axi_awvalid                           ),
	  .M_AXI_AWREADY               (s00_axi_awready                           ),
	  .M_AXI_WDATA                 (s00_axi_wdata                             ),
	  .M_AXI_WSTRB                 (s00_axi_wstrb                             ),
	  .M_AXI_WLAST                 (s00_axi_wlast                             ),
	  .M_AXI_WUSER                 (s00_axi_wuser                             ),
	  .M_AXI_WVALID                (s00_axi_wvalid                            ),
	  .M_AXI_WREADY                (s00_axi_wready                            ),
	  .M_AXI_BID                   (s00_axi_bid                               ),
	  .M_AXI_BRESP                 (s00_axi_bresp                             ),
	  .M_AXI_BUSER                 (s00_axi_buser                             ),
	  .M_AXI_BVALID                (s00_axi_bvalid                            ),
	  .M_AXI_BREADY                (s00_axi_bready                            ),
	  .M_AXI_ARID                  (s00_axi_arid                              ),
	  .M_AXI_ARADDR                (s00_axi_araddr                            ),
	  .M_AXI_ARLEN                 (s00_axi_arlen                             ),
	  .M_AXI_ARSIZE                (s00_axi_arsize                            ),
	  .M_AXI_ARBURST               (s00_axi_arburst                           ),
	  .M_AXI_ARLOCK                (s00_axi_arlock                            ),
	  .M_AXI_ARCACHE               (s00_axi_arcache                           ),
	  .M_AXI_ARPROT                (s00_axi_arprot                            ),
	  .M_AXI_ARQOS                 (s00_axi_arqos                             ),
	  .M_AXI_ARUSER                (s00_axi_aruser                            ),
	  .M_AXI_ARVALID               (s00_axi_arvalid                           ),
	  .M_AXI_ARREADY               (s00_axi_arready                           ),
	  .M_AXI_RID                   (s00_axi_rid                               ),
	  .M_AXI_RDATA                 (s00_axi_rdata                             ),
	  .M_AXI_RRESP                 (s00_axi_rresp                             ),
	  .M_AXI_RLAST                 (s00_axi_rlast                             ),
	  .M_AXI_RUSER                 (s00_axi_ruser                             ),
	  .M_AXI_RVALID                (s00_axi_rvalid                            ),
	  .M_AXI_RREADY                (s00_axi_rready                            ),
	  .MASTER_RST                  (1'b0                                      ),
	  .WR_START                    (wr_burst_req                              ),
	  .WR_ADRS                     ({wr_burst_addr,3'd0}                      ),
	  .WR_LEN                      ({wr_burst_len,3'd0}                       ),
	  .WR_READY                    (                                          ),
	  .WR_FIFO_RE                  (wr_burst_data_req                         ),
	  .WR_FIFO_EMPTY               (1'b0                                      ),
	  .WR_FIFO_AEMPTY              (1'b0                                      ),
	  .WR_FIFO_DATA                (wr_burst_data                             ),
	  .WR_DONE                     (wr_burst_finish                           ),
	  .RD_START                    (rd_burst_req                              ),
	  .RD_ADRS                     ({rd_burst_addr,3'd0}                      ),
	  .RD_LEN                      ({rd_burst_len,3'd0}                       ),
	  .RD_READY                    (                                          ),
	  .RD_FIFO_WE                  (rd_burst_data_valid                       ),
	  .RD_FIFO_FULL                (1'b0                                      ),
	  .RD_FIFO_AFULL               (1'b0                                      ),
	  .RD_FIFO_DATA                (rd_burst_data                             ),
	  .RD_DONE                     (rd_burst_finish                           ),
	  .DEBUG                       (                                          )
	);
	
/*video_write_req_gen video_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (vin_clk                  ),
	.video_vsync                (vin_vs                   ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);	
*/

video_write_req_gen video_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (PixelClk                 ),
  //  .pclk                     (video_clk                ),
	//.video_vsync              (vin_vs                   ),
	    .video_vsync              (vid_pVSync             ),
	//.video_vsync              (vid_pVSync_d1            ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);
//video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),	
	.vout_data                  (vout_data                )
);
/*video_timing_data1 video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.de_in                      (vid_pVDE                 ),
    .vs_in                      (vid_pVSync               ),
    . hs_in                     (vid_pHSync               ),
	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),	
	.vout_data                  (vout_data                )
);*/
//video frame data read-write control
frame_read_write frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (ext_mem_clk              ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (24'd0                    ), //The first frame address is 0
	.read_addr_1                (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (24'd4147200              ),
	.read_addr_3                (24'd6220800              ),
	.read_addr_index            (read_addr_index          ),
	.read_len                   (24'd460800               ), //frame size
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_clk                  (PixelClk                 ),
	//.write_clk                  (video_clk                ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (24'd0                    ),
	.write_addr_1               (24'd2073600              ),
	.write_addr_2               (24'd4147200              ),
	.write_addr_3               (24'd6220800              ),
	.write_addr_index           (write_addr_index         ),
	.write_len                  (24'd460800               ), //frame size
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);
endmodule
