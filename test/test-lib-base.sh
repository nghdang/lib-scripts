#!/usr/bin/env bash
#
# Source      : test/test-lib-base.sh
# Dependencies: src/lib-testing.sh
# FUT         : src/lib-base.sh
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__TEST_LIB_BASE_SH_LOADED:-}" ]] && return 0
declare -gr G__TEST_LIB_BASE_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../src/lib-testing.sh"

# ==================================================================================================
# Global Constants
# ==================================================================================================

TEST_SCRIPT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly TEST_SCRIPT_PARENT_DIR

FUT_RELATIVE_PATH="../src/lib-base.sh"
readonly FUT_RELATIVE_PATH

FUT_DEPENDENCY_RELATIVE_PATHS=()
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
# Equivalence class table of `lib_base__traceback`
# ID    min_stack       Expected STDERR                     Return Code
# --    ---------       -------------------------------     -----------
# TC1   (not provided)  contains Traceback header           G__ERR_OK
# TC2   non-number      contains Traceback header           G__ERR_OK
# TC3   0               contains frame 0 in traceback       G__ERR_OK
# TC4   high number     contains Traceback header only      G__ERR_OK
#

function tc__traceback__tc1__default_min_stack() {
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__traceback"

    _stderr="$(lib_base__traceback 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stderr" | grep -q "Traceback (most recent call last):"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected traceback header in STDERR"
}

function tc__traceback__tc2__invalid_min_stack() {
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__traceback"

    _stderr="$(lib_base__traceback "invalid" 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stderr" | grep -q "Traceback (most recent call last):"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected traceback header in STDERR"
}

function tc__traceback__tc3__zero_min_stack() {
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__traceback"

    _stderr="$(lib_base__traceback 0 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stderr" | grep -q "in tc__traceback__tc3__zero_min_stack"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected caller frame in STDERR"
}

function tc__traceback__tc4__high_min_stack() {
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__traceback"

    _stderr="$(lib_base__traceback 99 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stderr" | grep -q "Traceback (most recent call last):"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected traceback header in STDERR"

    echo "$_stderr" | grep -q "  File "
    lib_testing__eq "1" "$?" "Expected no frame lines for high min_stack"
}

#
# Equivalence class table of `lib_base__throw`
# ID    error_code          message         Expected STDERR / Exit Code     Exit Code
# --    -----------------   ------------    ---------------------------     -------------------
# TC1   (missing)           (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   $G__ERR_OK          too many args   exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   non-number          "message"       exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC4   $G__ERR_NOT_FOUND   "File missing"  exits with 20, STDERR has name  G__ERR_NOT_FOUND
# TC5   99                  "Custom err"    exits with 99, STDERR Unknown   99
#

function tc__throw__tc1__missing_args() {
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__throw"

    _stderr="$(lib_base__throw 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"

    echo "$_stderr" | grep -q "ERR_MISSING_ARG"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected ERR_MISSING_ARG in STDERR"
}

function tc__throw__tc2__too_many_args() {
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__throw"

    _stderr="$(lib_base__throw "$G__ERR_OK" "message" "extra" 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"

    echo "$_stderr" | grep -q "ERR_TOO_MANY_ARGS"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected ERR_TOO_MANY_ARGS in STDERR"
}

function tc__throw__tc3__non_numeric_error_code() {
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__throw"

    _stderr="$(lib_base__throw "invalid_code" "error message" 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"

    echo "$_stderr" | grep -q "ERR_TYPE_ERROR"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected ERR_TYPE_ERROR in STDERR"
}

function tc__throw__tc4__known_error_code() {
    local _MESSAGE="Target file was not found"
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__throw"

    _stderr="$(lib_base__throw "$G__ERR_NOT_FOUND" "$_MESSAGE" 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_FOUND" "$_error_code"

    echo "$_stderr" | grep -q "ERR_NOT_FOUND"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected ERR_NOT_FOUND in STDERR"

    echo "$_stderr" | grep -q "$_MESSAGE"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected exception message in STDERR"
}

function tc__throw__tc5__unknown_error_code() {
    local _UNKNOWN_CODE=99
    local _MESSAGE="Custom unmapped exception"
    local _stderr=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_base__throw"

    _stderr="$(lib_base__throw "$_UNKNOWN_CODE" "$_MESSAGE" 2>&1)"
    _error_code=$?
    lib_testing__error_code_eq "$_UNKNOWN_CODE" "$_error_code"

    echo "$_stderr" | grep -q "Unknown ($_UNKNOWN_CODE)"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected Unknown error name in STDERR"

    echo "$_stderr" | grep -q "$_MESSAGE"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected exception message in STDERR"
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
