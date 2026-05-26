# 芯片 CAD 学习 · VMware 虚拟机操作手册

> 零基础版：从打开 VMware 到跑完两个项目，每一步都写清楚

---

## 第 0 步：打开你的虚拟机

1. Mac 上找到 **VMware Fusion** 图标，双击打开
2. 左侧「虚拟机资源库」里，双击 **Ubuntu 64 位 ARM**（名字虽然写 Ubuntu，实际是 CentOS Stream 10）
3. 等它启动，看到桌面或登录界面后登录
   - **用户名**：`dep`
   - **密码**：`123456`
4. 登录后，桌面上应该有一个「终端」图标，或者在屏幕左上角点 **Activities → Terminal** 打开终端
5. 终端打开后是一个黑色窗口，里面有一行提示符，长这样：
   ```
   [dep@localhost ~]$
   ```
   这就是你的 **Shell**。`$` 后面闪光标，等着你敲命令。

> 或者你也可以不打开 VMware 窗口，直接在 Mac 终端里敲：
> ```
> ssh dep@192.168.210.128
> ```
> 输入密码 `123456` 就能连进去。效果一样，而且可以复制粘贴。

---

## 必学：三个最基础的 Linux 命令

不管做 Week 1 还是 Week 2，这三个命令你每分钟都在用。现在就敲一遍感受一下：

```bash
# 1. 看当前位置
pwd
# → 输出：/home/dep   （你现在在 dep 这个用户的家目录里）

# 2. 看当前目录下有什么
ls
# → 输出：week1-eda-env-setup  week2-tcl-report-parser  （两个项目文件夹）

# 3. 进入某个目录
cd week1-eda-env-setup
# → 提示符变成 /home/dep/week1-eda-env-setup，说明你进去了

# 回到上一级目录
cd ..
```

---

# Week 1：EDA 环境初始化脚本

## Week 1 是什么

一个 Shell 脚本，一键检测你的系统缺什么工具，然后设置好 EDA 工具需要的环境变量。

## 操作步骤

### 1. 进入项目目录

```bash
cd ~/week1-eda-env-setup
```

`~` 是 `$HOME` 的缩写，等于 `/home/dep`。这一行等价于 `cd /home/dep/week1-eda-env-setup`。

### 2. 看看里面有什么

```bash
ls
```

你应该看到：
```
README.md         config/           eda_env_setup.sh  lib/
```

### 3. 跑起来！

```bash
./eda_env_setup.sh
```

`./` 的意思是「当前目录下的」。Linux 不会自动搜索当前目录，必须加 `./` 前缀。

**你应该看到的输出（滚动出现在屏幕上）：**

```
==========================================
   EDA Environment Setup Tool v0.1
   Chip CAD Engineer Onboarding
==========================================

>>> Running dependency check...
  （12 项检测结果，每项标注 PASS/MISS/WARN）

>>> Setting up EDA environment...
  （14 个环境变量设置结果，每项标注 SET/FIX/OK）

============================================================
    EDA Environment Configuration Report
    ...（报告全文）
============================================================
```

### 4. 看"只检测模式"（不设环境变量）

```bash
./eda_env_setup.sh --check-only
```

跟上面一样，但只跑第一步（检测依赖），不会修改环境变量。

### 5. 把报告保存到文件

```bash
./eda_env_setup.sh --report my_report.txt
```

跑完后敲 `cat my_report.txt` 看报告内容。

### 6. 看帮助

```bash
./eda_env_setup.sh --help
```

### 7. 模拟模式（假装工具路径存在）

```bash
SIMULATE=true ./eda_env_setup.sh
```

因为你本地没有真的装 Synopsys/Cadence 工具，正常情况下 `PATH` 里不会加那些 bin 目录（因为脚本检查到目录不存在就跳过了）。加 `SIMULATE=true` 会让脚本假装那些目录存在，把路径加进去——方便你学习测试。

---

## Week 1 练习：加一个检测项

打开 `check_deps.sh`，在"Core Utilities"组里加一行检测 `git`：

```bash
# 用 vim 编辑（或者用 nano 更容易上手）
nano lib/check_deps.sh
```

