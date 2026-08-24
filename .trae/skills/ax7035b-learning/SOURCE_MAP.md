# Source Map — Topic to Resource Mapping

This map helps locate repository resources by learning topic.
Always verify by opening the actual files.

## Board Overview

| Type | Path |
|------|------|
| Primary docs | `AX7035开发板用户手册REV1.1.pdf` |
| Alt docs | `黑金AX7035B开发板用户手册REV1.0.pdf` |
| Testing guide | `AX7035开发板检测指南V2.0.pdf` |
| Schematics | `04_原理图PCB结构图/` |
| Tutorial mapping | `AX7035开发板教程与程序对应关系说明.pdf` |

## FPGA Device

| Type | Path |
|------|------|
| Device datasheet | `05_芯片手册/` (check for XC7A35T datasheet) |
| Vivado projects | `AI_REPO_INDEX/FPGA_PROJECTS.txt` |
| Evidence | XPR files: `Part=xc7a35tfgg484-2` |

## Clock (PLL)

| Type | Path |
|------|------|
| Demo | `01_demo_document/demo/03_pll_test/` |
| XDC | `01_demo_document/demo/03_pll_test/.../top.xdc` |
| IP | `01_demo_document/demo/03_pll_test/.../*.xci` (clk_wiz) |
| RTL | `01_demo_document/demo/03_pll_test/.../top.v` |

## LED / Key

| Type | Path |
|------|------|
| LED Demo | `01_demo_document/demo/01_led_test/` |
| Key Demo | `01_demo_document/demo/02_key_test/` |
| Debounce Demo | `01_demo_document/demo/05_key_debounce/` |
| XDC | Each demo's `.../top.xdc` |
| RTL | Each demo's `.../top.v` |

## UART

| Type | Path |
|------|------|
| Demo | `01_demo_document/demo/04_uart_test/` |
| XDC | `01_demo_document/demo/04_uart_test/.../top.xdc` |
| RTL | `01_demo_document/demo/04_uart_test/.../top.v` |

## I2C / EEPROM

| Type | Path |
|------|------|
| Demo | `01_demo_document/demo/6_i2c_eeprom_test/` |
| XDC | `01_demo_document/demo/6_i2c_eeprom_test/.../top.xdc` |
| RTL | `01_demo_document/demo/6_i2c_eeprom_test/.../top.v` |

## ROM / RAM / FIFO

| Type | Path |
|------|------|
| ROM Demo | `01_demo_document/demo/07_rom_test/` |
| RAM Demo | `01_demo_document/demo/08_ram_test/` |
| FIFO Demo | `01_demo_document/demo/09_fifo_test/` |
| IP | Each demo's `.../*.xci` (rom/ram/fifo IP) |
| COE data | Each demo's `.../*.coe` |

## SD Card

| Type | Path |
|------|------|
| SD Demo | `01_demo_document/demo/10_sd_test/` |
| SD Audio Demo | `01_demo_document/demo/14_sd_card_audio/` |
| SD Picture Demos | `01_demo_document/demo/16_1_sd_picture_hdmi/` etc. |
| XDC | Each demo's `.../top.xdc` |

## HDMI

| Type | Path |
|------|------|
| Output Demo | `01_demo_document/demo/11_1_hdmi_output_test/` |
| Loopback Demo | `01_demo_document/demo/11_4_hdmi_loop/` |
| DDR3 Loopback | `01_demo_document/demo/11_5hdmi_input_loopback_ddr/` |
| Character Demo | `01_demo_document/demo/15_1_hdmi_char/` |
| XDC | `IOSTANDARD TMDS_33` in each demo's XDC |
| RTL | Top module with TMDS ports |
| Note | HDMI connects directly to FPGA TMDS differential IO |

## DDR3

