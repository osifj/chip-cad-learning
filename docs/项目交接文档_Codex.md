# 芯片 CAD 学习路线 — 项目交接文档

> 给 Codex 的上下文文档。新会话里直接粘贴本文档即可让 Codex 了解全部项目状态。

---

## 一、项目概况

**目标**：芯片 CAD 工程师 5 周从零到入职的学习路线，项目驱动，每个阶段一个可交付的脚本工具。

**GitHub**：https://github.com/osifj/chip-cad-learning  
**Mac 本地**：`/Users/dep/Documents/Codex/2026-05-25/7-1-2-3-reference-flow/`  
**VMware 虚拟机**：`dep@192.168.210.128:/home/dep/chip-cad-learning/`（CentOS Stream 10，密码 123456）

**当前进度**：Week 1-5 全部完成 ✅

---

## 二、目录结构（完整文件清单）

```
chip-cad-learning/
├── README.md
├── .gitignore
│
├── 01-shell环境脚本学习/                  # Week 1 — Shell
│   ├── eda_env_setup.sh                   # 主入口（119行）
│   ├── config/default.conf                # EDA路径配置（入职后改这里）
│   ├── lib/check_deps.sh                  # 依赖检测（83行）
│   ├── lib/setup_env.sh                   # 环境变量设置（116行）
│   ├── lib/generate_report.sh             # 报告生成（66行）
│   └── README.md
│
├── 02-tcl-log解析器/                      # Week 2 — Tcl
│   ├── eda_report_parser.tcl              # 主解析器（~280行）
│   ├── sample_logs/dc_synthesis.log        # DC综合log样本
│   ├── sample_logs/pt_timing.log           # PT时序log样本
│   └── README.md
│
├── 03-python测试数据流水线/               # Week 3 — Python
│   ├── data/testchip_measurements.csv      # 模拟测试数据（40 dies）
│   ├── scripts/analyze_testchip.py         # 分析主脚本（~320行）
│   └── README.md
│
├── 04-eda流程自动化框架/                  # Week 4 — Flow
│   ├── Makefile                            # 流程编排核心
│   ├── scripts/run_synth.sh                # 模拟综合
│   ├── scripts/run_place.sh                # 模拟布局
│   ├── scripts/run_cts.sh                  # 模拟时钟树
│   ├── scripts/run_route.sh                # 模拟布线
│   ├── scripts/run_sta.sh                  # 模拟STA
│   ├── scripts/run_pv.sh                   # 模拟物理验证
│   ├── scripts/flow_report.py             # 汇总报告
│   └── README.md
│
├── 05-chipcad工具箱与AI部署/              # Week 5 — 集成
│   ├── chipcad.sh                          # Shell入口
│   ├── chipcad/cli.py                      # Python CLI（~250行）
│   ├── prompts/                            # LLM prompt存档
│   └── README.md
│
└── docs/                                   # 学习文档
    ├── VMware_操作手册_Week1_Week2.md       # VM零基础操作手册
    ├── Week1_EDA环境初始化脚本_完整讲解.docx
    └── Week2_Tcl_EDA_Log解析器_完整讲解.docx
```

---

## 三、每个项目的运行命令

### Week 1：Shell 环境脚本

```bash
cd 01-shell环境脚本学习
./eda_env_setup.sh                      # 完整流程
./eda_env_setup.sh --check-only         # 只看依赖
./eda_env_setup.sh --report file.txt    # 报告存盘
SIMULATE=true ./eda_env_setup.sh        # 模拟模式
```

功能：检测 gcc/perl/python3/tclsh 等 12 项依赖，设置 SNPS_ROOT/DC_HOME/ICC2_HOME/PT_HOME 等 14 个 EDA 环境变量，输出配置报告。自动检测包管理器（dnf/yum/apt）。

### Week 2：Tcl Log 解析器

```bash
cd 02-tcl-log解析器
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log
tclsh eda_report_parser.tcl sample_logs/pt_timing.log
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -summary
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -json
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -csv
```

功能：解析 DC/PT log，提取 area/power/timing/cells/DRC/warnings，支持 text/summary/json/csv 四种输出格式。使用状态机分段解析策略。

### Week 3：Python 数据流水线

```bash
cd 03-python测试数据流水线
pip3 install pandas matplotlib numpy
python3 scripts/analyze_testchip.py data/testchip_measurements.csv
python3 scripts/analyze_testchip.py data/testchip_measurements.csv --report html
python3 scripts/analyze_testchip.py data/testchip_measurements.csv --no-plot
```

功能：读取 CSV 测试数据，IQR 法清洗，良率分析（yield=97.5%），参数统计（Cpk），4 张图表（直方图/散点/柱状/饼图），text/HTML 报告。

### Week 4：EDA 流程自动化

```bash
cd 04-eda流程自动化框架
make all              # 跑全流程（6步）
make synth            # 单步
make status           # 查看状态
make clean            # 清理
RESUME=0 make all     # 从头重跑（关闭断点续跑）
DESIGN=my_chip make all  # 指定设计名
```

功能：Makefile 驱动 6 步流程（综合→布局→CTS→布线→STA→PV），每步是独立 Shell 脚本，.done 文件实现断点续跑，Python 脚本生成汇总报告。

### Week 5：chipcad 统一工具箱

