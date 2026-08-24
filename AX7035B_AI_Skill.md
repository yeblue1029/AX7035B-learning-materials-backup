# AX7035B AI Skill — FPGA Development Knowledge Base

> **Target Board:** ALINX AX7035B  
> **FPGA Chip:** Xilinx Artix-7 XC7A35T-2FGG484I  
> **Repository:** [AX7035B-learning-materials](https://github.com/yeblue1029/AX7035B-learning-materials)  
> **Revision:** `0748c6c` | **Total Files:** 14,737 | **Demo Projects:** 42

---

## 1. Board Overview

### 1.1 AX7035B Specifications

| Feature | Specification |
|---------|--------------|
| FPGA | Xilinx Artix-7 XC7A35T-2FGG484I |
| Logic Cells | 33,280 |
| DSP Slices | 90 (DSP48E1) |
| BRAM | 50 blocks (900 Kb total) |
| User I/O | 250+ available |
| DDR3 | 1 GiB DDR3 SDRAM (MT41K256M16) |
| Ethernet | 10/100/1000M (RTL8211D, RGMII) |
| USB | USB-to-JTAG (FT232H) + USB 2.0 (CY7C68013A) |
| HDMI | HDMI input + HDMI output |
| SD Card | MicroSD slot (SPI mode) |
| Camera | Dual camera interface (OV5640/AN5642) |
| ADC/DAC | AD9238 (8-bit, 2-channel), AD7606 (16-bit), AD9280 (8-bit), AD9767 (14-bit) |
| EEPROM | 24LC04 (I2C) |
| Temperature | LM75A (I2C) |
| Clock | 50 MHz single-ended oscillator |
| LEDs | 4 user LEDs |
| Keys | 4 user buttons |
| DIP Switches | 4 DIP switches |

### 1.2 XC7A35T Artix-7 Architecture

- **Speed Grade:** -2 (industrial)
- **Package:** FGG484 (484-pin BGA)
- **Voltage:** 1.0V core (VCCINT), 1.8V/2.5V/3.3V I/O (VCCO)
- **Transceivers:** 4 GTP transceivers (up to 6.6 Gb/s)
- **PCIe:** 1-lane PCIe Gen2 capable
- **XADC:** Built-in analog-to-digital converter (dual 12-bit, 1 MSPS)

---

## 2. Development Environment

### 2.1 Vivado

- **Supported Versions:** Vivado 2017.4 - 2023.2 (HLx Design Edition or WebPack)
- **Project Flow:** RTL project with IP Integrator block designs
- **Synthesis:** Vivado Synthesis (Vivado Synth)
- **Implementation:** Default strategy or performance-optimized
- **Programming:** JTAG via FT232H (USB-to-JTAG)

### 2.2 Hardware Description Languages

#### Verilog / SystemVerilog
- Primary HDL used in all 42 demo projects
- **File extensions:** `.v` (Verilog), `.sv` (SystemVerilog), `.vh` (Verilog header)
- **Total HDL files in repo:** 4,792

#### VHDL
- Supported by Vivado but less common in this repo
- **File extensions:** `.vhd`, `.vhdl`

### 2.3 Constraint Files (XDC)

- **Extension:** `.xdc` (Xilinx Design Constraints)
- **Total in repo:** 479 files
- **Purpose:** Pin assignment, I/O standards, timing constraints, clock definition
- **Key syntax:**
  ```tcl
  # Pin assignment
  set_property PACKAGE_PIN U18 [get_ports clk]
  set_property IOSTANDARD LVCMOS33 [get_ports clk]
  
  # Clock constraint
  create_clock -name clk_in -period 20.0 [get_ports clk]
  
  # False path
  set_false_path -from [get_clocks clk_in] -to [get_clocks clk_out]
  ```

### 2.4 TCL Scripting

- **Total TCL files in repo:** 313
- **Uses:** Project creation, IP generation, build automation, timing closure
- **Block design automation:** `.bd` files with TCL wrappers

---

## 3. Repository Structure

```
AX7035B-learning-materials/
├── 01_demo_document/          # 14,066 files - Demo projects
│   └── demo/                  # 42 FPGA demo projects + resources
│       ├── 01_led_test/       # LED blinking
│       ├── 02_key_test/       # Button input
│       ├── 03_pll_test/       # Clock generation (MMCM/PLL)
│       ├── 04_uart_test/      # UART communication
│       ├── 05_key_debounce/   # Debounce logic
│       ├── 6_i2c_eeprom_test/ # I2C EEPROM read/write
│       ├── 07_rom_test/       # ROM (BRAM) read
│       ├── 08_ram_test/       # RAM (BRAM) read/write
│       ├── 09_fifo_test/      # FIFO (BRAM) data buffer
│       ├── 10_sd_test/         # SD card (SPI mode)
│       ├── 11_1_hdmi_output_test/   # HDMI output
│       ├── 11_2_an430_lcd_test/    # LCD (AN430) display
│       ├── 11_3_an070_lcd_test/    # LCD (AN070) display
│       ├── 11_4_hdmi_loop/          # HDMI loopback
│       ├── 11_5hdmi_input_loopback_ddr/ # HDMI input via DDR3
│       ├── 12_ddr3_test/      # DDR3 (MIG) read/write
│       ├── 13_audio_record_play/ # Audio record/playback
│       ├── 14_sd_card_audio/  # SD card audio player
│       ├── 15_1_hdmi_char/    # HDMI character display
│       ├── 15_2_lcd_an430_char/ # LCD character display
│       ├── 15_3_lcd_an070_char/ # LCD character display
│       ├── 16_1_sd_picture_hdmi/  # SD picture to HDMI
│       ├── 16_2_sd_picture_lcd_an430/ # SD picture to LCD
│       ├── 16_3_sd_picture_lcd_an070/ # SD picture to LCD
│       ├── 17_1_dual_ov5640_an5642_hdmi/ # Dual camera to HDMI
│       ├── 17_2_ddr3_an5642_an430_lcd/  # Camera + DDR3 + LCD
│       ├── 17_3_ddr3_an5642_an070_lcd/  # Camera + DDR3 + LCD
│       ├── 18_ddr3_an5642_hdmi_sobel/   # Camera + DDR3 + HDMI edge detection
│       ├── 19_ad9238_hdmi_test/  # ADC (AD9238) to HDMI
│       ├── 20_ad7606_hdmi_test/  # ADC (AD7606) to HDMI
│       ├── 21_an108_adda_hdmi_test/ # ADC/DAC (AN108) to HDMI
│       ├── 22_ad9767_dual_sin_wave/   # DAC dual sine wave
│       ├── 23_ad9767_dual_trig_wave/  # DAC dual triangle wave
│       ├── 24_smg_interface_demo/    # Seven-segment display
│       ├── 25_temp_lm75_test/        # I2C temperature sensor
│       ├── 26_ethernet_test/         # Ethernet (RGMII) loopback
│       ├── 27_ad9238_ethernet/       # ADC + Ethernet streaming
│       ├── 28_ad7606_ethernet/       # ADC + Ethernet streaming
│       ├── 29_ad9280_ethernet/       # ADC + Ethernet streaming
│       ├── 30_video_ethernet/        # Video + Ethernet streaming
│       ├── 31_USB_speed_test/         # USB 2.0 speed test
│       └── demo_test/                # Board inspection (top.bin)
├── 02_学习教程之语言基础篇/  # Language basics tutorials
├── 03_学习教程之参考篇/     # Reference tutorials
├── 04_原理图PCB结构图/      # Schematics and PCB
├── 05_芯片手册/              # Chip datasheets (47 files)
│   ├── Artix-7/             # 7-series datasheets
│   ├── AD706/               # AD7606 datasheet
│   ├── AD9226/              # AD9226 datasheet
│   ├── AD9238/              # AD9238 datasheet
│   ├── AN9280/              # AD9280 datasheet
│   ├── EEPROM/              # 24LC04 datasheet
│   ├── Ethernet/            # RTL8211D datasheet
│   ├── ft232h/              # FT232H datasheet + drivers
│   ├── POWER/               # Power regulators
│   ├── SD Card/             # SD card specs
│   ├── Sensor/              # LM75A temp sensor
│   ├── UART/                # CP2102 UART
│   └── KSZ9031/             # KSZ9031RNX PHY
├── 06_模块资料/             # Module documentation
├── 07_软件工具及驱动/       # Software tools and drivers
├── 08_其他资料/             # Other materials
├── 09_microblaze/           # MicroBlaze soft processor (144 files)
├── 其它FPGA相关资料/        # Other FPGA materials (339 files)
│   ├── FPGA/               # FPGA textbooks
│   ├── FPGA学习路线/       # FPGA learning roadmap
│   ├── Verilog资料/        # Verilog references
│   ├── 数电资料/            # Digital electronics
│   └── 《电子工程师参考手册》/ # EE reference handbooks
├── AI_REPO_INDEX/           # AI repository navigation index
└── Root files: user manuals, README, top.bin/bit
```

---

## 4. FPGA Design Concepts

### 4.1 Clock Management (MMCM/PLL)

- **Primitive:** MMCME2_BASE / MMCME2_ADV (Artix-7 MMCM)
- **Input clock:** 50 MHz single-ended
- **Common output clocks:**
  - 100 MHz (DDR3 MIG reference)
  - 200 MHz (DDR3 IDELAY reference)
  - 148.5 MHz (HDMI pixel clock)
  - 74.25 MHz (HDMI pixel clock / 2)
  - Custom frequencies via MMCM dividers
- **Demo reference:** `03_pll_test/` — MMCM clock generation example
- **IP Core:** Clocking Wizard (clk_wiz) configured via .xci

#### MMCM Configuration Example
```verilog
// MMCME2_BASE primitive
MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT_F(20.0),   // VCO = 50MHz * 20 = 1000MHz
    .CLKOUT0_DIVIDE_F(10.0),  // 100MHz
    .CLKOUT1_DIVIDE(5),       // 200MHz
    .CLKOUT2_DIVIDE(40),      // 25MHz
    .CLKIN1_PERIOD(20.0)      // 50MHz input
) mmcm_inst (
    .CLKIN1(clk_50m),
    .CLKFBIN(clkfb),
    .CLKOUT0(clk_100m),
    .CLKOUT1(clk_200m),
    .CLKOUT2(clk_25m),
    .CLKFBOUT(clkfb),
    .LOCKED(mmcm_locked),
    .RST(1'b0),
    .PWRDWN(1'b0)
);
```

### 4.2 Clock Domain Crossing (CDC)

- **Techniques used in demos:**
  - **Two-flop synchronizer:** For single-bit control signals
  - **FIFO (BRAM-based):** For multi-bit data between clock domains
  - **Handshake protocol:** Ready/valid handshake for data transfer
- **Key rule:** Never sample multi-bit bus directly across clock domains; use FIFO or Gray-coded pointers
- **Demo reference:** `09_fifo_test/` — CDC FIFO example with independent read/write clocks

#### Two-Flop Synchronizer
```verilog
module sync_2ff (
    input  clk_dst,
    input  rst_n,
    input  signal_src,
    output signal_dst
);
    reg sync1, sync2;
    always @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) begin
            sync1 <= 1'b0;
            sync2 <= 1'b0;
        end else begin
            sync1 <= signal_src;
            sync2 <= sync1;
        end
    end
    assign signal_dst = sync2;
endmodule
```

### 4.3 Reset Strategy

- **Active-low reset** (common in Artix-7 designs)
- **Async assert, sync deassert** pattern:
  ```verilog
  // Async assert, sync deassert reset
  always @(posedge clk or posedge rst_async) begin
      if (rst_async) begin
          rst_sync1 <= 1'b1;
          rst_sync2 <= 1'b1;
      end else begin
          rst_sync1 <= 1'b0;
          rst_sync2 <= rst_sync1;
      end
  end
  assign rst_n = ~rst_sync2;  // Active-low synchronized reset
  ```
- **MMCM locked signal:** Use MMCM `LOCKED` output before releasing reset
- **External reset:** From push button (active-low, needs debouncing)

### 4.4 BRAM (Block RAM)

- **Total:** 50 blocks (900 Kb) in XC7A35T
- **Configurations:** Single-port, dual-port, simple dual-port, true dual-port
- **Width:** 1-72 bits, depth: configurable
- **Initialization:** Via `.coe` files (memory init files)
- **Demo references:**
  - `07_rom_test/` — ROM (BRAM) read-only with .coe initialization
  - `08_ram_test/` — RAM (BRAM) read/write
  - `09_fifo_test/` — FIFO using BRAM

### 4.5 FIFO

- **Implementation:** Xilinx FIFO Generator IP or custom BRAM-based FIFO
- **Use cases:**
  - Clock domain crossing (independent read/write clocks)
  - Data buffering (UART, Ethernet, video)
  - Elastic buffer between producer and consumer
- **Key signals:** `wr_en`, `rd_en`, `full`, `empty`, `almost_full`, `almost_empty`
- **Demo reference:** `09_fifo_test/`

### 4.6 DSP48E1

- **Total slices:** 90 in XC7A35T
- **Features:** 25x18 multiplier, 48-bit accumulator, pre/post adder
- **Use cases:**
  - FIR/IIR filters
  - FFT computation
  - Video processing (Sobel edge detection, color space conversion)
- **Demo reference:** `18_ddr3_an5642_hdmi_sobel/` — Sobel edge detection using DSP

---

## 5. Hardware Peripherals

### 5.1 DDR3 Memory (MIG)

- **Memory:** 1 GiB DDR3 SDRAM (MT41K256M16, 16-bit data bus)
- **IP Core:** MIG 7 Series (Memory Interface Generator)
- **Interface:** AXI4 (for MicroBlaze) or User Interface (for custom logic)
- **Clock:** 200 MHz reference → 400 MHz DDR3 clock (800 MT/s)
- **Demo references:**
  - `12_ddr3_test/` — Basic DDR3 read/write test
  - `11_5hdmi_input_loopback_ddr/` — HDMI input buffered via DDR3
  - `16_*/` — SD picture display through DDR3 frame buffer
  - `17_*/` — Camera capture through DDR3
  - `18_ddr3_an5642_hdmi_sobel/` — Video processing pipeline with DDR3

#### DDR3 MIG Key Ports
```verilog
// User interface (simplified)
mig_user_interface #(
    .C3_MEMCLK_PERIOD(3000),   // 3000ps = 333MHz
    .C3_RST_ACT_LOW(1),        // Active-low reset
    .C3_CALIB_SOFT_IP("FALSE")
) ddr3_inst (
    .c3_sys_clk(sys_clk_200m),     // 200MHz reference
    .c3_sys_rst(rst_n),
    .c3_calib_done(calib_done),    // Calibration complete
    .c3_pcie_clk(pcie_clk),
    // User interface
    .c3_p0_cmd_clk(user_clk),
    .c3_p0_cmd_en(cmd_en),
    .c3_p0_cmd_instr(cmd_instr),
    .c3_p0_cmd_bl(cmd_bl),
    .c3_p0_cmd_byte_addr(cmd_addr),
    .c3_p0_wr_data(wr_data),
    .c3_p0_wr_en(wr_en),
    .c3_p0_rd_data(rd_data),
    .c3_p0_rd_en(rd_en),
    // Physical DDR3 pins
    .ddr3_dq(ddr3_dq),
    .ddr3_dqs_n(ddr3_dqs_n),
    .ddr3_dqs_p(ddr3_dqs_p),
    .ddr3_addr(ddr3_addr),
    .ddr3_ba(ddr3_ba),
    .ddr3_ras_n(ddr3_ras_n),
    .ddr3_cas_n(ddr3_cas_n),
    .ddr3_we_n(ddr3_we_n),
    .ddr3_reset_n(ddr3_reset_n),
    .ddr3_ck_p(ddr3_ck_p),
    .ddr3_ck_n(ddr3_ck_n),
    .ddr3_cke(ddr3_cke),
    .ddr3_dm(ddr3_dm),
    .ddr3_odt(ddr3_odt)
);
```

### 5.2 HDMI

- **Hardware:** HDMI input (DVI receiver) + HDMI output (DVI transmitter)
- **Standard:** DVI/HDMI 1.4 (TMDS)
- **Clock:** Pixel clock 25-165 MHz (1080p @ 148.5 MHz)
- **Data:** 3 TMDS data channels (R, G, B) + 1 TMDS clock channel
- **Color depth:** 8-bit per channel (24-bit RGB)
- **Demo references:**
  - `11_1_hdmi_output_test/` — Basic HDMI output (color bar)
  - `11_4_hdmi_loop/` — HDMI loopback (input to output)
  - `11_5hdmi_input_loopback_ddr/` — HDMI input via DDR3 frame buffer
  - `15_1_hdmi_char/` — HDMI character overlay
  - `16_1_sd_picture_hdmi/` — SD card image to HDMI display
  - `17_1_dual_ov5640_an5642_hdmi/` — Camera to HDMI
  - `19_ad9238_hdmi_test/` — ADC waveform to HDMI
  - `30_video_ethernet/` — Video streaming over Ethernet

#### HDMI Output (TMDS Encoder)
```verilog
// TMDS encoding (simplified DVI)
tmds_encoder tmds_r (
    .clk(clk_pixel),
    .rst_n(rst_n),
    .de(data_enable),      // Data enable
    .ctrl({1'b0, 1'b0}),   // Control bits
    .din(red_8bit),         // 8-bit color data
    .dout(tmds_r_data)     // 10-bit encoded data
);
```

### 5.3 Ethernet (RGMII)

- **PHY:** RTL8211D (Gigabit Ethernet PHY) + KSZ9031RNX
- **Interface:** RGMII (Reduced Gigabit Media Independent Interface)
- **Speed:** 10/100/1000 Mbps
- **Clock:** 125 MHz (Gigabit), 2.5 MHz (10Mbps), 25 MHz (100Mbps)
- **Demo references:**
  - `26_ethernet_test/` — Ethernet loopback test (1553 files)
  - `27_ad9238_ethernet/` — ADC data over Ethernet
  - `28_ad7606_ethernet/` — ADC data over Ethernet
  - `29_ad9280_ethernet/` — ADC data over Ethernet
  - `30_video_ethernet/` — Video streaming over Ethernet

### 5.4 USB

- **Hardware:**
  - FT232H (USB-to-JTAG/SPI/I2C/UART — programming interface)
  - CY7C68013A (USB 2.0 high-speed — 480 Mbps data transfer)
- **Demo reference:** `31_USB_speed_test/` — USB 2.0 speed test (624 files)
- **FT232H also used as:** JTAG programmer for Vivado

### 5.5 UART

- **Standard:** RS-232 / TTL UART
- **Config:** 115200 baud (typical), 8 data bits, no parity, 1 stop bit
- **PHY:** CP2102 (USB-to-UART bridge)
- **Demo reference:** `04_uart_test/` — UART loopback/echo test
- **Protocol:** Standard UART frame (start bit, data, stop bit)

#### UART Transmitter
```verilog
module uart_tx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115200
) (
    input  clk,
    input  rst_n,
    input  [7:0] tx_data,
    input  tx_start,
    output tx_done,
    output tx_pin
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    // State machine: IDLE → START → DATA → STOP → DONE
    // ...
endmodule
```

### 5.6 SD Card

- **Interface:** SPI mode (4-wire SPI)
- **Capacity:** SD/SDHC (up to 32 GB)
- **File system:** FAT32 (raw block read in FPGA)
- **Demo references:**
  - `10_sd_test/` — SD card read/write test (199 files)
  - `14_sd_card_audio/` — SD card audio playback
  - `16_1_sd_picture_hdmi/` — SD card image display
  - `16_2_sd_picture_lcd_an430/` — SD card image to LCD
  - `16_3_sd_picture_lcd_an070/` — SD card image to LCD

### 5.7 Camera (OV5640/AN5642)

- **Camera module:** OV5640 (5MP CMOS) via AN5642 module (dual camera)
- **Interface:** DVP (8-bit parallel) or MIPI CSI-2
- **Resolution:** Up to 2592x1944 (5MP), commonly 1280x720 or 1920x1080
- **Format:** RAW RGB, YUV422, RGB565
- **Configuration:** SCCB (I2C-like) register programming
- **Demo references:**
  - `17_1_dual_ov5640_an5642_hdmi/` — Dual camera to HDMI
  - `17_2_ddr3_an5642_an430_lcd/` — Camera + DDR3 + LCD
  - `17_3_ddr3_an5642_an070_lcd/` — Camera + DDR3 + LCD
  - `18_ddr3_an5642_hdmi_sobel/` — Camera + edge detection + HDMI

### 5.8 ADC/DAC

| Chip | Resolution | Channels | Max Rate | Interface | Demos |
|------|-----------|-----------|----------|-----------|-------|
| AD9238 | 12-bit | 2 | 20-40 MSPS | Parallel LVCMOS | 19_ad9238_hdmi, 27_ad9238_ethernet |
| AD7606 | 16-bit | 8 | 200 kSPS | Parallel | 20_ad7606_hdmi, 28_ad7606_ethernet |
| AD9280 | 8-bit | 1 | 32 MSPS | Parallel | 29_ad9280_ethernet |
| AD9767 | 14-bit | 2 | 125 MSPS | Parallel | 22_ad9767_dual_sin, 23_ad9767_dual_trig |
| AN108 | 8-bit | 1 ADC + 1 DAC | 32 MSPS | Parallel | 21_an108_adda_hdmi |

#### ADC Interface Pattern
```verilog
// Generic ADC data capture
module adc_capture (
    input  adc_clk,        // ADC clock
    input  [11:0] adc_d, // ADC data (12-bit for AD9238)
    input  adc_ocds,      // Out-of-range indicator
    output reg [11:0] data_out,
    output reg data_valid
);
    always @(posedge adc_clk) begin
        data_out <= adc_d;
        data_valid <= 1'b1;
    end
endmodule
```

### 5.9 I2C Peripherals

#### EEPROM (24LC04)
- **Address:** 0x50 (7-bit I2C address)
- **Capacity:** 4 Kbit (512 bytes)
- **Demo:** `6_i2c_eeprom_test/`

#### Temperature Sensor (LM75A)
- **Address:** 0x48 (7-bit I2C address)
- **Resolution:** 0.125°C (9-12 bit)
- **Demo:** `25_temp_lm75_test/`

---

## 6. Debug Tools

### 6.1 ILA (Integrated Logic Analyzer)

- **Purpose:** In-circuit signal capture and analysis
- **IP Core:** ILA v3.x (debug IP)
- **Usage:** Insert `mark_debug` attribute on signals, then auto-insert ILA
- **Connection:** JTAG via FT232H
- **Features:**
  - Trigger on signal value/edge
  - Multi-window waveform display
  - Up to 1024 samples depth
  - Multiple probe ports

#### ILA Usage
```verilog
// Mark signal for debug
(* mark_debug = "true" *) wire [7:0] debug_data;
(* mark_debug = "true" *) wire debug_valid;

// In XDC:
# set_property C_CLK_INPUT_FREQ_HZ 50000000 [get_debug_cores ub_la]
```

### 6.2 VIO (Virtual Input/Output)

- **Purpose:** Runtime signal control and monitoring without physical I/O
- **IP Core:** VIO v3.x
- **Usage:** Set/reset output signals, monitor input signals via JTAG
- **Features:**
  - Virtual LEDs and switches
  - Real-time signal value display
  - No physical pin occupation

#### VIO Usage
```verilog
// VIO instance
vio_inst (
    .clk(clk),
    .probe_in_0(status_reg),    // Input probe (read-only)
    .probe_out_0(control_reg)   // Output probe (write)
);
```

---

## 7. MicroBlaze Soft Processor

### 7.1 Overview

- **Architecture:** 32-bit RISC soft processor (Xilinx MicroBlaze)
- **Clock:** Typically 100 MHz (from MMCM)
- **Pipeline:** 3-stage or 5-stage configurable
- **Instruction Set:** MicroBlaze ISA (BARREL_SHIFT, DIV, FPU optional)
- **Debugger:** Xilinx SDK / Vitis (GDB over JTAG)

### 7.2 AXI Interface

- **AXI4:** Memory-mapped for DDR3 access
- **AXI4-Lite:** Register interface for peripherals
- **AXI4-Stream:** Data streaming for video/audio
- **Bus width:** 32-bit (default), 64-bit (optional)

### 7.3 Peripheral Configuration (Typical)

| Peripheral | AXI Interface | Base Address | Notes |
|-----------|-------------|-------------|-------|
| DDR3 MIG | AXI4 | 0x40000000 | 1 GiB range |
| AXI UART | AXI4-Lite | 0x40600000 | 115200 baud |
| AXI GPIO | AXI4-Lite | 0x40000000 | LED/key control |
| AXI BRAM | AXI4 | 0x40000000 | Block RAM controller |
| AXI INTC | AXI4-Lite | 0x41200000 | Interrupt controller |
| AXI Timer | AXI4-Lite | 0x41C00000 | PWM/timing |

### 7.4 Repository Location

- **Directory:** `09_microblaze/` (144 files)
- **Contents:** BSP source, application C code, block designs, project files
- **Key file types:** `.c` (C source), `.h` (headers), `.tcl` (build scripts), `.bd` (block designs)

### 7.5 C Programming Pattern

```c
// MicroBlaze UART echo example
#include "xparameters.h"
#include "xuartlite.h"

#define UART_BASEADDR XPAR_UARTLITE_0_BASEADDR

int main() {
    u8 recv_buffer;
    
    // Initialize UART
    XUartLite uart;
    XUartLite_Initialize(&uart, XPAR_UARTLITE_0_DEVICE_ID);
    
    while (1) {
        // Read byte
        XUartLite_Recv(&uart, &recv_buffer, 1);
        // Echo back
        XUartLite_Send(&uart, &recv_buffer, 1);
    }
    return 0;
}
```

---

## 8. Demo Project Quick Reference

### 8.1 Learning Path (Recommended Order)

| # | Demo | Topics | Complexity |
|---|------|--------|------------|
| 1 | 01_led_test | GPIO output, basic Verilog | Beginner |
| 2 | 02_key_test | GPIO input, push button | Beginner |
| 3 | 03_pll_test | MMCM/PLL, clock generation | Beginner |
| 4 | 04_uart_test | UART protocol, serial communication | Beginner |
| 5 | 05_key_debounce | Debounce, shift register | Beginner |
| 6 | 6_i2c_eeprom_test | I2C protocol, EEPROM | Beginner |
| 7 | 07_rom_test | BRAM as ROM, .coe files | Beginner |
| 8 | 08_ram_test | BRAM as RAM, dual-port | Beginner |
| 9 | 09_fifo_test | FIFO, clock domain crossing | Intermediate |
| 10 | 10_sd_test | SD card, SPI protocol, FAT | Intermediate |
| 11 | 11_1_hdmi_output_test | TMDS, DVI/HDMI output | Intermediate |
| 12 | 12_ddr3_test | MIG, DDR3 interface | Intermediate |
| 13 | 13_audio_record_play | Audio codec, I2S | Intermediate |
| 14 | 16_1_sd_picture_hdmi | DDR3 frame buffer, image display | Advanced |
| 15 | 17_1_dual_ov5640_an5642_hdmi | Camera capture, video pipeline | Advanced |
| 16 | 18_ddr3_an5642_hdmi_sobel | DSP, image processing, video | Advanced |
| 17 | 26_ethernet_test | RGMII, MAC, network stack | Advanced |
| 18 | 31_USB_speed_test | USB 2.0, FIFO, high-speed data | Advanced |

### 8.2 IP Core Summary (175 total)

Common IP cores used across demos:
- **Clocking Wizard** (clk_wiz) — MMCM/PLL configuration
- **FIFO Generator** — Clock domain crossing, data buffering
- **BRAM Generator** — ROM/RAM storage
- **MIG 7 Series** — DDR3 memory controller
- **ILA** — Debug capture
- **VIO** — Virtual I/O debug
- **DDR3 MIG** — Memory interface
- **AXI DMA** — DMA controller (MicroBlaze)
- **AXI UART** — Serial communication (MicroBlaze)
- **AXI GPIO** — GPIO control (MicroBlaze)
- **AXI Interrupt Controller** — Interrupt handling (MicroBlaze)

### 8.3 File Statistics

| Category | Count | Notes |
|----------|-------|-------|
| HDL Source (.v/.sv/.vhd) | 4,792 | Verilog + SystemVerilog + VHDL |
| Constraint Files (.xdc) | 479 | Pin assignments, timing |
| Vivado Projects (.xpr) | 41 | One per demo (excl. demo_test) |
| IP Cores (.xci) | 175 | Configured IP instances |
| TCL Scripts (.tcl) | 313 | Build automation, IP config |
| C/C++ Source (.c/.h) | 134 | MicroBlaze software |
| Memory Init (.coe/.mif) | 117 | ROM/RAM initialization |
| PDF Documents | 183 | Datasheets, tutorials, manuals |
| Block Designs (.bd) | varies | IP Integrator designs |
| Bitstream (.bin/.bit) | 21 | Compiled FPGA images |

---

## 9. Vivado Project Workflow

### 9.1 Opening a Demo Project

1. Locate `.xpr` file in the demo directory (e.g., `01_demo_document/demo/01_led_test/led_test.xpr`)
2. Open Vivado → File → Open Project → select .xpr
3. Wait for Vivado to load IP cores and block designs
4. Run synthesis → implementation → bitstream generation
5. Program FPGA via JTAG (FT232H)

### 9.2 Creating a New Project

```tcl
# create_project.tcl
create_project my_project ./my_project -part xc7a35t-2fgg484i -force
set_property target_language Verilog [current_project]
set_property simulator_language Verilog [current_project]

# Add source files
add_files -norecurse {src/top.v src/module1.v}
add_files -norecurse {constraints/pins.xdc}

# Set top module
set_property top top [current_fileset]

# Create bitstream
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
```

### 9.3 Common XDC Patterns

```tcl
# 50MHz clock input
set_property PACKAGE_PIN R4 [get_ports sys_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports sys_clk_p]
create_clock -period 20.000 [get_ports sys_clk_p]

# LED outputs
set_property PACKAGE_PIN R2 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[0]}]

# Push button (active-low)
set_property PACKAGE_PIN N4 [get_ports {key[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {key[0]}]
set_property PULLDOWN true [get_ports {key[0]}]

# UART pins
set_property PACKAGE_PIN R6 [get_ports uart_rx]
set_property PACKAGE_PIN R7 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS15 [get_ports {uart_rx,uart_tx}]

# Timing constraints
set_max_delay 20.000 [get_paths -from [get_clocks clk_in] -to [get_clocks clk_out]]
set_false_path -from [get_clocks clk_in] -to [get_clocks clk_out]
```

---

## 10. Repository Navigation Guide

### 10.1 Finding Content

| Need | Location |
|------|----------|
| Demo project source code | `01_demo_document/demo/<project_name>/` |
| Chip datasheet | `05_芯片手册/<chip_name>/` |
| Schematic | `04_原理图PCB结构图/` |
| MicroBlaze code | `09_microblaze/` |
| FPGA textbooks | `其它FPGA相关资料/` |
| User manual | Root: `AX7035开发板用户手册REV1.1.pdf` |
| Board test guide | Root: `AX7035开发板检测指南V2.0.pdf` |
| Demo-to-tutorial mapping | Root: `AX7035开发板教程与程序对应关系说明.pdf` |
| Full file index | `AI_REPO_INDEX/REPO_FILES.tsv` |
| Project list | `AI_REPO_INDEX/FPGA_PROJECTS.txt` |
| HDL top modules | `AI_REPO_INDEX/HDL_TOP_MODULES.txt` |
| Constraint files | `AI_REPO_INDEX/CONSTRAINT_FILES.txt` |
| IP cores | `AI_REPO_INDEX/IP_CORES.txt` |

### 10.2 AI_REPO_INDEX Usage

The `AI_REPO_INDEX/` directory contains machine-readable index files:

- **REPO_FILES.tsv** — Full file catalog with path, extension, size, category
- **EXPERIMENTS.txt** — Demo project listing with HDL/XDC/XPR/XCI/TCL counts
- **FPGA_PROJECTS.txt** — All 41 Vivado project file paths
- **HDL_TOP_MODULES.txt** — 172 top-level HDL module files
- **CONSTRAINT_FILES.txt** — 479 constraint file paths
- **IP_CORES.txt** — 175 IP core configuration paths
- **MICROBLAZE_PROJECTS.txt** — MicroBlaze project breakdown

---

## 11. Common Pitfalls and Solutions

### 11.1 Clock Domain Crossing Issues

- **Problem:** Random data corruption across clock domains
- **Cause:** Multi-bit bus sampled directly in different clock domain
- **Solution:** Use FIFO with independent read/write clocks (BRAM-based)

### 11.2 DDR3 Calibration Failure

- **Problem:** MIG calibration never completes
- **Cause:** Incorrect clock frequencies, poor PCB signal integrity
- **Solution:**
  - Verify 200 MHz reference clock
  - Check IDELAYCTRL is instantiated
  - Ensure proper VCCO voltage (1.5V for DDR3)
  - Review MIG pin assignments against schematic

### 11.3 HDMI Display Issues

- **Problem:** No display or garbage on screen
- **Cause:** Wrong pixel clock, incorrect TMDS encoding, DE signal issues
- **Solution:**
  - Verify pixel clock frequency matches resolution
  - Check Data Enable (DE) signal timing
  - Ensure TMDS encoding is correct (DVI 8b/10b)
  - Verify color depth and format (RGB888 or YCbCr422)

### 11.4 Timing Closure

- **Problem:** Timing not met after implementation
- **Solution:**
  - Add proper timing constraints in XDC
  - Pipeline combinational logic paths
  - Use registered I/O
  - Enable retiming (enable_pipeline for DSP)
  - Reduce fanout on critical paths
  - Consider different optimization strategies

### 11.5 Long Path Issues (Windows)

- **Problem:** Vivado project extraction fails on Windows
- **Cause:** Path length exceeds Windows MAX_PATH (260 characters)
- **Solution:**
  - Enable Windows long path support (registry: LongPathsEnabled=1)
  - Use `\\?\` prefix for file operations
  - Keep project directory close to drive root
  - Use PowerShell `Remove-Item` with `-LiteralPath` for deletion

---

## 12. Quick Reference Card

### Board Pin Assignments (Key Signals)

| Signal | FPGA Pin | IOSTANDARD | Notes |
|--------|----------|------------|-------|
| Clock 50MHz | R4 | LVDS_25 | Differential, positive |
| LED[3:0] | R2/V2/Y2/T2 | LVCMOS15 | Active-high |
| Key[3:0] | N4/P4/U6/U7 | LVCMOS15 | Active-low |
| UART TX | R7 | LVCMOS15 | To CP2102 |
| UART RX | R6 | LVCMOS15 | From CP2102 |
| DDR3 DQ[15:0] | Multiple | SSTL15 | 1.5V |
| HDMI CLK+ | Multiple | TMDS_33 | 3.3V |
| Ethernet TX/RX | Multiple | LVCMOS25 | 2.5V |

### Vivado Keyboard Shortcuts

| Action | Shortcut |
|--------|---------|
| Open project | Ctrl+O |
| Run synthesis | F11 |
| Run implementation | F12 |
| Generate bitstream | Shift+F12 |
| Open synthesized design | F4 |
| Open implemented design | F5 |
| Tcl Console | Ctrl+Shift+T |
| Find | Ctrl+F |

### Common Baud Rates

| Baud | Clock Divider (50 MHz) | Error |
|------|----------------------|-------|
| 9600 | 5208 | 0.03% |
| 19200 | 2604 | 0.16% |
| 38400 | 1302 | 0.16% |
| 57600 | 868 | 0.08% |
| 115200 | 434 | 0.16% |

---

*This knowledge base is generated from the AX7035B-learning-materials GitHub repository. For the complete file index, see `AI_REPO_INDEX/`. For specific demo details, open the corresponding `.xpr` file in Vivado.*
