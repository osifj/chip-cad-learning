# VMware Ubuntu 零基础操作手册

这份文档只讲一件事：你如何在虚拟机 Linux 里运行这个 EDA 学习项目。

## 1. VMware 是什么

VMware 是虚拟机软件。你可以把它理解成“在 Mac 里面再开一台 Linux 电脑”。这台 Linux 电脑有自己的桌面、终端、IP 地址、文件系统。

## 2. Ubuntu 是什么

Ubuntu 是 Linux 系统的一种。真实 EDA / IC CAD 工作中，经常使用 Linux 服务器，因为很多 EDA 工具、license 服务、脚本流程都在 Linux 上运行。

如果你的 VMware 名字叫 Ubuntu，但终端里显示 CentOS，也不用紧张。Ubuntu 和 CentOS 都是 Linux，基础命令大部分相同。

## 3. 为什么 EDA 实习常用 Linux

EDA 工具通常运行在 Linux 上，例如 Synopsys Design Compiler、PrimeTime、Cadence Innovus、Calibre 等。实习里你经常会：

- 登录 Linux 服务器。
- 进入项目目录。
- 运行 Shell / Tcl / Python 脚本。
- 查看 log。
- 修改配置。
- 用 git 拉取代码。

所以学会 VMware / Ubuntu / Terminal 是进入 CAD 自动化工作的第一步。

## 4. 怎么打开虚拟机

1. 在 Mac 上打开 VMware Fusion，或在 Windows 上打开 VMware Workstation。
2. 左侧或主界面会显示虚拟机列表。
3. 找到名字类似 `Ubuntu`、`CentOS`、`Linux` 的虚拟机。
4. 点击它。
5. 点击启动按钮，通常是一个三角形播放图标。
6. 等待 30 秒到几分钟，直到看到 Linux 登录界面或桌面。

如果虚拟机提示恢复、挂起、继续运行，选择继续或启动即可。

## 5. 怎么打开 Ubuntu Terminal

Terminal 是 Linux 里输入命令的地方。

打开方法：

1. 快捷键：按 `Ctrl + Alt + T`。
2. 应用菜单：点击左下角或左上角的应用按钮，搜索 `Terminal`。
3. 右键菜单：在桌面空白处右键，选择 `Open in Terminal`。

打开后你会看到类似：

```text
dep@ubuntu:~$
```

其中：

- `dep` 是用户名。
- `ubuntu` 是机器名。
- `~` 代表 home 目录。
- `$` 后面可以输入命令。

## 6. 怎么用命令行

最常用三条：

```bash
pwd
```

显示当前路径。

```bash
ls
```

列出当前目录里的文件。

```bash
cd ~/chip-cad-learning
```

进入项目目录。`~` 是 `/home/dep` 的简写。

如果命令执行完没有输出，不一定是失败。很多 Linux 命令成功时就是安静返回。

## 7. 怎么查看 IP

在 Ubuntu Terminal 输入：

```bash
hostname -I
```

正常输出：

```text
192.168.210.128
```

这就是虚拟机 IP。你的 IP 可能不同。如果输出多个 IP，通常选择 `192.168...` 或 `172...` 这种局域网地址。

也可以输入：

```bash
ip addr
```

这个输出更长，适合排查网络。

## 8. 怎么 SSH

SSH 是从 Mac 远程登录 Ubuntu 的方式。你可以在 Mac Terminal 操作 Ubuntu，不一定非要在 VMware 窗口里打字。

在 Mac Terminal 输入：

```bash
ssh dep@192.168.210.128
```

把 IP 换成你自己的。

第一次连接可能看到：

