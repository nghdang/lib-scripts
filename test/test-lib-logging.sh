#!/usr/bin/env bash
#
# Source      : test/test-lib-logging.sh
# Dependencies: test/lib-tests.sh
# FUT         : src/lib-logging.sh
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

FUT_RELATIVE_PATH="../src/lib-logging.sh"
readonly FUT_RELATIVE_PATH

FUT_DEPENDENCY_RELATIVE_PATHS=(
    "../src/lib-base.sh"
)
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
# TC2   G__LOG_LEVEL_DEBUG      non-empty       non-number      STDOUT does not contain message     G__ERR_INVALID_ARG  -
# TC3   G__LOG_LEVEL_DEBUG      non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-logging.sh
# TC4   G__LOG_LEVEL_DEBUG      non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-logging.sh
# TC5   >G__LOG_LEVEL_DEBUG     non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

function tc__debug__tc1__missing_message() {
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__debug"

    _stdout="$(lib_logging__debug)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__debug__tc2__invalid_stack() {
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__debug"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_DEBUG" lib_logging__debug "$_MESSAGE" "invalid_stack")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_INVALID_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__debug__tc3__default_stack() {
    local _FILE_CONTEXT="lib-logging.sh"
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__debug"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_DEBUG" lib_logging__debug "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__debug__tc4__custom_stack() {
    local _FILE_CONTEXT="test-lib-logging.sh"
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__debug"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_DEBUG" lib_logging__debug "$_MESSAGE" 1)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__debug__tc5__suppression() {
    local _MESSAGE="This is debug message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__debug"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" lib_logging__debug "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

#
# Equivalence class table of `lib_logging__info`
# ID    LOG_LEVEL               message         stack           Expected                            Return Code         File Context
# --    ------------------      -----------     ------------    -------------------------------     ------------------  -------------------
# TC1   not relevant            not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   G__LOG_LEVEL_INFO       non-empty       non-number      STDOUT does not contain message     G__ERR_INVALID_ARG  -
# TC3   G__LOG_LEVEL_INFO       non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-logging.sh
# TC4   G__LOG_LEVEL_INFO       non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-logging.sh
# TC5   >G__LOG_LEVEL_INFO      non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

function tc__info__tc1__missing_message() {
    local _MESSAGE="This is info message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__info"

    _stdout="$(lib_logging__info)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__info__tc2__invalid_stack() {
    local _MESSAGE="This is info message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__info"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" lib_logging__info "$_MESSAGE" "invalid_stack")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_INVALID_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__info__tc3__default_stack() {
    local _FILE_CONTEXT="lib-logging.sh"
    local _MESSAGE="This is info message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__info"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" lib_logging__info "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__info__tc4__custom_stack() {
    local _FILE_CONTEXT="test-lib-logging.sh"
    local _MESSAGE="This is info message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__info"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" lib_logging__info "$_MESSAGE" 1)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__info__tc5__suppression() {
    local _MESSAGE="This is info message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__info"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" lib_logging__info "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

#
# Equivalence class table of `lib_logging__warn`
# ID    LOG_LEVEL               message         stack           Expected                            Return Code         File Context
# --    ------------------      -----------     ------------    -------------------------------     ------------------  -------------------
# TC1   not relevant            not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   G__LOG_LEVEL_WARN       non-empty       non-number      STDOUT does not contain message     G__ERR_INVALID_ARG  -
# TC3   G__LOG_LEVEL_WARN       non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-logging.sh
# TC4   G__LOG_LEVEL_WARN       non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-logging.sh
# TC5   >G__LOG_LEVEL_WARN      non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

function tc__warn__tc1__missing_message() {
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__warn"

    _stdout="$(lib_logging__warn)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__warn__tc2__invalid_stack() {
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__warn"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" lib_logging__warn "$_MESSAGE" "invalid_stack")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_INVALID_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__warn__tc3__default_stack() {
    local _FILE_CONTEXT="lib-logging.sh"
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__warn"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" lib_logging__warn "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__warn__tc4__custom_stack() {
    local _FILE_CONTEXT="test-lib-logging.sh"
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__warn"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" lib_logging__warn "$_MESSAGE" 1)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__warn__tc5__suppression() {
    local _MESSAGE="This is warn message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__warn"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" lib_logging__warn "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

#
# Equivalence class table of `lib_logging__error`
# ID    LOG_LEVEL               message         stack           Expected                            Return Code         File Context
# --    -------------------     -----------     ------------    -------------------------------     ------------------  -------------------
# TC1   not relevant            not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   G__LOG_LEVEL_ERROR      non-empty       non-number      STDOUT does not contain message     G__ERR_INVALID_ARG  -
# TC3   G__LOG_LEVEL_ERROR      non-empty       default (0)     STDOUT contains message             G__ERR_OK           lib-logging.sh
# TC4   G__LOG_LEVEL_ERROR      non-empty       caller (1)      STDOUT contains message             G__ERR_OK           test-lib-logging.sh
# TC5   >G__LOG_LEVEL_ERROR     non-empty       not relevant    STDOUT does not contain message     G__ERR_OK           -
#

function tc__error__tc1__missing_message() {
    local _MESSAGE="This is error message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__error"

    _stdout="$(lib_logging__error)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__error__tc2__invalid_stack() {
    local _MESSAGE="This is error message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__error"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" lib_logging__error "$_MESSAGE" "invalid_stack")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_INVALID_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__error__tc3__default_stack() {
    local _FILE_CONTEXT="lib-logging.sh"
    local _MESSAGE="This is error message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__error"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" lib_logging__error "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__error__tc4__custom_stack() {
    local _FILE_CONTEXT="test-lib-logging.sh"
    local _MESSAGE="This is error message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__error"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" lib_logging__error "$_MESSAGE" 1)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__error__tc5__suppression() {
    local _MESSAGE="This is error message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__error"

    _stdout="$(LOG_LEVEL="$G__LOG_LEVEL_FATAL" lib_logging__error "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_OK" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

#
# Equivalence class table of `lib_logging__fatal`
# ID    message         exit_code       stack           Expected                            Return Code         File Context
# --    -----------     ---------       ------------    -------------------------------     ------------------  -------------------
# TC1   not provide     not relevant    not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC2   non-empty       not provide     not relevant    STDOUT does not contain message     G__ERR_MISSING_ARG  -
# TC3   non-empty       non-number      not relevant    STDOUT does not contain message     G__ERR_INVALID_ARG  -
# TC4   non-empty       number          non-number      STDOUT does not contain message     G__ERR_INVALID_ARG  -
# TC5   non-empty       number          default (0)     STDOUT contains message             G__ERR_OK           lib-logging.sh
# TC6   non-empty       number          caller (1)      STDOUT contains message             G__ERR_OK           test-lib-logging.sh
#

function tc__fatal__tc1__missing_message() {
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__fatal"

    _stdout="$(lib_logging__fatal)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__fatal__tc2__missing_exit_code() {
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__fatal"

    _stdout="$(lib_logging__fatal "$_MESSAGE")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_MISSING_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__fatal__tc3__invalid_exit_code() {
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__fatal"

    _stdout="$(lib_logging__fatal "$_MESSAGE" "invalid_exit_code")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_INVALID_ARG" "$_ret_code"
    lib_tests__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__fatal__tc4__invalid_stack() {
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__fatal"

    _stdout="$(lib_logging__fatal "$_MESSAGE" "$G__ERR_NOT_OK" "invalid_stack")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_INVALID_ARG" "$_ret_code"

    echo "$_stdout" | grep "G__ERR_INVALID_ARG"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected nested error: 'G__ERR_INVALID_ARG' STDOUT: '$_stdout'"
}

function tc__fatal__tc5__default_stack() {
    local _FILE_CONTEXT="lib-logging.sh"
    local _MESSAGE="This is fatal message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__fatal"

    _stdout="$(lib_logging__fatal "$_MESSAGE" "$G__ERR_NOT_OK")"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_NOT_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
}

function tc__fatal__tc6__custom_stack() {
    local _FILE_CONTEXT="test-lib-logging.sh"
    local _MESSAGE="This is error message"

    local _stdout=""
    local _ret_code="$G__ERR_OK"

    lib_tests__sut_existence "lib_logging__fatal"

    _stdout="$(lib_logging__fatal "$_MESSAGE" "$G__ERR_NOT_OK" 1)"
    _ret_code=$?
    lib_tests__error_code_eq "$G__ERR_NOT_OK" "$_ret_code"

    echo "$_stdout" | grep "$_FILE_CONTEXT"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Expected file context: '$_FILE_CONTEXT' STDOUT: '$_stdout'"

    echo "$_stdout" | grep "$_MESSAGE"
    _ret_code=$?
    lib_tests__eq "$G__ERR_OK" "$_ret_code" "Missing log message: '$_MESSAGE' STDOUT: '$_stdout'"
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
