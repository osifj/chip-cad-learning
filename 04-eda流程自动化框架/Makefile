# ============================================================
# Makefile -- EDA Flow Orchestrator (Week 4)
#
# 模拟芯片设计全流程：综合 → 布局布线 → 时序分析 → 物理验证
# 每步失败自动记录日志，支持断点续跑。
#
# 用法：
#   make all              # 跑全流程
#   make synth            # 只跑综合
#   make clean            # 清理所有输出
#   make status           # 查看流程状态
#   DESIGN=my_chip make   # 指定设计名
# ============================================================

DESIGN     ?= aes_core_top
FLOW_DIR   := $(shell pwd)
RUN_DIR    := $(FLOW_DIR)/flow
LOG_DIR    := $(FLOW_DIR)/logs
RESUME     ?= 1     # 1=断点续跑, 0=从头跑
TECH       ?= tsmc7nm
CLK_MHZ    ?= 1200

# ── 步骤定义 ──
STEPS = synth place cts route sta pv

# ── 每个步骤的状态文件 ──
SYNTH_DONE  = $(RUN_DIR)/.synth_done
PLACE_DONE  = $(RUN_DIR)/.place_done
CTS_DONE    = $(RUN_DIR)/.cts_done
ROUTE_DONE  = $(RUN_DIR)/.route_done
STA_DONE    = $(RUN_DIR)/.sta_done
PV_DONE     = $(RUN_DIR)/.pv_done

# ── 日志文件 ──
SYNTH_LOG   = $(LOG_DIR)/01_synthesis.log
PLACE_LOG   = $(LOG_DIR)/02_placement.log
CTS_LOG     = $(LOG_DIR)/03_cts.log
ROUTE_LOG   = $(LOG_DIR)/04_routing.log
STA_LOG     = $(LOG_DIR)/05_sta.log
PV_LOG      = $(LOG_DIR)/06_pv.log

.PHONY: all clean status help synth place cts route sta pv

# ── 全流程 ──
all: init synth place cts route sta pv summary
	@echo ""
	@echo "[FLOW] All steps completed for $(DESIGN)"

# ── 初始化目录 ──
init:
	@mkdir -p $(RUN_DIR) $(LOG_DIR)
	@echo "========================================" | tee $(LOG_DIR)/flow.log
	@echo "  EDA Flow: $(DESIGN) @ $(TECH)" | tee -a $(LOG_DIR)/flow.log
	@echo "  Clock: $(CLK_MHZ) MHz" | tee -a $(LOG_DIR)/flow.log
	@echo "  Started: $$(date)" | tee -a $(LOG_DIR)/flow.log
	@echo "========================================" | tee -a $(LOG_DIR)/flow.log

# ── 综合 (Synthesis) ──
synth:
	@if [ "$(RESUME)" = "1" ] && [ -f "$(SYNTH_DONE)" ]; then \
		echo "[SYNTH] Already done (resume). Skip."; \
	else \
		echo "[SYNTH] Running synthesis for $(DESIGN)..."; \
		./scripts/run_synth.sh $(DESIGN) $(TECH) $(CLK_MHZ) > $(SYNTH_LOG) 2>&1; \
		if [ $$? -eq 0 ]; then touch $(SYNTH_DONE); echo "[SYNTH] OK"; \
		else echo "[SYNTH] FAILED - check $(SYNTH_LOG)"; exit 1; fi; \
	fi

# ── 布局 (Placement) ──
place:
	@if [ "$(RESUME)" = "1" ] && [ -f "$(PLACE_DONE)" ]; then \
		echo "[PLACE] Already done (resume). Skip."; \
	else \
		echo "[PLACE] Running placement..."; \
		./scripts/run_place.sh $(DESIGN) > $(PLACE_LOG) 2>&1; \
		if [ $$? -eq 0 ]; then touch $(PLACE_DONE); echo "[PLACE] OK"; \
		else echo "[PLACE] FAILED - check $(PLACE_LOG)"; exit 1; fi; \
	fi

