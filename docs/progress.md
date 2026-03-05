# 项目进度记录（压缩版）

**项目**: 直流平台供应船变流器系统建模与仿真
**更新时间**: 2026-03-05

## 1) 当前阶段结论

- 阶段：`重建执行中（已完成结构重建 + 指标回归）`
- 结果：模型已从“单 MATLAB Function 简化体”重建为“分层子系统链路模型”。
- 状态：全量自动化测试通过，数据产物已刷新。

## 2) 本轮关键执行证据

### A. TDD（RED → GREEN）
- RED：新增 `tests/test_model_structure.m` 后首次运行失败（缺少 `Control_Subsystem` 等分层结构）。
- GREEN：重写 `scripts/build_dc_psv_system.m` 后结构测试通过。

### B. 模型结构重建
- 顶层已包含：`Control_Subsystem`、`Generation_Subsystem`、`DC_Bus_Subsystem`、`Load_Subsystem`、`Fault_Subsystem`、`GroundMonitor_Subsystem`。
- 分层规模：
  - `Generation_Subsystem_BLOCKS=51`
  - `Load_Subsystem_BLOCKS=139`
  - `Fault_Subsystem_BLOCKS=19`
  - `DC_Bus_Subsystem_BLOCKS=14`
  - `GroundMonitor_Subsystem_BLOCKS=13`
  - `Control_Subsystem_BLOCKS=6`
- 反取巧门禁：`MATLAB_FUNCTION_BLOCKS=0`。

### C. 验证命令与结果
- 全量测试：
  - `/Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "run('tests/run_all_tests.m'); run_all_tests;"`
  - 输出：`ALL_TESTS_PASSED`
- 关键指标：
  - `VDC_02_MEAN=1505.700`
  - `VDC_02_MIN=1505.083`
  - `VDC_02_MAX=1506.347`
  - `FAULT_BUS_MIN=837.372`

### D. 数据产物刷新
- 已更新：`data/mode*.csv/png`、`data/fault*.csv/png`、`data/summary_results.csv`。

## 3) GitHub 状态

- 已纳管并推送：`kkunkunya/dc-psv-converter-sim`（private）。
- 进展：提交已包含重建代码与证据更新。
- 备注：私有仓库分支保护仍受账号策略限制（403）。

## 4) 下一步

- 继续按 M3/M4 做高保真扩展（电机与控制环细化、参数辨识、2020b 兼容复验）。
