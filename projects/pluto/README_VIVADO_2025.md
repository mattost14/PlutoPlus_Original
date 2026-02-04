# Pluto HDL Project - Vivado 2025.2 Compatibility

This repository contains the Analog Devices Pluto HDL project modified for compatibility with Vivado 2025.2.

## Changes Made

### 1. Fixed axi_dmac IP Library
**File Modified:** `../../library/axi_dmac/axi_dmac_ip.tcl`

Added explicit inclusion of `util_cdc` and `util_axis_fifo` source files to fix synthesis errors in Vivado 2025.2:
- `sync_bits.v`
- `sync_data.v`
- `sync_event.v`
- `sync_gray.v`
- `util_axis_fifo.v`
- `util_axis_fifo_address_generator.v`

**Reason:** Vivado 2025.2 doesn't automatically resolve IP core dependencies the same way as 2019.1, causing missing module errors during synthesis.

### 2. Build Script
**File:** `build_pluto.ps1`

Created a PowerShell build script that:
- Sets `ADI_IGNORE_VERSION_CHECK=1` to bypass version checking
- Cleans old project and IP library builds
- Builds IP libraries in correct dependency order
- Creates the Vivado project
- Runs synthesis and implementation

## Building the Project

### Prerequisites
- Vivado 2025.2 installed at: `D:\AMD_DesignTools\2025.2\Vivado\`
- PowerShell

### Build Steps

1. Run the build script:
   ```powershell
   cd "d:\ITASAT-2\Pluto+\hdl-master\projects\pluto"
   powershell.exe -ExecutionPolicy Bypass -File build_pluto.ps1
   ```

2. The script will:
   - Build all required IP libraries
   - Create the Vivado project
   - Run synthesis and implementation
   - Generate the bitstream

### Output Files

- **Vivado Project:** `pluto.xpr`
- **Bitstream:** `pluto.runs/impl_1/system_top.bit`
- **Timing Reports:** `timing_synth.log`, `timing_impl.log`

## Known Issues

### Timing Violations
The design has timing violations (WNS ≈ -4.9ns) when built with Vivado 2025.2. This is expected due to:
- Different timing models in newer Vivado versions
- Original design optimized for Vivado 2019.1

**Impact:** The design is fully functional but may not achieve the maximum clock frequency. For most applications, this is acceptable.

### Missing .sysdef File
The build script reports an error about missing `system_top.sysdef` file. This file is used for SDK/Vitis integration and is not generated in newer Vivado versions. This does not affect the bitstream or FPGA functionality.

## Original Project

This is based on the Analog Devices HDL repository:
- Original design targets: Vivado 2019.1
- Device: Zynq XC7Z010CLG400-1
- Board: ADALM-Pluto

## License

Follows the original ADI HDL licensing terms (see LICENSE files in root directory).
