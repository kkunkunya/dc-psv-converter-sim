# 项目进度记录（压缩版）

**项目**: 直流平台供应船变流器系统建模与仿真  
**更新时间**: 2026-03-05

## 1) 当前阶段结论
- 阶段：`M5.3 限流元件故障斜率验证（本轮完成）`
- 结果：完成“有电感 vs 无电感”故障电流上升斜率对比，且未破坏既有门禁。

## 2) RED → GREEN 证据
- RED 命令：`/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "run('tests/run_all_tests.m'); run_all_tests;"`
- RED 首败：`Error using run_case_simulation - Too many input arguments.`
- 根因：`run_case_simulation` 缺少 `case_options` 入参和 `I_fault_total` 输出。
- GREEN 同命令输出：`ALL_TESTS_PASSED`。

## 3) 本轮实现摘要
- 参数化仿真入口：支持 `with_inductor` 切换并注入 `Lrect_tau_sim/Lbus_tau_sim`。
- 故障指标链路：输出 `I_fault_total`，测试使用 `t=0.6~0.65s` 窗口计算 `dI/dt`。
- 批量产物刷新：新增 `fault_bus_short_with_inductor` / `fault_bus_short_without_inductor` CSV+PNG。
- 汇总指标升级：`data/summary_results.csv` 增加 `with_inductor`、`fault_peak_current_a`、`fault_didt_max_a_per_s`。

## 4) 强制命令与输出摘要
- `/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "run('tests/run_all_tests.m'); run_all_tests;"`  
  输出：`ALL_TESTS_PASSED`
- `/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "addpath('scripts'); run_all_cases;"`  
  输出：批量完成并写入 `data/*.csv/png` 与 `data/summary_results.csv`

## 5) M5.3 对比指标（故障窗口 t=0.6~0.65s）
| case | with_inductor | vdc_min (V) | fault_peak_current (A) | dI/dt_max (A/s) |
|---|---:|---:|---:|---:|
| fault_bus_short_with_inductor | 1 | 893.515 | 36136.665 | 79502.983 |
| fault_bus_short_without_inductor | 0 | 731.464 | 36146.805 | 369047.725 |

- 结论：`dI/dt_without > dI/dt_with`，比值约 `4.64`，差值约 `289544.742 A/s`。

## 6) 本轮改动文件
- `tests/test_acceptance_criteria.m`
- `scripts/run_case_simulation.m`
- `scripts/build_dc_psv_system.m`
- `scripts/export_case_results.m`
- `scripts/run_all_cases.m`
- `init_params.m`
