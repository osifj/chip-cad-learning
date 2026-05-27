# 05 chipcad 工具箱与 AI 部署

## 1. 这个项目是做什么的

这个项目把 Week 1-4 的功能封装成一个统一命令行工具 `chipcad`。你不用每次记住不同目录里的脚本，只需要用一个入口调用环境检查、log 解析、数据分析、flow 状态和 AI prompt 生成。

入口脚本：

```text
chipcad.sh
```

核心 Python CLI：

```text
chipcad/cli.py
```

## 2. 它对应真实 EDA 实习里的什么工作

对应岗位能力：

- 内部工具封装。
- Python CLI。
- Shell / Tcl / Python / Makefile 集成。
- AI 工具资源部署与应用支持。
- 把重复命令整理成统一接口。

真实场景例子：团队里有很多小脚本，实习生可以把它们封装成统一命令，减少使用成本。

## 3. 运行前需要知道什么

你只需要先理解：

- `chipcad.sh` 是外层入口。
- 它底层调用 `python3 chipcad/cli.py`。
- `cli.py` 再去调用 Week 1-4 的脚本。
- AI prompt 只生成提示词，不代表脚本已经验证。

## 4. Mac 上一步一步运行

打开 Terminal，进入项目根目录：

```bash
cd /Users/dep/Documents/Codex/2026-05-25/7-1-2-3-reference-flow
```

安装依赖：

```bash
python3 -m pip install -r requirements.txt
```

查看帮助：

```bash
./05-chipcad工具箱与AI部署/chipcad.sh
```

正常会看到：

```text
chipcad -- Chip CAD Script Toolbox
Commands:
  env check
  parse <log>
  analyze <csv>
  flow run [step]
  ai prompt <需求>
```

运行 log 解析：

```bash
./05-chipcad工具箱与AI部署/chipcad.sh parse 02-tcl-log解析器/sample_logs/dc_synthesis.log --format summary
```

运行测试数据分析：

```bash
./05-chipcad工具箱与AI部署/chipcad.sh analyze 03-python测试数据流水线/data/testchip_measurements.csv --no-plot
```

查看 flow 状态：

```bash
./05-chipcad工具箱与AI部署/chipcad.sh flow status
```

## 5. VMware Ubuntu 上一步一步运行

1. 打开 VMware。
2. 启动 Ubuntu。
3. 按 `Ctrl + Alt + T` 打开 Terminal。
4. 输入：

```bash
cd ~/chip-cad-learning
python3 -m pip install -r requirements.txt
./05-chipcad工具箱与AI部署/chipcad.sh
./05-chipcad工具箱与AI部署/chipcad.sh env check
```

如果提示没有执行权限：

```bash
chmod +x 05-chipcad工具箱与AI部署/chipcad.sh
```

## 6. 输入文件是什么

根据命令不同，输入不同：

```bash
chipcad env check
```

输入：Week 1 的环境配置和当前系统状态。

```bash
chipcad parse <log>
```

输入：EDA log 文件，例如 `02-tcl-log解析器/sample_logs/dc_synthesis.log`。

```bash
chipcad analyze <csv>
```

输入：测试数据 CSV，例如 `03-python测试数据流水线/data/testchip_measurements.csv`。

```bash
chipcad ai prompt "需求"
```

输入：你想让 AI 帮你写的脚本需求。

## 7. 输出结果是什么

常见输出：

- `env check`：环境依赖报告。
- `parse`：log 解析摘要。
- `analyze`：`03-python测试数据流水线/outputs/analysis_report.txt`。
- `flow status`：每个 flow step 的 DONE/PEND 状态。
- `ai prompt`：终端显示 prompt，并保存到 `05-chipcad工具箱与AI部署/prompts/`。

判断成功：

- 不出现 Python traceback。
- 命令返回结果符合对应 Week 的输出。
- 分析报告或 prompt 文件能在对应目录找到。

## 8. 常见错误和解决方法

| 错误 | 原因 | 解决 |
|---|---|---|
| `Permission denied` | `chipcad.sh` 无执行权限 | `chmod +x 05-chipcad工具箱与AI部署/chipcad.sh` |
| `Unknown command` | 命令写错 | 不带参数运行查看帮助 |
| `Error: ... not found` | 输入文件路径错 | `ls` 检查文件 |
| `缺少依赖: pandas` | Python 依赖没装 | `python3 -m pip install -r requirements.txt` |
| `tclsh` 不存在 | Tcl 没装 | Ubuntu: `sudo apt install tcl` |

## 9. 我应该掌握什么

学完这个项目，你要能说清：

- CLI 是命令行工具入口。
- Python 可以调用 Shell / Tcl / Makefile。
- 统一工具箱能降低重复命令的使用成本。
- AI prompt 是辅助，不是最终验证结果。
- 为什么内部工具要有清晰帮助和默认路径。

## 10. 面试怎么讲

中文：

> 我把前四个模块封装成一个统一的 `chipcad` CLI 工具箱，可以通过 `env check`、`parse`、`analyze`、`flow status` 等命令调用 Shell、Tcl、Python 和 Makefile 脚本。同时我加入了 AI prompt 生成入口，用来把脚本需求标准化。这个模块对应内部 CAD 工具封装和 AI 工具应用支持。

English:

> I wrapped the previous modules into a unified `chipcad` CLI toolbox. It provides commands such as `env check`, `parse`, `analyze` and `flow status`, and internally calls Shell, Tcl, Python and Makefile scripts. I also added an AI prompt helper to standardize scripting requests. This maps to internal CAD tool integration and AI-assisted workflow support.
