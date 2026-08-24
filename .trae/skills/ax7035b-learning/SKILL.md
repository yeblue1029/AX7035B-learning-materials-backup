---
name: ax7035b-learning
description: Evidence-first learning, development, debugging, and repository navigation assistant for the ALINX AX7035B / Xilinx Artix-7 XC7A35T FPGA platform. Use when studying AX7035B demos, Vivado projects, Verilog/SystemVerilog, XDC constraints, DDR3, HDMI, Ethernet, USB, UART, SD, ADC/DAC, camera interfaces, or MicroBlaze.
---

# AX7035B Learning Skill

## Core Principle

```
Skill = tells AI how to verify and work
Index = tells AI where to find
Real manuals/XDC/XPR/XCI/RTL = determines the answer
```

This skill does NOT hardcode hardware facts. It teaches the agent to locate evidence before answering.

## Standard Workflow

```
User Question
  ↓
AI_REPO_INDEX (find paths)
  ↓
Locate board manual / schematic / tutorial / demo
  ↓
Inspect XPR / XDC / XCI / RTL
  ↓
Cross-check facts
  ↓
Answer with evidence paths
```

## Evidence Priority

| Priority | Source | Use For |
|----------|--------|---------|
| 1 | Repository board manuals, schematics, PCB docs | Board-level facts (pin connections, chip models, power) |
| 2 | AMD/Xilinx official device docs, Vivado/MIG/IP docs | Device-level capabilities, IP behavior |
| 3 | Actual Demo projects (XPR/XDC/XCI/BD/TCL/RTL) | Practical implementation, pin assignments, IP config |
| 4 | Board-mounted chip datasheets | Chip-specific parameters |
| 5 | Repository learning tutorials | Step-by-step guidance |
| 6 | Reliable external resources | Supplementary context |
| 7 | AI inference | Last resort — must be labeled as inference |

**For board-level questions ("how is X connected on this board?"):**
Board manual/schematic takes priority over chip datasheet.
A chip *supporting* a feature does not mean the AX7035B board *implements* it.

## Device vs Board Distinction

This is critical. Always distinguish:

- **FPGA silicon capability** — what the XC7A35T chip *can* do
- **AX7035B board implementation** — what the board *actually connects*

Examples:
- XC7A35T silicon has GTP transceivers, but AX7035B board may not power/connect them
- XC7A35T supports certain IOSTANDARDs, but board pin assignments and bank voltages determine what is usable
- The chip has 33,280 logic cells — this is silicon fact; how many are *available* depends on board design

Never assume board capability from device capability alone. Verify with board docs and XDC.

## Repository Navigation

### Key Directories

| Directory | Content |
|-----------|---------|
| `01_demo_document/demo/` | 41 Vivado demo projects + 1 demo_test |
| `02_学习教程之语言基础篇/` | Verilog/SystemVerilog language tutorials |
| `03_学习教程之参考篇/` | Reference tutorials |
| `04_原理图PCB结构图/` | Board schematics and PCB layout |
| `05_芯片手册/` | Chip datasheets |
| `06_模块资料/` | Module documentation |
| `07_软件工具及驱动/` | Software tools and drivers |
| `08_其他资料/` | Other resources |
| `09_microblaze/` | MicroBlaze projects |
| `其它FPGA相关资料/` | Other FPGA-related materials |

### AI_REPO_INDEX Usage

1. Read `AI_REPO_INDEX/INDEX_SUMMARY.md` for overview
2. Use `AI_REPO_INDEX/EXPERIMENTS.txt` to find demo projects
3. Use `AI_REPO_INDEX/FPGA_PROJECTS.txt` to find Vivado projects
4. Use `AI_REPO_INDEX/HDL_TOP_MODULES.txt` to find top modules
5. Use `AI_REPO_INDEX/CONSTRAINT_FILES.txt` to find constraints
6. Use `AI_REPO_INDEX/IP_CORES.txt` to find IP configurations
7. Use `AI_REPO_INDEX/IMPORTANT_FILES.txt` for key learning resources

**Remember:** Index entry ≠ authoritative hardware fact. Always open the actual file.

### Board Manuals (Priority 1 Evidence)

| File | Purpose |
|------|---------|
| `AX7035开发板用户手册REV1.1.pdf` | Board user manual (latest) |
| `黑金AX7035B开发板用户手册REV1.0.pdf` | Board user manual (REV1.0) |
| `AX7035开发板检测指南V2.0.pdf` | Board testing guide |
| `AX7035开发板教程与程序对应关系说明.pdf` | Demo-to-tutorial mapping |
| `04_原理图PCB结构图/` | Schematics and PCB layouts |

## Demo Learning Workflow

When a user asks "I want to learn about X":

1. Find the simplest demo for topic X in `EXPERIMENTS.txt`
2. Find the corresponding tutorial
3. Find the top module in `HDL_TOP_MODULES.txt`
4. Find clock/reset logic
5. Find timing/serializer details
6. Find XDC pin assignments
7. Explain layer by layer

### Topic-to-Demo Map

