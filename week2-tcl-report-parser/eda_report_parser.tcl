#!/usr/bin/env tclsh
# ============================================================
# eda_report_parser.tcl -- EDA Log Parser & Report Generator
#
# Week 2 项目：解析 Synopsys DC/PT 综合日志，提取
#   面积 / 功耗 / 时序(slack) / 单元数 / 警告
# 并生成格式化文本报告。
#
# 用法：
#   tclsh eda_report_parser.tcl <log_file>
#   tclsh eda_report_parser.tcl <log_file> -o report.txt
#   tclsh eda_report_parser.tcl <log_file> -summary
#   tclsh eda_report_parser.tcl <log_file> -json
# ============================================================

# ── 全局变量 ──
set DESIGN_NAME     "unknown"
set DESIGN_DATE     "unknown"
set TOTAL_AREA      0.0
set TOTAL_POWER     0.0
set TOTAL_CELLS     0
set NUM_WARNINGS    0
set WORST_SLACK     999.0
set WORST_SLACK_PATH ""
set SLACK_VIOLATED   0
set SLACK_MET        0
set TIMING_PATHS     [list]
set DRC_VIOLATIONS   [list]

# ── 参数解析 ──
if {$argc < 1} {
    puts stderr "Usage: tclsh $argv0 <log_file> \[options\]"
    puts stderr "  -o FILE     Save report to FILE"
    puts stderr "  -summary    One-line summary only"
    puts stderr "  -json       JSON format output"
    puts stderr "  -csv        CSV format output"
    exit 1
}

set LOG_FILE    ""
set OUTPUT_FILE ""
set FORMAT      "text"

for {set i 0} {$i < $argc} {incr i} {
    set arg [lindex $argv $i]
    switch -exact -- $arg {
        "-o"       { incr i; set OUTPUT_FILE [lindex $argv $i] }
        "-summary" { set FORMAT "summary" }
        "-json"    { set FORMAT "json" }
        "-csv"     { set FORMAT "csv" }
        default    { if {$LOG_FILE eq ""} { set LOG_FILE $arg } }
    }
}

if {$LOG_FILE eq "" || ![file exists $LOG_FILE]} {
    puts stderr "Error: log file not found: $LOG_FILE"
    exit 1
}

# ── 解析函数 ──

# extract_val: 从一行文本中用正则提取数值
# 例: extract_val "Total cell area: 33142.10 um^2" {([0-9.]+)} → 33142.10
proc extract_val {line pattern} {
    if {[regexp $pattern $line -> val]} {
        return [string trim $val]
    }
    return ""
}

# parse_area_block: 解析面积报告块
proc parse_area_block {lines} {
    global TOTAL_AREA
    foreach line $lines {
        set v [extract_val $line {Total cell area:\s+([0-9.]+)}]
        if {$v ne ""} { set TOTAL_AREA $v }
    }
}

# parse_power_block: 解析功耗报告块
proc parse_power_block {lines} {
    global TOTAL_POWER
    foreach line $lines {
        if {[regexp {^Total\s+([0-9.]+)\s+mW\s+([0-9.]+)\s+mW\s+([0-9.]+)\s+mW\s+([0-9.]+)\s+mW} $line -> i s l t]} {
            set TOTAL_POWER $t
        }
    }
}

# parse_timing_block: 解析时序报告块（按 Path 分段）
proc parse_timing_block {lines} {
    global TIMING_PATHS
    set current [dict create]
    set in_path 0

    foreach line $lines {
        # 新 Path 开始
        if {[regexp {^Path\s+(\d+):} $line]} {
            if {$in_path && [dict get $current startpoint] ne ""} {
                lappend TIMING_PATHS $current
            }
            set current [dict create startpoint "" endpoint "" slack 0.0 slack_status ""]
            set in_path 1
            continue
        }

        if {!$in_path} { continue }

        if {[regexp {Startpoint:\s+(.+)} $line -> v]} {
            dict set current startpoint [string trim $v]
        }
        if {[regexp {Endpoint:\s+(.+)} $line -> v]} {
            dict set current endpoint [string trim $v]
        }
        if {[regexp {slack\s+\((\w+)\):\s+(-?[0-9.]+)} $line -> status v]} {
            dict set current slack $v
            dict set current slack_status $status
        }
    }
    # 最后一条
    if {$in_path && [dict get $current startpoint] ne ""} {
        lappend TIMING_PATHS $current
    }
}

