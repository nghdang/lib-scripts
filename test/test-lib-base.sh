#!/usr/bin/env bash
#
# Source      : test/test-lib-base.sh
# Dependencies: test/lib-tests.sh
# FUT         : src/lib-base.sh
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__TEST_LIB_BASE_SH_LOADED:-}" ]] && return 0
export G__TEST_LIB_BASE_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-testing.sh"

# =============================================================================
# Global Constants
# =============================================================================

TEST_SCRIPT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly TEST_SCRIPT_PARENT_DIR

FUT_RELATIVE_PATH="../src/lib-base.sh"
readonly FUT_RELATIVE_PATH

FUT_DEPENDENCY_RELATIVE_PATHS=()
readonly FUT_DEPENDENCY_RELATIVE_PATHS

# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Helper Functions
# =============================================================================

# =============================================================================
# Test Cases
# =============================================================================

#
# Equivalence class table of `lib_logging__debug`
# ID    LOG_LEVEL               message         stack           Expected                            Return Code         File Context
# --    -------------------     -----------     ------------    -------------------------------     ------------------  -------------------
# TC1   not relevant            not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   G__LOG_LEVEL_DEBUG      non-empty       non-number      STDOUT does not contain message     G__ERR_TYPE_ERROR  -
# TC3   G__LOG_LEVEL_DEBUG      non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-base.sh
# TC4   G__LOG_LEVEL_DEBUG      non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-base.sh
# TC5   >G__LOG_LEVEL_DEBUG     non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

# =============================================================================
# Entry Point
# =============================================================================
function main() {
    set -u

    local _fut_path=""
    local _fut_relative_path=""
    local -a fut_dependency_paths=()

    _fut_path="$(realpath "${TEST_SCRIPT_PARENT_DIR}/${FUT_RELATIVE_PATH}")"

    for _fut_relative_path in "${FUT_DEPENDENCY_RELATIVE_PATHS[@]}"; do
        fut_dependency_paths+=("$(realpath "${TEST_SCRIPT_PARENT_DIR}/${_fut_relative_path}")")
    done

    lib_testing__test_main "$_fut_path" "${fut_dependency_paths[@]}"
}

main
