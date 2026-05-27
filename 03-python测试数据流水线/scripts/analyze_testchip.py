#!/usr/bin/env python3
"""
=============================================================================
 analyze_testchip.py -- Testchip Measurement Data Analysis Pipeline
=============================================================================
Week 3 项目：芯片流片测试数据收集、管理及分析流程自动化

功能：
  1. 读取 CSV 测试数据
  2. 数据清洗（去异常值、补缺失）
  3. 统计分析（均值/标准差/良率/分bin）
  4. 可视化（直方图/散点/趋势/热力图）
  5. 生成 HTML 或文本报告

用法：
  python3 analyze_testchip.py data/testchip_measurements.csv
  python3 analyze_testchip.py data/testchip_measurements.csv --report html
  python3 analyze_testchip.py data/testchip_measurements.csv --no-plot
  python3 analyze_testchip.py data/testchip_measurements.csv --output-dir outputs/

依赖：
  pip3 install pandas matplotlib numpy
=============================================================================
"""

import argparse
import os
import sys
from datetime import datetime

# ── 尝试导入依赖，缺了就提示 ──
MISSING = []
try:
    import pandas as pd
except ImportError:
    MISSING.append("pandas")
try:
    import numpy as np
except ImportError:
    MISSING.append("numpy")
try:
    import matplotlib
    matplotlib.use("Agg")  # 无 GUI 后端
    import matplotlib.pyplot as plt
except ImportError:
    MISSING.append("matplotlib")

if MISSING:
    print(f"缺少依赖: {', '.join(MISSING)}")
    print(f"安装: pip3 install {' '.join(MISSING)}")
    sys.exit(1)

# ── 全局配置 ──
plt.rcParams["font.size"] = 10
plt.rcParams["axes.titlesize"] = 12
plt.rcParams["figure.dpi"] = 120


# ============================================================
# 1. 数据加载
# ============================================================
def load_data(csv_path):
    """读取 CSV 并做基本校验"""
    if not os.path.exists(csv_path):
        print(f"错误: 文件不存在: {csv_path}")
        sys.exit(1)

    df = pd.read_csv(csv_path)
    print(f"加载数据: {len(df)} 行, {len(df.columns)} 列")
    print(f"列名: {', '.join(df.columns)}")
    return df


# ============================================================
# 2. 数据清洗
# ============================================================
def clean_data(df):
    """去异常值、检查缺失"""
    total = len(df)
    report = []

    # 检查缺失值
    missing = df.isnull().sum()
    missing_cols = missing[missing > 0]
    if len(missing_cols) > 0:
        report.append(f"缺失值列: {dict(missing_cols)}")
        df = df.dropna()
    else:
        report.append("无缺失值")

    # 用 IQR 方法检测 fmax 和 leakage 异常值
    for col, name in [("fmax_mhz", "Fmax"), ("leakage_ua", "Leakage")]:
        if col in df.columns:
            q1 = df[col].quantile(0.25)
            q3 = df[col].quantile(0.75)
            iqr = q3 - q1
            lower = q1 - 3.0 * iqr
            upper = q3 + 3.0 * iqr
            outliers = df[(df[col] < lower) | (df[col] > upper)]
            if len(outliers) > 0:
                report.append(f"{name} 异常值: {len(outliers)} 个 (范围 [{lower:.1f}, {upper:.1f}])")
                df = df[(df[col] >= lower) & (df[col] <= upper)]
            else:
                report.append(f"{name} 无异常值")

    clean_count = len(df)
    removed = total - clean_count
    report.append(f"清洗结果: 保留 {clean_count}/{total}, 移除 {removed}")
    return df, report


