# 05-chipcad工具箱与AI部署 — Chip CAD Toolbox & AI

Week 5 项目：统一命令行工具箱，集成 Week 1-4 所有脚本，支持 AI 辅助脚本生成。

## 项目结构

```
05-chipcad工具箱与AI部署/
├── chipcad.sh                # Shell 入口（放到 PATH 里就能全局调用）
├── chipcad/
│   └── cli.py               # Python CLI 核心（~250 行）
├── prompts/                  # 生成的 LLM prompt 存档
├── config/                   # 预留配置文件目录
└── README.md
```

## 快速开始

```bash
# 回到仓库根目录后安装 Python 依赖
python3 -m pip install -r requirements.txt

# 添加执行权限
chmod +x chipcad.sh

# 查看所有命令
./chipcad.sh

# 或者加到 PATH 后全局使用
export PATH="$PWD:$PATH"
chipcad env check
```

## 所有命令

| 命令 | 功能 | 对应周 |
|------|------|--------|
| `chipcad env check` | 检测系统依赖（gcc/tclsh/perl...） | Week 1 |
| `chipcad env setup` | 设置 EDA 环境变量 | Week 1 |
| `chipcad parse <log>` | 解析 EDA log 提取 area/power/timing | Week 2 |
| `chipcad analyze <csv>` | 分析测试数据（良率/统计/图表） | Week 3 |
| `chipcad flow run` | 跑 EDA 全流程（综合→PV） | Week 4 |
| `chipcad flow status` | 查看流程状态 | Week 4 |
| `chipcad ai prompt <需求>` | 生成 LLM prompt 用于 AI 辅助写脚本 | Week 5 |

## AI 脚本生成

`chipcad ai prompt` 命令生成精心构造的 prompt，可直接复制到 ChatGPT / Ollama / Claude 使用：

```bash
chipcad ai prompt "写一个Tcl脚本提取PT时序log中的所有setup violation路径"
```

生成的 prompt 包含：
1. 角色设定（资深芯片 CAD 工程师）
2. 格式要求（脚本类型、代码、说明、注意事项）
3. EDA 工具语境（Synopsys/Cadence 对应的 Tcl 命令）

## 集成方式

chipcad 通过路径引用调用前四周的项目：
- 01-shell环境脚本学习 → `chipcad env check/setup`
- 02-tcl-log解析器 → `chipcad parse`
- 03-python测试数据流水线 → `chipcad analyze`
- 04-eda流程自动化框架 → `chipcad flow`

不需要复制代码，各项目保持独立。

## 对应岗位能力

这个项目对应 JD 里的“AI 工具资源部署与应用支持”。重点不是让 AI 替你写完所有脚本，而是把常用 CAD 自动化任务沉淀成统一入口，并用 prompt 模板规范 AI 输出，最后仍然通过本地脚本验证。
