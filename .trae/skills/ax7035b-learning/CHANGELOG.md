# Skill Changelog

## v2 (2026-08-24) — Phase 3

### Fixed
- DDR3 capacity/model: Corrected to verify from XCI/XDC and board manual instead of hardcoding
- XC7A35T BRAM: Removed hardcoded 900 Kb, now directs to verify from device documentation
- Ethernet PHY: Removed hardcoded model, now directs to board manual/schematic
- USB/UART/JTAG: Separated into distinct interfaces, removed conflation
- HDMI architecture: Clarified as direct TMDS connection to FPGA, not via external chip
- GTP board availability: Added device-vs-board distinction
- MIG interface guidance: Corrected from Spartan-6 c3_p0_* to 7-Series app_* interface

### Added
- Evidence-first workflow (locate → verify → answer)
- Device vs Board distinction section
- Evidence priority hierarchy (7 levels)
- Repository navigation workflow
- Demo learning workflow with difficulty ordering
- Code generation rules (reuse from existing demos)
- Debug workflow (14-step systematic)
- MicroBlaze coverage
- Output evidence path requirements
- Topic-to-demo map for quick navigation
- Deterministic index generator (GENERATE_REPO_INDEX.ps1)

### Changed
- Moved canonical skill from `AX7035B_AI_Skill.md` to `.trae/skills/ax7035b-learning/SKILL.md`
- Rebuilt `AI_REPO_INDEX` from clean source tree (v2)
- `AX7035B_AI_Skill.md` replaced with compatibility pointer
- Index now excludes AI artifacts from source corpus
- Index uses `**/*.runs/` glob patterns in .gitignore

### Removed
- Vivado generated build artifacts (*.runs, *.cache, *.hw, *.sim, *.gen, ip_user_files) — 9504 files
- Hardcoded pin tables (replaced with "check the XDC" guidance)
- Mixed device/board capability claims
- Legacy Spartan-6 MIG interface as standard

## v1 (Phase 2) — Initial

- Created `AX7035B_AI_Skill.md` (846 lines)
- Created `AI_REPO_INDEX/` v1 (had directory/file counting errors)
- Issues: hardcoded hardware facts, mixed device/board capabilities, included generated artifacts