```bash
./05-chipcad工具箱与AI部署/chipcad.sh env check
./05-chipcad工具箱与AI部署/chipcad.sh env setup
./05-chipcad工具箱与AI部署/chipcad.sh parse 02-tcl-log解析器/sample_logs/dc_synthesis.log
./05-chipcad工具箱与AI部署/chipcad.sh analyze 03-python测试数据流水线/data/testchip_measurements.csv
./05-chipcad工具箱与AI部署/chipcad.sh flow run
./05-chipcad工具箱与AI部署/chipcad.sh flow status
./05-chipcad工具箱与AI部署/chipcad.sh ai prompt "写一个Tcl脚本提取PT时序log中的WNS"
```

功能：通过路径引用集成 Week 1-4 的所有脚本，统一 CLI 入口。AI 命令生成 LLM prompt 用于辅助写 EDA 脚本。

---

## 四、VMware 虚拟机部署

### 基本信息

| 项目 | 值 |
|------|-----|
| 虚拟机位置 | VMware Fusion → Ubuntu 64 位 ARM（实际 CentOS Stream 10） |
| 用户名/密码 | `dep` / `123456` |
| IP 地址 | `192.168.210.128`（NAT 模式，可能变动） |
| SSH 免密 | Mac `~/.ssh/id_ed25519` 已注入 VM |
| 项目路径 | `/home/dep/chip-cad-learning/`（git clone 自 GitHub） |
| 旧项目路径 | `~/week1-eda-env-setup/` 和 `~/week2-tcl-report-parser/`（仍可用，不再更新） |

### 连接方式

```bash
# 方式1: SSH（推荐，可复制粘贴）
ssh dep@192.168.210.128

# 方式2: VMware Fusion GUI → 打开虚拟机窗口 → Activities → Terminal
```

### 更新 VM 上的代码

```bash
ssh dep@192.168.210.128 "cd ~/chip-cad-learning && git pull origin master"
```

### 如果 IP 变了

在 VM 终端里敲 `hostname -I` 或 `ip addr show | grep 192`，拿到新 IP 后替换。

---

## 五、已安装的依赖

### Mac 端
- `homebrew` 已安装
- `gh`（GitHub CLI）已认证（账号 osifj）
- `tclsh`（macOS 自带）
- `python3` / `pip3`（已安装 pandas, matplotlib, numpy, python-docx）
- `expect`（macOS 自带）
- `sshpass`（brew 安装途中可能未完成）

### VM 端（CentOS Stream 10）
- gcc 14.3.1 + g++
- make 4.4.1
- tcl 8.6.13
- perl 5.40.2
- python3 3.12.12
- git（已装，clone 了 chip-cad-learning）
- SSH 密钥对已配置

---

## 六、GitHub 仓库

| 项目 | 值 |
|------|-----|
| URL | https://github.com/osifj/chip-cad-learning |
| 可见性 | Public |
| 当前分支 | master |
| 最近 commit | `beb1028` — "Update VM manual with Week 3-5 instructions" |
| Remote | `origin https://github.com/osifj/chip-cad-learning.git` |

推送命令：
```bash
cd /Users/dep/Documents/Codex/2026-05-25/7-1-2-3-reference-flow
git add -A && git commit -m "描述" && git push origin master
```

---

## 七、关键设计决策

1. **项目用中文命名**：为了让零基础用户一眼看懂每个文件夹是干什么的，不使用英文 week1-week5
2. **各项目独立**：每个周的项目有独立的 README 和运行脚本，不互相依赖（Week 5 通过路径引用集成）
3. **配置与逻辑分离**：`config/default.conf` 独立于脚本逻辑，入职后只需改配置
4. **断点续跑**：Week 4 用 `.done` 标记文件实现，编译中断后不重跑已完成的步骤
5. **模拟数据**：Sample log 和 CSV 数据模拟真实 EDA 工具输出，无需 license 即可学习
6. **VM 部署用 git clone**：比 scp 逐个文件同步更可靠，更新只需 git pull

---

## 八、已知问题

1. **VM 输出捕获**：`vmrun runProgramInGuest` 和 `ssh` 在某些情况下 stdout 不回显（exit code 正常）。不影响实际执行，但验证需在 VM GUI 终端里直接操作。
2. **VM IP 不固定**：NAT 模式下 IP 可能变动，需在 VM 终端用 `hostname -I` 确认。
3. **VM 名称显示"Ubuntu"实为 CentOS**：`/etc/os-release` 显示 CentOS Stream 10，不影响使用。

---

## 九、给 Codex 的操作指引

当用户说以下话时，对应的操作：

| 用户说 | 应该做什么 |
|--------|-----------|
| "帮我在 VM 上跑一下 Week 1" | `ssh dep@192.168.210.128` 然后 `cd ~/chip-cad-learning/01-shell环境脚本学习 && ./eda_env_setup.sh` |
| "VM 上更新代码" | `ssh dep@192.168.210.128 "cd ~/chip-cad-learning && git pull"` |
| "推代码到 GitHub" | Mac 上 `cd` 到项目根目录，`git add -A && git commit -m "..." && git push` |
| "帮我加一个新功能" | 修改 Mac 上的对应文件，测试通过后 git push，然后 VM 上 git pull |
| "给我讲一下某段代码" | 打开对应文件，逐行讲解（参考 docs/ 里的 Word 讲解文档） |
| "完成 Week X" | 检查该周项目的 README.md，确认功能是否完整 |

---

> 文档版本：2026-05-27 · 对应 chip-cad-learning master 分支 beb1028
