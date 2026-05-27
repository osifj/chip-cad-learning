#!/bin/bash
# ============================================================
# setup_env.sh -- EDA environment variable setup module
#
# Usage: source this file then call setup_eda_env
# Exports EDA_* env vars and populates ENV_REPORT array
# ============================================================

declare -a ENV_REPORT=()

# Get variable value safely (works under set -u)
getvar() {
    local var="$1"
    eval "echo \"\${${var}:-}\""
}

# safe_export <var_name> <value> <description>
safe_export() {
    local var="$1"
    local val="$2"
    local desc="$3"
    local old_val
    old_val=$(getvar "$var")

    if [[ -n "$old_val" ]]; then
        if [[ "$old_val" = "$val" ]]; then
            ENV_REPORT+=("  [OK]   $var already set ($desc)")
        else
            ENV_REPORT+=("  [FIX]  $var corrected: ${old_val} -> ${val} ($desc)")
        fi
    else
        ENV_REPORT+=("  [SET]  $var = $val ($desc)")
    fi
    export "$var"="$val"
}

# append_path <dir>
append_path() {
    local dir="$1"
    if [[ -d "$dir" ]] || [[ "${SIMULATE:-false}" = true ]]; then
        export PATH="$dir:$PATH"
    fi
}

# setup_eda_env -- configure all EDA toolchain environment variables
setup_eda_env() {
    ENV_REPORT+=("======== EDA Environment Setup ========")
    ENV_REPORT+=("")

    local cad_root="${CAD_ROOT:-/opt/eda}"
    local snps_ver="${SYNOPSYS_VERSION:-2024.03}"
    local cds_ver="${CADENCE_VERSION:-24.1}"
    local mentor_ver="${MENTOR_VERSION:-2024.1}"
    local pdk_root="${PDK_ROOT:-/opt/pdk}"
    local pdk_name="${PDK_NAME:-tsmc7nm}"
    local license="${LM_LICENSE_FILE:-5280@license-server}"

    ENV_REPORT+=("CAD_ROOT        = $cad_root")
    ENV_REPORT+=("SYNOPSYS_VERSION = $snps_ver")
    ENV_REPORT+=("CADENCE_VERSION  = $cds_ver")
    ENV_REPORT+=("")

    # Synopsys tools
    local snps_root="${cad_root}/synopsys/${snps_ver}"
    safe_export "SNPS_ROOT"    "$snps_root"                          "Synopsys root"
    safe_export "DC_HOME"      "${snps_root}/DC"                     "Design Compiler"
    safe_export "ICC2_HOME"    "${snps_root}/ICC2"                   "IC Compiler II"
    safe_export "PT_HOME"      "${snps_root}/PT"                     "PrimeTime STA"

    # Cadence tools
    local cds_root="${cad_root}/cadence/${cds_ver}"
    safe_export "CDS_ROOT"     "$cds_root"                           "Cadence root"
    safe_export "INNOVUS_HOME" "${cds_root}/INNOVUS"                 "Innovus P&R"
    safe_export "TEMPUS_HOME"  "${cds_root}/TEMPUS"                  "Tempus STA"

    # Mentor tools
    local mentor_root="${cad_root}/mentor/${mentor_ver}"
    safe_export "MENTOR_HOME"  "$mentor_root"                        "Mentor Graphics"
    safe_export "CALIBRE_HOME" "${mentor_root}/calibre"              "Calibre DRC/LVS"

    # PATH (EDA bins before system bins)
    append_path "${SNPS_ROOT}/bin"
    append_path "${CDS_ROOT}/bin"
    append_path "${MENTOR_HOME}/bin"
    append_path "${DC_HOME}/bin"
    append_path "${ICC2_HOME}/bin"
    append_path "${PT_HOME}/bin"
    append_path "${CALIBRE_HOME}/bin"
    ENV_REPORT+=("  [OK]   PATH prepended with EDA tool bin dirs")

    # LD_LIBRARY_PATH
    local lib_paths="${SNPS_ROOT}/lib:${CDS_ROOT}/lib:${MENTOR_HOME}/lib"
    local old_ld
    old_ld=$(getvar "LD_LIBRARY_PATH")
    if [[ -n "$old_ld" ]]; then
        lib_paths="${lib_paths}:${old_ld}"
    fi
    safe_export "LD_LIBRARY_PATH" "$lib_paths" "dynamic library search path"

    # License
    safe_export "LM_LICENSE_FILE" "$license" "license server address"

    # PDK
    safe_export "PDK_HOME" "${pdk_root}/${pdk_name}" "process design kit"

    # MANPATH (if EDA man pages exist)
    if [[ -d "${SNPS_ROOT}/man" ]] || [[ "${SIMULATE:-false}" = true ]]; then
        local old_man
        old_man=$(getvar "MANPATH")
        export MANPATH="${SNPS_ROOT}/man:${CDS_ROOT}/man:${old_man}"
        ENV_REPORT+=("  [OK]   MANPATH updated for EDA man pages")
    fi

    ENV_REPORT+=("")
    ENV_REPORT+=("=======================================")
}
