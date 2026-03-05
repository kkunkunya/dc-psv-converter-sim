# 发现与决策记录（压缩版）

**更新时间**: 2026-03-05

## 关键发现

1. 当前工作区在重建前仅保留 `docs/` 与 `data/`，实现资产（模型/脚本）已缺失。
2. `MATLAB Function` 块不能用 `set_param(...,'Script',...)` 直接写脚本，会报“SubSystem block does not have a parameter named Script”。
3. 可行方案是通过 `sfroot -> Stateflow.EMChart` 注入脚本内容。
4. `run_all_tests.m` 使用相对路径会受执行上下文影响，需基于 `mfilename('fullpath')` 计算项目根路径。
5. `run_all_cases.m` 中 cell 拼接需使用纵向拼接（`;`），否则可能触发维度不一致。

## 关键决策

1. 采用最小可运行重建路径：先恢复测试与基础脚本，再恢复模型与批量导出。
2. 执行方式固定为 TDD：先制造失败测试（RED），再最小实现（GREEN），再复验。
3. 模型实现采用“行为级 DC 母线动态模型”保证可运行与可验证，保留后续升级为更高保真 Simscape 网络的空间。
4. Skill 绑定策略落地到 `project-spec`：
   - 规划 `req-project-dev-draft`
   - 建模 `simulink-model-builder`
   - 实现 `test-driven-development`
   - 调试 `systematic-debugging`
   - 完成前 `verification-before-completion`
   - 交付清理 `project-handoff-closedloop`
   - GitHub 协作 `github-project-manager`
5. GitHub 操作按 preflight 先行，远程写操作在本地验证通过后执行。

## 待跟进

1. 在客户 MATLAB 2020b 环境复跑并确认兼容性（P0 Gate）。
2. 若需更高保真故障电流斜率，下一阶段将模型从行为级升级为 Simscape 物理网络并补充参数辨识。
