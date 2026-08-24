//////////////////////////////////////////////////////////////////////////////////
//   vga color bar test                                                         //
//                                                                              //
//  Author:lhj                                                                  //
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
//2019/08/05                   1.0          Original
//*******************************************************************************/
module top(
input                           sys_clk,           //system clock 50Mhz on board
input                           rst_n,             //reset ,low active     
output                          tmds_clk_p,        //HDMI differential clock positive
output                          tmds_clk_n,        //HDMI differential clock negative
output[2:0]                     tmds_data_p,       //HDMI differential data positive
output[2:0]                     tmds_data_n,       //HDMI differential data negative
output [0:0]                    HDMI_OEN           //HDMI out enable
);

wire                            video_clk;        //pixel clock
wire                            video_clk5x;      //5x PixelClk
wire                            video_hs;         //horizontal synchronization
wire                            video_vs;         //vertical synchronization
wire                            video_de;         //video valid
wire[7:0]                       video_r;          //video red data
wire[7:0]                       video_g;          //video green data
wire[7:0]                       video_b;          //video blue data

wire                            hdmi_hs;          //hdmi horizontal synchronization
wire                            hdmi_vs;          //hdmi vertical synchronization
wire                            hdmi_de;          //hdmi data valid
wire[7:0]                       hdmi_r;           //hdmi red data
wire[7:0]                       hdmi_g;           //hdmi green data
wire[7:0]                       hdmi_b;           //hdmi blue data

wire                            osd_hs;           //osd horizontal synchronization
wire                            osd_vs;           //osd vertical synchronization
wire                            osd_de;           //osd data valid
wire[7:0]                       osd_r;            //osd red data
wire[7:0]                       osd_g;            // osd green data
wire[7:0]                       osd_b;            //osd blue

assign HDMI_OEN = 1'b1;

assign hdmi_hs     = osd_hs;
assign hdmi_vs    = osd_vs;
assign hdmi_de     = osd_de;
assign hdmi_r      = osd_r[7:0];
assign hdmi_g      = osd_g[7:0];
assign hdmi_b      = osd_b[7:0];
/*************************************************************************
Generate the pixel clock and 5x pixel clock required for the video
****************************************************************************/
video_pll video_pll_m0
(
.clk_in1                        (sys_clk                  ),
.clk_out1                       (video_clk                ),
.clk_out2                       (video_clk5x              ),
.reset                          (1'b0                     ),
.locked                         (                         )
);
/*************************************************************************
Call color bar generation module
****************************************************************************/
color_bar color_bar_m0
(
.clk                            (video_clk                ),
.rst                            (~rst_n                   ),
.hs                             (video_hs                 ),
.vs                             (video_vs                 ),
.de                             (video_de                 ),
.rgb_r                          (video_r                  ),
.rgb_g                          (video_g                  ),
.rgb_b                          (video_b                  )
);
 /*************************************************************************
RGB to DVI conversion module
****************************************************************************/
rgb2dvi
#(
.kGenerateSerialClk             (1'b0                     ),
.kClkRange                      (1                        ),     
.kRstActiveHigh                 (1'b1                     )
)
rgb2dvi_m0 
(
// DVI 1.0 TMDS video interface
.TMDS_Clk_p                     (tmds_clk_p               ),
.TMDS_Clk_n                     (tmds_clk_n               ),
.TMDS_Data_p                    (tmds_data_p              ),
.TMDS_Data_n                    (tmds_data_n              ),
//Auxiliary signals 
.aRst                           (1'b0                     ), //asynchronous reset; must be reset when RefClk is not within spec
.aRst_n                         (1'b1                     ), //-asynchronous reset; must be reset when RefClk is not within spec
// Video in
.vid_pData                      ({hdmi_r,hdmi_b,hdmi_g}   ),
.vid_pVDE                       (hdmi_de                  ),
.vid_pHSync                     (hdmi_hs                  ),
.vid_pVSync                     (hdmi_vs                  ),
.PixelClk                       (video_clk                ),

.SerialClk                      (video_clk5x              ) // 5x PixelClk
);   
 /*************************************************************************
Character OSD display
****************************************************************************/
osd_display  osd_display_m0
(
.rst_n                          (rst_n                    ),
.pclk                           (video_clk                ),
.i_hs                           (video_hs                 ),
.i_vs                           (video_vs                 ),
.i_de                           (video_de                 ),
.i_data                         ({video_r,video_g,video_b}),
.o_hs                           (osd_hs                   ),
.o_vs                           (osd_vs                   ),
.o_de                           (osd_de                   ),
.o_data                         ({osd_r,osd_g,osd_b}      )
);
endmodule