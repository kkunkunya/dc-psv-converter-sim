# 项目进度记录（压缩版）

**项目**: 直流平台供应船变流器系统建模与仿真  
**更新时间**: 2026-03-05

## 1) 当前阶段结论
- 阶段：`M5.4 O3 证据链补强（本轮完成）`
- 结果：mode1~mode4 的中点接地与对称性已形成“测试 + 汇总指标”双证据链；既有 M5.3 限流验证未被破坏。

## 2) O3 RED → GREEN 证据
- RED-1 命令：`/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "run('tests/run_all_tests.m'); run_all_tests;"`
- RED-1 首败：`O3 failed: summary missing column midpoint_abs_max_v`
- RED-1 根因：`data/summary_results.csv` 未聚合 O3 指标列。
- 修复-1：`scripts/run_all_cases.m` 增加 `midpoint_abs_max_v`、`vpos_halfbus_err_max_v`、`vneg_halfbus_err_max_v`。
- RED-2 首败：`Unrecognized table variable name 'case'`
- RED-2 根因：MATLAB `readtable` 默认改写列名，`case` 列访问失效。
- 修复-2：`tests/test_acceptance_criteria.m` 使用 `VariableNamingRule='preserve'` + 动态列访问。
- GREEN 输出：`ALL_TESTS_PASSED`

## 3) 强制验证命令与新鲜输出（2026-03-05）
- `run_all_tests`：输出 `ALL_TESTS_PASSED`（exit 0）。
- `run_all_cases`：批量刷新 `data/*.csv`、`data/*.png` 与 `data/summary_results.csv`（exit 0）。
- `git status --short`：显示本轮测试、脚本、文档、汇总数据与波形图变更。

## 4) O3 指标快照（稳态窗口 t >= 0.8s）
| case | midpoint_abs_max_v | vpos_halfbus_err_max_v | vneg_halfbus_err_max_v |
|---|---:|---:|---:|
| mode1_cruise_low | 0 | 0 | 0 |
| mode2_cruise_high | 0 | 0 | 0 |
| mode3_dp_normal | 0 | 0 | 0 |
| mode4_dp_harsh | 0 | 0 | 0 |

## 5) 本轮改动文件
- `tests/test_acceptance_criteria.m`
- `scripts/run_all_cases.m`
- `data/summary_results.csv`
- `docs/project-spec.md`
- `docs/progress.md`
- `docs/findings.md`
