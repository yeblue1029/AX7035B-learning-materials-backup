# AX7035B Learning Skill

## Installation

This skill is located at:
```
.trae/skills/ax7035b-learning/SKILL.md
```

It is automatically available when working in this repository with TRAE.

## How to Trigger

In TRAE, use phrases like:
- "使用 ax7035b-learning skill，带我学习 01_led_test。"
- "使用 ax7035b-learning skill，分析 DDR3 Demo 的数据流。"
- "使用 ax7035b-learning skill，根据仓库现有 Ethernet Demo 帮我解释 RGMII。"

## How to Manually Invoke

Read `SKILL.md` and follow the evidence-first workflow.

## How to Regenerate AI_REPO_INDEX

```
.trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.cmd
```

Or directly:
```
powershell -File .trae/skills/ax7035b-learning/GENERATE_REPO_INDEX.ps1
```

## How to Update the Skill

1. Edit `SKILL.md` — the canonical skill file
2. Update `SOURCE_MAP.md` if new topics/demos are added
3. Update `CHANGELOG.md` with what changed
4. Regenerate `AI_REPO_INDEX/` using the generator script
5. Commit changes

## How to Verify

1. Run the index generator twice — output must be deterministic
2. Check that `INDEX_SUMMARY.md` counts match actual repository
3. Verify `EXPERIMENTS.txt` has no loose assets (BMP/WAV)
4. Verify `REPO_DIRS.txt` contains directories only
5. Verify hardware facts in `58_SKILL_V2_FACT_CHECK.tsv` have evidence paths

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Canonical skill file (YAML frontmatter + workflow) |
| `README.md` | This file |
| `PROMPT.md` | General AI prompt for use with any AI tool |
| `PROMPT_可直接复制.txt` | Short copy-paste prompt |
| `SOURCE_MAP.md` | Topic-to-resource mapping |
| `CHANGELOG.md` | Version history |
| `GENERATE_REPO_INDEX.ps1` | Index generator (PowerShell) |
| `GENERATE_REPO_INDEX.cmd` | Index generator (CMD wrapper) |
