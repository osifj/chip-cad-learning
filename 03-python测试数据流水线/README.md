# 03 Python 测试数据流水线

## 1. 这个项目是做什么的

这个项目用 Python 分析模拟 testchip（测试芯片）测量数据。输入是 CSV 文件，里面有每颗 die 的参数、speed bin 和 pass/fail 结果。脚本会计算良率、统计参数、生成报告和图表。

主脚本：

```text
scripts/analyze_testchip.py
```

输入数据：

```text
data/testchip_measurements.csv
```

## 2. 它对应真实 EDA 实习里的什么工作

对应岗位能力：

- Python 数据分析。
- Testchip data analysis（测试芯片数据分析）。
- IP 流片测试数据处理。
- Yield report（良率报告）。
- 参数统计和异常值检查。

真实场景例子：测试工程师给你一份 CSV，你需要自动统计多少 die 通过、哪个 wafer 表现差、参数是否异常。

## 3. 运行前需要知道什么

你只需要先理解：

- CSV 是表格文本文件。
- `pandas` 是 Python 里处理表格数据的库。
- yield = passed dies / total dies。
- `--no-plot` 表示不画图，只生成文字报告。

## 4. Mac 上一步一步运行

打开 Terminal，进入项目根目录：

```bash
cd /Users/dep/Documents/Codex/2026-05-25/7-1-2-3-reference-flow
```

安装依赖：

```bash
python3 -m pip install -r requirements.txt
```

进入 Week 3：

```bash
cd 03-python测试数据流水线
```

运行文字报告：

```bash
python3 scripts/analyze_testchip.py data/testchip_measurements.csv --no-plot
```

命令解释：

- `python3`：运行 Python。
- `scripts/analyze_testchip.py`：分析脚本。
- `data/testchip_measurements.csv`：输入测试数据。
- `--no-plot`：不生成图片。

正常输出：

```text
Testchip Data Analysis Pipeline v1.0
加载数据: 40 行, 15 列
Yield: 97.5% (39/40)
Report saved: outputs/analysis_report.txt
```

生成 HTML 和图表：

```bash
python3 scripts/analyze_testchip.py data/testchip_measurements.csv --report html
```

## 5. VMware Ubuntu 上一步一步运行

1. 打开 VMware。
2. 启动 Ubuntu。
3. 按 `Ctrl + Alt + T` 打开 Terminal。
4. 输入：

```bash
cd ~/chip-cad-learning
python3 -m pip install -r requirements.txt
cd 03-python测试数据流水线
python3 scripts/analyze_testchip.py data/testchip_measurements.csv --no-plot
```

如果 `pip` 不存在：

Ubuntu：

```bash
sudo apt install python3-pip
```

CentOS：

```bash
sudo dnf install python3-pip
```

## 6. 输入文件是什么

输入文件：

```text
data/testchip_measurements.csv
```

它模拟一枚 AES 测试芯片的 CP 测试数据：

- 40 颗 die。
- 3 片 wafer。
- 2 个 lot。
- 参数包括 `vth_n_mv`、`vth_p_mv`、`idsat_n_ua`、`idsat_p_ua`、`ioff_na`、`fmax_mhz`、`leakage_ua`。
- `speed_bin` 表示 FAST / TYP / SLOW。
- `pass_flag` 为 1 表示通过，0 表示失败。

## 7. 输出结果是什么

默认输出目录：

```text
outputs/
```

常见输出：

- `outputs/analysis_report.txt`
- `outputs/analysis_report.html`
- `outputs/01_histograms.png`
- `outputs/02_fmax_vs_leakage.png`
- `outputs/03_yield_by_wafer.png`
- `outputs/04_speed_bin_pie.png`

判断成功：

- 屏幕显示 `Yield: 97.5% (39/40)`。
- `outputs/analysis_report.txt` 存在。
- 如果没有加 `--no-plot`，会生成 png 图。

## 8. 常见错误和解决方法

| 错误 | 原因 | 解决 |
|---|---|---|
| `缺少依赖: pandas` | Python 包未安装 | `python3 -m pip install -r requirements.txt` |
| `错误: 文件不存在` | CSV 路径错 | 运行 `ls data` |
| `python3: command not found` | 没装 Python | Ubuntu: `sudo apt install python3` |
| 图表无法显示 | 服务器无 GUI | 正常，脚本会保存 png 文件 |

## 9. 我应该掌握什么

学完这个项目，你要能说清：

- CSV 是输入数据。
- `pandas.read_csv` 可以读取表格。
- yield 的计算方式。
- IQR 可以用于异常值检查。
- Cpk 粗略反映参数分布和规格边界关系。
- Python 可以把测试数据自动变成工程报告。

## 10. 面试怎么讲

中文：

> 我用 Python/pandas 做了一个 testchip 数据分析流水线，输入 CSV 测试数据，自动完成缺失值检查、IQR 异常值检测、整体良率、wafer 良率、speed bin 分布和参数统计，并输出 text / HTML 报告和图表。这个项目对应 IP 流片测试数据收集、管理和分析自动化。

English:

> I built a Python and pandas pipeline for testchip measurement data analysis. It reads CSV data, checks missing values and outliers, calculates overall yield, wafer-level yield, speed-bin distribution and parametric statistics, and generates text or HTML reports with plots. This maps to testchip data processing and yield reporting tasks.
