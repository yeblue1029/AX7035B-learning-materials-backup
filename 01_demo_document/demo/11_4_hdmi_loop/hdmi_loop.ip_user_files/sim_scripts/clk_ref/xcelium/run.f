-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../hdmi_loop.srcs/sources_1/ip/clk_ref/clk_ref_clk_wiz.v" \
  "../../../../hdmi_loop.srcs/sources_1/ip/clk_ref/clk_ref.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

