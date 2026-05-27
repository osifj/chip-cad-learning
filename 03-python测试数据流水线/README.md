# 03-python测试数据流水线 — Python Testchip Data Pipeline

Week 3 项目：芯片流片测试数据收集、管理及分析流程自动化。

## 项目结构

```
03-python测试数据流水线/
├── data/
│   └── testchip_measurements.csv   # 模拟流片测试数据（40 dies, 3 wafers）
├── scripts/
│   └── analyze_testchip.py         # 数据分析主脚本（~320 行）
├── outputs/                        # 输出图表和报告
└── README.md
```

## 快速开始

```bash
pip3 install pandas matplotlib numpy

# 基本分析
python3 scripts/analyze_testchip.py data/testchip_measurements.csv

# HTML 报告
python3 scripts/analyze_testchip.py data/testchip_measurements.csv --report html

# 不生成图表（纯数据）
python3 scripts/analyze_testchip.py data/testchip_measurements.csv --no-plot

# 通过 chipcad 工具箱调用
chipcad analyze data/testchip_measurements.csv
```

## 功能

| 功能 | 说明 |
|------|------|
| 数据加载 | pandas 读取 CSV，自动识别列 |
| 数据清洗 | IQR 法去异常值，检测缺失 |
| 良率分析 | 整体良率 + 按 wafer 分组 + speed bin 分布 |
| 参数统计 | 均值/标准差/最大最小/Cpk |
| 可视化 | 直方图、散点图、柱状图、饼图 |
| 报告输出 | text / HTML 两种格式 |

## 示例数据

模拟一枚 AES 加密芯片的 CP（Chip Probe）测试数据：
- 40 颗 die，3 片 wafer，2 个 lot
- 参数：Vth NMOS/PMOS、Idsat、Ioff、Fmax、Leakage
- Speed bin：FAST / TYP / SLOW
- 良率：97.5%（39/40 passed）
