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
//2018/01/05        lhj            1.0          Original
//*******************************************************************************/
module top(
input           sys_clk,          //system clock 50Mhz on board
output [0:0]    HDMI_OEN,         //HDMI out enable
output          TMDS_clk_n,       //HDMI differential clock negative
output          TMDS_clk_p,       //HDMI differential clock positive
output [2:0]    TMDS_data_n,      //HDMI differential data negative
output [2:0]    TMDS_data_p       //HDMI differential data positive
);
wire            video_clk;        //pixel clock
wire            video_clk_5x;     //5x PixelClk
wire            video_hs;         //horizontal synchronization
wire            video_vs;         //vertical synchronization
wire            video_de;         //video valid
wire[7:0]       video_r;          //video red data
wire[7:0]       video_g;          //video green data
wire[7:0]       video_b;          //video blue data

assign HDMI_OEN = 1'b1;
/*************************************************************************
Call color bar generation module
****************************************************************************/
color_bar hdmi_color_bar
(
.clk                    (video_clk                  ),
.rst                    (1'b0                       ),
.hs                     (video_hs                   ),
.vs                     (video_vs                   ),
.de                     (video_de                   ),
.rgb_r                  (video_r                    ),
.rgb_g                  (video_g                    ),
.rgb_b                  (video_b                    )
);
/*************************************************************************
Generate the pixel clock and 5x pixel clock required for the video
****************************************************************************/
video_pll video_pll_m0
(
.clk_in1                (sys_clk                    ),
.clk_out1               (video_clk                  ),
.clk_out2               (video_clk_5x               ),
.reset                  (1'b0                       ),
.locked                 (                           )
);
 /*************************************************************************
RGB to DVI conversion module
****************************************************************************/
rgb2dvi
#(
.kGenerateSerialClk     (1'b0                       ),
.kClkRange              (1                          ),     
.kRstActiveHigh         (1'b1                       )
)
rgb2dvi_m0 (
// DVI 1.0 TMDS video interface
.TMDS_Clk_p             (TMDS_clk_p                 ),
.TMDS_Clk_n             (TMDS_clk_n                 ),
.TMDS_Data_p            (TMDS_data_p                ),
.TMDS_Data_n            (TMDS_data_n                ),
//Auxiliary signals 
.aRst                   (1'b0                       ), //asynchronous reset; must be reset when RefClk is not within spec
.aRst_n                 (1'b1                       ), //-asynchronous reset; must be reset when RefClk is not within spec
// Video in
.vid_pData              ({video_r,video_b,video_g}  ),
.vid_pVDE               (video_de                   ),
.vid_pHSync             (video_hs                   ),
.vid_pVSync             (video_vs                   ),
.PixelClk               (video_clk                  ),

.SerialClk              (video_clk_5x               )// 5x PixelClk
);   
endmodule