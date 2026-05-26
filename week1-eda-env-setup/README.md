# Week 1: EDA 环境初始化脚本

芯片 CAD 工程师入职第一周项目 — 工作环境一键配置自动化。

## 项目结构

```
week1-eda-env-setup/
├── eda_env_setup.sh          # 主入口脚本
├── config/
│   └── default.conf          # EDA 工具路径配置（入职后改这里）
├── lib/
│   ├── check_deps.sh         # 系统依赖检测模块
│   ├── setup_env.sh          # 环境变量配置模块
│   └── generate_report.sh    # 配置报告生成模块
└── README.md
```

## 快速开始

```bash
# 运行完整流程：检测依赖 + 设置环境 + 输出报告
./eda_env_setup.sh

# 只检测依赖
./eda_env_setup.sh --check-only

# 输出报告到文件
./eda_env_setup.sh --report setup_report.txt

# 模拟模式（假装 EDA 工具已安装，用于学习/测试）
SIMULATE=true ./eda_env_setup.sh

# 查看帮助
./eda_env_setup.sh --help
```

## 功能说明

### 1. 依赖检测 (`lib/check_deps.sh`)

自动检测以下工具是否安装及版本是否满足要求：

- **编译工具链**: gcc, g++, make
- **脚本语言**: perl, python3, tclsh (EDA 三大脚本语言)
- **基础工具**: grep, sed, awk, bc
- **网络工具**: ping, nc (License 通信必需)

### 2. 环境变量配置 (`lib/setup_env.sh`)

设置 EDA 工具链所需的关键环境变量：

| 变量 | 用途 |
|------|------|
| `SNPS_ROOT` | Synopsys 工具根路径 |
| `DC_HOME` | Design Compiler (综合) |
| `ICC2_HOME` | IC Compiler II (布局布线) |
| `PT_HOME` | PrimeTime (时序分析) |
| `CDS_ROOT` | Cadence 工具根路径 |
| `INNOVUS_HOME` | Innovus (布局布线) |
| `TEMPUS_HOME` | Tempus (时序分析) |
| `CALIBRE_HOME` | Calibre (DRC/LVS 物理验证) |
| `PDK_HOME` | 工艺设计套件路径 |
| `LM_LICENSE_FILE` | License 服务器地址 |
| `PATH` | 追加 EDA 工具 bin 目录 |
| `LD_LIBRARY_PATH` | 追加 EDA 动态库路径 |

### 3. 配置报告 (`lib/generate_report.sh`)

生成包含以下内容的格式化报告：
- 依赖检测结果（PASS/MISS/WARN）
- 环境变量设置结果（SET/FIX/OK）
- 当前 Shell 环境快照

## 入职后需要改什么

打开 `config/default.conf`，修改以下变量为公司的实际路径：

```bash
export CAD_ROOT="/opt/eda"              # -> 公司 EDA 工具安装根目录
export LM_LICENSE_FILE="5280@license-server"  # -> 公司 License 服务器
export PDK_ROOT="/opt/pdk"              # -> 公司 PDK 根目录
export PDK_NAME="tsmc7nm"              # -> 实际工艺节点
```

## 学习要点

通过这个项目你应该理解：

1. **Shell 脚本的模块化**: `source` 引入外部脚本，函数封装功能
2. **环境变量的作用域**: `export` vs 普通变量，PATH 的追加 vs 覆盖
3. **EDA 工具的环境依赖**: 为什么需要 `LD_LIBRARY_PATH`、`LM_LICENSE_FILE`
4. **Bash 编程范式**: `set -euo pipefail`、`[[ ]]` 条件测试、数组、局部变量
5. **Unix 哲学**: 管道、命令替换 `$(...)`、退出码

## 练习建议

1. 在 `check_deps.sh` 中增加检测项（如 `git`、`vim`、`tmux`）
2. 在 `setup_env.sh` 中增加 Mentor Calibre 的环境变量
3. 给 `safe_export` 加一个 `--force` 选项，强制覆盖已有变量
4. 让报告支持 JSON 格式输出
5. 把这个脚本加到你的 `~/.bashrc` 里，每次登录自动配置

## 后续项目衔接

- Week 2: Tcl 脚本解析 EDA log
- Week 3: Python 测试数据处理
- Week 4: Shell/Tcl/Python 混合流程自动化
- Week 5: 命令行工具箱 + LLM 部署
