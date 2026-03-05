# 发现与决策记录（压缩版）

**更新时间**: 2026-03-05

## 关键发现
1. O3 自动验收缺口不在原始波形采集，而在汇总层：`summary_results.csv` 缺少中点接地/对称性聚合指标。
2. MATLAB `readtable` 默认变量名规范化会改写 `case` 列名，直接使用 `summary_tbl.case` 不稳定。
3. 现有 mode1~mode4 数据在 `t>=0.8s` 窗口内满足严格对称关系（本轮汇总指标均为 0）。

## 根因与最小修复
1. 根因：`run_all_cases` 仅写入 Vdc/M5.3 指标，未写 O3 指标。  
   修复：新增 `compute_o3_metrics`，写入三列：
   - `midpoint_abs_max_v`
   - `vpos_halfbus_err_max_v`
   - `vneg_halfbus_err_max_v`
2. 根因：测试读取 CSV 时列名被改写。  
   修复：测试端指定 `VariableNamingRule='preserve'` 并改为 `summary_tbl.('case')` 访问。

## 阈值决策（O3）
1. `|V_pos_gnd + V_neg_gnd| <= 20V`：约为 1500V 母线的 1.3%，覆盖离散求解噪声。
2. `|V_pos_gnd - Vdc/2| <= 10V`、`|V_neg_gnd + Vdc/2| <= 10V`：约为半母线 750V 的 1.3%，用于约束对称性。

## 经验沉淀
1. 新增验收项要同时落地“实时测试断言 + 汇总表列门禁”，否则不可复现。
2. MATLAB 表格读写测试需显式固定列名策略，避免关键字列名导致假失败。
3. 保持最小修复面：本轮仅动 O3 测试与汇总脚本，不做模型拓扑重构。
