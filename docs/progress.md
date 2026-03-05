# 项目进度记录（压缩版）

**项目**: 直流平台供应船变流器系统建模与仿真  
**更新时间**: 2026-03-05

## 1) 当前阶段结论

- 阶段：`分层模型验收强化（本轮完成）`
- 结果：保留了用户手工删线基线，完成四工况稳态 + WC2→WC4 过渡 + 故障验收增强。
- 状态：强制验证命令全部通过，数据产物已刷新。

## 2) 本轮关键证据

### A. 基线锁定
- 初始检查：`git status --short` 仅有 `M models/dc_psv_system.slx`。
- 基线提交：`b56f9ea chore: preserve manual line cleanup baseline`。

### B. TDD（RED → GREEN）
- RED 命令：`/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "run('tests/run_all_tests.m'); run_all_tests;"`
- RED 输出：`Error using assert ... dangling line detected ...`（`test_model_structure`）。
- GREEN 同命令输出：`ALL_TESTS_PASSED`。

### C. 强制仿真刷新
- 执行：`/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "addpath('scripts'); run_all_cases;"`
- 结果：`data/mode*.csv/png`、`data/fault*.csv/png`、`data/summary_results.csv` 全部更新。

### D. 关键指标（复现实测）
- `MODE1_STEADY mean=1505.247 std=0.155 min=1504.983 max=1505.520`
- `MODE2_STEADY mean=1497.972 std=0.070 min=1497.850 max=1498.092`
- `MODE3_STEADY mean=1498.153 std=0.065 min=1498.037 max=1498.263`
- `MODE4_STEADY mean=1497.890 std=0.073 min=1497.762 max=1498.015`
- `TRANSIENT_WC2_TO_WC4_RECOVERY_S=0.0000`
- `FAULT_BUS_SHORT_MIN_VDC=731.464`
- `FAULT_POS_GROUND_VPOS_ABS_MAX=0.000`
- `FAULT_POS_GROUND_VNEG_MEAN=-1506.039`

## 3) 本轮改动范围

- 脚本：`scripts/build_dc_psv_system.m`、`scripts/run_case_simulation.m`、`init_params.m`
- 测试：`tests/test_acceptance_criteria.m`、`tests/test_model_structure.m`
- 数据：`data/*.csv`、`data/*.png`、`data/summary_results.csv`

## 4) 下一步

- 在不破坏当前门禁通过的前提下，继续推进 M3/M4 高保真物理细化与 2020b 兼容复验。
