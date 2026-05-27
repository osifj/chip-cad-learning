# 04-eda流程自动化框架 — EDA Flow Automation

Week 4 项目：Shell/Tcl/Python 混合流程编排，Makefile 驱动的自动化回归测试框架。

## 项目结构

```
04-eda流程自动化框架/
├── Makefile                  # 流程编排核心（Makefile）
├── scripts/
│   ├── run_synth.sh          # 模拟 DC 综合
│   ├── run_place.sh          # 模拟布局
│   ├── run_cts.sh            # 模拟时钟树综合
│   ├── run_route.sh          # 模拟布线
│   ├── run_sta.sh            # 模拟 PT 时序分析
│   ├── run_pv.sh             # 模拟 Calibre DRC/LVS
│   └── flow_report.py        # 汇总报告生成
├── flow/                     # 运行时状态文件 (.done 标记)
├── logs/                     # 流程日志
└── README.md
```

## 快速开始

```bash
# 跑全流程
make all

# 单步执行
make synth

# 从头重跑（不续跑）
RESUME=0 make all

# 查看状态
make status

# 清理
make clean

# 指定设计名
DESIGN=my_chip make all
```

## 流程设计

```
综合 (Synthesis)  →  布局 (Place)  →  CTS  →  布线 (Route)  →  STA  →  PV
    run_synth.sh      run_place.sh          run_route.sh   run_sta.sh  run_pv.sh
         ↓                  ↓                    ↓              ↓           ↓
    .synth_done       .place_done         .route_done    .sta_done   .pv_done
```

每步完成后写入 `.done` 标记文件，下次运行自动跳过（断点续跑）。

## 关键设计点

- **Makefile 编排**：利用 Make 的依赖管理和并行能力（`make -j 2` 可并行无依赖步骤）
- **断点续跑**：`.done` 文件机制，某一步挂了修好后从断点继续
- **步骤独立**：每个步骤是独立 Shell 脚本，可单独调试
- **日志收集**：所有输出重定向到 `logs/` 目录
- **汇总报告**：Python 脚本扫描所有 log 生成最终状态表