```text
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

输入：

```text
yes
```

然后输入密码。密码输入时屏幕不会显示，这是正常现象。

连接成功后，你会看到：

```text
dep@ubuntu:~$
```

这代表你已经在 Ubuntu 里。

退出 SSH：

```bash
exit
```

## 9. 怎么从 Mac 操作 Ubuntu

典型流程：

1. 先打开 VMware，启动 Ubuntu。
2. 在 Ubuntu 里运行 `hostname -I` 查看 IP。
3. 回到 Mac Terminal。
4. 输入 `ssh dep@你的IP`。
5. 登录后运行 Linux 命令。

你在 SSH 窗口里输入的命令是在 Ubuntu 执行，不是在 Mac 执行。

## 10. 怎么把项目拉到 Ubuntu

如果 Ubuntu 里还没有项目：

```bash
cd ~
git clone https://github.com/osifj/chip-cad-learning.git
cd chip-cad-learning
```

解释：

- `cd ~`：回到 home 目录。
- `git clone ...`：从 GitHub 下载项目。
- `cd chip-cad-learning`：进入项目。

确认：

```bash
pwd
ls
```

应该看到 `README.md` 和 5 个项目文件夹。

## 11. 怎么更新 GitHub 仓库

如果项目已经存在：

```bash
cd ~/chip-cad-learning
git pull origin master
```

含义：

- `git pull`：从 GitHub 拉取最新代码。
- `origin`：远端仓库名字。
- `master`：分支名。

正常输出可能是：

```text
Already up to date.
```

或显示下载了新 commit。

## 12. 怎么运行项目

先安装依赖：

```bash
cd ~/chip-cad-learning
python3 -m pip install -r requirements.txt
```

再跑自检：

```bash
bash scripts/check_all.sh
```

再逐个运行：

```bash
cd 01-shell环境脚本学习
./eda_env_setup.sh --check-only
cd ..
```

```bash
cd 02-tcl-log解析器
tclsh eda_report_parser.tcl sample_logs/dc_synthesis.log -summary
cd ..
```

```bash
cd 03-python测试数据流水线
python3 scripts/analyze_testchip.py data/testchip_measurements.csv --no-plot
cd ..
```

```bash
cd 04-eda流程自动化框架
make all
make status
cd ..
```

```bash
./05-chipcad工具箱与AI部署/chipcad.sh flow status
```

## 13. 怎么关闭虚拟机

推荐在 Ubuntu 里正常关机：

1. 点击右上角电源按钮。
2. 选择 Power Off / Shut Down。
3. 等待虚拟机关闭。

也可以在 Terminal 输入：

```bash
sudo shutdown now
```

它可能要求输入密码。

不要频繁强制关闭虚拟机，否则可能造成文件未保存。

## 14. 常见错误

### SSH 连接不上

可能原因：

- 虚拟机没启动。
- IP 变了。
- SSH 服务没开。
- Mac 和 VM 网络不通。

先在 Ubuntu 里运行：

```bash
hostname -I
```

再用新 IP 连接。

### `git: command not found`

Ubuntu：

```bash
sudo apt update
sudo apt install git
```

CentOS：

```bash
sudo dnf install git
```

### `python3: command not found`

Ubuntu：

```bash
sudo apt install python3 python3-pip
```

CentOS：

```bash
sudo dnf install python3 python3-pip
```

### `tclsh: command not found`

Ubuntu：

```bash
sudo apt install tcl
```

CentOS：

```bash
sudo dnf install tcl
```

### `make: command not found`

Ubuntu：

```bash
sudo apt install make
```

CentOS：

```bash
sudo dnf install make
```

### `bc: command not found`

Week 4 的 STA 脚本用 `bc` 算时钟周期。

Ubuntu：

```bash
sudo apt install bc
```

CentOS：

```bash
sudo dnf install bc
```

## 15. 你要掌握的底线

学完这份文档，你至少要能做到：

1. 打开 VMware。
2. 打开 Ubuntu Terminal。
3. 用 `pwd`、`ls`、`cd` 找到项目。
4. 用 `hostname -I` 查看 IP。
5. 从 Mac 用 SSH 登录 Ubuntu。
6. 用 `git pull` 更新代码。
7. 跑 `bash scripts/check_all.sh`。
8. 看懂 `[OK]` 和 `[FAIL]`。

