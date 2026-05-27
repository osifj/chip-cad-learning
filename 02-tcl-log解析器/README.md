# 02 Tcl Log 解析器

## 1. 这个项目是做什么的

这个项目用 Tcl 解析模拟 EDA 工具日志。EDA 工具运行后会输出很多 log，里面包含面积、功耗、时序、warning、violation 等信息。人工翻 log 很慢，所以 CAD 工程师经常写脚本自动提取关键指标。

主脚本：

```text
eda_report_parser.tcl
```

样例输入：

```text
sample_logs/dc_synthesis.log
sample_logs/pt_timing.log
```

## 2. 它对应真实 EDA 实习里的什么工作

对应岗位能力：

- Tcl 脚本。
- Log parsing（日志解析）。
- IP QA（IP 质量检查）。
- Timing / area / power 摘要提取。
- 把长 log 变成可读报告。

真实场景例子：团队每天跑 regression flow，你需要自动统计哪些 design 有 timing violation、warning 变多、面积功耗异常。

## 3. 运行前需要知道什么

你只需要先理解：

- `tclsh` 是 Tcl 解释器。
- `.tcl` 文件是 Tcl 脚本。
- log 文件是普通文本文件。
- parser 的输入是 log，输出是 summary / report / json / csv。

Tcl 在 EDA 中很重要，因为很多 Synopsys / Cadence 工具都支持 Tcl 命令。

## 4. Mac 上一步一步运行

打开 Terminal，进入项目根目录：

```bash
cd /Users/dep/Documents/Codex/2026-05-25/7-1-2-3-reference-flow
```

进入 Week 2：

```bash
cd 02-tcl-log解析器
```

解析 DC 综合 log：

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -summary
```

命令解释：

- `tclsh`：运行 Tcl 脚本的程序。
- `eda_report_parser.tcl`：本项目的解析器。
- `sample_logs/dc_synthesis.log`：输入 log。
- `-summary`：只输出一行摘要。

正常输出：

```text
>>> Parsing: sample_logs/dc_synthesis.log
aes_core_top | area=33142.10 | power=28.139 | cells=45231 | slack=-0.100 | violated=1 | warn=2
```

解析 PT 时序 log：

```bash
tclsh eda_report_parser.tcl sample_logs/pt_timing.log -summary
```

输出 JSON：

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -json
```

保存报告：

```bash
mkdir -p reports
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -o reports/dc_report.txt
```

## 5. VMware Ubuntu 上一步一步运行

1. 打开 VMware。
2. 启动 Ubuntu。
3. 按 `Ctrl + Alt + T` 打开 Terminal。
4. 输入：

```bash
cd ~/chip-cad-learning
cd 02-tcl-log解析器
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -summary
```

如果提示 `tclsh: command not found`：

Ubuntu：

```bash
sudo apt install tcl
```

CentOS：

```bash
sudo dnf install tcl
```

## 6. 输入文件是什么

输入是 EDA 工具 log 样本：

- `dc_synthesis.log`：模拟 Synopsys Design Compiler 综合报告。
- `pt_timing.log`：模拟 PrimeTime 时序报告。

脚本会从 log 中提取：

- design name。
- total cell area。
- total power。
- cell count。
- timing paths。
- worst slack。
- DRC violations。
- warning 数量。

## 7. 输出结果是什么

支持 4 种输出：

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -summary
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -json
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -csv
```

保存文件：

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -o reports/dc_report.txt
```

判断成功：

- 输出里有 design 名字。
- `area`、`power`、`cells` 有数值。
- `slack` 有数值。
- 保存报告后 `reports/dc_report.txt` 存在。

## 8. 常见错误和解决方法

| 错误 | 原因 | 解决 |
|---|---|---|
| `tclsh: command not found` | 没装 Tcl | Ubuntu: `sudo apt install tcl` |
| `Error: log file not found` | log 路径错 | 运行 `ls sample_logs` |
| `No such file or directory` | 不在 Week 2 目录 | 运行 `pwd` 确认 |
| 输出全是 0 | log 格式和 parser 规则不匹配 | 先用样例 log 验证 |

## 9. 我应该掌握什么

学完这个项目，你要能说清：

- Tcl 的 `set`、`proc`、`regexp`、`dict`、`foreach` 基本作用。
- log parser 的输入和输出。
- worst slack 负数表示 timing violation。
- warning/error 数量可以作为 QA 指标。
- 为什么 summary/json/csv 输出适合自动化流程。

## 10. 面试怎么讲

中文：

> 我用 Tcl 做了一个 EDA log parser，输入模拟 DC/PT log，自动提取 area、power、cell count、worst slack、timing violation 和 warning 数量。它支持 text、summary、json、csv 输出，可以作为 IP QA 或 flow regression 的报告基础。

English:

> I implemented a Tcl-based EDA log parser for simulated DC/PT reports. It extracts area, power, cell count, worst slack, timing violations and warning counts, and supports text, summary, JSON and CSV outputs. This is related to log parsing and IP QA automation in CAD flows.
