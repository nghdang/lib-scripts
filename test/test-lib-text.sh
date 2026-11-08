#!/usr/bin/env bash
#
# Source      : test/test-lib-text.sh
# Dependencies: src/lib-testing.sh
# FUT         : src/lib-text.sh
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__TEST_LIB_TEXT_SH_LOADED:-}" ]] && return 0
declare -gr G__TEST_LIB_TEXT_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../src/lib-testing.sh"

# ==================================================================================================
# Global Constants
# ==================================================================================================

TEST_SCRIPT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly TEST_SCRIPT_PARENT_DIR

FUT_RELATIVE_PATH="../src/lib-text.sh"
readonly FUT_RELATIVE_PATH

FUT_DEPENDENCY_RELATIVE_PATHS=(
    "../src/lib-base.sh"
    "../src/lib-validation.sh"
    "../src/lib-assertion.sh"
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
# Equivalence class table of `lib_text__align`
# ID    ret_val_ref text    width   align   Expected Output         Return Code
# --    ----------- -----   -----   -----   ----------------------- --------------------
# TC1   (missing)   (miss)  (miss)  (miss)  exits with MISSING_ARG  G__ERR_MISSING_ARG
# TC2   "var" "a"   10      "left"  "extra" exits with TOO_MANY_ARG G__ERR_TOO_MANY_ARGS
# TC3   "var" "cat" "abc"   "left"  (none)  exits with TYPE_ERROR   G__ERR_TYPE_ERROR
# TC4   "var" "cat" 10      "bad"   (none)  exits with TYPE_ERROR   G__ERR_TYPE_ERROR
# TC5   "var" "cat" 10      "left"  (none)  left-padded             G__ERR_OK
# TC6   "var" "cat" 10      "right" (none)  right-padded            G__ERR_OK
# TC7   "var" "cat" 10      "center"(none)  center-padded           G__ERR_OK
#

function tc__align__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__align"

    (lib_text__align)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__align__tc2__too_many_args() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__align"

    (lib_text__align _result "text" 10 "left" "extra")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__align__tc3__invalid_width() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__align"

    (lib_text__align _result "text" "not_a_number" "left")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__align__tc4__invalid_align() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__align"

    (lib_text__align _result "text" 10 "diagonal")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__align__tc5__left_align() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__align"

    lib_text__align _result "cat" 10 "left"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "cat       " "$_result" "Expected left-aligned text"
}

function tc__align__tc6__right_align() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__align"

    lib_text__align _result "cat" 10 "right"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "       cat" "$_result" "Expected right-aligned text"
}

function tc__align__tc7__center_align() {
    local _result=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__align"

    lib_text__align _result "cat" 10 "center"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "   cat    " "$_result" "Expected center-aligned text"
}

#
# Equivalence class table of `lib_text__find_max_len`
# ID    ret_val_ref items           Expected Output         Return Code
# --    ----------- --------------- ----------------------- -------------------
# TC1   (missing)   (missing)       exits with MISSING_ARG  G__ERR_MISSING_ARG
# TC2   "var"       "a"             max_len = 1             G__ERR_OK
# TC3   "var"       "hi" "longest"  max_len = 7             G__ERR_OK
#

function tc__find_max_len__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__find_max_len"

    (lib_text__find_max_len)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__find_max_len__tc2__single_item() {
    local _max_len=0
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__find_max_len"

    lib_text__find_max_len _max_len "hello"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "5" "$_max_len" "Expected length 5"
}

function tc__find_max_len__tc3__multiple_items() {
    local _max_len=0
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_text__find_max_len"

    lib_text__find_max_len _max_len "a" "elephant" "cat" "dog"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "8" "$_max_len" "Expected length 8 for elephant"
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
