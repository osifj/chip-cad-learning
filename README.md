# 芯片 CAD 工程师学习路线 (Chip CAD Learning)

> 5 周从零到入职 · 项目驱动 · 每个阶段一个可交付的脚本工具

## 适合谁

这个仓库面向想入门芯片 CAD / EDA 流程自动化的同学，尤其适合准备“脚本工具编写、工作环境配置、Reference Flow/Testchip/IP QA 自动化、AI 工具部署”类实习岗位。

如果你是零基础，先读：[docs/零基础完整运行手册.md](docs/零基础完整运行手册.md)。

## 项目总览

| 周次 | 目录 | 主题 | 产出 | 技术栈 |
|------|------|------|------|--------|
| Week 1 | `01-shell环境脚本学习` | Shell + Linux | EDA 环境初始化脚本 | Bash, 环境变量 |
| Week 2 | `02-tcl-log解析器` | Tcl + 正则 | EDA Log 解析器 | Tcl, 正则, 状态机 |
| Week 3 | `03-python测试数据流水线` | Python + 数据分析 | 测试数据自动分析 | Pandas, Matplotlib |
| Week 4 | `04-eda流程自动化框架` | 流程编排 | EDA 全流程自动化 | Makefile, Shell+Tcl+Python |
| Week 5 | `05-chipcad工具箱与AI部署` | 集成 + AI | 统一工具箱 + LLM 辅助 | Python CLI, LLM Prompt |

## 快速开始

### 1. 安装 Python 依赖

```bash
python3 -m pip install -r requirements.txt
```

### 2. 运行一键自检

```bash
bash scripts/check_all.sh
```

看到 `All core demos passed.` 就说明核心 demo 都能跑。

### 3. 先用统一入口试跑

```bash
./05-chipcad工具箱与AI部署/chipcad.sh
./05-chipcad工具箱与AI部署/chipcad.sh env check
./05-chipcad工具箱与AI部署/chipcad.sh parse 02-tcl-log解析器/sample_logs/dc_synthesis.log --format summary
./05-chipcad工具箱与AI部署/chipcad.sh analyze 03-python测试数据流水线/data/testchip_measurements.csv --no-plot
./05-chipcad工具箱与AI部署/chipcad.sh flow status
```

### 4. 分周单独运行

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

`docs/` 目录包含零基础完整讲解手册和项目交接文档：

- `docs/零基础完整运行手册.md`：从打开终端到跑通 5 个模块的总入口
- `docs/命令逐行解释手册.md`：解释每条常用命令的含义
- `docs/VMware_Ubuntu_零基础操作手册.md`：VMware / Ubuntu / SSH 小白操作说明
- `docs/7天零基础学习计划.md`：每天学什么、跑什么、面试积累什么
- `docs/面试讲法.md`：中文/英文项目介绍和常见问答
- `docs/从零开始学习指南.md`：按 JD 拆解学习路线
- `docs/VMware_操作手册_Week1_Week2.md`：早期 VMware / Linux 操作手册
- `docs/项目交接文档_Codex.md`：给新 Codex 会话恢复上下文
- `docs/Week1_EDA环境初始化脚本_完整讲解.docx`
- `docs/Week2_Tcl_EDA_Log解析器_完整讲解.docx`

## 自检脚本

如果你不确定环境是否准备好，在仓库根目录运行：

```bash
bash scripts/check_all.sh
```

它会检查 Python、pip、Tcl、make、Python 依赖，并运行 Week 1-5 的关键 demo。失败时会给出类似这样的提示：

```text
[FAIL] Python packages are missing
解决方法：在仓库根目录运行：python3 -m pip install -r requirements.txt
```

## 环境要求

- Linux / macOS / WSL
- Bash 4.0+, Tcl 8.5+, Python 3.8+
- `python3 -m pip install -r requirements.txt`

提示：macOS 自带 `make` 可能是 3.81，Week 1 会给出版本警告；Week 4 的学习流程仍可运行。真实 Linux/VM 环境建议使用 GNU Make 4.x。
