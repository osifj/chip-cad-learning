#!/bin/bash
# ============================================================
# eda_env_setup.sh -- EDA Environment Initialization Script
#
# 芯片 CAD 工程师的"工作环境一键配置"脚本。
# 
# 用法：
#   ./eda_env_setup.sh                    # 交互模式，检测 + 设置 + 报告
#   ./eda_env_setup.sh --check-only       # 只检测依赖
#   ./eda_env_setup.sh --report file.txt  # 只生成报告到文件
#   ./eda_env_setup.sh --help             # 显示帮助
#   SIMULATE=true ./eda_env_setup.sh      # 模拟模式（工具路径不存在也不报错）
# ============================================================

set -euo pipefail

# ---- Find the script directory (so we can source lib files) ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"
CONFIG_DIR="${SCRIPT_DIR}/config"

# ---- Source library modules ----
source "${LIB_DIR}/check_deps.sh"
source "${LIB_DIR}/setup_env.sh"
source "${LIB_DIR}/generate_report.sh"

# ---- Load config if present ----
if [[ -f "${CONFIG_DIR}/default.conf" ]]; then
    source "${CONFIG_DIR}/default.conf"
fi

# ---- Simulate mode: pretend EDA tool dirs exist (for learning) ----
export SIMULATE="${SIMULATE:-false}"

# ---- Banner ----
banner() {
    echo "=========================================="
    echo "   EDA Environment Setup Tool v0.1"
    echo "   Chip CAD Engineer Onboarding"
    echo "=========================================="
    echo
}

# ---- Help ----
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --check-only          Only run dependency checks"
    echo "  --report FILE         Generate report and save to FILE"
    echo "  --help                Show this help"
    echo
    echo "Environment:"
    echo "  SIMULATE=true         Simulate mode: skip existence checks"
    echo
    echo "Config file: config/default.conf"
    echo
}

# ---- Main ----
main() {
    local mode="full"
    local report_file=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check-only)
                mode="check"
                shift
                ;;
            --report)
                report_file="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    banner

    # Step 1 -- Always check dependencies
    echo ">>> Running dependency check..."
    check_all_deps

    if [[ "$mode" = "check" ]]; then
        generate_report "$report_file"
        exit 0
    fi

    # Step 2 -- Set up environment
    echo
    echo ">>> Setting up EDA environment..."
    setup_eda_env

    # Step 3 -- Generate report
    echo
    generate_report "$report_file"

    # Summary
    echo
    if [[ "$DEPS_OK" = true ]]; then
        echo "[DONE] Environment ready. Add this to your ~/.bashrc:"
        echo "       source ${SCRIPT_DIR}/eda_env_setup.sh --check-only"
    else
        echo "[DONE] Environment configured with warnings. Review report above."
    fi
}

# ---- Entry point ----
main "$@"
