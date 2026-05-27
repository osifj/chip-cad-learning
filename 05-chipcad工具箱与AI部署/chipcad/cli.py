#!/usr/bin/env python3
"""
=============================================================================
 chipcad -- 芯片 CAD 脚本工具箱 (Week 5)
=============================================================================
统一命令行入口，集成 Week 1-4 的所有脚本。

用法：
  chipcad env check                 # 检测系统依赖（调用 Week 1）
  chipcad env setup                 # 设置 EDA 环境变量（调用 Week 1）
  chipcad parse <log_file>          # 解析 EDA log（调用 Week 2 Tcl 脚本）
  chipcad analyze <csv_file>        # 分析测试数据（调用 Week 3）
  chipcad flow run                  # 跑 EDA 全流程（调用 Week 4 Makefile）
  chipcad ai prompt "<需求>"        # AI 生成 Tcl/Shell 脚本框架
  chipcad --help                    # 帮助

依赖：
  pip3 install click pyyaml
=============================================================================
"""

import subprocess
import sys
import os
import json

TOOLBOX_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(TOOLBOX_DIR)
REPO_ROOT = os.path.dirname(ROOT_DIR)

# 各周项目的路径
W1_DIR = os.path.join(REPO_ROOT, "01-shell环境脚本学习")
W2_DIR = os.path.join(REPO_ROOT, "02-tcl-log解析器")
W3_DIR = os.path.join(REPO_ROOT, "03-python测试数据流水线")
W4_DIR = os.path.join(REPO_ROOT, "04-eda流程自动化框架")


def _find_tclsh():
    """Find tclsh executable."""
    for p in ["/usr/bin/tclsh", "/usr/local/bin/tclsh"]:
        if os.path.exists(p):
            return p
    # try which
    try:
        return subprocess.check_output(["which", "tclsh"], text=True).strip()
    except Exception:
        return "tclsh"


def cmd_env_check():
    """Run Week 1 dependency check."""
    script = os.path.join(W1_DIR, "eda_env_setup.sh")
    if not os.path.exists(script):
        print(f"Error: {script} not found")
        return 1
    return subprocess.run(["bash", script, "--check-only"]).returncode


def cmd_env_setup():
    """Run Week 1 full environment setup."""
    script = os.path.join(W1_DIR, "eda_env_setup.sh")
    if not os.path.exists(script):
        print(f"Error: {script} not found")
        return 1
    return subprocess.run(["bash", script]).returncode


def cmd_parse(log_file, fmt="text", output=None):
    """Run Week 2 Tcl log parser."""
    tclsh = _find_tclsh()
    script = os.path.join(W2_DIR, "eda_report_parser.tcl")
    if not os.path.exists(script):
        print(f"Error: {script} not found")
        return 1
    args = [tclsh, script, log_file]
    if fmt == "summary":
        args.append("-summary")
    elif fmt == "json":
        args.append("-json")
    elif fmt == "csv":
        args.append("-csv")
    if output:
        args.extend(["-o", output])
    return subprocess.run(args).returncode


def cmd_analyze(csv_file, output_dir=None, no_plot=False):
    """Run Week 3 Python analysis pipeline."""
    script = os.path.join(W3_DIR, "scripts", "analyze_testchip.py")
    if not os.path.exists(script):
        print(f"Error: {script} not found")
        return 1
    csv_path = os.path.abspath(csv_file)
    if output_dir is None:
        output_path = os.path.join(W3_DIR, "outputs")
    else:
        output_path = os.path.abspath(output_dir)
    args = ["python3", script, csv_path, "--output-dir", output_path]
    if no_plot:
        args.append("--no-plot")
    return subprocess.run(args).returncode


def cmd_flow(step="all", design="aes_core_top", resume=True):
    """Run Week 4 EDA flow (Makefile)."""
    makefile_dir = W4_DIR
    if not os.path.exists(os.path.join(makefile_dir, "Makefile")):
        print(f"Error: Makefile not found in {makefile_dir}")
        return 1
    env = os.environ.copy()
    env["DESIGN"] = design
    if not resume:
        env["RESUME"] = "0"
    args = ["make", "-C", makefile_dir]
    if step == "all":
        args.append("all")
    else:
        args.append(step)
    return subprocess.run(args, env=env).returncode


