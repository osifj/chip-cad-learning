#!/usr/bin/env python3
"""Generate flow summary report from log files."""
import sys, os, glob
design = sys.argv[1] if len(sys.argv) > 1 else "unknown"
log_dir = sys.argv[2] if len(sys.argv) > 2 else "logs"

sep = "=" * 55
print(sep)
print(f"  Flow Report: {design}")
print(sep)
for f in sorted(glob.glob(f"{log_dir}/*.log")):
    name = os.path.basename(f)
    size = os.path.getsize(f)
    with open(f) as fh:
        lines = fh.readlines()
    status = "PASS" if any("completed" in l.lower() for l in lines) else "UNKNOWN"
    print(f"  [{status}] {name}  ({size} bytes)")
print(sep)