# ── 时钟树综合 (CTS) ──
cts:
	@if [ "$(RESUME)" = "1" ] && [ -f "$(CTS_DONE)" ]; then \
		echo "[CTS] Already done (resume). Skip."; \
	else \
		echo "[CTS] Running clock tree synthesis..."; \
		./scripts/run_cts.sh $(DESIGN) > $(CTS_LOG) 2>&1; \
		if [ $$? -eq 0 ]; then touch $(CTS_DONE); echo "[CTS] OK"; \
		else echo "[CTS] FAILED - check $(CTS_LOG)"; exit 1; fi; \
	fi

# ── 布线 (Routing) ──
route:
	@if [ "$(RESUME)" = "1" ] && [ -f "$(ROUTE_DONE)" ]; then \
		echo "[ROUTE] Already done (resume). Skip."; \
	else \
		echo "[ROUTE] Running routing..."; \
		./scripts/run_route.sh $(DESIGN) > $(ROUTE_LOG) 2>&1; \
		if [ $$? -eq 0 ]; then touch $(ROUTE_DONE); echo "[ROUTE] OK"; \
		else echo "[ROUTE] FAILED - check $(ROUTE_LOG)"; exit 1; fi; \
	fi

# ── 静态时序分析 (STA) ──
sta:
	@if [ "$(RESUME)" = "1" ] && [ -f "$(STA_DONE)" ]; then \
		echo "[STA] Already done (resume). Skip."; \
	else \
		echo "[STA] Running static timing analysis..."; \
		./scripts/run_sta.sh $(DESIGN) $(CLK_MHZ) > $(STA_LOG) 2>&1; \
		if [ $$? -eq 0 ]; then touch $(STA_DONE); echo "[STA] OK"; \
		else echo "[STA] FAILED - check $(STA_LOG)"; exit 1; fi; \
	fi

# ── 物理验证 (Physical Verification: DRC/LVS) ──
pv:
	@if [ "$(RESUME)" = "1" ] && [ -f "$(PV_DONE)" ]; then \
		echo "[PV] Already done (resume). Skip."; \
	else \
		echo "[PV] Running physical verification..."; \
		./scripts/run_pv.sh $(DESIGN) $(TECH) > $(PV_LOG) 2>&1; \
		if [ $$? -eq 0 ]; then touch $(PV_DONE); echo "[PV] OK"; \
		else echo "[PV] FAILED - check $(PV_LOG)"; exit 1; fi; \
	fi

# ── 汇总报告 ──
summary:
	@echo ""
	@echo "========================================"
	@echo "  Flow Summary: $(DESIGN)"
	@echo "========================================"
	@for step in synth place cts route sta pv; do \
		done_file="$(RUN_DIR)/.$${step}_done"; \
		if [ -f "$$done_file" ]; then \
			echo "  [PASS] $$step"; \
		else \
			echo "  [FAIL] $$step"; \
		fi; \
	done
	@echo "========================================"
	@python3 scripts/flow_report.py $(DESIGN) $(LOG_DIR) 2>/dev/null || echo "  (report script not available)"

# ── 清理 ──
clean:
	@echo "Cleaning flow outputs..."
	@rm -rf $(RUN_DIR) $(LOG_DIR)
	@echo "Clean."

# ── 状态 ──
status:
	@echo "Flow status for $(DESIGN):"
	@for step in synth place cts route sta pv; do \
		done_file="$(RUN_DIR)/.$${step}_done"; \
		log_file="$(LOG_DIR)/$$(printf '%02d' $$(echo synth place cts route sta pv | tr ' ' '\n' | grep -n $$step | cut -d: -f1))_$$step.log"; \
		if [ -f "$$done_file" ]; then \
			echo "  [DONE] $$step"; \
		else \
			echo "  [PEND] $$step"; \
		fi; \
	done

# ── 帮助 ──
help:
	@echo "EDA Flow Orchestrator"
	@echo "  make all              Run full flow"
	@echo "  make synth/place/...  Run single step"
	@echo "  make status           Check flow status"
	@echo "  make clean            Remove all outputs"
	@echo "  RESUME=0 make all     Restart from scratch"
	@echo "  DESIGN=xxx make all   Specify design name"
