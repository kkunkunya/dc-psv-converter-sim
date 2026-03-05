# 发现与决策记录（压缩版）

**更新时间**: 2026-03-05

## 关键发现

1. `clear_subsystem` 只删除 Block 不删除 Line，会保留子系统默认 `In1->Out1` 残线，触发“悬空线”问题复发。
2. `find_system(...,'Type','line')` 线句柄中包含断开的历史线段，直接检查 `Src/DstPortHandle` 能稳定识别该问题。
3. mode2/mode3 稳态偏差主要来自发电侧固定 `Ibias` 与工况负载不匹配（高载欠供、低载过供）。
4. 工况切换验收需要可控起始模式，单一“默认 mode1 起步”不足以覆盖 `WC2→WC4` 强扰动验证。

## 关键决策

1. 在 `clear_subsystem` 中先删 line 再删 block，强制保留“无悬空线”结果。
2. 发电支路改为“模式前馈电流偏置 + 电压 PI 反馈”的纯块图实现，保持 `MATLAB Function=0`。
3. `run_case_simulation` 扩展 `base_mode_id`，并新增 `mode_base_sim`，用于 `WC2→WC4` 过渡验收。
4. 母线/故障参数做最小重调（`Vdc_Ref=1500`、`Kvreg=35`、`Inv_Rfault=24`）以同时满足稳态与故障可观测。

## 待跟进

1. 在 MATLAB 2020b 客户环境跑一次同版验证命令并回传证据。
2. 继续推进 M3/M4 高保真建模（电机/逆变器细节、参数辨识、故障后恢复策略）。