# parse_cell_block: 解析单元数
proc parse_cell_block {lines} {
    global TOTAL_CELLS
    foreach line $lines {
        set v [extract_val $line {Total cells:\s+([0-9]+)}]
        if {$v ne ""} { set TOTAL_CELLS $v }
    }
}

# parse_drc_block: 解析 DRC 违规
proc parse_drc_block {lines} {
    global DRC_VIOLATIONS
    foreach line $lines {
        if {[regexp {(\w[\w\s]+violations):\s+(\d+)} $line -> type count]} {
            lappend DRC_VIOLATIONS [list [string trim $type] $count]
        }
    }
}

# ── 主解析流程：按"报告块"分段 ──

puts ">>> Parsing: $LOG_FILE"

set fp [open $LOG_FILE r]
set all_lines [split [read $fp] "\n"]
close $fp

# 提取 header
foreach line $all_lines {
    if {[regexp {Design:\s+(.+)} $line -> v]} { set DESIGN_NAME [string trim $v] }
    if {[regexp {Date:\s+(.+)} $line -> v]}    { set DESIGN_DATE [string trim $v] }
}

# 统计警告
set NUM_WARNINGS 0
foreach line $all_lines {
    if {[string match "Warning:*" $line]} { incr NUM_WARNINGS }
}

# ── 核心：按节 (section) 收集行 ──
# 策略：用 section 变量跟踪当前在哪个报告块里。
# 只有遇到新 section 标题时才切换，===== 和 ----- 分隔线被忽略。
# 这样每个报告块的行完整收集，不会提前被截断。

set section    "none"
set area_lines   [list]
set power_lines  [list]
set timing_lines [list]
set cell_lines   [list]
set drc_lines    [list]

foreach line $all_lines {
    # 检测 section 标题（精确匹配块标题）
    if {[string match "*Area Report*" $line]} {
        set section "area"
        continue
    }
    if {[string match "*Power Report*" $line]} {
        set section "power"
        continue
    }
    if {[string match "*Timing Report*" $line]} {
        set section "timing"
        continue
    }
    if {[string match "*Cell Count Report*" $line]} {
        set section "cell"
        continue
    }
    if {[string match "*DRC Report*" $line]} {
        set section "drc"
        continue
    }

    # 按当前 section 收集行
    switch $section {
        "area"   { lappend area_lines   $line }
        "power"  { lappend power_lines  $line }
        "timing" { lappend timing_lines $line }
        "cell"   { lappend cell_lines   $line }
        "drc"    { lappend drc_lines    $line }
    }
}

# 调试：打印每个 block 收集了多少行
# puts "  area_lines: [llength $area_lines] lines"
# puts "  power_lines: [llength $power_lines] lines"
# puts "  timing_lines: [llength $timing_lines] lines"
# puts "  cell_lines: [llength $cell_lines] lines"

# 调用各解析函数
parse_area_block   $area_lines
parse_power_block  $power_lines
parse_timing_block $timing_lines
parse_cell_block   $cell_lines
parse_drc_block    $drc_lines

# 计算时序汇总
set WORST_SLACK 999.0
set SLACK_VIOLATED 0
set SLACK_MET 0
foreach path $TIMING_PATHS {
    set s [dict get $path slack]
    set st [dict get $path slack_status]
    if {$s < $WORST_SLACK} {
        set WORST_SLACK $s
        set WORST_SLACK_PATH "[dict get $path startpoint] -> [dict get $path endpoint]"
    }
    if {$st eq "VIOLATED"} { incr SLACK_VIOLATED } else { incr SLACK_MET }
}

# ── 报告输出 ──

if {$FORMAT eq "summary"} {
    puts [format "%s | area=%.2f | power=%.3f | cells=%d | slack=%.3f | violated=%d | warn=%d" \
        $DESIGN_NAME $TOTAL_AREA $TOTAL_POWER $TOTAL_CELLS $WORST_SLACK $SLACK_VIOLATED $NUM_WARNINGS]
    exit 0
}

