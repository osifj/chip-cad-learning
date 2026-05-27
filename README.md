# 芯片 CAD 工程师学习路线 (Chip CAD Learning)

> 5 周从零到入职 · 项目驱动 · 每个阶段一个可交付的脚本工具

## 项目总览

| 周次 | 目录 | 主题 | 产出 | 技术栈 |
|------|------|------|------|--------|
| Week 1 | `01-shell环境脚本学习` | Shell + Linux | EDA 环境初始化脚本 | Bash, 环境变量 |
| Week 2 | `02-tcl-log解析器` | Tcl + 正则 | EDA Log 解析器 | Tcl, 正则, 状态机 |
| Week 3 | `03-python测试数据流水线` | Python + 数据分析 | 测试数据自动分析 | Pandas, Matplotlib |
| Week 4 | `04-eda流程自动化框架` | 流程编排 | EDA 全流程自动化 | Makefile, Shell+Tcl+Python |
| Week 5 | `05-chipcad工具箱与AI部署` | 集成 + AI | 统一工具箱 + LLM 辅助 | Python CLI, LLM Prompt |

## 快速开始

```bash
# Week 1: 检测环境
cd 01-shell环境脚本学习 && ./eda_env_setup.sh

# Week 2: 解析 log
cd 02-tcl-log解析器 && tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log

# Week 3: 分析数据
cd 03-python测试数据流水线 && python3 scripts/analyze_testchip.py data/testchip_measurements.csv

# Week 4: 跑流程
cd 04-eda流程自动化框架 && make all

# Week 5: 统一入口
./05-chipcad工具箱与AI部署/chipcad.sh env check
./05-chipcad工具箱与AI部署/chipcad.sh ai prompt "写一个Tcl脚本提取PT时序log中的WNS"
```

## 学习文档

`docs/` 目录包含三份零基础完整讲解手册（Word + Markdown）。

## 环境要求

- Linux / macOS / WSL
- Bash 4.0+, Tcl 8.5+, Python 3.8+
- pip3 install pandas matplotlib numpy
