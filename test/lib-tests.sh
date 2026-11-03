#!/usr/bin/env bash
#
# Source      : test/lib-tests.sh
# Dependencies: src/lib-base.sh
# Description : Testing framework.
#

# ----- Source Guard -----
[[ -n "${G__LIB_TESTS_SH_LOADED:-}" ]] && return 0
export G__LIB_TESTS_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====
LIB_TESTS_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly LIB_TESTS_PARENT_DIR

LIB_BASE_PATH="$(realpath "${LIB_TESTS_PARENT_DIR}/../src/lib-base.sh")"
readonly LIB_BASE_PATH

# =============================================================================
# Global Variables
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====

declare -A test_cases=()
declare -A test_results=()

# =============================================================================
# Private Functions
# =============================================================================

# ----- Utilities -----

# ----- Test main breaking down functions -----

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
function _lib_tests__load_sut() {
    # Constants

    # Variables
    local _fut_path
    local -a _fut_deps=()

    local _fut_dep

    # Parse and validate arguments
    [[ $# -eq 0 ]] && return "$G__ERR_MISSING_ARG"

    _fut_path="$1"
    shift
    _fut_deps=("$@")

    # Function body
    for _fut_dep in "${_fut_deps[@]}"; do
        echo -n "Loading FUT dependency: '$_fut_dep'"

        if [[ ! -f "$_fut_dep" ]]; then
            echo -e "${G__COLOR_RED}  >> Dependency does not exist!!${G__COLOR_RESET}"
            return "$G__ERR_NOT_FOUND"
        fi

        # shellcheck disable=SC1090,SC1091
        source "$_fut_dep"
        echo -e "${G__COLOR_GREEN}  >> Loaded${G__COLOR_RESET}"
    done

    echo -n "Loading FUT: '${_fut_path}'"
    if [[ ! -f "$_fut_path" ]]; then
        echo -e "${G__COLOR_RED}  >> FUT does not exist!!${G__COLOR_RESET}"
        return "$G__ERR_NOT_FOUND"
    fi

    # shellcheck disable=SC1090,SC1091
    source "$_fut_path"
    echo -e "${G__COLOR_GREEN}  >> Loaded${G__COLOR_RESET}"

    echo ""
    lib_base__gen_divider "$G__DIVIDER_H2_CHAR"
    echo -e "${G__COLOR_BLUE}>> FUT: ${_fut_path}${G__COLOR_RESET}"
    for _fut_dep in "${_fut_deps[@]}"; do
        echo -e "${G__COLOR_GRAY}     - ${_fut_dep}${G__COLOR_RESET}"
    done
    lib_base__gen_divider "$G__DIVIDER_H2_CHAR"

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
function _lib_tests__collect_tests() {
    # Constants

    # Variables
    local -a _fut_tc_names=()
    local _fut_tc_names_raw
    local _tc_name
    local -a _sut_names=()
    local _sut_name

    # Parse and validate arguments

    # Function body
    echo "Finding test cases..."

    _fut_tc_names_raw="$(declare -F | grep 'declare -f tc_' | sort | awk '{print $3}')"

    if [[ -z "$_fut_tc_names_raw" ]]; then
        echo -e "${G__COLOR_YELLOW}No test case is found. All test cases should start with 'tc_' to be able to recognize${G__COLOR_RESET}"
        return "$G__ERR_OK"
    fi

    mapfile -t _fut_tc_names <<<"$_fut_tc_names_raw"

    for _tc_name in "${_fut_tc_names[@]}"; do
        _sut_name="${_tc_name#tc__}"
        _sut_name="${_sut_name%%__*}"

        if [[ ! -v "test_cases[$_sut_name]" ]]; then
            declare -g -a "$_sut_name=()"
            test_cases["$_sut_name"]=1
        fi

        local -n _sut_ref="$_sut_name"
        _sut_ref+=("$_tc_name")
    done

    mapfile -t _sut_names < <(printf "%s\n" "${!test_cases[@]}" | sort)
    for _sut_name in "${_sut_names[@]}"; do
        local _tc_idx

        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut_name"

        echo -e "${G__COLOR_CYAN}>> SUT: $_sut_name - ${#_sut_ref[@]} TCs${G__COLOR_RESET}"

        for _tc_idx in "${!_sut_ref[@]}"; do
            echo "     $((_tc_idx + 1)). ${_sut_ref[$_tc_idx]}"
        done
    done

    echo "Total SUTs: ${#test_cases[@]}"
    echo "Total TCs: ${#_fut_tc_names[@]}"

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
function _lib_tests__run_tests() {
    # Constants

    # Variables
    local _total_suts="${#test_cases[@]}"
    local _sut_no=1
    local _sut_result_color="$G__COLOR_GREEN"
    local _ret_code=$G__ERR_OK
    local -a _sut_names=()
    local _sut_name

    # Parse and validate arguments

    # Function body
    if [[ "$_total_suts" -eq 0 ]]; then
        return "$G__ERR_OK"
    fi

    mapfile -t _sut_names < <(printf "%s\n" "${!test_cases[@]}" | sort)
    for _sut_name in "${_sut_names[@]}"; do
        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut_name"

        local _total_tcs="${#_sut_ref[@]}"
        local _idx

        echo ""
        echo -e "${G__COLOR_CYAN}>> START SUT: [${_sut_no}/${_total_suts}] ${_sut_name}${G__COLOR_RESET}"

        for _idx in "${!_sut_ref[@]}"; do
            local _tc_name="${_sut_ref[$_idx]}"
            local _tc_summary="[$((_idx + 1))/${_total_tcs}] TC: ${_tc_name}"

            local _tc_return_code
            local _tc_result_color

            echo -e "${G__COLOR_CYAN}  ++ TC: [$((_idx + 1))/${_total_tcs}] ${_tc_name}${G__COLOR_RESET}"

            (
                "$_tc_name"
            )
            _tc_return_code=$?

            if [[ $_tc_return_code -eq 0 ]]; then
                _tc_result_color="$G__COLOR_GREEN"
                test_results[$_tc_name]="PASSED"
            else
                _tc_result_color="$G__COLOR_RED"
                _sut_result_color="$G__COLOR_RED"
                test_results[$_tc_name]="FAILED"
                _ret_code=$G__ERR_NOT_OK
            fi
        done

        echo -e "${_sut_result_color}>> END SUT: [${_sut_no}/${_total_suts}] ${_sut_name}${G__COLOR_RESET}"

        _sut_no=$((_sut_no + 1))
    done

    return "$_ret_code"
}

#######################################
# Print the test summary banner displaying the path of the FUT.
#
# Arguments:
#   fut_path [in]: Path to the FUT script.
#
# Returns:
#   G__ERR_OK: Summary banner was printed successfully.
#   G__ERR_MISSING_ARG: No FUT path was provided.
#######################################
function _lib_tests__print_summary() {
    # Constants

    # Variables
    local _fut_path

    local _summary
    local _pad_len
    local _pad
    local _line

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _fut_path="$1"

    # Function body
    _summary="FUT: $_fut_path"
    _pad_len=$(((G__TABLE_WIDTH - ${#_summary}) / 2))

    _pad="$(printf "%0.s " $(seq 1 $_pad_len))"
    _line="$(printf "%-*s" "$G__TABLE_WIDTH" "${_pad}${_summary}")"

    echo ""
    lib_base__gen_divider "$G__DIVIDER_H2_CHAR"
    echo "${G__TABLE_ROW_PREFIX}${_line}${G__TABLE_ROW_SUFFIX}"
    lib_base__gen_divider "$G__DIVIDER_H2_CHAR"

    return "$G__ERR_OK"
}

#######################################
# Populate table column value arrays with headers and test case execution statuses.
#
# Arguments:
#   None.
#
# Returns:
#   G__ERR_OK: Table values were prepared successfully.
#######################################
function _lib_tests__prepare_table_values() {
    # Constants

    # Variables
    local -a _sut_names=()
    local _sut_name

    # Parse and validate arguments

    # Function body
    if [[ "${#test_cases[@]}" -eq 0 ]]; then
        return "$G__ERR_OK"
    fi

    _col1_values=("SUT")
    _col2_values=("Test Case")
    _col3_values=("Status")

    mapfile -t _sut_names < <(printf "%s\n" "${!test_cases[@]}" | sort)

    for _sut_name in "${_sut_names[@]}"; do
        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut_name"

        local _tc_name
        local _test_result

        for _tc_name in "${_sut_ref[@]}"; do
            _test_result="${test_results[$_tc_name]}"

            _col1_values+=("$_sut_name")
            _col2_values+=("$_tc_name")
            _col3_values+=("$_test_result")
        done
    done

    return "$G__ERR_OK"
}

#######################################
# Calculate column widths for the test results table.
#
# Arguments:
#   None.
#
# Returns:
#   G__ERR_OK: Column widths were calculated successfully.
#######################################
function _lib_tests__calc_column_widths() {
    # Constants

    # Variables
    local _item

    # Parse and validate arguments

    # Function body
    for _item in "${_col1_values[@]}"; do
        if [[ ${#_item} -gt $_col1_width ]]; then
            _col1_width=${#_item}
        fi
    done

    for _item in "${_col3_values[@]}"; do
        if [[ ${#_item} -gt $_col3_width ]]; then
            _col3_width=${#_item}
        fi
    done

    _col2_width=$((G__TABLE_WIDTH - _col1_width - G__TABLE_COL_SEPARATOR_LEN))
    _col2_width=$((_col2_width - _col3_width - G__TABLE_COL_SEPARATOR_LEN))

    return "$G__ERR_OK"
}

#######################################
# Print a formatted row of the test results table with status-based color styling.
#
# Arguments:
#   col1_val [in]: Column 1 text (SUT name).
#   col2_val [in]: Column 2 text (Test case name).
#   col3_val [in]: Column 3 text (Status: PASSED or FAILED).
#   col1_w [in]: Width of column 1.
#   col2_w [in]: Width of column 2.
#   col3_w [in]: Width of column 3.
#
# Returns:
#   G__ERR_OK: Row was printed successfully.
#   G__ERR_MISSING_ARG: Missing required arguments.
#######################################
function _lib_tests__print_row() {
    # Constants

    # Variables
    local _col1_val
    local _col2_val
    local _col3_val
    local _col1_w
    local _col2_w
    local _col3_w

    local _row_color="$G__COLOR_RESET"
    local _line

    # Parse and validate arguments
    [[ $# -lt 6 ]] && return "$G__ERR_MISSING_ARG"

    _col1_val="$1"
    _col2_val="$2"
    _col3_val="$3"
    _col1_w="$4"
    _col2_w="$5"
    _col3_w="$6"

    # Function body
    if [[ "$_col3_val" == "PASSED" ]]; then
        _row_color="$G__COLOR_GREEN"
    elif [[ "$_col3_val" == "FAILED" ]]; then
        _row_color="$G__COLOR_RED"
    else
        _row_color="$G__COLOR_YELLOW"
    fi

    _line="${_row_color}$(printf "%-*s" "$_col1_w" "$_col1_val")"
    _line="${_line}${G__TABLE_COL_SEPARATOR}"
    _line="${_line}$(printf "%-*s" "$_col2_w" "$_col2_val")"
    _line="${_line}${G__TABLE_COL_SEPARATOR}"
    _line="${_line}$(printf "%-*s" "$_col3_w" "$_col3_val")${G__COLOR_RESET}"

    echo "${G__TABLE_ROW_PREFIX}${_line}${G__TABLE_ROW_SUFFIX}"

    return "$G__ERR_OK"
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
function _lib_tests__print_test_results() {
    # Constants

    # Variables
    local _fut_path

    local -a _col1_values=()
    local -a _col2_values=()
    local -a _col3_values=()
    local _col1_width=0
    local _col2_width=0
    local _col3_width=0
    local _total_passed=0
    local _total_failed=0
    local _rowx

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _fut_path="$1"

    # Function body
    _lib_tests__print_summary "$_fut_path"
    _lib_tests__prepare_table_values
    _lib_tests__calc_column_widths

    for _rowx in "${!_col1_values[@]}"; do
        local _col1_value="${_col1_values[$_rowx]}"
        local _col2_value="${_col2_values[$_rowx]}"
        local _col3_value="${_col3_values[$_rowx]}"

        if [[ "$_col3_value" == "PASSED" ]]; then
            _total_passed=$((_total_passed + 1))
        elif [[ "$_col3_value" == "FAILED" ]]; then
            _total_failed=$((_total_failed + 1))
        fi

        if [[ $_rowx -gt 1 ]] && [[ "$_col1_value" != "${_col1_values[$((_rowx - 1))]}" ]]; then
            lib_base__gen_divider "$G__DIVIDER_H4_CHAR"
        fi

        _lib_tests__print_row "$_col1_value" "$_col2_value" "$_col3_value" "$_col1_width" "$_col2_width" "$_col3_width"

        if [[ $_rowx -eq 0 ]]; then
            lib_base__gen_divider "$G__DIVIDER_H3_CHAR"
        fi
    done
    lib_base__gen_divider "$G__DIVIDER_H3_CHAR"
    echo -e "Total passed: ${G__COLOR_GREEN}${_total_passed} TCs${G__COLOR_RESET}"
    echo -e "Total failed: ${G__COLOR_RED}${_total_failed} TCs${G__COLOR_RESET}"
    lib_base__gen_divider "$G__DIVIDER_H2_CHAR"

    return "$G__ERR_OK"
}

# =============================================================================
# Public Functions
# =============================================================================

#######################################
# Assert whether SUT exists.
#
# Arguments:
#   sut_name [in]: Name of the SUT to assert.
#
# Returns:
#   G__ERR_OK: SUT does exist.
#   G__ERR_MISSING_ARG: No SUT name was provided.
#   G__ERR_NOT_OK: SUT does not exist.
#######################################
function lib_tests__sut_existence() {
    # Constants

    # Variables
    local _sut_name

    local _sut_exists=$G__ERR_OK

    # Parse and validate arguments
    [[ $# -eq 0 ]] && exit "$G__ERR_MISSING_ARG"

    _sut_name="$1"

    # Function body
    type "$_sut_name" >/dev/null 2>&1 || _sut_exists=$?

    if [[ "$_sut_exists" -eq "$G__ERR_OK" ]]; then
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
#   actual [in]: Actual error code.
#
# Returns:
#   G__ERR_OK: Expected code and actual code are equal.
#   G__ERR_MISSING_ARG: Expected or actual code was not provided.
#   G__ERR_INVALID_ARG: Expected or actual code was not a number.
#   G__ERR_NOT_OK: Error codes are not equal.
#######################################
function lib_tests__error_code_eq() {
    # Constants

    # Variables
    local _expected
    local _actual

    local _expected_str=""
    local _actual_str=""

    # Parse and validate arguments
    if [[ $# -lt 2 ]]; then
        echo -e "${G__COLOR_RED}[FATAL] Expected code and actual code must be provided${G__COLOR_RESET}" >&2
        exit "$G__ERR_MISSING_ARG"
    fi

    _expected="$1"
    _actual="$2"

    if [[ ! "$_expected" =~ ^0*[0-9][0-9]*$ ]]; then
        echo -e "${G__COLOR_RED}[FATAL] Expected code must be a number${G__COLOR_RESET}" >&2
        exit "$G__ERR_INVALID_ARG"
    fi

    if [[ ! "$_actual" =~ ^0*[0-9][0-9]*$ ]]; then
        echo -e "${G__COLOR_RED}[FATAL] Actual code must be a number${G__COLOR_RESET}" >&2
        exit "$G__ERR_INVALID_ARG"
    fi

    # Function body
    if [[ "$_expected" == "$_actual" ]]; then
        return "$G__ERR_OK"
    fi

    _expected_str="$(lib_base__error_code_to_string "$_expected")"
    _actual_str="$(lib_base__error_code_to_string "$_actual")"

    echo -e "${G__COLOR_RED}[ERROR] Assertion failed: error codes are not equal${G__COLOR_RESET}" >&2
    echo -e "${G__COLOR_CYAN}  Expected: '${_expected_str}'${G__COLOR_RESET}" >&2
    echo -e "${G__COLOR_MAGENTA}    Actual: '${_actual_str}'${G__COLOR_RESET}" >&2

    exit "$G__ERR_NOT_OK"
}

#######################################
# Assert equality between expected and actual values.
#
# Arguments:
#   expected [in]: Expected value.
#   actual [in]: Actual value to compare against expected.
#   message [in]: (optional) Failure message to print if values differ.
#
# Returns:
#   G__ERR_OK: Expected and actual values are equal.
#   G__ERR_MISSING_ARG: Expected or actual value was not provided.
#   G__ERR_NOT_OK: Values are not equal.
#######################################
function lib_tests__eq() {
    # Constants

    # Variables
    local _expected
    local _actual
    local _message

    # Parse and validate arguments
    [[ $# -lt 2 ]] && exit "$G__ERR_MISSING_ARG"

    _expected="$1"
    _actual="$2"
    _message="${3:-}"

    # Function body
    if [[ "$_expected" == "$_actual" ]]; then
        return "$G__ERR_OK"
    fi

    echo -e "${G__COLOR_RED}[ERROR] Assertion failed: values are not equal${G__COLOR_RESET}" >&2
    [[ -n "$_message" ]] && echo -e "${G__COLOR_RED}  >> ${_message}${G__COLOR_RESET}" >&2
    echo -e "${G__COLOR_CYAN}  Expected: '${_expected}'${G__COLOR_RESET}" >&2
    echo -e "${G__COLOR_MAGENTA}    Actual: '${_actual}'${G__COLOR_RESET}" >&2

    exit "$G__ERR_NOT_OK"
}

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
function lib_tests__test_main() {
    # Constants

    # Variables
    local _fut_path
    local -a _fut_deps=()

    local _ret_code=$G__ERR_OK

    # Parse and validate arguments
    if [[ $# -lt 1 ]]; then
        echo -e "${G__COLOR_RED}Must provide FUT path${G__COLOR_RESET}"
        return "$G__ERR_MISSING_ARG"
    fi

    _fut_path="$1"
    shift
    _fut_deps=("$@")

    # Function body
    echo -e "${G__COLOR_BLUE}~~~~~ START TESTS ~~~~~${G__COLOR_RESET}"

    _lib_tests__load_sut "$_fut_path" "${_fut_deps[@]}"
    _ret_code=$?

    if [[ "$_ret_code" -eq "$G__ERR_OK" ]]; then
        _lib_tests__collect_tests
        _ret_code=$?
    fi

    if [[ "$_ret_code" -eq "$G__ERR_OK" ]]; then
        _lib_tests__run_tests
        _ret_code=$?
    fi

    _lib_tests__print_test_results "$_fut_path"

    echo -e "${G__COLOR_BLUE}~~~~~ END TESTS ~~~~~${G__COLOR_RESET}"

    if [[ "$_ret_code" -ne "$G__ERR_OK" ]]; then
        echo -e "${G__COLOR_RED}Unexpectedly exit with ${_ret_code}${G__COLOR_RESET}"
    fi

    return "$_ret_code"
}

# =============================================================================
# Entry Point
# =============================================================================

# shellcheck disable=SC1090,SC1091
source "$LIB_BASE_PATH"
