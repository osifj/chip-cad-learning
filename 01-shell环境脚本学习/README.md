# 01 Shell 环境脚本学习

## 1. 这个项目是做什么的

这个项目模拟“EDA / IC CAD 实习生入职后检查工作环境”的任务。真实工作里，你可能需要确认 Linux 上有没有 `gcc`、`make`、`python3`、`tclsh`，还要设置 Synopsys、Cadence、Calibre、PDK、license 相关环境变量。

主脚本是：

```text
eda_env_setup.sh
```

它会调用 `lib/` 里的模块完成三件事：

1. 检查系统依赖。
2. 设置 EDA 环境变量。
3. 生成环境报告。

## 2. 它对应真实 EDA 实习里的什么工作

对应岗位能力：

- Linux 环境操作。
- Shell 自动化脚本。
- EDA tool setup。
- License 变量配置。
- PDK / CAD 工具路径理解。

真实场景例子：组里给你一台 Linux 机器，你需要确认 EDA flow 运行前依赖是否齐全，并把工具路径加入环境变量。

## 3. 运行前需要知道什么

你只需要先理解：

- Terminal 是输入命令的地方。
- `cd` 是进入目录。
- `./xxx.sh` 是运行当前目录下的 Shell 脚本。
- 环境变量是给系统和程序读取的配置，例如 `PATH`、`LM_LICENSE_FILE`。

本项目不会真的启动 Synopsys / Cadence 工具，也不需要真实 license。它是学习用模拟环境。

## 4. Mac 上一步一步运行

先打开 Terminal，然后进入仓库根目录：

```bash
cd /Users/dep/Documents/Codex/2026-05-25/7-1-2-3-reference-flow
```

进入 Week 1 目录：

```bash
cd 01-shell环境脚本学习
```

只检查依赖：

```bash
./eda_env_setup.sh --check-only
```

命令解释：

- `./eda_env_setup.sh`：运行主脚本。
- `--check-only`：只做依赖检查，不完整设置环境。

正常输出会包含：

```text
EDA Environment Setup Tool
>>> Running dependency check...
[PASS] gcc
[PASS] python3
[OK]   tclsh installed
```

Mac 上可能看到：

```text
[WARN] make v3.81 too old
```

这是因为 macOS 自带 `make` 版本旧。学习阶段可以继续；真实 Linux/VM 环境通常会是 GNU Make 4.x。

模拟完整环境：

```bash
SIMULATE=true ./eda_env_setup.sh
```

`SIMULATE=true` 表示即使真实 EDA 工具目录不存在，也先模拟设置环境变量，适合学习。

生成报告文件：

```bash
./eda_env_setup.sh --report setup_report.txt
```

成功后当前目录会出现：

```text
setup_report.txt
```

## 5. VMware Ubuntu 上一步一步运行

1. 打开 VMware Fusion / VMware Workstation。
2. 启动 Ubuntu / Linux 虚拟机。
3. 进入桌面后按 `Ctrl + Alt + T` 打开 Terminal。
4. 输入：

```bash
cd ~/chip-cad-learning
cd 01-shell环境脚本学习
./eda_env_setup.sh --check-only
```

如果项目还没拉到 Ubuntu，先运行：

```bash
cd ~
git clone https://github.com/osifj/chip-cad-learning.git
cd chip-cad-learning
```

Ubuntu 上正常更可能看到 `make` 通过：

```text
[PASS] make v4.x (>= 4.0)
```

如果提示缺少工具，根据提示安装。例如 Ubuntu：

```bash
sudo apt install make gcc g++ tcl perl bc netcat-openbsd
```

CentOS：

```bash
sudo dnf install make gcc gcc-c++ tcl perl bc nc
```

## 6. 输入文件是什么

主要输入是配置文件：

```text
config/default.conf
```

里面定义了：

- `CAD_ROOT`：EDA 工具安装根目录。
- `SYNOPSYS_VERSION`：Synopsys 版本。
- `CADENCE_VERSION`：Cadence 版本。
- `PDK_ROOT`：PDK 根目录。
- `LM_LICENSE_FILE`：license 服务器地址。

学习阶段不需要改。入职后才会把这些路径换成公司真实路径。

## 7. 输出结果是什么

脚本会在屏幕上输出报告，包括：

- 系统依赖检查。
- EDA 环境变量设置。
- 当前 Shell 环境快照。

如果使用 `--report setup_report.txt`，会生成文本报告文件。

判断成功：

- 脚本能正常结束。
- 输出中大部分是 `[PASS]` 或 `[OK]`。
- 没有出现直接中断的 error。

## 8. 常见错误和解决方法

| 错误 | 原因 | 解决 |
|---|---|---|
| `Permission denied` | 脚本没有执行权限 | `chmod +x eda_env_setup.sh` |
| `No such file or directory` | 不在正确目录 | 运行 `pwd`、`ls` 确认 |
| `command not found: gcc` | 没装 gcc | Ubuntu: `sudo apt install gcc` |
| `command not found: tclsh` | 没装 Tcl | Ubuntu: `sudo apt install tcl` |
| `make v3.81 too old` | Mac 自带 make 旧 | 学习可继续，VM/Linux 更真实 |

## 9. 我应该掌握什么

学完这个项目，你要能说清：

- `PATH` 是命令搜索路径。
- `LD_LIBRARY_PATH` 是动态库搜索路径。
- `LM_LICENSE_FILE` 是 EDA license 服务器地址。
- Shell 脚本可以自动检查工具是否安装。
- `source` 可以加载其他 Shell 文件。
- 配置和逻辑分离：`config/default.conf` 放配置，`lib/` 放函数。

## 10. 面试怎么讲

中文：

> 我做了一个 Shell 环境初始化脚本，用来模拟 CAD 工程师配置工作环境。它会检查 gcc、make、python3、tclsh 等依赖，并设置 Synopsys、Cadence、Calibre、PDK 和 license 相关环境变量。通过这个模块，我理解了 EDA 工具运行前为什么需要配置 `PATH`、`LD_LIBRARY_PATH` 和 `LM_LICENSE_FILE`。

English:

> I built a Shell-based environment setup script to simulate CAD workstation initialization. It checks dependencies such as gcc, make, python3 and tclsh, and configures EDA-related environment variables for Synopsys, Cadence, Calibre, PDK and license settings. This helped me understand basic EDA tool setup in a Linux environment.
