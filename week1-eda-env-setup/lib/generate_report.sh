#!/bin/bash
# generate_report.sh - configuration report generator

generate_report() {
    local outfile="$1"
    local ts hn us
    ts="$(date '+%Y-%m-%d %H:%M:%S %Z')"
    hn="$(hostname 2>/dev/null || echo unknown)"
    us="$(whoami 2>/dev/null || echo unknown)"

    # Build report in a function so we can both print and save
    _print_report() {
        echo "============================================================"
        echo "    EDA Environment Configuration Report"
        echo "    Generated: $ts"
        echo "    Host:      $hn"
        echo "    User:      $us"
        echo "============================================================"
        echo

        if [[ ${#DEPS_REPORT[@]} -gt 0 ]]; then
            for line in "${DEPS_REPORT[@]}"; do echo "$line"; done
            echo
            if [[ "$DEPS_OK" = true ]]; then
                echo "  >>> All dependencies satisfied."
            else
                echo "  >>> WARNING: missing or outdated dependencies."
            fi
        else
            echo "  (dependency check not run)"
        fi
        echo

        if [[ ${#ENV_REPORT[@]} -gt 0 ]]; then
            for line in "${ENV_REPORT[@]}"; do echo "$line"; done
        else
            echo "  (environment setup not run)"
        fi
        echo

        echo "======== Current Environment Snapshot ========"
        echo
        echo "SHELL            = ${SHELL:-unset}"
        echo "HOME             = ${HOME:-unset}"
        echo "USER             = ${USER:-unset}"
        echo "HOSTNAME         = ${HOSTNAME:-unset}"
        echo "OSTYPE           = ${OSTYPE:-unset}"
        echo "PATH             = ${PATH:-unset}"
        echo "LD_LIBRARY_PATH  = ${LD_LIBRARY_PATH:-unset}"
        echo "LM_LICENSE_FILE  = ${LM_LICENSE_FILE:-unset}"
        echo
        echo "============================================================"
        echo "    Report complete."
        echo "============================================================"
    }

    # Always print to stdout
    _print_report

    # Optionally save to file
    if [[ -n "$outfile" ]]; then
        _print_report > "$outfile"
        echo
        echo "Report saved to: $outfile"
    fi
}
