#!/bin/bash
# Beginner-friendly self check for chip-cad-learning.

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS_COUNT=0
FAIL_COUNT=0

ok() {
    echo "[OK] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo "[FAIL] $1"
    if [[ $# -gt 1 ]]; then
        echo "解决方法：$2"
    fi
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

section() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

run_check() {
    local label="$1"
    local fix="$2"
    shift 2
    if "$@" >/tmp/chipcad_check_stdout.txt 2>/tmp/chipcad_check_stderr.txt; then
        ok "$label"
        return 0
    fi
    fail "$label" "$fix"
    echo "错误输出："
    sed -n '1,8p' /tmp/chipcad_check_stderr.txt
    return 1
}

cd "$ROOT_DIR" || exit 1

echo "chip-cad-learning self check"
echo "项目目录：$ROOT_DIR"
echo "如果出现 [FAIL]，先看它下面的“解决方法”。"

section "1. Basic tools"

if command -v python3 >/dev/null 2>&1; then
    ok "Python is available: $(python3 --version 2>&1)"
else
    fail "Python is not available" "安装 Python 3；Ubuntu: sudo apt install python3 python3-pip"
fi

if python3 -m pip --version >/dev/null 2>&1; then
    ok "pip is available"
else
    fail "pip is not available" "安装 pip；Ubuntu: sudo apt install python3-pip"
fi

if command -v tclsh >/dev/null 2>&1; then
    ok "tclsh is available"
else
    fail "tclsh is not available" "安装 Tcl；Ubuntu: sudo apt install tcl；CentOS: sudo dnf install tcl"
fi

if command -v make >/dev/null 2>&1; then
    ok "make is available"
else
    fail "make is not available" "安装 make；Ubuntu: sudo apt install make；CentOS: sudo dnf install make"
fi

if command -v bc >/dev/null 2>&1; then
    ok "bc is available"
else
    fail "bc is not available" "Week 4 STA demo 需要 bc；Ubuntu: sudo apt install bc；CentOS: sudo dnf install bc"
fi

section "2. Python packages"

if python3 - <<'PY' >/tmp/chipcad_check_stdout.txt 2>/tmp/chipcad_check_stderr.txt
import pandas
import numpy
import matplotlib
print("python packages ok")
PY
then
    ok "Python packages pandas/numpy/matplotlib are installed"
else
    fail "Python packages are missing" "在仓库根目录运行：python3 -m pip install -r requirements.txt"
    sed -n '1,8p' /tmp/chipcad_check_stderr.txt
fi

section "3. Project demos"

run_check \
    "Week 1 Shell dependency check passed" \
    "进入 01-shell环境脚本学习 后运行：./eda_env_setup.sh --check-only" \
    bash "$ROOT_DIR/01-shell环境脚本学习/eda_env_setup.sh" --check-only

run_check \
    "Week 2 Tcl parser demo passed" \
    "确认 tclsh 可用，并检查 sample log 路径" \
    tclsh "$ROOT_DIR/02-tcl-log解析器/eda_report_parser.tcl" "$ROOT_DIR/02-tcl-log解析器/sample_logs/dc_synthesis.log" -summary

rm -rf /tmp/chipcad_check_outputs
run_check \
    "Week 3 Testchip analysis demo passed" \
    "安装依赖：python3 -m pip install -r requirements.txt" \
    python3 "$ROOT_DIR/03-python测试数据流水线/scripts/analyze_testchip.py" "$ROOT_DIR/03-python测试数据流水线/data/testchip_measurements.csv" --no-plot --output-dir /tmp/chipcad_check_outputs

if [[ -f /tmp/chipcad_check_outputs/analysis_report.txt ]]; then
    ok "Testchip analysis output generated"
else
    fail "Testchip analysis output not found" "检查 Week 3 脚本是否成功运行"
fi

run_check \
    "Week 4 flow status command passed" \
    "确认 make 可用，并在 04-eda流程自动化框架 目录运行 make status" \
    make -C "$ROOT_DIR/04-eda流程自动化框架" status

run_check \
    "Week 5 chipcad parse command passed" \
    "确认 chipcad.sh 有执行权限：chmod +x 05-chipcad工具箱与AI部署/chipcad.sh" \
    "$ROOT_DIR/05-chipcad工具箱与AI部署/chipcad.sh" parse "$ROOT_DIR/02-tcl-log解析器/sample_logs/dc_synthesis.log" --format summary

section "4. Summary"

echo "[OK] count: $PASS_COUNT"
echo "[FAIL] count: $FAIL_COUNT"

if [[ "$FAIL_COUNT" -eq 0 ]]; then
    echo "All core demos passed."
    exit 0
fi

echo "Some checks failed. 按上面的解决方法修复后，再运行：bash scripts/check_all.sh"
exit 1
