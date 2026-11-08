#!/usr/bin/env bash
#
# Source      : test/test-lib-layout.sh
# Dependencies: src/lib-testing.sh
# FUT         : src/lib-layout.sh
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__TEST_LIB_LAYOUT_SH_LOADED:-}" ]] && return 0
declare -rx G__TEST_LIB_LAYOUT_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../src/lib-testing.sh"

# ==================================================================================================
# Global Constants
# ==================================================================================================

TEST_SCRIPT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly TEST_SCRIPT_PARENT_DIR

FUT_RELATIVE_PATH="../src/lib-layout.sh"
readonly FUT_RELATIVE_PATH

FUT_DEPENDENCY_RELATIVE_PATHS=(
    "../src/lib-base.sh"
    "../src/lib-validation.sh"
    "../src/lib-assertion.sh"
    "../src/lib-text.sh"
)
readonly FUT_DEPENDENCY_RELATIVE_PATHS

# ==================================================================================================
# Global Variables
# ==================================================================================================

# ==================================================================================================
# Helper Functions
# ==================================================================================================

# ==================================================================================================
# Test Cases
# ==================================================================================================

#
# Equivalence class table of `lib_layout__draw_divider`
# ID    ret_val_ref char    width   Expected Output / Behavior      Return Code
# --    ----------- -----   -----   --------------------------      --------------------
# TC1   (missing)   (miss)  (miss)  exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "var" "-"   80      (extra) exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   "var" ""    80      (none)  exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC4   "var" "-"   "abc"   (none)  exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC5   "var" "="   10      (none)  divider of 10 '='               G__ERR_OK
# TC6   "var" "-"   (none)  (none)  default width 80 '-'            G__ERR_OK
#

function tc__draw_divider__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_divider"

    (lib_layout__draw_divider)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__draw_divider__tc2__too_many_args() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_divider"

    (lib_layout__draw_divider _result "=" 80 "extra")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__draw_divider__tc3__empty_char() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_divider"

    (lib_layout__draw_divider _result "" 80)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__draw_divider__tc4__non_numeric_width() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_divider"

    (lib_layout__draw_divider _result "=" "bad_width")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__draw_divider__tc5__custom_width() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_divider"

    lib_layout__draw_divider _result "=" 10
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "==========" "$_result" "Expected 10 equals characters"
}

function tc__draw_divider__tc6__default_width() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_divider"

    lib_layout__draw_divider _result "-"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "80" "${#_result}" "Expected default width 80"
}

#
# Equivalence class table of `lib_layout__draw_table`
# ID    ncols   cells       summary     Expected Output         Return Code
# --    -----   -----       -------     ----------------------- ------------------------
# TC1   (miss)  (missing)   (none)      exits with MISSING_ARG  G__ERR_MISSING_ARG
# TC2   2       3 cells     (none)      incompatible cell count G__ERR_INCOMPATIBLE_ARGS
# TC3   2       4 cells     "Summary"   table with summary      G__ERR_OK
# TC4   2       4 cells     ""          table without summary   G__ERR_OK
#

function tc__draw_table__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_table"

    (lib_layout__draw_table)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__draw_table__tc2__incompatible_cell_count() {
    local _table=""
    local -a _cells=("A" "B" "C")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_table"

    (lib_layout__draw_table _table 2 _cells)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_INCOMPATIBLE_ARGS" "$_error_code"
}

function tc__draw_table__tc3__table_with_summary() {
    local _table=""
    local -a _cells=("Col1" "Col2" "Val1" "Val2")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_table"

    lib_layout__draw_table _table 2 _cells "My Table Summary"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_table" | grep -q "My Table Summary"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected summary text in table output"

    echo "$_table" | grep -q "Col1"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected cell text in table output"
}

function tc__draw_table__tc4__table_without_summary() {
    local _table=""
    local -a _cells=("Name" "Age" "Alice" "30")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_table"

    lib_layout__draw_table _table 2 _cells ""
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_table" | grep -q "Name"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected header in table output"

    echo "$_table" | grep -q "Alice"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected row data in table output"
}

# ==================================================================================================
# Entry Point
# ==================================================================================================
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

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