# ============================================================
# 3. 良率分析
# ============================================================
def yield_analysis(df):
    """计算良率、按 wafer/lot/speed_bin 分组"""
    results = {}

    total = len(df)
    passed = df[df["pass_flag"] == 1]
    failed = df[df["pass_flag"] == 0]
    results["total_dies"] = total
    results["passed"] = len(passed)
    results["failed"] = len(failed)
    results["yield_pct"] = round(len(passed) / total * 100, 2)

    # 按 wafer 分良率
    if "wafer_id" in df.columns:
        wafer_yield = df.groupby("wafer_id").agg(
            total=("pass_flag", "count"),
            passed=("pass_flag", "sum"),
        )
        wafer_yield["yield_pct"] = round(wafer_yield["passed"] / wafer_yield["total"] * 100, 2)
        results["wafer_yield"] = wafer_yield.to_dict("index")

    # 按 speed_bin 分布
    if "speed_bin" in df.columns:
        bin_counts = passed["speed_bin"].value_counts().to_dict()
        results["speed_bins"] = bin_counts

    return results


# ============================================================
# 4. 参数统计分析
# ============================================================
def parametric_analysis(df):
    """对模拟参数做统计"""
    params = ["vth_n_mv", "vth_p_mv", "idsat_n_ua", "idsat_p_ua",
              "ioff_na", "fmax_mhz", "leakage_ua"]
    stats = {}
    for col in params:
        if col in df.columns:
            s = df[col]
            stats[col] = {
                "mean": round(s.mean(), 2),
                "std": round(s.std(), 2),
                "min": round(s.min(), 2),
                "max": round(s.max(), 2),
                "median": round(s.median(), 2),
                "cpk": round((s.mean() - s.min()) / (3 * s.std()), 3) if s.std() > 0 else 0,
            }
    return stats


# ============================================================
# 5. 可视化
# ============================================================
def generate_plots(df, output_dir):
    """生成 4 张分析图表"""
    os.makedirs(output_dir, exist_ok=True)
    saved = []

    # ── 图1: 关键参数直方图 ──
    fig, axes = plt.subplots(2, 3, figsize=(14, 8))
    plot_params = [
        ("fmax_mhz", "Fmax (MHz)", "steelblue"),
        ("leakage_ua", "Leakage (uA)", "indianred"),
        ("vth_n_mv", "Vth NMOS (mV)", "seagreen"),
        ("vth_p_mv", "Vth PMOS (mV)", "darkorange"),
        ("idsat_n_ua", "Idsat NMOS (uA)", "mediumpurple"),
        ("idsat_p_ua", "Idsat PMOS (uA)", "goldenrod"),
    ]
    for ax, (col, title, color) in zip(axes.flat, plot_params):
        if col in df.columns:
            ax.hist(df[col].dropna(), bins=20, color=color, edgecolor="white", alpha=0.85)
            ax.axvline(df[col].mean(), color="red", linestyle="--", linewidth=1, label=f"mean={df[col].mean():.1f}")
            ax.set_title(title)
            ax.legend(fontsize=7)
    fig.suptitle("Testchip Parametric Distributions", fontweight="bold", y=1.01)
    fig.tight_layout()
    path1 = os.path.join(output_dir, "01_histograms.png")
    fig.savefig(path1, bbox_inches="tight")
    plt.close(fig)
    saved.append(path1)

    # ── 图2: Fmax vs Leakage 散点图（工艺角可视化）──
    fig, ax = plt.subplots(figsize=(8, 6))
    colors = {"FAST": "steelblue", "TYP": "seagreen", "SLOW": "indianred"}
    for bin_name, group in df.groupby("speed_bin"):
        ax.scatter(group["leakage_ua"], group["fmax_mhz"],
                   c=colors.get(bin_name, "gray"), label=bin_name, alpha=0.7, edgecolors="white", s=50)
    ax.set_xlabel("Leakage (uA)")
    ax.set_ylabel("Fmax (MHz)")
    ax.set_title("Fmax vs Leakage by Speed Bin")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    path2 = os.path.join(output_dir, "02_fmax_vs_leakage.png")
    fig.savefig(path2)
    plt.close(fig)
    saved.append(path2)

    # ── 图3: 良率按 Wafer ──
    if "wafer_id" in df.columns:
        wafer = df.groupby("wafer_id").agg(
            total=("pass_flag", "count"),
            yield_pct=("pass_flag", lambda x: x.sum() / len(x) * 100)
        ).reset_index()
        fig, ax = plt.subplots(figsize=(8, 5))
        bars = ax.bar(wafer["wafer_id"], wafer["yield_pct"], color="steelblue", edgecolor="white")
        ax.axhline(y=90, color="red", linestyle="--", label="90% target")
        ax.set_ylabel("Yield (%)")
        ax.set_title("Yield by Wafer")
        ax.legend()
        for bar, pct in zip(bars, wafer["yield_pct"]):
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5, f"{pct:.1f}%",
                    ha="center", fontsize=9)
        fig.tight_layout()
        path3 = os.path.join(output_dir, "03_yield_by_wafer.png")
        fig.savefig(path3)
        plt.close(fig)
        saved.append(path3)

    # ── 图4: Speed Bin 饼图 ──
    if "speed_bin" in df.columns:
        bins = df[df["pass_flag"] == 1]["speed_bin"].value_counts()
        fig, ax = plt.subplots(figsize=(6, 6))
        pie_colors = [colors.get(b, "gray") for b in bins.index]
        ax.pie(bins.values, labels=bins.index, autopct="%1.1f%%", colors=pie_colors,
               startangle=90, explode=[0.02]*len(bins))
        ax.set_title("Speed Bin Distribution (passed dies)")
        fig.tight_layout()
        path4 = os.path.join(output_dir, "04_speed_bin_pie.png")
        fig.savefig(path4)
        plt.close(fig)
        saved.append(path4)

    return saved


