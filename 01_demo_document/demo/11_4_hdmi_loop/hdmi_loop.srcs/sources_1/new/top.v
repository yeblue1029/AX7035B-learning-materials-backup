//      Author:lhj                                                              //
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
//2019/07/30                   1.0          Original
//*******************************************************************************/
module top
(
input               sys_clk,                    //system clock 50Mhz on board
input               rst_n,                      //reset ,low active
//hdmi in
inout               hdmi_ddc_scl_io,            //hdmi input edid scl 
inout               hdmi_ddc_sda_io,            //hdmi input edid data
output              hdmi_hdmi_in_hpd,           //hdmi input edid data
output[0:0]         HDMI_hdmi_in_OEN,           //hdmi input or output enable 
input               TMDS_clk_hdmi_in_n,         //HDMI input differential clock negative
input               TMDS_clk_hdmi_in_p,         //HDMI input differential clock positive
input[2:0]          TMDS_data_hdmi_in_n,        //HDMI input differential data negative
input[2:0]          TMDS_data_hdmi_in_p,        //HDMI input differential data positive
//hdmi out
output[0:0]         HDMI_hdmi_out_OEN,          //HDMI output enable high level enable
output              TMDS_clk_hdmi_out_n,        //HDMI output differential clock negative
output              TMDS_clk_hdmi_out_p,        //HDMI output differential clock positive
output [2:0]        TMDS_data_hdmi_out_n,       //HDMI output differential data negative
output [2:0]        TMDS_data_hdmi_out_p        //HDMI input differential data positive
    );
wire                hdmi_ddc_scl_i;
wire                hdmi_ddc_scl_o;
wire                hdmi_ddc_scl_t;
wire                hdmi_ddc_sda_i;
wire                hdmi_ddc_sda_o;
wire                hdmi_ddc_sda_t;
wire                clk_200mhz;                 //Reference clock
wire[23:0]          vid_pData;                  //get data from the hdmi input
wire                vid_pVDE;                   //data valid  flag from the hdmi input
wire                vid_pHSync;                 //horizontal synchronization
wire                vid_pVSync;                 //vertical synchronization

reg[23:0]           vid_pData_d0;
reg                 vid_pVDE_d0;
reg                 vid_pHSync_d0;
reg                 vid_pVSync_d0;

reg[23:0]           vid_pData_d1;
reg                 vid_pVDE_d1;
reg                 vid_pHSync_d1;
reg                 vid_pVSync_d1;

