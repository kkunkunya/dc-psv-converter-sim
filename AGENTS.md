# Repository Guidelines

## Project Structure & Module Organization
This repository is a delivery-and-evidence workspace for the DC PSV converter simulation.
- `docs/`: project intent and execution evidence (`project-spec.md`, `progress.md`, `findings.md`).
- `data/`: simulation outputs only (CSV waveforms and PNG plots, e.g., `mode1_cruise_low.csv`, `mode1_cruise_low.png`).
- `客户具体详细要求.rtf`: original client requirement source.

Keep root clean: active files in root, old drafts moved to `archive/` when present.

## Build, Test, and Development Commands
There is no local build pipeline in this snapshot (no source scripts checked in). Use these checks before committing data/docs updates:
- `rg --files` — quick inventory of repository contents.
- `ls data/*.csv data/*.png` — verify required artifacts exist.
- `head -n 5 data/summary_results.csv` — sanity-check summary output format.
- `wc -l docs/*.md` — monitor document growth and keep records concise.

## Coding Style & Naming Conventions
For new files and updates:
- Use descriptive names: `主题_用途` (example: `工况对比_结果汇总.csv`).
- Avoid meaningless suffixes like `v1`, `final2`, `最新版`.
- Prefer Markdown for records and CSV/PNG for outputs.
- Keep text concise, evidence-first, and directly actionable.

## Testing Guidelines
Validation in this repository is artifact-based:
- Every new result should include both numeric data (`.csv`) and visual evidence (`.png`).
- Keep paired naming for traceability (same prefix for CSV/PNG).
- Update `docs/progress.md` with command evidence and observed outcomes.
- Record root-cause and decisions in `docs/findings.md` when fixing anomalies.

## Commit & Pull Request Guidelines
This folder is currently not initialized as a Git repository, so no historical commit convention is available yet.
When Git is enabled, follow Conventional Commits:
- `docs: refine voltage-stability acceptance criteria`
- `data: refresh WC4 waveform outputs`

PRs should include:
- scope summary (what changed and why),
- affected files/paths,
- validation evidence (commands + key output),
- screenshots for plot changes when relevant.