在键盘上按方向键找到这一段：

```bash
DEPS_REPORT+=("--- Core Utilities ---")
check_cmd "grep"    "$pkg install grep"
check_cmd "sed"     "$pkg install sed"
check_cmd "awk"     "$pkg install gawk"
check_cmd "bc"      "$pkg install bc"
```

在 `bc` 后面加一行：

```bash
check_cmd "git"     "$pkg install git"
```

**保存并退出 nano**：`Ctrl+O` 回车（保存），`Ctrl+X`（退出）。

再跑一遍看效果：

```bash
./eda_env_setup.sh --check-only
```

你现在应该能看到多了一行 `git` 的检测结果。

---

# Week 2：Tcl EDA Log 解析器

## Week 2 是什么

一个 Tcl 脚本，自动读 EDA 工具的 log 文件，提取面积、功耗、时序等关键数据，输出报告。

## 操作步骤

### 1. 进入项目目录

```bash
cd ~/week2-tcl-report-parser
```

### 2. 看看里面有什么

```bash
ls
```

你应该看到：
```
README.md               eda_report_parser.tcl   sample_logs/
```

再看看 sample_logs 里有什么：

```bash
ls sample_logs/
```

两个文件：`dc_synthesis.log`（DC 综合 log）和 `pt_timing.log`（PrimeTime 时序 log）。

### 3. 跑起来！

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log
```

**你应该看到的输出：**

```
>>> Parsing: sample_logs/dc_synthesis.log
============================================================
    EDA Synthesis Report Summary
    Design:    aes_core_top
    Date:      2025-06-15 14:32:10
============================================================
--- Area ---
  Total Cell Area:    33142.10 um^2
--- Power ---
  Total Power:          28.139 mW
--- Timing ---
  Paths Analyzed:        3
  Paths MET:             2
  Paths VIOLATED:        1
  Worst Slack:         -0.100 ns
--- Cell Count ---
  Total Cells:       45231
--- DRC Violations ---
  Max Transition violations        3
  Max Capacitance violations       1
  Max Fanout violations            0
--- Warnings ---
  Total Warnings:        2
--- Timing Path Details ---
  Path 1   slack=   0.331 (MET)    ... -> ...
  Path 2   slack=   0.163 (MET)    ... -> ...
  Path 3   slack=  -0.100 (VIOLATED) ... -> ... <<< VIOLATION
```

### 4. 试试一行摘要

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -summary
```

输出只有一行：
```
aes_core_top | area=33142.10 | power=28.139 | cells=45231 | slack=-0.100 | violated=1 | warn=2
```

### 5. 试试 JSON 格式

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -json
```

### 6. 试试 CSV 格式

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -csv
```

### 7. 解析另一个 log（PrimeTime 时序）

```bash
tclsh eda_report_parser.tcl sample_logs/pt_timing.log
```

跟上面的 DC log 对比——同样的脚本，不同的输入，自动提取不同的数据。这展示了为什么 Tcl 正则这么强大。