| Type | Path |
|------|------|
| Demo | `01_demo_document/demo/12_ddr3_test/` |
| XPR | `01_demo_document/demo/12_ddr3_test/ddr3_ex.xpr` |
| XDC | `01_demo_document/demo/12_ddr3_test/.../ddr3.xdc` |
| MIG XCI | `01_demo_document/demo/12_ddr3_test/.../ddr3.xci` |
| MIG IP | mig_7series v4.2 |
| Data width | 16-bit (16 DQ pins in XDC) |
| Speed | 800 Mbps / 400 MHz (TIMEPERIOD_PS=1250) |
| IOSTANDARD | SSTL15 |
| Interface | 7-Series MIG UI (app_addr, app_cmd, etc.) |
| Board manual | Check `AX7035开发板用户手册REV1.1.pdf` for chip model |

## Camera

| Type | Path |
|------|------|
| Dual Camera Demo | `01_demo_document/demo/17_1_dual_ov5640_an5642_hdmi/` |
| DDR3 Camera+LCD | `01_demo_document/demo/17_2_ddr3_an5642_an430_lcd/` |
| DDR3 Camera+LCD | `01_demo_document/demo/17_3_ddr3_an5642_an070_lcd/` |
| Sobel Edge | `01_demo_document/demo/18_ddr3_an5642_hdmi_sobel/` |

## ADC

| Type | Path |
|------|------|
| AD9238 Demo | `01_demo_document/demo/19_ad9238_hdmi_test/` |
| AD7606 Demo | `01_demo_document/demo/20_ad7606_hdmi_test/` |
| ADDA Demo | `01_demo_document/demo/21_an108_adda_hdmi_test/` |
| AD9238+Ethernet | `01_demo_document/demo/27_ad9238_ethernet/` |
| AD7606+Ethernet | `01_demo_document/demo/28_ad7606_ethernet/` |

## DAC

| Type | Path |
|------|------|
| Dual Sin Wave | `01_demo_document/demo/22_ad9767_dual_sin_wave/` |
| Dual Trig Wave | `01_demo_document/demo/23_ad9767_dual_trig_wave/` |
| ADDA Demo | `01_demo_document/demo/21_an108_adda_hdmi_test/` |

## Ethernet

| Type | Path |
|------|------|
| Basic Demo | `01_demo_document/demo/26_ethernet_test/` |
| AD9238+Eth | `01_demo_document/demo/27_ad9238_ethernet/` |
| AD7606+Eth | `01_demo_document/demo/28_ad7606_ethernet/` |
| AD9280+Eth | `01_demo_document/demo/29_ad9280_ethernet/` |
| Video+Eth | `01_demo_document/demo/30_video_ethernet/` |
| Interface | RGMII (from XDC) |
| IOSTANDARD | LVCMOS33 |
| PHY model | Check board manual/schematic |

## USB

| Type | Path |
|------|------|
| Demo | `01_demo_document/demo/31_USB_speed_test/` |
| Controller | Check board manual for FT232H family |
| Note | USB2.0 (FT232H) is separate from USB-UART (CP2102) and JTAG |

## Temperature

| Type | Path |
|------|------|
| Demo | `01_demo_document/demo/25_temp_lm75_test/` |
| Sensor | LM75 (I2C temperature sensor) |

## MicroBlaze

| Type | Path |
|------|------|
| Directory | `09_microblaze/` |
| Index | `AI_REPO_INDEX/MICROBLAZE_PROJECTS.txt` |
| Note | Distinguish FPGA hardware design from MicroBlaze software |

## Vivado

| Type | Path |
|------|------|
| Projects | 41 .xpr files (see `FPGA_PROJECTS.txt`) |
| IP Cores | 113 .xci files (see `IP_CORES.txt`) |
| Constraints | 385 .xdc/.ucf files (see `CONSTRAINT_FILES.txt`) |
| Generated artifacts | Removed (not in repository) |

## Verilog / SystemVerilog

| Type | Path |
|------|------|
| Language tutorials | `02_学习教程之语言基础篇/` |
| HDL files | 3494 files (see `REPO_FILES.tsv`) |
| Top modules | See `HDL_TOP_MODULES.txt` |

## Debug

| Type | Path |
|------|------|
| Debug workflow | See `SKILL.md` Debug Workflow section |
| ILA demos | Check demos with ILA IP (e.g., 07_rom_test, 08_ram_test) |
