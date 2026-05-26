# Week 2: Tcl EDA Log Parser & Report Generator

芯片 CAD 工程师第二周项目 — 用 Tcl 解析综合/时序分析 Log 并生成报告。

## 项目结构

```
week2-tcl-report-parser/
├── eda_report_parser.tcl       # 主解析脚本（~280 行）
├── sample_logs/
│   ├── dc_synthesis.log        # DC 综合 log 样本
│   └── pt_timing.log           # PrimeTime 时序 log 样本
├── reports/                    # 输出报告目录
└── README.md
```

## 快速开始

```bash
# 解析 DC 综合 log
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log

# 解析 PT 时序 log
tclsh eda_report_parser.tcl sample_logs/pt_timing.log

# 一行摘要（适合脚本调用）
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -summary

# JSON 格式输出
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -json

# CSV 格式输出
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -csv

# 保存报告到文件
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -o reports/dc_report.txt
```

## 提取的数据

| 类别 | 提取内容 | 来源 |
|------|---------|------|
| Area | Total cell area (um^2) | DC/PT Area Report |
| Power | Total power (mW) | DC/PT Power Report |
| Timing | Path count, MET/VIOLATED, worst slack, path details | DC/PT Timing Report |
| Cells | Total cell count | Cell Count Report |
| DRC | Max transition/capacitance/fanout violations | DRC Report |
| Warnings | Total warning count | 全文 Warning: 匹配 |

## Tcl 语法学习要点

| 语法 | 说明 | 脚本中出现位置 |
|------|------|---------------|
| `set var value` | 赋值 | 全局变量定义 |
| `$var` | 取值 | 所有变量引用 |
| `[command ...]` | 命令替换（= Shell 的 `$(...)`) | `[llength $list]` |
| `proc name {args} {body}` | 定义函数 | 所有解析函数 |
| `regexp {pattern} $str -> $v1` | 正则匹配捕获 | 所有提取行 |
| `dict create / dict set / dict get` | 字典操作 | 时序路径存储 |
| `lappend list $item` | 列表追加 | 收集行/路径 |
| `foreach item $list { ... }` | 遍历 | 所有循环 |
| `switch -exact -- $val { ... }` | 分支 | 参数解析 |
| `for {set i 0} {$i < $n} {incr i}` | C 风格循环 | 参数遍历 |
| `if {cond} { ... } elseif { ... }` | 条件 | 到处 |
| `string match "pat*" $str` | 通配符匹配 | 区块检测 |
| `format` | 格式化字符串 | 报告输出 |
| `open / close / puts / read` | 文件 IO | 读取 log / 写报告 |
| `[split $text "\n"]` | 字符串转列表 | 读文件后按行分割 |

## Tcl 与 Shell 的关键区别

| | Tcl | Shell |
|---|-----|-------|
| 注释 | `#` | `#` |
| 赋值 | `set x 5` | `x=5`（不能有空格） |
| 取值 | `$x` | `$x` |
| 命令替换 | `[expr 1+2]` | `$(expr 1+2)` |
| 条件 | `if {$x > 0} { ... }` | `if [[ $x -gt 0 ]]; then ... fi` |
| 函数 | `proc name {args} {body}` | `name() { ... }` |
| 列表 | `list a b c` → `a b c` | `arr=(a b c)` |
| 字典 | `dict create k v` | `declare -A arr; arr[k]=v` |

## 练习建议

1. 加一个 `-grep` 选项，支持只输出匹配关键词的时序路径（如只显示 VIOLATED 的）
2. 加面积利用率计算：从 log 中提取 Combinational/Noncombinational 面积并算比例
3. Shell + Tcl 混合脚本：写一个 Shell 脚本调用 tclsh 解析多个 log 文件并汇总

## Week 1 → Week 2 衔接思路

Week 1 的 `check_deps.sh` 会检测 `tclsh` 是否安装。
Week 2 证明了 Tcl 在 EDA 中的核心地位——所有 EDA 工具的 log 都可以用 Tcl 正则解析。
入职后你可以把这个解析器改造成公司内部的 Dashboard 数据源。