if {$FORMAT eq "json"} {
    puts "{"
    puts "  \"design\": \"$DESIGN_NAME\","
    puts "  \"date\": \"$DESIGN_DATE\","
    puts "  \"area\": $TOTAL_AREA,"
    puts "  \"power\": $TOTAL_POWER,"
    puts "  \"cells\": $TOTAL_CELLS,"
    puts "  \"warnings\": $NUM_WARNINGS,"
    puts "  \"timing\": \{"
    puts "    \"paths_total\": [llength $TIMING_PATHS],"
    puts "    \"paths_met\": $SLACK_MET,"
    puts "    \"paths_violated\": $SLACK_VIOLATED,"
    puts "    \"worst_slack\": $WORST_SLACK"
    puts "  \}"
    puts "}"
    exit 0
}

if {$FORMAT eq "csv"} {
    puts "design,date,area_um2,power_mW,cells,warnings,paths_total,paths_met,paths_violated,worst_slack_ns"
    puts [format "%s,%s,%.2f,%.3f,%d,%d,%d,%d,%d,%.3f" \
        $DESIGN_NAME $DESIGN_DATE $TOTAL_AREA $TOTAL_POWER $TOTAL_CELLS $NUM_WARNINGS \
        [llength $TIMING_PATHS] $SLACK_MET $SLACK_VIOLATED $WORST_SLACK]
    exit 0
}

# ── 文本报告（默认格式）──
set report ""
proc L {text} { global report; append report "$text\n" }
proc S {{char "="} {w 60}} { global report; append report [string repeat $char $w] "\n" }

S; L "    EDA Synthesis Report Summary"
L "    Design:    $DESIGN_NAME"
L "    Date:      $DESIGN_DATE"
L "    Log File:  $LOG_FILE"
S; L ""

L "--- Area ---"
L [format "  Total Cell Area:  %10.2f um^2" $TOTAL_AREA]
L ""

L "--- Power ---"
L [format "  Total Power:      %10.3f mW" $TOTAL_POWER]
L ""

L "--- Timing ---"
L [format "  Paths Analyzed:   %6d" [llength $TIMING_PATHS]]
L [format "  Paths MET:        %6d" $SLACK_MET]
L [format "  Paths VIOLATED:   %6d" $SLACK_VIOLATED]
L [format "  Worst Slack:      %10.3f ns" $WORST_SLACK]
L "  Worst Path:       $WORST_SLACK_PATH"
L ""

L "--- Cell Count ---"
L [format "  Total Cells:      %6d" $TOTAL_CELLS]
L ""

L "--- DRC Violations ---"
if {[llength $DRC_VIOLATIONS] > 0} {
    foreach v $DRC_VIOLATIONS {
        L [format "  %-30s %3s" [lindex $v 0] [lindex $v 1]]
    }
} else {
    L "  (none reported)"
}
L ""

L "--- Warnings ---"
L [format "  Total Warnings:   %6d" $NUM_WARNINGS]
L ""

L "--- Timing Path Details ---"
set idx 0
foreach path $TIMING_PATHS {
    incr idx
    set s  [dict get $path slack]
    set st [dict get $path slack_status]
    set sp [dict get $path startpoint]
    set ep [dict get $path endpoint]
    set flag ""
    if {$s < 0} { set flag " <<< VIOLATION" }
    L [format "  Path %-2d  slack=%8.3f (%s)  %s -> %s%s" $idx $s $st $sp $ep $flag]
}
L ""

S; L [format "SUMMARY: %s | area=%.2f | power=%.3f | cells=%d | slack=%.3f | violated=%d | warn=%d" \
    $DESIGN_NAME $TOTAL_AREA $TOTAL_POWER $TOTAL_CELLS $WORST_SLACK $SLACK_VIOLATED $NUM_WARNINGS]
S

puts $report

if {$OUTPUT_FILE ne ""} {
    set fp [open $OUTPUT_FILE w]
    puts $fp $report
    close $fp
    puts "\nReport saved to: $OUTPUT_FILE"
}
