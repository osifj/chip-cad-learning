#!/bin/bash
# ============================================================
# check_deps.sh -- system dependency checker
#
# Usage: source this file then call check_all_deps
# Output: DEPS_OK (true/false), DEPS_REPORT array
# ============================================================

DEPS_OK=true
declare -a DEPS_REPORT=()

# Extract version number from --version or -V output.
# Returns empty string if version can't be detected.
extract_version() {
    local cmd="$1"
    local raw
    raw="$("$cmd" --version 2>&1 || "$cmd" -V 2>&1 || true)"
    echo "$raw" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || true
}

# check_cmd <cmd> <pkg_hint> [min_version]
check_cmd() {
    local cmd="$1"
    local pkg_hint="$2"
    local min_version="${3:-}"

    if ! command -v "$cmd" &>/dev/null; then
        DEPS_REPORT+=("  [MISS] $cmd not found -> $pkg_hint")
        DEPS_OK=false
        return
    fi

    if [[ -z "$min_version" ]]; then
        DEPS_REPORT+=("  [OK]   $cmd installed")
        return
    fi

    local version
    version=$(extract_version "$cmd")

    if [[ -z "$version" ]]; then
        DEPS_REPORT+=("  [OK]   $cmd installed (version check skipped)")
        return
    fi

    local lowest
    lowest=$(printf "%s\n%s" "$min_version" "$version" | sort -V | head -1)
    if [[ "$lowest" = "$min_version" ]]; then
        DEPS_REPORT+=("  [PASS] $cmd v$version (>= $min_version)")
    else
        DEPS_REPORT+=("  [WARN] $cmd v$version too old, need >= $min_version ($pkg_hint)")
        DEPS_OK=false
    fi
}

# check_all_deps -- run the full dependency check suite
# Auto-detect which package manager to use
detect_pkg_manager() {
    if command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v apt &>/dev/null; then
        echo "apt"
    else
        echo "unknown"
    fi
}

check_all_deps() {
    local pkg
    pkg=$(detect_pkg_manager)

    DEPS_REPORT+=("======== System Dependency Check ========")
    DEPS_REPORT+=("  Package manager: $pkg")
    DEPS_REPORT+=("")

    DEPS_REPORT+=("--- Compiler Toolchain ---")
    check_cmd "gcc"     "$pkg install gcc"             "7.0"
    check_cmd "g++"     "$pkg install gcc-c++"         "7.0"
    check_cmd "make"    "$pkg install make"            "4.0"

    DEPS_REPORT+=("--- Scripting Languages ---")
    check_cmd "perl"    "$pkg install perl"            "5.16"
    check_cmd "python3" "$pkg install python3"         "3.8"
    check_cmd "tclsh"   "$pkg install tcl"             "8.5"

    DEPS_REPORT+=("--- Core Utilities ---")
    check_cmd "grep"    "$pkg install grep"
    check_cmd "sed"     "$pkg install sed"
    check_cmd "awk"     "$pkg install gawk"
    check_cmd "bc"      "$pkg install bc"

    DEPS_REPORT+=("--- Network (License Required) ---")
    check_cmd "ping"    "built-in"
    check_cmd "nc"      "$pkg install nc"

    DEPS_REPORT+=("")
    DEPS_REPORT+=("==========================================")
}
