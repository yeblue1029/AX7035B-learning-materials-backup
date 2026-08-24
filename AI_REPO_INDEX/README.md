# AI_REPO_INDEX

**AI_REPO_INDEX is a navigation layer, not the source of truth.**

## Purpose

This directory contains a machine-readable index of the repository's tracked
source files. It helps AI assistants (and humans) navigate the repository
without scanning every file.

## Important Rule

`
Index entry != authoritative hardware fact
`

The index tells you WHERE to find information.
The actual hardware facts come from:

1. Board manuals, schematics, and PCB layout files in the repository
2. AMD/Xilinx official device documentation
3. Actual Vivado project files (XPR, XDC, XCI, BD)
4. Actual HDL source code (Verilog, VHDL)
5. Chip datasheets

## How to Use

1. Use REPO_DIRS.txt to find directories
2. Use REPO_FILES.tsv to find specific files
3. Use EXPERIMENTS.txt to find demo projects
4. Use FPGA_PROJECTS.txt to find Vivado projects
5. Use HDL_TOP_MODULES.txt to find top modules
6. Use CONSTRAINT_FILES.txt to find constraints
7. Use IP_CORES.txt to find IP configurations
8. Use MICROBLAZE_PROJECTS.txt to find MicroBlaze content
9. Use IMPORTANT_FILES.txt to find key learning resources
10. Always open the actual file to verify facts

## Regenerating

Run the generator script:

`
.trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.cmd
`

Or directly:

`
powershell -File .trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.ps1
`

## IndexedSourceCommit

See REPO_REVISION.txt for the commit SHA this index was generated from.
