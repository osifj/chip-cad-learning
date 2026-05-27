# 04 EDA 流程自动化框架

## 1. 这个项目是做什么的

这个项目用 Makefile 模拟一个简化版 EDA reference flow。真实芯片流程会有很多步骤，例如综合、布局、时钟树、布线、时序分析、物理验证。这里用小脚本模拟这些步骤，让你理解 flow automation 的基本思想。

流程：

```text
synth -> place -> cts -> route -> sta -> pv
```

## 2. 它对应真实 EDA 实习里的什么工作

对应岗位能力：

- Reference Flow 自动化。
- Makefile 流程编排。
- Shell 脚本串联。
- 日志管理。
- 断点续跑。
- STA / PV / place route 基础概念。

真实场景例子：你需要帮团队维护一个 flow，运行失败后能看 log，修好后从失败步骤继续跑。

## 3. 运行前需要知道什么

你只需要先理解：

- `make` 会读取当前目录的 `Makefile`。
- `make all` 表示执行完整流程。
- 每个步骤会生成 log。
- `.done` 文件表示某一步已经完成。
- 本项目是模拟流程，不需要真实 EDA license。

## 4. Mac 上一步一步运行

打开 Terminal，进入项目根目录：

```bash
cd /Users/dep/Documents/Codex/2026-05-25/7-1-2-3-reference-flow
```

进入 Week 4：

```bash
cd 04-eda流程自动化框架
```

查看状态：

```bash
make status
```

从头运行完整流程：

```bash
make clean
make all
```

命令解释：

- `make clean`：删除旧的 `flow/` 和 `logs/`。
- `make all`：按顺序运行 synth、place、cts、route、sta、pv。

正常输出：

```text
[SYNTH] OK
[PLACE] OK
[CTS] OK
[ROUTE] OK
[STA] OK
[PV] OK
```

再次查看状态：

```bash
make status
```

正常输出：

```text
[DONE] synth
[DONE] place
[DONE] cts
[DONE] route
[DONE] sta
[DONE] pv
```

## 5. VMware Ubuntu 上一步一步运行

1. 打开 VMware。
2. 启动 Ubuntu。
3. 按 `Ctrl + Alt + T` 打开 Terminal。
4. 输入：

```bash
cd ~/chip-cad-learning
cd 04-eda流程自动化框架
make clean
make all
make status
```

如果 `make` 不存在：

Ubuntu：

```bash
sudo apt install make
```

CentOS：

```bash
sudo dnf install make
```

如果提示 `bc: command not found`：

Ubuntu：

```bash
sudo apt install bc
```

CentOS：

```bash
sudo dnf install bc
```

## 6. 输入文件是什么

主要输入是：

- `Makefile`：定义流程怎么跑。
- `scripts/run_synth.sh`：模拟综合。
- `scripts/run_place.sh`：模拟布局。
- `scripts/run_cts.sh`：模拟 CTS。
- `scripts/run_route.sh`：模拟布线。
- `scripts/run_sta.sh`：模拟静态时序分析。
- `scripts/run_pv.sh`：模拟物理验证。

可以通过变量改变运行配置：

```bash
DESIGN=my_chip make all
CLK_MHZ=1000 make all
RESUME=0 make all
```

## 7. 输出结果是什么

输出目录：

```text
logs/
flow/
```

`logs/` 里有每一步日志：

- `01_synthesis.log`
- `02_placement.log`
- `03_cts.log`
- `04_routing.log`
- `05_sta.log`
- `06_pv.log`

`flow/` 里有完成标记：

- `.synth_done`
- `.place_done`
- `.cts_done`
- `.route_done`
- `.sta_done`
- `.pv_done`

判断成功：

- `make all` 结束时显示 `All steps completed`。
- `make status` 全部显示 `[DONE]`。
- `logs/` 中有 6 个 log 文件。

## 8. 常见错误和解决方法

| 错误 | 原因 | 解决 |
|---|---|---|
| `make: command not found` | 没装 make | Ubuntu: `sudo apt install make` |
| `bc: command not found` | STA 脚本需要 bc | Ubuntu: `sudo apt install bc` |
| 某一步显示 FAILED | 对应脚本失败 | 查看 `logs/xx.log` |
| 第二次运行都被 Skip | `.done` 文件存在 | `make clean` 或 `RESUME=0 make all` |
| Mac make 版本旧 | macOS 自带 make 旧 | 学习可继续，VM/Linux 更真实 |

## 9. 我应该掌握什么

学完这个项目，你要能说清：

- EDA flow 为什么要拆步骤。
- synth / place / CTS / route / STA / PV 大概代表什么。
- Makefile 如何串联脚本。
- log 文件用于排查失败。
- `.done` 文件如何实现断点续跑。

## 10. 面试怎么讲

中文：

> 我用 Makefile 做了一个简化 reference flow，把 synth、place、CTS、route、STA、PV 串起来。每一步由独立 Shell 脚本模拟，输出独立 log，并在成功后生成 `.done` 文件支持断点续跑。这个模块让我理解了 EDA flow automation、日志管理和失败恢复的基本思路。

English:

> I built a simplified reference flow using Makefile. It orchestrates synthesis, placement, CTS, routing, STA and physical verification. Each step is an independent Shell script with its own log, and `.done` files are used for resume support. This helped me understand basic EDA flow automation, log management and failure recovery.
