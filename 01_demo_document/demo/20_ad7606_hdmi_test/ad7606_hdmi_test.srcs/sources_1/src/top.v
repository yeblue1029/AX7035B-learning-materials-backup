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
//2019/08/15                   1.0          Original
//*******************************************************************************/
module top
(
input                            sys_clk,                 //system clock 50Mhz on board
input                            rst_n,                   //reset ,low active
input[15:0]                      ad7606_data,             //ad7606 data
input                            ad7606_busy,             //ad7606 busy
input                            ad7606_first_data,       //ad7606 first data
output[2:0]                      ad7606_os,               //ad7606
output                           ad7606_cs,               //ad7606 AD cs
output                           ad7606_rd,               //ad7606 AD data read
output                           ad7606_reset,            //ad7606 AD reset
output                           ad7606_convstab,         //ad7606 AD convert start
//hdmi output        
output                           tmds_clk_p,              //HDMI differential clock positive
output                           tmds_clk_n,              //HDMI differential clock negative
output [2:0]                     tmds_data_n,             //HDMI differential data negative
output [2:0]                     tmds_data_p,             //HDMI differential data positive
output [0:0]                     HDMI_OEN                 //HDMI out enable
);
wire                            video_clk;               //pixel clock
wire                            video_clk5x;             //5x PixelClk
wire                            video_hs;                //horizontal synchronization
wire                            video_vs;                //vertical synchronization
wire                            video_de;                //video valid
wire[7:0]                       video_r;                 //video red data
wire[7:0]                       video_g;                 //video green data
wire[7:0]                       video_b;                 //video blue data

wire                            hdmi_hs;                 //hdmi horizontal synchronization
wire                            hdmi_vs;                 //hdmi vertical synchronization
wire                            hdmi_de;                 //hdmi data valid
wire[7:0]                       hdmi_r;                  //hdmi red data
wire[7:0]                       hdmi_g;                  //hdmi green data
wire[7:0]                       hdmi_b;                  //hdmi blue data


wire                            grid_hs;                 //grid horizontal synchronization
wire                            grid_vs;                 //grid vertical synchronization
wire                            grid_de;                 //grid data valid
wire[7:0]                       grid_r;                  //grid red data
wire[7:0]                       grid_g;                  //grid green data
wire[7:0]                       grid_b;                  //grid blue data

wire                            wave0_hs;                //wave 0 horizontal synchronization            
wire                            wave0_vs;                //wave 0 vertical synchronization
wire                            wave0_de;                //wave 0 data valid
wire[7:0]                       wave0_r;                 //wave 0 red data
wire[7:0]                       wave0_g;                 //wave 0 green data
wire[7:0]                       wave0_b;                 //wave 0 blue data

wire                            wave1_hs;                //wave 1 horizontal synchronization
wire                            wave1_vs;                //wave 1 vertical synchronization
wire                            wave1_de;                //wave 1 data valid
wire[7:0]                       wave1_r;                 //wave 1 red data
wire[7:0]                       wave1_g;                 //wave 1 green data
wire[7:0]                       wave1_b;                 //wave 1 blue data

wire                            adc_clk;                 //ADC data processing clock
wire                            adc0_buf_wr;             //ADC channel 0 write buf enable
wire[10:0]                      adc0_buf_addr;           //ADC channel 0 write buf address
wire[7:0]                       adc0_buf_data;           //ADC channel 0 buf data
wire                            adc1_buf_wr;             //ADC channel 1 write buf enable       
wire[10:0]                      adc1_buf_addr;           //ADC channel 1 write buf address
wire[7:0]                       adc1_buf_data;           //ADC channel 1 data 
wire                            ad_data_valid;           //ADC data valid
wire signed[15:0]               ad_ch1;                  //AD channel 1 data
wire signed[15:0]               ad_ch2;                  //AD channel 2 data
wire signed[15:0]               ad_ch3;                  //AD channel 3 data 
wire signed[15:0]               ad_ch4;                  //AD channel 4 data 
wire signed[15:0]               ad_ch5;                  //AD channel 5 data 
wire signed[15:0]               ad_ch6;                  //AD channel 6 data 
wire signed[15:0]               ad_ch7;                  //AD channel 7 data 
wire signed[15:0]               ad_ch8;                  //AD channel 8 data 
assign hdmi_hs = wave1_hs;
assign hdmi_vs = wave1_vs;
assign hdmi_de = wave1_de;
assign hdmi_r  = wave1_r;
assign hdmi_g  = wave1_g;
assign hdmi_b  = wave1_b;