wire                PixelClk;                   //Pixel clock
wire                peripheral_aresetn;         // reset
wire                SerialClk;                  //5x PixelClk 
reg                 hdmi_hpd_r;                 //hdmi hpd signal  
wire                aPixelClkLckd;              //clock locked high is active
assign HDMI_hdmi_in_OEN = 1'b0;
assign hdmi_hdmi_in_hpd = hdmi_hpd_r;
/*************************************************************************
Generate hdmi input hpd 
****************************************************************************/
always@(posedge clk_200mhz or negedge rst_n)
begin
    if( rst_n == 1'b0)
        hdmi_hpd_r <= 1'b0;
    else
        hdmi_hpd_r <= 1'b1;
end
/*************************************************************************
call IOBUF conversion
****************************************************************************/
IOBUF hdmi_ddc_scl_iobuf
(
.I                  (hdmi_ddc_scl_o         ),
.IO                 (hdmi_ddc_scl_io        ),
.O                  (hdmi_ddc_scl_i         ),
.T                  (hdmi_ddc_scl_t         )
);
IOBUF hdmi_ddc_sda_iobuf
(
.I                  (hdmi_ddc_sda_o         ),
.IO                 (hdmi_ddc_sda_io        ),
.O                  (hdmi_ddc_sda_i         ),
.T                  (hdmi_ddc_sda_t         )
); 
/*************************************************************************
Call the third-party dvi2rgb module
****************************************************************************/
dvi2rgb
#(
.kEmulateDDC        (1'b1                   ),
.kRstActiveHigh     (1'b0                   ),
.kAddBUFG           (1'b1                   ),
.kClkRange          (1                      ),
.kEdidFileName      ("900p_edid.txt"      ),
.kIDLY_TapValuePs   (78                     ),
.kIDLY_TapWidth     (5                      )
)
dvi2rgb_m0
(
.TMDS_Clk_p         (TMDS_clk_hdmi_in_p     ),
.TMDS_Clk_n         (TMDS_clk_hdmi_in_n     ),
.TMDS_Data_p        (TMDS_data_hdmi_in_p    ),
.TMDS_Data_n        (TMDS_data_hdmi_in_n    ),

.RefClk             (clk_200mhz             ),
.aRst               (1'b0                   ),
.aRst_n             (rst_n                  ),

.vid_pData          (vid_pData              ),
.vid_pVDE           (vid_pVDE               ), 
.vid_pHSync         (vid_pHSync             ), 
.vid_pVSync         (vid_pVSync             ), 
.PixelClk           (PixelClk               ),

.SerialClk          (SerialClk              ),
.aPixelClkLckd      (aPixelClkLckd          ),

.DDC_SDA_I          (hdmi_ddc_sda_i         ),
.DDC_SDA_O          (hdmi_ddc_sda_o         ), 
.DDC_SDA_T          (hdmi_ddc_sda_t         ), 
.DDC_SCL_I          (hdmi_ddc_scl_i         ),
.DDC_SCL_O          (hdmi_ddc_scl_o         ),  
.DDC_SCL_T          (hdmi_ddc_scl_t         ), 

.pRst               (1'b0                   ),
.pRst_n             (rst_n                  )
);

/*************************************************************************
Data delay 
****************************************************************************/
always@(posedge PixelClk)
begin
    vid_pData_d0    <=  vid_pData;
    vid_pVDE_d0     <=  vid_pVDE;
    vid_pHSync_d0   <=  vid_pHSync;
    vid_pVSync_d0   <=  vid_pVSync;
    vid_pData_d1    <=  vid_pData_d0;
    vid_pVDE_d1     <=  vid_pVDE_d0;
    vid_pHSync_d1   <=  vid_pHSync_d0;
    vid_pVSync_d1   <=  vid_pVSync_d0;
end  
assign HDMI_hdmi_out_OEN = 1'b1; //enable hdmi output
/*************************************************************************
Generate reference clock required for dvi2rgb module
****************************************************************************/
clk_ref clk_refm0
(
.clk_out1           (clk_200mhz             ),  // output clk_out1
.reset              (1'b0                   ),  // input reset
.locked             (                       ),  // output locked
.clk_in1            (sys_clk                )   // input clk_in1
);       
/*************************************************************************
Call the third-party rgb2dvi module
****************************************************************************/
rgb2dvi
#(
.kGenerateSerialClkv(1'b1                   ),
.kClkRange          (1                      ),     
.kRstActiveHigh     (1'b1                   )
)
rgb2dvi_m0 
(
// DVI 1.0 TMDS video interface
.TMDS_Clk_p         (TMDS_clk_hdmi_out_p    ),
.TMDS_Clk_n         (TMDS_clk_hdmi_out_n    ),
.TMDS_Data_p        (TMDS_data_hdmi_out_p   ),
.TMDS_Data_n        (TMDS_data_hdmi_out_n   ),  
//Auxiliary signals 
.aRst               (1'b0                   ),  //asynchronous reset; must be reset when RefClk is not within spec
.aRst_n             (1'b1                   ),  //-asynchronous reset; must be reset when RefClk is not within spec
// Video in
.vid_pData          (vid_pData_d1           ),
.vid_pVDE           (vid_pVDE_d1            ),
.vid_pHSync         (vid_pHSync_d1          ),
.vid_pVSync         (vid_pVSync_d1          ),
.PixelClk           (PixelClk               ),
.SerialClk          (SerialClk              )   // 5x PixelClk
); 
endmodule

