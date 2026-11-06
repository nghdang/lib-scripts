#!/usr/bin/env bash
#
# Source      : test/test-lib-utils.sh
# Dependencies: test/lib-tests.sh
# FUT         : src/lib-utils.sh
#

# ===== Source Guard =====
[[ -n "${G__TEST_LIB_UTILS_SH_LOADED:-}" ]] && return 0
export G__TEST_LIB_UTILS_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================

TEST_SCRIPT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly TEST_SCRIPT_PARENT_DIR

LIB_TESTS_PATH="${TEST_SCRIPT_PARENT_DIR}/lib-tests.sh"
readonly LIB_TESTS_PATH

FUT_RELATIVE_PATH="../src/lib-utils.sh"
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
# Equivalence class table of `lib_utils__find_max_len`
# ID    items                                   Expected                            Return Code
# --    ------------------------------------    --------------------------------    -------------------
# TC1   not provide                             STDOUT is empty                     G__ERR_MISSING_ARG
# TC2   single empty string ("")                STDOUT is "0"                       G__ERR_OK
# TC3   single string ("abc")                   STDOUT is "3"                       G__ERR_OK
# TC4   multiple strings, distinct lengths      STDOUT is max length ("3")          G__ERR_OK
# TC5   multiple strings, equal max length      STDOUT is max length ("3")          G__ERR_OK
# TC6   strings with spaces ("hello world")     STDOUT is max length ("11")         G__ERR_OK
#

function tc__find_max_len__tc1__missing_items() {
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__find_max_len"

    _stdout="$(lib_utils__find_max_len)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
    lib_testing__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__find_max_len__tc2__single_empty_string() {
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__find_max_len"

    _stdout="$(lib_utils__find_max_len "")"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "0" "$_stdout" "Expected max length '0', got '$_stdout'"
}

function tc__find_max_len__tc3__single_string() {
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__find_max_len"

    _stdout="$(lib_utils__find_max_len "abc")"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "3" "$_stdout" "Expected max length '3', got '$_stdout'"
}

function tc__find_max_len__tc4__multiple_strings_distinct_lengths() {
    local -a _items=("a" "abc" "ab")
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__find_max_len"

    _stdout="$(lib_utils__find_max_len "${_items[@]}")"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "3" "$_stdout" "Expected max length '3', got '$_stdout'"
}

function tc__find_max_len__tc5__multiple_strings_equal_max_length() {
    local -a _items=("foo" "bar" "ox")
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__find_max_len"

    _stdout="$(lib_utils__find_max_len "${_items[@]}")"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "3" "$_stdout" "Expected max length '3', got '$_stdout'"
}

function tc__find_max_len__tc6__strings_with_spaces() {
    local -a _items=("hello world" "hi")
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__find_max_len"

    _stdout="$(lib_utils__find_max_len "${_items[@]}")"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "11" "$_stdout" "Expected max length '11', got '$_stdout'"
}

#
# Equivalence class table of `lib_utils__run_command`
# ID    cmd                     stdout_var_name     DRY_RUN         Expected                                                    Return Code
# --    -------------------     ---------------     ------------    --------------------------------------------------------    -------------------
# TC1   not provide             not relevant        not relevant    command not executed                                        G__ERR_MISSING_ARG
# TC2   non-empty               invalid             not relevant    command not executed                                        G__ERR_TYPE_ERROR
# TC3   non-empty (success)     not provide         unset           command executed, STDOUT to terminal                        G__ERR_OK
# TC4   non-empty (failure)     not provide         unset           command executed, failure exit code                         <exit code>
# TC5   non-empty (success)     valid               unset           command executed, STDOUT stored in variable                 G__ERR_OK
# TC6   non-empty (failure)     valid               unset           command executed, STDOUT stored in variable, failure        <exit code>
# TC7   non-empty               not provide         set (1)         command not executed, log message printed                   G__ERR_OK
# TC8   non-empty               valid               set (1)         command not executed, log message printed, empty variable   G__ERR_OK
#

function tc__run_command__tc1__missing_cmd() {
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__run_command"

    _stdout="$(lib_utils__run_command)"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
    lib_testing__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__run_command__tc2__invalid_stdout_var_name() {
    local _cmd="echo 'test'"
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__run_command"

    _stdout="$(lib_utils__run_command "$_cmd" "invalid-var-name")"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
    lib_testing__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__run_command__tc3__success_without_stdout_var() {
    local _cmd="echo 'test output'"
    local _expected_stdout="test output"
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__run_command"

    _stdout="$(
        unset DRY_RUN
        lib_utils__run_command "$_cmd"
    )"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "$_expected_stdout" "$_stdout" "STDOUT mismatch: '$_stdout'"
}

function tc__run_command__tc4__failure_without_stdout_var() {
    local _cmd="(exit 42)"
    local _expected_code=42
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__run_command"

    _stdout="$(
        unset DRY_RUN
        lib_utils__run_command "$_cmd"
    )"
    _error_code=$?
    lib_testing__error_code_eq "$_expected_code" "$_error_code"
    lib_testing__eq "" "$_stdout" "Expected empty STDOUT: '$_stdout'"
}

function tc__run_command__tc5__success_with_stdout_var() {
    local _cmd="echo 'captured output'"
    local _expected_output="captured output"
    local _captured="initial_value"
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__run_command"

    unset DRY_RUN
    lib_utils__run_command "$_cmd" "_captured"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "$_expected_output" "$_captured" "Captured output mismatch: '$_captured'"
}

function tc__run_command__tc6__failure_with_stdout_var() {
    local _cmd="echo 'failure output'; (exit 42)"
    local _expected_output="failure output"
    local _expected_code=42
    local _captured="initial_value"
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__run_command"

    unset DRY_RUN
    lib_utils__run_command "$_cmd" "_captured"
    _error_code=$?
    lib_testing__error_code_eq "$_expected_code" "$_error_code"
    lib_testing__eq "$_expected_output" "$_captured" "Captured output mismatch: '$_captured'"
}

function tc__run_command__tc7__dry_run_without_stdout_var() {
    local _cmd="(exit 42)"
    local _expected_log="Running: (exit 42)"
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__run_command"

    _stdout="$(DRY_RUN=1 lib_utils__run_command "$_cmd")"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep -F "$_expected_log"
    _error_code=$?
    lib_testing__eq "$G__ERR_OK" "$_error_code" "Expected log message '$_expected_log' in STDOUT: '$_stdout'"
}

function tc__run_command__tc8__dry_run_with_stdout_var() {
    local _cmd="(exit 42)"
    local _expected_log="Running: (exit 42)"
    local _captured="initial_value"
    local _stdout=""
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_utils__run_command"

    export DRY_RUN=1
    _stdout="$(lib_utils__run_command "$_cmd" "_captured")"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_stdout" | grep -F "$_expected_log"
    _error_code=$?
    lib_testing__eq "$G__ERR_OK" "$_error_code" "Expected log message '$_expected_log' in STDOUT: '$_stdout'"

    lib_utils__run_command "$_cmd" "_captured" >/dev/null
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
    lib_testing__eq "" "$_captured" "Expected empty captured variable: '$_captured'"
}

# =============================================================================
# Entry Point
# =============================================================================
function main() {
    # shellcheck disable=SC1090,SC1091
    source "$LIB_TESTS_PATH"

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
