vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm

vlog -work xil_defaultlib -64 -sv \
"C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_ctrl_addr_decode.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_ctrl_read.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_ctrl_reg.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_ctrl_reg_bank.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_ctrl_top.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_ctrl_write.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_ar_channel.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_aw_channel.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_b_channel.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_cmd_arbiter.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_cmd_fsm.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_cmd_translator.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_fifo.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_incr_cmd.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_r_channel.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_simple_fifo.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_wrap_cmd.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_wr_cmd_fsm.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_axi_mc_w_channel.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_axic_register_slice.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_axi_register_slice.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_axi_upsizer.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_a_upsizer.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_carry_and.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_carry_latch_and.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_carry_latch_or.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_carry_or.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_command_fifo.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_comparator.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_comparator_sel.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_comparator_sel_static.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_r_upsizer.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/axi/mig_7series_v4_0_ddr_w_upsizer.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/clocking/mig_7series_v4_0_clk_ibuf.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/clocking/mig_7series_v4_0_infrastructure.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/clocking/mig_7series_v4_0_iodelay_ctrl.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/clocking/mig_7series_v4_0_tempmon.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_arb_mux.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_arb_row_col.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_arb_select.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_bank_cntrl.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_bank_common.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_bank_compare.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_bank_mach.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_bank_queue.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_bank_state.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_col_mach.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_mc.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_rank_cntrl.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_rank_common.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_rank_mach.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/controller/mig_7series_v4_0_round_robin_arb.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ecc/mig_7series_v4_0_ecc_buf.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ecc/mig_7series_v4_0_ecc_dec_fix.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ecc/mig_7series_v4_0_ecc_gen.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ecc/mig_7series_v4_0_ecc_merge_enc.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ecc/mig_7series_v4_0_fi_xor.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ip_top/mig_7series_v4_0_memc_ui_top_axi.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ip_top/mig_7series_v4_0_mem_intfc.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_byte_group_io.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_byte_lane.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_calib_top.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_if_post_fifo.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_mc_phy.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_mc_phy_wrapper.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_of_pre_fifo.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_4lanes.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_dqs_found_cal.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_dqs_found_cal_hr.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_init.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_cntlr.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_data.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_edge.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_lim.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_mux.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_po_cntlr.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_samp.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_oclkdelay_cal.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_prbs_rdlvl.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_rdlvl.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_tempmon.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_top.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrcal.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrlvl.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrlvl_off_delay.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_prbs_gen.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_ddr_skip_calib_tap.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_poc_cc.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_poc_edge_store.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_poc_meta.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_poc_pd.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_poc_tap_base.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/phy/mig_7series_v4_0_poc_top.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ui/mig_7series_v4_0_ui_cmd.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ui/mig_7series_v4_0_ui_rd_data.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ui/mig_7series_v4_0_ui_top.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ui/mig_7series_v4_0_ui_wr_data.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ddr3_mig_sim.v" \
"../../../../ad7606_ethernet.srcs/sources_1/ip/ddr3/ddr3/user_design/rtl/ddr3.v" \

vlog -work xil_defaultlib \
"glbl.v"