assign HDMI_OEN = 1'b1;
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
Generate the  clock required for the AD data processing
****************************************************************************/
adc_pll adc_pll_m0
(
.clk_in1                        (sys_clk                  ),
.clk_out1                       (adc_clk                  ),
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
Sampling all channels data of the AD7606 
****************************************************************************/
ad7606_if ad7606_if_m0(
.clk                            (adc_clk                  ),
.rst_n                          (rst_n                    ),
.ad_data                        (ad7606_data              ), //ad7606 data
.ad_busy                        (ad7606_busy              ), //ad7606 busy
.first_data                     (ad7606_first_data        ), //ad7606 first data
.ad_os                          (ad7606_os                ), //ad7606
.ad_cs                          (ad7606_cs                ), //ad7606 AD cs
.ad_rd                          (ad7606_rd                ), //ad7606 AD data read
.ad_reset                       (ad7606_reset             ), //ad7606 AD reset
.ad_convstab                    (ad7606_convstab          ), //ad7606 AD convert start
.ad_data_valid                  (ad_data_valid            ),
.ad_ch1                         (ad_ch1                   ),
.ad_ch2                         (ad_ch2                   ),
.ad_ch3                         (ad_ch3                   ),
.ad_ch4                         (ad_ch4                   ),
.ad_ch5                         (ad_ch5                   ),
.ad_ch6                         (ad_ch6                   ),
.ad_ch7                         (ad_ch7                   ),
.ad_ch8                         (ad_ch8                   )
);
 /*************************************************************************
Grid image display
****************************************************************************/
grid_display  grid_display_m0
(
.rst_n                          (rst_n                    ),
.pclk                           (video_clk                ),
.i_hs                           (video_hs                 ),
.i_vs                           (video_vs                 ),
.i_de                           (video_de                 ),
.i_data                         ({video_r,video_g,video_b}),
.o_hs                           (grid_hs                  ),
.o_vs                           (grid_vs                  ),
.o_de                           (grid_de                  ),
.o_data                         ({grid_r,grid_g,grid_b}   )
);
/*************************************************************************
AD ch1 data pre-processing and interface signals for generating and storing data to RAM 
****************************************************************************/
ad7606_sample ad7606_sample_m0
(
.adc_clk                        (adc_clk                  ),
.rst                            (~rst_n                   ),
.adc_data                       (ad_ch1                   ),
.adc_data_valid                 (ad_data_valid            ),
.adc_buf_wr                     (adc0_buf_wr              ),
.adc_buf_addr                   (adc0_buf_addr            ),
.adc_buf_data                   (adc0_buf_data            )
);
/*************************************************************************
AD ch2 data pre-processing and interface signals for generating and storing data to RAM
****************************************************************************/
ad7606_sample ad7606_sample_m1
(
.adc_clk                        (adc_clk                  ),
.rst                            (~rst_n                   ),
.adc_data                       (ad_ch2                   ),
.adc_data_valid                 (ad_data_valid            ),
.adc_buf_wr                     (adc1_buf_wr              ),
.adc_buf_addr                   (adc1_buf_addr            ),
.adc_buf_data                   (adc1_buf_data            )
);
/*************************************************************************
AD9706 channel 1 data and  grid overlay
****************************************************************************/
wav_display wav_display_m0
(
.rst_n                          (rst_n                    ),
.pclk                           (video_clk                ),
.wave_color                     (24'hff0000               ),
.adc_clk                        (adc_clk                  ),
.adc_buf_wr                     (adc0_buf_wr              ),
.adc_buf_addr                   (adc0_buf_addr            ),
.adc_buf_data                   (adc0_buf_data            ),
.i_hs                           (grid_hs                  ),
.i_vs                           (grid_vs                  ),
.i_de                           (grid_de                  ),
.i_data                         ({grid_r,grid_g,grid_b}   ),
.o_hs                           (wave0_hs                 ),
.o_vs                           (wave0_vs                 ),
.o_de                           (wave0_de                 ),
.o_data                         ({wave0_r,wave0_g,wave0_b})
);
 /*************************************************************************
AD7606 channel 2 data and wav_display_m0 module output overlay
****************************************************************************/
wav_display wav_display_m1
(
.rst_n                          (rst_n                    ),
.pclk                           (video_clk                ),
.wave_color                     (24'h00ffff               ),
.adc_clk                        (adc_clk                  ),
.adc_buf_wr                     (adc1_buf_wr              ),
.adc_buf_addr                   (adc1_buf_addr            ),
.adc_buf_data                   (adc1_buf_data            ),
.i_hs                           (wave0_hs                 ),
.i_vs                           (wave0_vs                 ),
.i_de                           (wave0_de                 ),
.i_data                         ({wave0_r,wave0_g,wave0_b}),
.o_hs                           (wave1_hs                 ),
.o_vs                           (wave1_vs                 ),
.o_de                           (wave1_de                 ),
.o_data                         ({wave1_r,wave1_g,wave1_b})
);
endmodule