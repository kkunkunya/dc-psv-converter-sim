# 直流PSV变流器仿真重建工程

本工程用于按 `docs/project-spec.md` 重建并验证直流母线工况/故障仿真链路，交付可运行模型、参数脚本、测试与结果数据。

## 快速开始

1. 运行单案例仿真（模式1、无故障）：
   ```bash
   /Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "addpath('scripts'); out=run_case_simulation(1,0,1.0); disp(mean(out.Vdc(out.t>=0.2)));"
   ```
2. 运行测试：
   ```bash
   /Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "run('tests/run_all_tests.m'); run_all_tests;"
   ```
3. 批量导出四工况+三故障结果：
   ```bash
   /Applications/MATLAB_R2025a.app/bin/matlab -nodesktop -nosplash -batch "addpath('scripts'); run_all_cases;"
   ```

## 目录

- `init_params.m`: 参数初始化与默认仿真变量
- `models/`: 主模型 `dc_psv_system.slx`
- `scripts/`: 模型构建、单案例仿真、批量导出
- `utils/`: 工况与故障配置函数
- `tests/`: TDD 测试入口与验收测试
- `data/`: 工况/故障 CSV 与 PNG、汇总统计
- `docs/`: 规格、进展、发现
