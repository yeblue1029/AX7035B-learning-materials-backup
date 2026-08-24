-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Mon Aug 12 11:22:52 2019
-- Host        : PC-201805041311 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               I:/ax7035_2019.1/demo/16_1_sd_picture_hdmi/sd_picture_hdmi/sd_picture_hdmi.srcs/sources_1/ip/clk_200M/clk_200M_stub.vhdl
-- Design      : clk_200M
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_200M is
  Port ( 
    clk_out1 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end clk_200M;

architecture stub of clk_200M is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1,reset,locked,clk_in1";
begin
end;
