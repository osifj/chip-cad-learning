# 芯片 CAD 工程师学习路线 (Chip CAD Learning)

> 5 周从零到入职 · 项目驱动 · 每个阶段一个可交付的脚本工具

## 背景

芯片 CAD（Computer-Aided Design）工程师的日常工作：
- 在 Linux 终端里操作 Synopsys/Cadence/Mentor 等 EDA 工具
- 用 Shell 脚本管理环境和工作流
- 用 Tcl 脚本与 EDA 工具交互、解析 log
- 用 Python 处理测试数据、搭建数据分析流水线
- 部署 AI 工具辅助脚本开发

## 项目结构

```
chip-cad-learning/
├── week1-eda-env-setup/       # Week 1: Shell — EDA 环境初始化脚本
├── week2-tcl-report-parser/   # Week 2: Tcl  — EDA Log 解析器
├── docs/                      # 完整讲解手册
│   ├── Week1_EDA环境初始化脚本_完整讲解.docx
│   ├── Week2_Tcl_EDA_Log解析器_完整讲解.docx
│   └── VMware_操作手册_Week1_Week2.md
└── README.md
```

## Week 1：Shell — EDA 环境初始化脚本

一键检测系统依赖（gcc/python3/tclsh 等 12 项），自动设置 Synopsys/Cadence/Mentor 全套 EDA 环境变量，输出格式化配置报告。

```
./eda_env_setup.sh                    # 完整流程
./eda_env_setup.sh --check-only       # 只看依赖
./eda_env_setup.sh --report file.txt  # 报告存盘
SIMULATE=true ./eda_env_setup.sh      # 模拟模式
```

**技术点：** Bash 模块化、环境变量管理、版本号语义化比对、管道与正则

---

## Week 2：Tcl — EDA Log 解析器

解析 DC 综合 / PT 时序分析 log，自动提取面积、功耗、时序(slack)、单元数、DRC、警告。支持 text/json/csv/summary 四种输出格式。

```
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -summary
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -json
```

**技术点：** Tcl 正则、状态机分段解析、dict 数据建模、Shell+Tcl 互操作

---

## 学习文档

三份从零基础出发的完整讲解文档（含源码、运行步骤、练习）：

| 文档 | 说明 |
|------|------|
| `docs/Week1_EDA环境初始化脚本_完整讲解.docx` | Shell 逐行精讲 + 语法速查 + EDA 工具表 |
| `docs/Week2_Tcl_EDA_Log解析器_完整讲解.docx` | Tcl 语法速成 + 正则实战 + Shell vs Tcl 对照 |
| `docs/VMware_操作手册_Week1_Week2.md` | 零基础 VMware 操作步骤（每个命令敲什么、预期看到什么） |

## 快速开始

```bash
# Week 1
cd week1-eda-env-setup
./eda_env_setup.sh

# Week 2
cd week2-tcl-report-parser
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log
```

## 学习路线

| 周次 | 主题 | 产出 |
|------|------|------|
| Week 1 | Shell + Linux | EDA 环境初始化脚本 |
| Week 2 | Tcl + 正则 | EDA Log 解析器 |
| Week 3 | Python + Git | 测试数据流水线（进行中） |
| Week 4 | IC 流程认知 | 混合脚本流程自动化 |
| Week 5 | AI 工具部署 | 命令行工具箱 + LLM 集成 |

## 环境要求

- Linux / macOS / WSL
- Bash 4.0+, Tcl 8.5+, Python 3.8+
- VMware CentOS 镜像（可选，用于模拟公司服务器环境）
