# Repository Guidelines

## Project Structure & Module Organization
This repository is a delivery-and-evidence workspace for the DC PSV converter simulation.
- `docs/`: project intent and execution evidence (`project-spec.md`, `progress.md`, `findings.md`).
- `data/`: simulation outputs only (CSV waveforms and PNG plots, e.g., `mode1_cruise_low.csv`, `mode1_cruise_low.png`).
- `models/`: delivered Simulink model (`dc_psv_system.slx`).
- `scripts/`: model build/run/export automation.
- `tests/`: structure and acceptance tests (`run_all_tests.m` entry).
- `utils/`: operating-mode and fault configuration helpers.
- `客户具体详细要求.rtf`: original client requirement source.

Keep root clean: active files in root, old drafts moved to `archive/` when present.

## Build, Test, and Development Commands
Use these checks before committing model/data/docs updates:
- `rg --files` — quick inventory of repository contents.
- `ls data/*.csv data/*.png` — verify required artifacts exist.
- `head -n 5 data/summary_results.csv` — sanity-check summary output format.
- `wc -l docs/*.md` — monitor document growth and keep records concise.
- `/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "run('tests/run_all_tests.m'); run_all_tests;"` — mandatory verification gate.
- `/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "addpath('scripts'); run_all_cases;"` — refresh all mode/fault outputs.

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
Follow Conventional Commits:
- `docs: refine voltage-stability acceptance criteria`
- `data: refresh WC4 waveform outputs`
- `feat: rebuild simulink layered topology for dc bus`

PRs should include:
- scope summary (what changed and why),
- affected files/paths,
- validation evidence (commands + key output),
- screenshots for plot changes when relevant.

## Project Rules (System Prompt Additions)
1. Delivery boundary: deliver a credible layered Simulink model matching `docs/project-spec.md`; do not stop at quick behavior-only prototypes.
2. Topology gate: top level must contain `Control_Subsystem`, `Generation_Subsystem`, `DC_Bus_Subsystem`, `Load_Subsystem`, `Fault_Subsystem`, `GroundMonitor_Subsystem`; generation keeps 4 `DG*_Branch`, load keeps at least 8 `*_Branch`.
3. Modeling rule: main electrical chain uses Simulink/Simscape block topology; `MATLAB Function` is not allowed as a core-path shortcut.
4. TDD + verification rule: code/model changes follow RED→GREEN; no completion claim without fresh `run_all_tests` output evidence.
5. Debugging lessons: convert comparator boolean outputs to `double` before weighted sums; avoid concurrent MATLAB writes to the same `.slx`; auto-rebuild model when builder script is newer.
6. Data rule: case outputs must remain paired (`CSV` + `PNG`) and `data/summary_results.csv` is the baseline KPI ledger for each stage.
7. GitHub collaboration rule: run preflight (`gh auth status`, `git rev-parse --is-inside-work-tree`, `git remote -v`) before remote ops; use `1 issue = 1 branch = 1 PR` with evidence-backed PRs.
8. Hygiene + records rule: remove generated `slprj/slxc/temp/debug` artifacts after verification; keep `docs/progress.md` and `docs/findings.md` compressed to key conclusions + evidence index.
