#!/usr/bin/env bash
#
# Source      : src/lib-testing.sh
# Dependencies: src/lib-base.sh
# Description : Testing framework.
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__LIB_TESTING_SH_LOADED:-}" ]] && return 0
declare -gr G__LIB_TESTING_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-base.sh"

# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# _lib_testing__load_sut                  p01
# _lib_testing__collect_tests             p02
# _lib_testing__run_tests                 p03
# _lib_testing__print_test_results        p04
# lib_testing__test_main                  i01
# lib_testing__sut_existence              i02
# lib_testing__error_code_eq              i03
# lib_testing__eq                         i04
# -----------------------------------------

# ==================================================================================================
# Global Constants
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====

# ==================================================================================================
# Global Variables
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====

declare -A test_cases=()
declare -A test_results=()

# ==================================================================================================
# Private Functions
# ==================================================================================================
#######################################
# Load and source the FUT and its dependencies.
#
# Arguments:
#   fut_path [in]: Path to the FUT.
#   fut_deps [in]: (optional) Paths of dependency scripts required by the FUT.
#
# Returns:
#   G__ERR_OK: FUT and its dependencies were loaded successfully.
#   G__ERR_MISSING_ARG: FUT was not provided.
#   G__ERR_NOT_FOUND: FUT or any dependency does not exist.
#######################################
function _lib_testing__load_sut() {
    # Constants

    # Variables
    local _testing_p01__fut_path
    local -a _testing_p01__fut_deps=()

    local _testing_p01__fut_dep

    # Parse and validate arguments
    [[ $# -eq 0 ]] && return "$G__ERR_MISSING_ARG"

    _testing_p01__fut_path="$1"
    shift
    _testing_p01__fut_deps=("$@")

    # Function body
    for _testing_p01__fut_dep in "${_testing_p01__fut_deps[@]}"; do
        echo -e "Loading FUT dependency: '$_testing_p01__fut_dep'"

        if [[ ! -f "$_testing_p01__fut_dep" ]]; then
            echo -e "${G__COLOR_RED}  >> Dependency does not exist!!${G__COLOR_RESET}"
            return "$G__ERR_NOT_FOUND"
        fi

        # shellcheck disable=SC1090,SC1091
        source "$_testing_p01__fut_dep"
        echo -e "${G__COLOR_GREEN}  >> Loaded${G__COLOR_RESET}"
    done

    echo -e "Loading FUT: '${_testing_p01__fut_path}'"
    if [[ ! -f "$_testing_p01__fut_path" ]]; then
        echo -e "${G__COLOR_RED}  >> FUT does not exist!!${G__COLOR_RESET}"
        return "$G__ERR_NOT_FOUND"
    fi

    # shellcheck disable=SC1090,SC1091
    source "$_testing_p01__fut_path"
    echo -e "${G__COLOR_GREEN}  >> Loaded${G__COLOR_RESET}"

    echo -e ""
    echo -e "======================================================================================"
    echo -e "${G__COLOR_BLUE}>> FUT: ${_testing_p01__fut_path}${G__COLOR_RESET}"
    for _testing_p01__fut_dep in "${_testing_p01__fut_deps[@]}"; do
        echo -e "${G__COLOR_GRAY}     - ${_testing_p01__fut_dep}${G__COLOR_RESET}"
    done
    echo -e "======================================================================================"

    return "$G__ERR_OK"
}

#######################################
# Discover and group test functions starting with 'tc_' by their SUT.
#
# Arguments:
#   None.
#
# Returns:
#   G__ERR_OK: Test discovery completed.
#######################################
function _lib_testing__collect_tests() {
    # Constants

    # Variables
    local -a _testing_p02__fut_tc_names=()
    local _testing_p02__fut_tc_names_raw
    local _testing_p02__tc_name
    local -a _testing_p02__sut_names=()
    local _testing_p02__sut_name

    # Parse and validate arguments

    # Function body
    echo -e "Finding test cases..."

    _testing_p02__fut_tc_names_raw="$(declare -F | grep 'declare -f tc_' | sort | awk '{print $3}')"

    if [[ -z "$_testing_p02__fut_tc_names_raw" ]]; then
        echo -e "${G__COLOR_YELLOW}>> No test case is found.${G__COLOR_RESET}"
        echo -e "${G__COLOR_YELLOW}   All test cases must start with 'tc_'${G__COLOR_RESET}"
        return "$G__ERR_OK"
    fi

    mapfile -t _testing_p02__fut_tc_names <<<"$_testing_p02__fut_tc_names_raw"

    for _testing_p02__tc_name in "${_testing_p02__fut_tc_names[@]}"; do
        _testing_p02__sut_name="${_testing_p02__tc_name#tc__}"
        _testing_p02__sut_name="${_testing_p02__sut_name%%__*}"

        if [[ ! -v "test_cases[$_testing_p02__sut_name]" ]]; then
            declare -g -a "$_testing_p02__sut_name=()"
            test_cases["$_testing_p02__sut_name"]=1
        fi

        # shellcheck disable=SC2178
        local -n _testing_p02__sut_ref="$_testing_p02__sut_name"
        _testing_p02__sut_ref+=("$_testing_p02__tc_name")
    done

    mapfile -t _testing_p02__sut_names < <(printf "%s\n" "${!test_cases[@]}" | sort)
    for _testing_p02__sut_name in "${_testing_p02__sut_names[@]}"; do
        local _testing_p02__tc_idx

        # shellcheck disable=SC2178
        local -n _testing_p02__sut_ref="$_testing_p02__sut_name"

        echo -e "${G__COLOR_CYAN}>> SUT: $_testing_p02__sut_name - ${#_testing_p02__sut_ref[@]} TCs${G__COLOR_RESET}"

        for _testing_p02__tc_idx in "${!_testing_p02__sut_ref[@]}"; do
            echo -e "     $((_testing_p02__tc_idx + 1)). ${_testing_p02__sut_ref[$_testing_p02__tc_idx]}"
        done
    done

    echo -e "Total SUTs: ${#test_cases[@]}"
    echo -e "Total TCs: ${#_testing_p02__fut_tc_names[@]}"

    return "$G__ERR_OK"
}

#######################################
# Execute all collected test cases grouped by SUT and record the results.
#
# Arguments:
#   None.
#
# Returns:
#   G__ERR_OK: All test cases passed.
#   G__ERR_NOT_OK: One or more test cases failed.
#######################################
function _lib_testing__run_tests() {
    # Constants

    # Variables
    local _testing_p03__total_suts="${#test_cases[@]}"
    local _testing_p03__sut_no=1
    local _testing_p03__sut_result_color="$G__COLOR_GREEN"
    local _testing_p03__error_code=$G__ERR_OK
    local -a _testing_p03__sut_names=()
    local _testing_p03__sut_name

    # Parse and validate arguments

    # Function body
    if [[ "$_testing_p03__total_suts" -eq 0 ]]; then
        return "$G__ERR_OK"
    fi

    mapfile -t _testing_p03__sut_names < <(printf "%s\n" "${!test_cases[@]}" | sort)
    for _testing_p03__sut_name in "${_testing_p03__sut_names[@]}"; do
        # shellcheck disable=SC2178
        local -n _testing_p03__sut_ref="$_testing_p03__sut_name"

        local _testing_p03__total_tcs="${#_testing_p03__sut_ref[@]}"
        local _testing_p03__idx

        echo ""
        echo -e "${G__COLOR_CYAN}>> START SUT: [${_testing_p03__sut_no}/${_testing_p03__total_suts}] ${_testing_p03__sut_name}${G__COLOR_RESET}"

        for _testing_p03__idx in "${!_testing_p03__sut_ref[@]}"; do
            local _testing_p03__tc_name="${_testing_p03__sut_ref[$_testing_p03__idx]}"
            local _testing_p03__tc_summary="[$((_testing_p03__idx + 1))/${_testing_p03__total_tcs}] TC: ${_testing_p03__tc_name}"

            local _testing_p03__tc_return_code
            local _testing_p03__tc_result_color

            echo -e "${G__COLOR_CYAN}  ++ ${_testing_p03__tc_summary}${G__COLOR_RESET}"

            (
                "$_testing_p03__tc_name"
            )
            _testing_p03__tc_return_code=$?

            if [[ $_testing_p03__tc_return_code -eq 0 ]]; then
                _testing_p03__tc_result_color="$G__COLOR_GREEN"
                test_results[$_testing_p03__tc_name]="PASSED"
            else
                _testing_p03__tc_result_color="$G__COLOR_RED"
                _testing_p03__sut_result_color="$G__COLOR_RED"
                test_results[$_testing_p03__tc_name]="FAILED"
                _testing_p03__error_code=$G__ERR_NOT_OK
            fi
        done

        echo -e "${_testing_p03__sut_result_color}>> END SUT: [${_testing_p03__sut_no}/${_testing_p03__total_suts}] ${_testing_p03__sut_name}${G__COLOR_RESET}"

        _testing_p03__sut_no=$((_testing_p03__sut_no + 1))
    done

    return "$_testing_p03__error_code"
}

#######################################
# Print a formatted summary table of all test case execution results.
#
# Arguments:
#   fut_path [in]: Path to the FUT script.
#
# Returns:
#   G__ERR_OK: Test results were printed successfully.
#   G__ERR_MISSING_ARG: FUT was not provided.
#######################################
function _lib_testing__print_test_results() {
    # Constants
    local -r _LIB_TESTING_P04__DIVIDER_H2="$(printf '%.0s=' {1..80})"
    local -r _LIB_TESTING_P04__DIVIDER_H3="$(printf '%.0s-' {1..80})"

    # Variables
    local _testing_p04__fut_path
    local -a _testing_p04__sut_names=()
    local _testing_p04__sut_name
    local _testing_p04__tc_name
    local _testing_p04__test_result
    local _testing_p04__result_table
    local -a _testing_p04__column_widths=(10 -1 10)

    local _testing_p04__total_passed=0
    local _testing_p04__total_failed=0

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _testing_p04__fut_path="$1"

    # Function body
    echo ""
    echo "$_LIB_TESTING_P04__DIVIDER_H2"
    printf '%-10s %-10s %-s\n' "SUT" "Status" "Test Case"
    echo "$_LIB_TESTING_P04__DIVIDER_H2"

    if [[ "${#test_cases[@]}" -gt "0" ]]; then
        mapfile -t _testing_p04__sut_names < <(printf "%s\n" "${!test_cases[@]}" | sort)

        for _testing_p04__sut_name in "${_testing_p04__sut_names[@]}"; do
            # shellcheck disable=SC2178
            local -n _testing_p04__sut_ref="$_testing_p04__sut_name"

            for _testing_p04__tc_name in "${_testing_p04__sut_ref[@]}"; do
                _testing_p04__test_result="${test_results[$_testing_p04__tc_name]}"

                if [[ "$_testing_p04__test_result" == "PASSED" ]]; then
                    _testing_p04__total_passed=$((_testing_p04__total_passed + 1))
                else
                    _testing_p04__total_failed=$((_testing_p04__total_failed + 1))
                fi

                printf '%-10s %-10s %-s\n' "$_testing_p04__sut_name" "$_testing_p04__test_result" "$_testing_p04__tc_name"
            done

            echo "$_LIB_TESTING_P04__DIVIDER_H3"
        done
    fi

    echo -e "Total passed: ${G__COLOR_GREEN}${_testing_p04__total_passed} TCs${G__COLOR_RESET}"
    echo -e "Total failed: ${G__COLOR_RED}${_testing_p04__total_failed} TCs${G__COLOR_RESET}"
    echo "$_LIB_TESTING_P04__DIVIDER_H2"

    return "$G__ERR_OK"
}

# ==================================================================================================
# Public Functions
# ==================================================================================================
#######################################
# Execute the main test suite workflow for a given File Under Test (FUT).
#
# Arguments:
#   fut_path [in]: Path to the FUT script.
#   fut_deps [in]: (optional) Paths of dependency scripts required by the FUT.
#
# Returns:
#   G__ERR_OK: All tests passed successfully.
#   G__ERR_MISSING_ARG: FUT was not provided.
#   G__ERR_NOT_OK: One or more tests failed.
#######################################
function lib_testing__test_main() {
    # Constants

    # Variables
    local _testing_i01__fut_path
    local -a _testing_i01__fut_deps=()

    local _testing_i01__error_code=$G__ERR_OK

    # Parse and validate arguments
    if [[ "$#" -lt "1" ]]; then
        lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required at least 1 argument"
    fi

    _testing_i01__fut_path="$1"
    shift
    _testing_i01__fut_deps=("$@")

    # Function body
    echo -e "${G__COLOR_BLUE}~~~~~ START TESTS ~~~~~${G__COLOR_RESET}"

    _lib_testing__load_sut "$_testing_i01__fut_path" "${_testing_i01__fut_deps[@]}"
    _testing_i01__error_code=$?

    if [[ "$_testing_i01__error_code" -eq "$G__ERR_OK" ]]; then
        _lib_testing__collect_tests
        _testing_i01__error_code=$?
    fi

    if [[ "$_testing_i01__error_code" -eq "$G__ERR_OK" ]]; then
        _lib_testing__run_tests
        _testing_i01__error_code=$?
    fi

    _lib_testing__print_test_results "$_testing_i01__fut_path"

    echo -e "${G__COLOR_BLUE}~~~~~ END TESTS ~~~~~${G__COLOR_RESET}"

    if [[ "$_testing_i01__error_code" -ne "$G__ERR_OK" ]]; then
        echo -e "${G__COLOR_RED}Unexpectedly exit with ${_testing_i01__error_code}${G__COLOR_RESET}"
    fi

    return "$_testing_i01__error_code"
}

#######################################
# Assert whether SUT exists.
#
# Arguments:
#   sut_name [in]: Name of the SUT to assert.
#
# Returns:
#   G__ERR_OK: SUT does exist.
#
# Exits:
#   G__ERR_MISSING_ARG: No SUT name was provided.
#   G__ERR_TOO_MANY_ARGS: More than 1 argument was provided.
#   G__ERR_NOT_OK: SUT does not exist.
#######################################
function lib_testing__sut_existence() {
    # Constants

    # Variables
    local _assertion_01__sut_name

    local _assertion_01__sut_exists=$G__ERR_OK

    # Parse and validate arguments
    [[ $# -lt 1 ]] && exit "$G__ERR_MISSING_ARG"
    [[ $# -gt 1 ]] && exit "$G__ERR_TOO_MANY_ARGS"

    _assertion_01__sut_name="$1"

    # Function body
    type "$_assertion_01__sut_name" >/dev/null 2>&1 || _assertion_01__sut_exists=$?

    if [[ "$_assertion_01__sut_exists" -eq "$G__ERR_OK" ]]; then
        return "$G__ERR_OK"
    fi

    echo -e "${G__COLOR_RED}[ERROR] SUT does not exist!!${G__COLOR_RESET}" >&2

    exit "$G__ERR_NOT_OK"
}

#######################################
# Assert whether an error code matches with the expectation.
#
# Arguments:
#   expected [in]: Expected error code.
#   actual   [in]: Actual error code.
#
# Returns:
#   G__ERR_OK: Expected code and actual code are equal.
#
# Exits:
#   G__ERR_MISSING_ARG: Expected or actual code was not provided.
#   G__ERR_NOT_OK: Error codes are not equal.
#######################################
function lib_testing__error_code_eq() {
    # Constants

    # Variables
    local _assertion_02__expected
    local _assertion_02__actual

    local _assertion_02__expected_str=""
    local _assertion_02__actual_str=""

    # Parse and validate arguments
    if [[ $# -lt 2 ]]; then
        echo -e "${G__COLOR_RED}[FATAL] Expected code and actual code must be provided${G__COLOR_RESET}" >&2
        exit "$G__ERR_MISSING_ARG"
    fi

    _assertion_02__expected="$1"
    _assertion_02__actual="$2"

    # Function body
    if [[ "$_assertion_02__expected" == "$_assertion_02__actual" ]]; then
        return "$G__ERR_OK"
    fi

    _assertion_02__expected_str="${G__ERR_NAMES[$_assertion_02__expected]:-$_assertion_02__expected}"
    _assertion_02__actual_str="${G__ERR_NAMES[$_assertion_02__actual]:-$_assertion_02__actual}"

    echo -e "${G__COLOR_RED}[ERROR] Assertion failed: error codes are not equal${G__COLOR_RESET}" >&2
    echo -e "${G__COLOR_CYAN}  Expected: '${_assertion_02__expected_str}'${G__COLOR_RESET}" >&2
    echo -e "${G__COLOR_MAGENTA}    Actual: '${_assertion_02__actual_str}'${G__COLOR_RESET}" >&2

    exit "$G__ERR_NOT_OK"
}

#######################################
# Assert equality between expected and actual values.
#
# Arguments:
#   expected [in]: Expected value.
#   actual   [in]: Actual value to compare against expected.
#   message  [in]: (optional) Failure message to print if values differ.
#
# Returns:
#   G__ERR_OK: Expected and actual values are equal.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_NOT_OK: Values are not equal.
#######################################
function lib_testing__eq() {
    # Constants

    # Variables
    local _assertion_03__expected
    local _assertion_03__actual
    local _assertion_03__message

    # Parse and validate arguments
    [[ $# -lt 2 ]] && exit "$G__ERR_MISSING_ARG"

    _assertion_03__expected="$1"
    _assertion_03__actual="$2"
    _assertion_03__message="${3:-}"

    # Function body
    if [[ "$_assertion_03__expected" == "$_assertion_03__actual" ]]; then
        return "$G__ERR_OK"
    fi

    echo -e "${G__COLOR_RED}[ERROR] Assertion failed: values are not equal${G__COLOR_RESET}" >&2
    [[ -n "$_assertion_03__message" ]] && echo -e "${G__COLOR_RED}  >> ${_assertion_03__message}${G__COLOR_RESET}" >&2
    echo -e "${G__COLOR_CYAN}  Expected: '${_assertion_03__expected}'${G__COLOR_RESET}" >&2
    echo -e "${G__COLOR_MAGENTA}    Actual: '${_assertion_03__actual}'${G__COLOR_RESET}" >&2

    exit "$G__ERR_NOT_OK"
}
