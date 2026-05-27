#!/bin/bash
DESIGN="$1"; CLK_MHZ="${2:-1200}"
PERIOD_NS=$(echo "scale=3; 1000 / $CLK_MHZ" | bc)
echo "[STA] PrimeTime analysis for $DESIGN @ ${CLK_MHZ}MHz (period=${PERIOD_NS}ns)..."
sleep 0.4
echo "  Setup paths:  42138 total, 42137 MET, 1 VIOLATED"
echo "  Hold paths:   42138 total, 42138 MET"
echo "  WNS (setup):  -0.054 ns"
echo "  WNS (hold):    0.012 ns"
echo "STA completed."
exit 0
