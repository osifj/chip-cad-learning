#!/bin/bash
# chipcad -- unified CLI wrapper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "${SCRIPT_DIR}/chipcad/cli.py" "$@"