### 8. 保存报告到文件

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -o dc_report.txt
```

然后：
```bash
cat dc_report.txt    # 看报告内容
```

---
---

## Week 2 练习：手动改脚本加功能

### 练习 1：加 -grep 过滤选项（15 分钟）

用 nano 打开脚本：

```bash
nano eda_report_parser.tcl
```

**第一步**：在参数解析那段（大概第 40 行附近），找到 `-json` 的处理行：

```tcl
"-json"    { set FORMAT "json" }
```

在它下面加两行：

```tcl
"-grep"    { incr i; set GREP_FILTER [lindex $argv $i] }
```

**第二步**：在报告生成的"Timing Path Details"循环里（大概第 220 行附近），找到：

```tcl
foreach path $TIMING_PATHS {
```

在这一行前面加上 `-grep` 过滤逻辑。找到循环体里输出路径的那行：

```tcl
    L [format "  Path %-2d  slack=%8.3f (%s)  %s -> %s%s" $idx $s $st $sp $ep $flag]
```

把它改成：

```tcl
    if {![info exists GREP_FILTER] || $st eq $GREP_FILTER} {
        L [format "  Path %-2d  slack=%8.3f (%s)  %s -> %s%s" $idx $s $st $sp $ep $flag]
    }
```

保存（`Ctrl+O` 回车，`Ctrl+X`）。

**试跑：**

```bash
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -grep VIOLATED
```

你应该只看到 Path 3（那条 VIOLATED 的）。

---

## 常用 Linux 命令速查

| 命令 | 作用 | 例子 |
|------|------|------|
| `pwd` | 看当前在哪个目录 | `pwd` |
| `ls` | 列出当前目录的文件 | `ls` |
| `ls -la` | 列出所有文件（含隐藏的）+ 详细信息 | `ls -la` |
| `cd 目录名` | 进入一个目录 | `cd week1-eda-env-setup` |
| `cd ..` | 回到上一级 | `cd ..` |
| `cd ~` | 回家目录 | `cd ~` |
| `cat 文件名` | 看文件内容 | `cat README.md` |
| `head 文件名` | 看文件前 10 行 | `head dc_report.txt` |
| `tail 文件名` | 看文件最后 10 行 | `tail dc_synthesis.log` |
| `less 文件名` | 分页浏览文件（按 q 退出）| `less README.md` |
| `nano 文件名` | 编辑文件 | `nano lib/check_deps.sh` |
| `cp A B` | 复制文件 | `cp report.txt backup.txt` |
| `mv A B` | 移动/重命名 | `mv old.txt new.txt` |
| `rm 文件名` | 删除文件（不可恢复！）| `rm junk.txt` |
| `mkdir 目录名` | 创建目录 | `mkdir test_reports` |
| `./program` | 运行当前目录下的程序 | `./eda_env_setup.sh` |
| `↑` / `↓` | 回看/前进历史命令 | 按键盘上箭头 |
| `Tab` | 自动补全文件名 | 敲了前两个字母后按 Tab |
| `Ctrl+C` | 终止正在运行的程序 | 卡住了就按这个 |
| `clear` | 清屏 | `clear` |

---

## 常见问题

### Q: 敲了 ./eda_env_setup.sh 提示 Permission denied？
```bash
chmod +x eda_env_setup.sh    # 加执行权限
```

### Q: 提示 command not found？
1. 检查拼写是否正确（大小写敏感！）
2. 检查是否在正确的目录（用 `pwd`）
3. 检查是否加了 `./` 前缀

### Q: SSH 连不上（`ssh dep@192.168.210.128` 失败）？
1. 确认 VMware Fusion 里的虚拟机正在运行
2. 确认 IP 地址没变（在 VM 终端里敲 `ip addr` 看 IP）
3. 如果 IP 变了，把新 IP 替换掉 192.168.210.128

### Q: 怎么把 Mac 上改的代码同步到 VM？
在 Mac 终端里敲：
```bash
scp -r ~/Documents/Codex/2026-05-25/7-1-2-3-reference-flow/week1-eda-env-setup/* \
    dep@192.168.210.128:/home/dep/week1-eda-env-setup/
```
输入密码 `123456`。

### Q: 关机后 VM 的 IP 地址变了怎么办？
在 VM 终端里敲 `hostname -I`（大写 I）或 `ip addr show | grep 192`，看新的 IP 地址，然后用新 IP 替换。

---

## 学习节奏建议

| 时间 | 做什么 | 在哪个环境 |
|------|--------|-----------|
| 第 1 天 | 打开 VM，学会 `cd`、`ls`、`cat`、`nano` | VM 终端 |
| 第 2 天 | 完整走一遍 Week 1 的所有命令 | VM 终端 |
| 第 3 天 | Week 1 练习：加 git 检测项 | VM 终端（用 nano 改） |
| 第 4 天 | 完整走一遍 Week 2 的所有命令 | VM 终端 |
| 第 5 天 | Week 2 练习：加 -grep 过滤 | VM 终端（用 nano 改） |
| 第 6 天 | 在 Mac 上打开 Word 讲解文档，对着脚本源码再看一遍 | Mac |
| 第 7 天 | 复述：不看文档，自己从零敲一遍 Week 1 + Week 2 | VM 终端 |

---

> 手册版本：2026-05-26 · 对应 Week 1 + Week 2
