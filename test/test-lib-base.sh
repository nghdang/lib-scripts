#!/usr/bin/env bash
#
# Source      : test/test-lib-base.sh
# Dependencies: test/lib-tests.sh
# FUT         : src/lib-base.sh
#

# ----- Source Guard -----
[[ -n "${G__TEST_LIB_LOGGING_SH_LOADED:-}" ]] && return 0
export G__TEST_LIB_LOGGING_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================

TEST_SCRIPT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly TEST_SCRIPT_PARENT_DIR

LIB_TESTS_PATH="${TEST_SCRIPT_PARENT_DIR}/lib-tests.sh"
readonly LIB_TESTS_PATH

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
# Equivalence class table of `lib_base__debug`
# ID    LOG_LEVEL               message         stack           Expected                            Return Code         File Context
# --    -------------------     -----------     ------------    -------------------------------     ------------------  -------------------
# TC1   not relevant            not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   G__LOG_LEVEL_DEBUG      non-empty       non-number      STDOUT does not contain message     G__ERR_TYPE_ERROR  -
# TC3   G__LOG_LEVEL_DEBUG      non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-base.sh
# TC4   G__LOG_LEVEL_DEBUG      non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-base.sh
# TC5   >G__LOG_LEVEL_DEBUG     non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

function tc__debug__tc1__missing_message() {
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__debug"

    _stdout="$(lib_base__debug)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__debug__tc2__invalid_stack() {
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__debug"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_DEBUG" lib_base__debug "$_MESSAGE" "invalid_stack")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__debug__tc3__default_stack() {
    local _FILE_CONTEXT="lib-base.sh"
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__debug"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_DEBUG" lib_base__debug "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__debug__tc4__custom_stack() {
    local _FILE_CONTEXT="test-lib-base.sh"
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__debug"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_DEBUG" lib_base__debug "$_MESSAGE" 1)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__debug__tc5__suppression() {
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__debug"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" lib_base__debug "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

#
# Equivalence class table of `lib_base__info`
# ID    LOG_LEVEL               message         stack           Expected                            Return Code         File Context
# --    ------------------      -----------     ------------    -------------------------------     ------------------  -------------------
# TC1   not relevant            not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   G__LOG_LEVEL_INFO       non-empty       non-number      STDOUT does not contain message     G__ERR_TYPE_ERROR  -
# TC3   G__LOG_LEVEL_INFO       non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-base.sh
# TC4   G__LOG_LEVEL_INFO       non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-base.sh
# TC5   >G__LOG_LEVEL_INFO      non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

function tc__info__tc1__missing_message() {
    local _MESSAGE="This is info message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__info"

    _stdout="$(lib_base__info)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__info__tc2__invalid_stack() {
    local _MESSAGE="This is info message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__info"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" lib_base__info "$_MESSAGE" "invalid_stack")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__info__tc3__default_stack() {
    local _FILE_CONTEXT="lib-base.sh"
    local _MESSAGE="This is info message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__info"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" lib_base__info "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__info__tc4__custom_stack() {
    local _FILE_CONTEXT="test-lib-base.sh"
    local _MESSAGE="This is info message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__info"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" lib_base__info "$_MESSAGE" 1)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__info__tc5__suppression() {
    local _MESSAGE="This is info message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__info"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" lib_base__info "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

#
# Equivalence class table of `lib_base__warn`
# ID    LOG_LEVEL               message         stack           Expected                            Return Code         File Context
# --    ------------------      -----------     ------------    -------------------------------     ------------------  -------------------
# TC1   not relevant            not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   G__LOG_LEVEL_WARN       non-empty       non-number      STDOUT does not contain message     G__ERR_TYPE_ERROR  -
# TC3   G__LOG_LEVEL_WARN       non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-base.sh
# TC4   G__LOG_LEVEL_WARN       non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-base.sh
# TC5   >G__LOG_LEVEL_WARN      non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

function tc__warn__tc1__missing_message() {
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__warn"

    _stdout="$(lib_base__warn)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__warn__tc2__invalid_stack() {
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__warn"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" lib_base__warn "$_MESSAGE" "invalid_stack")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__warn__tc3__default_stack() {
    local _FILE_CONTEXT="lib-base.sh"
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__warn"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" lib_base__warn "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__warn__tc4__custom_stack() {
    local _FILE_CONTEXT="test-lib-base.sh"
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__warn"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" lib_base__warn "$_MESSAGE" 1)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__warn__tc5__suppression() {
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__warn"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" lib_base__warn "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

#
# Equivalence class table of `lib_base__error`
# ID    LOG_LEVEL               message         stack           Expected                            Return Code         File Context
# --    -------------------     -----------     ------------    -------------------------------     ------------------  -------------------
# TC1   not relevant            not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   G__LOG_LEVEL_ERROR      non-empty       non-number      STDOUT does not contain message     G__ERR_TYPE_ERROR  -
# TC3   G__LOG_LEVEL_ERROR      non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-base.sh
# TC4   G__LOG_LEVEL_ERROR      non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-base.sh
# TC5   >G__LOG_LEVEL_ERROR     non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

function tc__error__tc1__missing_message() {
    local _MESSAGE="This is error message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__error"

    _stdout="$(lib_base__error)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__error__tc2__invalid_stack() {
    local _MESSAGE="This is error message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__error"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" lib_base__error "$_MESSAGE" "invalid_stack")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__error__tc3__default_stack() {
    local _FILE_CONTEXT="lib-base.sh"
    local _MESSAGE="This is error message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__error"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" lib_base__error "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__error__tc4__custom_stack() {
    local _FILE_CONTEXT="test-lib-base.sh"
    local _MESSAGE="This is error message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__error"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" lib_base__error "$_MESSAGE" 1)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__error__tc5__suppression() {
    local _MESSAGE="This is error message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__error"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_FATAL" lib_base__error "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

#
# Equivalence class table of `lib_base__fatal`
# ID    message         exit_code       stack           Expected                            Return Code         File Context
# --    -----------     ---------       ------------    -------------------------------     ------------------  -------------------
# TC1   not provide     not relevant    not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   non-empty       not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC3   non-empty       non-number      not relevant    STDOUT does not contain message     G__ERR_TYPE_ERROR  -
# TC4   non-empty       number          non-number      STDOUT does not contain message     G__ERR_TYPE_ERROR  -
# TC5   non-empty       number          default (0)     STDOUT contains message             G__ERR_OK           lib-base.sh
# TC6   non-empty       number          caller (1)      STDOUT contains message             G__ERR_OK           test-lib-base.sh
#

function tc__fatal__tc1__missing_message() {
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__fatal"

    _stdout="$(lib_base__fatal)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__fatal__tc2__missing_exit_code() {
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__fatal"

    _stdout="$(lib_base__fatal "$_MESSAGE")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__fatal__tc3__invalid_exit_code() {
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__fatal"

    _stdout="$(lib_base__fatal "$_MESSAGE" "invalid_exit_code")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__fatal__tc4__invalid_stack() {
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__fatal"

    _stdout="$(lib_base__fatal "$_MESSAGE" "$G__ERR_NOT_OK" "invalid_stack")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"

    echo "$_stdout" | grep "G__ERR_TYPE_ERROR"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected nested error: 'G__ERR_TYPE_ERROR' STDOUT: '$_stdout'"
}

function tc__fatal__tc5__default_stack() {
    local _FILE_CONTEXT="lib-base.sh"
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__fatal"

    _stdout="$(lib_base__fatal "$_MESSAGE" "$G__ERR_NOT_OK")"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_NOT_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__fatal__tc6__custom_stack() {
    local _FILE_CONTEXT="test-lib-base.sh"
    local _MESSAGE="This is error message"

    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_base__fatal"

    _stdout="$(lib_base__fatal "$_MESSAGE" "$G__ERR_NOT_OK" 1)"
    _error_code=$?
    lib_tests__error_code_eq "$G__ERR_NOT_OK" "$_error_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _error_code=$?
    lib_tests__eq "$G__ERR_OK" "$_error_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

# =============================================================================
# Entry Point
# =============================================================================
function main() {
    set -u

    # shellcheck disable=SC1090,SC1091
    source "$LIB_TESTS_PATH"

    local _fut_path=""
    local _fut_relative_path=""
    local -a fut_dependency_paths=()

    _fut_path="$(realpath "${TEST_SCRIPT_PARENT_DIR}/${FUT_RELATIVE_PATH}")"

    for _fut_relative_path in "${FUT_DEPENDENCY_RELATIVE_PATHS[@]}"; do
        fut_dependency_paths+=("$(realpath "${TEST_SCRIPT_PARENT_DIR}/${_fut_relative_path}")")
    done

    lib_tests__test_main "$_fut_path" "${fut_dependency_paths[@]}"
}

main
