# 发现与决策记录（压缩版）

**更新时间**: 2026-03-05

## 关键发现
1. M5.3 RED 首败来自接口缺口：`run_case_simulation` 不支持 `case_options`，且未输出 `I_fault_total`。
2. 当前简化模型里，直接把 `L_rect/L_bus` 设极小值并不会稳定地产生更大的 `fault dI/dt`，存在耦合非单调。
3. `I_fault_total` 才是故障斜率判别的一致指标，`Idc` 不能替代。

## 关键决策
1. 扩展 `run_case_simulation`：支持 `with_inductor`，并输出 `I_gen_total/I_load_total/I_fault_total`。
2. 构建脚本参数化：`Lrect_Dynamics` 与 `Lbus_Dynamics` 使用 `Lrect_tau_sim/Lbus_tau_sim`。
3. 固化 M5.3 对比参数组：
   - with inductor：`Lrect_tau=0.005`、`Lbus_tau=0.0025`
   - without inductor：`Lrect_tau=0.02`、`Lbus_tau=0.01`
4. `run_all_cases` 固化输出两组 M5.3 产物并写入 `fault_didt_max_a_per_s`。

## 经验沉淀
1. 方向性断言前先做敏感性扫点，避免把错误单调假设写进测试。
2. 故障 KPI 必须进入 `summary_results.csv`，否则阶段间不可追踪。
3. 默认配置优先守住既有门禁，再扩展专项对比。