# ============================================================
# 6. 报告生成
# ============================================================
def generate_text_report(yield_res, param_stats, clean_report, csv_path, plot_paths):
    """生成文本报告"""
    report = []
    sep = "=" * 62

    report.append(sep)
    report.append("    Testchip Measurement Data Analysis Report")
    report.append(f"    Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append(f"    Data File: {csv_path}")
    report.append(sep)
    report.append("")

    # 清洗
    report.append("--- Data Cleaning ---")
    for r in clean_report:
        report.append(f"  {r}")
    report.append("")

    # 良率
    report.append("--- Yield Analysis ---")
    report.append(f"  Total Dies:       {yield_res['total_dies']}")
    report.append(f"  Passed:           {yield_res['passed']}")
    report.append(f"  Failed:           {yield_res['failed']}")
    report.append(f"  Overall Yield:    {yield_res['yield_pct']}%")
    report.append("")

    if "wafer_yield" in yield_res:
        report.append("  Yield by Wafer:")
        for wid, wy in yield_res["wafer_yield"].items():
            report.append(f"    {wid}: {wy['yield_pct']}% ({wy['passed']}/{wy['total']})")
        report.append("")

    if "speed_bins" in yield_res:
        report.append("  Speed Bin Distribution (passed):")
        for b, c in sorted(yield_res["speed_bins"].items()):
            report.append(f"    {b}: {c}")
        report.append("")

    # 参数统计
    report.append("--- Parametric Statistics ---")
    header = f"  {'Parameter':<16} {'Mean':>10} {'Std':>8} {'Min':>8} {'Max':>8} {'Cpk':>7}"
    report.append(header)
    report.append("  " + "-" * 57)
    for col, s in param_stats.items():
        report.append(f"  {col:<16} {s['mean']:>10.2f} {s['std']:>8.2f} {s['min']:>8.2f} {s['max']:>8.2f} {s['cpk']:>7.3f}")
    report.append("")

    # 图表
    report.append("--- Generated Plots ---")
    for p in plot_paths:
        report.append(f"  {p}")
    report.append("")

    report.append(sep)
    report.append("    Analysis Complete.")
    report.append(sep)

    return "\n".join(report)


def generate_html_report(yield_res, param_stats, clean_report, csv_path, plot_paths):
    """生成 HTML 报告"""
    plots_html = "".join(
        f'<div class="plot"><h3>{os.path.basename(p)}</h3><img src="{p}" style="max-width:100%"></div>'
        for p in plot_paths
    )

    rows = ""
    for col, s in param_stats.items():
        rows += f"<tr><td>{col}</td><td>{s['mean']:.2f}</td><td>{s['std']:.2f}</td><td>{s['min']:.2f}</td><td>{s['max']:.2f}</td><td>{s['cpk']:.3f}</td></tr>"

    html = f"""<!DOCTYPE html>
<html lang="zh">
<head><meta charset="UTF-8"><title>Testchip Analysis Report</title>
<style>
  body {{ font-family: -apple-system, sans-serif; max-width: 960px; margin: 40px auto; padding: 20px; background: #f8f9fa; color: #222; }}
  h1 {{ color: #1a56db; border-bottom: 3px solid #1a56db; padding-bottom: 10px; }}
  h2 {{ color: #333; margin-top: 32px; }}
  table {{ border-collapse: collapse; width: 100%; margin: 12px 0; }}
  th,td {{ padding: 8px 12px; text-align: right; border-bottom: 1px solid #ddd; }}
  th {{ background: #e9ecef; }}
  td:first-child {{ text-align: left; font-family: monospace; }}
  .stat {{ background: white; padding: 16px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,.1); }}
  .plot {{ margin: 20px 0; }}
  .yield {{ font-size: 24px; font-weight: bold; color: {'green' if yield_res['yield_pct'] > 90 else 'orange'}; }}
</style></head>
<body>
<h1>Testchip Measurement Data Analysis</h1>
<p>Data: {csv_path} &nbsp;|&nbsp; Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
<p>Yield: <span class="yield">{yield_res['yield_pct']}%</span> &nbsp;({yield_res['passed']}/{yield_res['total_dies']} passed)</p>

<h2>Parametric Statistics</h2>
<div class="stat">
<table><tr><th>Parameter</th><th>Mean</th><th>Std</th><th>Min</th><th>Max</th><th>Cpk</th></tr>{rows}</table>
</div>

<h2>Plots</h2>
{plots_html}

<h2>Cleaning Log</h2><ul>
{''.join(f'<li>{r}</li>' for r in clean_report)}
</ul>

<p style="color:#888;margin-top:40px">chip-cad-learning Week 3</p>
</body></html>"""
    return html


# ============================================================
# main
# ============================================================
def main():
    parser = argparse.ArgumentParser(description="Testchip Measurement Data Analysis Pipeline")
    parser.add_argument("csv", help="Path to measurement CSV file")
    parser.add_argument("--report", choices=["text", "html"], default="text", help="Report format")
    parser.add_argument("--no-plot", action="store_true", help="Skip plot generation")
    parser.add_argument("--output-dir", default="outputs", help="Output directory")
    args = parser.parse_args()

    print("=" * 50)
    print("  Testchip Data Analysis Pipeline v1.0")
    print("=" * 50)
    print()

    # 1. 加载
    print("[1/5] Loading data...")
    df = load_data(args.csv)

    # 2. 清洗
    print("[2/5] Cleaning data...")
    df, clean_report = clean_data(df)

    # 3. 良率
    print("[3/5] Yield analysis...")
    yield_res = yield_analysis(df)
    print(f"      Yield: {yield_res['yield_pct']}% ({yield_res['passed']}/{yield_res['total_dies']})")

    # 4. 参数统计
    print("[4/5] Parametric statistics...")
    param_stats = parametric_analysis(df)

    # 5. 可视化 + 报告
    print("[5/5] Generating report...")
    plot_paths = []
    if not args.no_plot:
        plot_paths = generate_plots(df, args.output_dir)
        print(f"      {len(plot_paths)} plot(s) saved to {args.output_dir}/")

    if args.report == "html":
        report = generate_html_report(yield_res, param_stats, clean_report, args.csv, plot_paths)
        report_path = os.path.join(args.output_dir, "analysis_report.html")
    else:
        report = generate_text_report(yield_res, param_stats, clean_report, args.csv, plot_paths)
        report_path = os.path.join(args.output_dir, "analysis_report.txt")

    os.makedirs(args.output_dir, exist_ok=True)
    with open(report_path, "w") as f:
        f.write(report)
    print(f"      Report saved: {report_path}")
    print()
    print(report[:500] + "..." if len(report) > 500 else report)
    print()
    print("Done.")


if __name__ == "__main__":
    main()