def cmd_ai_prompt(requirement):
    """Generate a prompt for LLM to create Tcl/Shell EDA scripts."""
    prompt = f"""你是一位资深芯片 CAD 工程师。请根据以下需求生成 EDA 脚本。

需求：{requirement}

请输出：
1. 脚本类型（Shell / Tcl / Python）
2. 完整的脚本代码
3. 使用说明（参数含义、示例运行命令）
4. 注意事项（依赖、环境变量要求）

如果需求涉及 EDA 工具（Synopsys DC/PT/ICC2、Cadence Innovus/Tempus），请使用对应的 Tcl 命令。
"""
    print("=" * 55)
    print("  LLM Prompt (copy this to ChatGPT / Ollama / Claude):")
    print("=" * 55)
    print()
    print(prompt)
    print("=" * 55)

    # Also save to file
    prompt_dir = os.path.join(TOOLBOX_DIR, "..", "prompts")
    os.makedirs(prompt_dir, exist_ok=True)
    import datetime
    ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    prompt_file = os.path.join(prompt_dir, f"prompt_{ts}.txt")
    with open(prompt_file, "w") as f:
        f.write(prompt)
    print(f"Prompt saved: {prompt_file}")
    return 0


# ============================================================
# CLI Entry Point
# ============================================================
def main():
    if len(sys.argv) < 2:
        print("chipcad -- Chip CAD Script Toolbox")
        print("Usage: chipcad <command> [options]")
        print()
        print("Commands:")
        print("  env check            Check system dependencies (Week 1)")
        print("  env setup            Setup EDA environment variables (Week 1)")
        print("  parse <log>          Parse EDA log file (Week 2)")
        print("  analyze <csv>        Analyze testchip data (Week 3)")
        print("  flow run [step]      Run EDA flow (Week 4)")
        print("  ai prompt <需求>     Generate LLM prompt for script creation")
        print()
        print("Examples:")
        print("  chipcad env check")
        print("  chipcad parse sample_logs/dc_synthesis.log")
        print("  chipcad analyze data/testchip_measurements.csv")
        print("  chipcad flow run")
        print("  chipcad ai prompt '写一个脚本解析PT时序log并提取WNS'")
        sys.exit(0)

    cmd = sys.argv[1]

    if cmd == "env":
        sub = sys.argv[2] if len(sys.argv) > 2 else "check"
        if sub == "check":
            sys.exit(cmd_env_check())
        elif sub == "setup":
            sys.exit(cmd_env_setup())
        else:
            print(f"Unknown env subcommand: {sub}")
            sys.exit(1)

    elif cmd == "parse":
        if len(sys.argv) < 3:
            print("Usage: chipcad parse <log_file> [--format json|summary|csv] [--output file]")
            sys.exit(1)
        log = sys.argv[2]
        fmt = "text"
        out = None
        i = 3
        while i < len(sys.argv):
            if sys.argv[i] == "--format" and i+1 < len(sys.argv):
                fmt = sys.argv[i+1]; i += 2
            elif sys.argv[i] == "--output" and i+1 < len(sys.argv):
                out = sys.argv[i+1]; i += 2
            else:
                i += 1
        sys.exit(cmd_parse(log, fmt, out))

    elif cmd == "analyze":
        if len(sys.argv) < 3:
            print("Usage: chipcad analyze <csv_file> [--output-dir dir] [--no-plot]")
            sys.exit(1)
        csv_file = sys.argv[2]
        out_dir = None
        no_plot = False
        i = 3
        while i < len(sys.argv):
            if sys.argv[i] == "--output-dir" and i+1 < len(sys.argv):
                out_dir = sys.argv[i+1]; i += 2
            elif sys.argv[i] == "--no-plot":
                no_plot = True; i += 1
            else:
                i += 1
        sys.exit(cmd_analyze(csv_file, out_dir, no_plot))

    elif cmd == "flow":
        sub = sys.argv[2] if len(sys.argv) > 2 else "run"
        if sub == "run":
            step = sys.argv[3] if len(sys.argv) > 3 else "all"
            sys.exit(cmd_flow(step))
        elif sub == "status":
            import subprocess as sp
            sp.run(["make", "-C", W4_DIR, "status"])
        elif sub == "clean":
            import subprocess as sp
            sp.run(["make", "-C", W4_DIR, "clean"])
        else:
            print(f"Unknown flow subcommand: {sub}")
            sys.exit(1)

    elif cmd == "ai":
        if len(sys.argv) < 4 or sys.argv[2] != "prompt":
            print("Usage: chipcad ai prompt <requirement>")
            sys.exit(1)
        req = " ".join(sys.argv[3:])
        sys.exit(cmd_ai_prompt(req))

    else:
        print(f"Unknown command: {cmd}")
        print("Run 'chipcad' without arguments for help.")
        sys.exit(1)


if __name__ == "__main__":
    main()