| Topic | Start Here |
|-------|------------|
| LED/Basics | `01_led_test` |
| Keys/Debounce | `02_key_test`, `05_key_debounce` |
| PLL | `03_pll_test` |
| UART | `04_uart_test` |
| I2C/EEPROM | `6_i2c_eeprom_test` |
| ROM/RAM/FIFO | `07_rom_test`, `08_ram_test`, `09_fifo_test` |
| SD Card | `10_sd_test`, `14_sd_card_audio` |
| HDMI Output | `11_1_hdmi_output_test` → `11_4_hdmi_loop` → `11_5hdmi_input_loopback_ddr` |
| LCD | `11_2_an430_lcd_test`, `11_3_an070_lcd_test` |
| DDR3 | `12_ddr3_test` |
| Audio | `13_audio_record_play` |
| HDMI Character | `15_1_hdmi_char` → `15_2/15_3` |
| SD Picture | `16_1/16_2/16_3` |
| Camera | `17_1/17_2/17_3` |
| Sobel Edge Detection | `18_ddr3_an5642_hdmi_sobel` |
| ADC | `19_ad9238_hdmi_test`, `20_ad7606_hdmi_test` |
| DAC | `21_an108_adda_hdmi_test`, `22_ad9767_*`, `23_ad9767_*` |
| Ethernet | `26_ethernet_test` → `27-30` |
| USB | `31_USB_speed_test` |
| Temperature | `25_temp_lm75_test` |
| MicroBlaze | `09_microblaze/` |

### Difficulty Ordering

When multiple demos exist for a topic, recommend in order:
1. Simplest first (fewest IP cores, simplest data flow)
2. Then intermediate (multiple IPs, data paths)
3. Then advanced (DDR3 + complex algorithms)

## Code Generation Rules

When a user asks "help me write a Verilog project for AX7035B":

1. Find the closest existing demo in the repository
2. Reuse from that demo:
   - Clock/reset logic
   - Pin constraints (XDC)
   - IP configuration (XCI)
   - Interface timing
3. Do NOT guess:
   - FPGA pin assignments
   - IOSTANDARD settings
   - DDR3 pin connections
   - Ethernet PHY connections
4. Clearly label:
   - What comes from existing demos
   - What is newly written
   - What needs user verification in Vivado

## Debug Workflow

When debugging an FPGA issue on AX7035B, follow this order:

1. **Power / board connection** — Is the board powered? JTAG connected?
2. **Clock** — Is the clock signal present and correct?
3. **Reset** — Is reset properly synchronized?
4. **Top module** — Is the correct top module set?
5. **XDC pin assignment** — Are pins correctly assigned?
6. **IOSTANDARD / Bank voltage** — Do they match the hardware?
7. **IP configuration** — Is the IP (PLL, MIG, etc.) configured correctly?
8. **Synthesis warnings** — Any critical warnings?
9. **Implementation / DRC** — Any DRC errors?
10. **Timing constraints** — Are constraints met?
11. **CDC (Clock Domain Crossing)** — Are CDC issues handled?
12. **Protocol state machine** — Is the FSM correct?
13. **ILA/VIO** — Can you use debug cores?
14. **Hardware observation** — What does the hardware actually show?

Do not immediately suggest major RTL changes. Start from the basics.

## MicroBlaze

For MicroBlaze questions, check:

1. `09_microblaze/` directory
2. `AI_REPO_INDEX/MICROBLAZE_PROJECTS.txt`

Distinguish:
- **FPGA hardware design** — the PL (programmable logic) side
- **MicroBlaze processor system** — the processor, peripherals, memory map
- **BSP** — board support package
- **Application software** — C/C++ code

Do not mix pure RTL demos with MicroBlaze demos.

## Output Requirements

When answering based on repository content, include evidence paths:

```
Evidence:
- 04_原理图PCB结构图/schematic.pdf
- 01_demo_document/demo/12_ddr3_test/ddr3_ex.xpr
- 01_demo_document/demo/12_ddr3_test/.../top.v
- 01_demo_document/demo/12_ddr3_test/.../ddr3.xdc
```

If a conclusion is AI inference only:
```
Inference — not directly confirmed by repository evidence.
```

## Hardware Facts (Verified from Repository)

These facts are confirmed by repository evidence. For unverified items, check board manuals.

| Fact | Value | Evidence |
|------|-------|---------|
| FPGA model | XC7A35T-2FGG484 | XPR: `Part=xc7a35tfgg484-2` |
| DDR3 data width | 16-bit | XDC: 16 DQ pins (indices 0-15) |
| DDR3 speed | 800 Mbps / 400 MHz | XCI: TIMEPERIOD_PS=1250 |
| DDR3 IOSTANDARD | SSTL15 | XDC: `IOSTANDARD SSTL15` |
| DDR3 MIG IP | mig_7series v4.2 | XCI: componentRef |
| Ethernet interface | RGMII | XDC: `rgmii_rxd/txd/rxc/txc/rxctl/txctl` |
| Ethernet IOSTANDARD | LVCMOS33 | XDC: `IOSTANDARD LVCMOS33` |
| HDMI interface | TMDS (direct) | XDC: `IOSTANDARD TMDS_33`, TMDS_clk/data ports |
| HDMI connection | Direct to FPGA diff IO | XDC: no external transmitter/receiver chip |

For chip models (DDR3 part number, Ethernet PHY, USB controller, UART chip):
**Check board manuals and schematics in the repository.**

For XC7A35T device resources (logic cells, BRAM, DSP):
**Check Xilinx/AMD official device documentation in `05_芯片手册/`.**

## MIG Interface Guidance

AX7035B uses 7-Series MIG (mig_7series). The user interface is the 7-Series MIG UI:

- `app_addr`, `app_cmd`, `app_en`, `app_rdy`
- `app_wdf_data`, `app_wdf_wren`, `app_wdf_end`, `app_wdf_mask`, `app_wdf_rdy`
- `app_rd_data`, `app_rd_data_valid`, `app_rd_data_end`
- `ui_clk`, `ui_clk_sync_rst`, `init_calib_complete`

**Always verify against the actual DDR3 Demo XCI and RTL in the repository.**

Do NOT use Spartan-6 MIG interface names (c3_p0_cmd_*, c3_p0_wr_*, c3_p0_rd_*) as the standard for AX7035B. Those are legacy interface examples from a different FPGA generation.

## Regenerating the Index

```
.trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.cmd
```

Or:
```
powershell -File .trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.ps1
```
