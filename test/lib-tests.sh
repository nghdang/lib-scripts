#!/usr/bin/env bash
#
# Source      : src/lib-constants.sh
# Dependencies: None
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

LIB_TESTS_DEPS=(
    "../src/lib-constants.sh"
)
readonly LIB_TESTS_DEPS

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

#######################################
# Generate a divider.
#
# Arguments:
#   _char [in]: Divider character to paint.
#
# Returns:
#   G__ERR_OK: Divider was generated successfully.
#   G__ERR_MISSING_ARG: Divider char was not provided.
#   G__ERR_INVALID_ARG: Divider char is empty.
#######################################
function _lib_tests__gen_divider() {
    [[ $# -eq 0 ]] && return "$G__ERR_MISSING_ARG"

    local _char="$1"
    [[ -z "$_char" ]] && return "$G__ERR_INVALID_ARG"

    local _placeholder

    printf -v _placeholder '%*s' "$G__DIVIDER_WIDTH" ''
    echo "${_placeholder// /$_char}"

    return "$G__ERR_OK"
}

# ----- Test main breaking down functions -----

#######################################
# Load and source the FUT and its dependencies.
#
# Arguments:
#   _fut_path [in]: Path to the FUT.
#   _fut_deps [in]: (optional) Paths of dependency scripts required by the FUT.
#
# Returns:
#   G__ERR_OK: FUT and it's dependencies were loaded successfully.
#   G__ERR_MISSING_ARG: FUT was not provided.
#   G__ERR_NOT_FOUND: FUT or any dependency does not exist.
#######################################
function _load_sut() {
    [[ $# -eq 0 ]] && return "$G__ERR_MISSING_ARG"

    local _fut_path="$1"
    shift
    local _fut_deps=("$@")

    local _fut_dep

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
    _lib_tests__gen_divider "$G__DIVIDER_H2_CHAR"
    echo -e "${G__COLOR_BLUE}>> FUT: ${_fut_path}${G__COLOR_RESET}"
    for _fut_dep in "${_fut_deps[@]}"; do
        echo -e "${G__COLOR_GRAY}     - ${_fut_dep}${G__COLOR_RESET}"
    done
    _lib_tests__gen_divider "$G__DIVIDER_H2_CHAR"
}

#######################################
# Discover and group test functions starting with 'tc_' by their SUT.
#
# Globals:
#   test_cases: Associative array mapping discovered SUT names to test cases.
#   COLOR_CYAN: Cyan terminal ANSI escape sequence.
#   COLOR_RESET: Terminal reset ANSI sequence.
#
# Returns:
#   0: Test discovery completed or no test cases found.
#######################################
function _collect_tests() {
    local -a _fut_tc_names=()

    local _fut_tc_names_raw
    local _tc_name
    local _sut_names
    local _sut_name

    echo "Finding test cases..."

    _fut_tc_names_raw="$(declare -F | grep 'declare -f tc_' | sort | awk '{print $3}')"

    if [[ -z "$_fut_tc_names_raw" ]]; then
        echo -e "${G__COLOR_YELLOW}No test case is found. All test cases should start with 'tc_' to be able to recognize${G__COLOR_RESET}"
        return 0
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
}

#######################################
# Execute all collected test cases grouped by SUT and record the results.
#
#######################################
function _run_tests() {
    local _total_suts="${#test_cases[@]}"
    local _sut_no=1
    local _sut_result_color="$COLOR_GREEN"

    local _ret_code=0
    local _sut_names
    local _sut_name

    mapfile -t _sut_names < <(printf "%s\n" "${!test_cases[@]}" | sort)
    for _sut_name in "${_sut_names[@]}"; do
        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut_name"

        local _total_tcs="${#_sut_ref[@]}"
        local _tc_idx

        echo ""
        _lib_tests__gen_divider "$G__DIVIDER_H2_CHAR"
        echo -e "${G__COLOR_CYAN}>> START SUT: [${_sut_no}/${_total_suts}] ${_sut_name}${G__COLOR_RESET}"
        _lib_tests__gen_divider "$G__DIVIDER_H2_CHAR"

        for _idx in "${!_sut_ref[@]}"; do
            local _tc_name="${_sut_ref[$_idx]}"
            local _tc_summary="[$((_idx + 1))/${_total_tcs}] TC: ${_tc_name}"

            local _tc_return_code
            local _tc_result_color

            echo -e "${G__COLOR_CYAN}  ++ TC: [$((_idx + 1))/${_total_tcs}] ${_tc_name}${G__COLOR_RESET}"

            "$_tc_name"
            _tc_return_code=$?

            if [[ $_tc_return_code -eq 0 ]]; then
                _tc_result_color="$COLOR_GREEN"
                test_results[$_tc_name]="$PASSED"
            else
                _tc_result_color="$COLOR_RED"
                _sut_result_color="$COLOR_RED"
                test_results[$_tc_name]="$FAILED"
                _ret_code=1
            fi

            _lib_tests__gen_divider "$G__DIVIDER_H3_CHAR"
        done

        echo -e "${_sut_result_color}>> END SUT: [${_sut_no}/${_total_suts}] ${_sut_name}${G__COLOR_RESET}"
        _lib_tests__gen_divider "$G__DIVIDER_H2_CHAR"

        _sut_no=$((_sut_no + 1))
    done

    return "$_ret_code"
}

#######################################
# Print a formatted summary table of all test case execution results.
#
# Arguments:
#   fut_path [in]: Path to the FUT script.
#######################################
function _print_test_results() {
    local _fut_path="${1}"

    local -a _col1_values=()
    local -a _col2_values=()
    local -a _col3_values=()

    local _col1_width=0
    local _col2_width=0
    local _col3_width=0

    local _total_passed=0
    local _total_failed=0

    local _line
    local _rowx

    _print_test_results__print_summary "$_fut_path"
    _print_test_results__prepare_table_values
    _print_test_results__calc_column_widths

    for _rowx in "${!_col1_values[@]}"; do
        local _col1_value="${_col1_values[$_rowx]}"
        local _col2_value="${_col2_values[$_rowx]}"
        local _col3_value="${_col3_values[$_rowx]}"

        if [[ "$_col3_value" == "$PASSED" ]]; then
            _total_passed=$((_total_passed + 1))
        elif [[ "$_col3_value" == "$FAILED" ]]; then
            _total_failed=$((_total_failed + 1))
        fi

        _print_test_results__print_row

        if [[ $_rowx -eq 0 ]]; then
            _lib_tests__gen_divider "$G__DIVIDER_H3_CHAR"
        else
            _lib_tests__gen_divider "$G__DIVIDER_H4_CHAR"
        fi
    done

    echo -e "Total passed: ${G__COLOR_GREEN}${_total_passed} TCs${G__COLOR_RESET}"
    echo -e "Total failed: ${G__COLOR_RED}${_total_failed} TCs${G__COLOR_RESET}"
    _lib_tests__gen_divider "$G__DIVIDER_H2_CHAR"
}

#######################################
# Print the test summary banner displaying the path of the FUT.
#
# Arguments:
#   fut_path [in]: Path to the FUT script.
#######################################
function _print_test_results__print_summary() {
    local _fut_path="${1}"

    local _summary="FUT: $_fut_path"
    local _pad_len=$(((G__TABLE_WIDTH - ${#_summary}) / 2))

    local _pad
    local _line

    _pad="$(printf "%0.s " $(seq 1 $_pad_len))"
    _line="$(printf "%-*s" "$G__TABLE_WIDTH" "${_pad}${_summary}")"

    echo ""
    _lib_tests__gen_divider "$G__DIVIDER_H2_CHAR"
    echo "${G__TABLE_ROW_PREFIX}${_line}${G__TABLE_ROW_SUFFIX}"
    _lib_tests__gen_divider "$G__DIVIDER_H2_CHAR"
}

#######################################
# Populate table column value arrays with headers and test case execution statuses.
#
# Globals:
#   test_cases: Associative array mapping discovered SUT names to test cases.
#   test_results: Associative array storing execution status of each test case.
#######################################
function _print_test_results__prepare_table_values() {
    _col1_values=("SUT")
    _col2_values=("Test Case")
    _col3_values=("Status")

    local _sut_names
    local _sut_name
    mapfile -t _sut_names < <(printf "%s\n" "${!test_cases[@]}" | sort)

    for _sut_name in "${_sut_names[@]}"; do
        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut_name"

        local _tc_name

        for _tc_name in "${_sut_ref[@]}"; do
            _test_result="${test_results[$_tc_name]}"

            _col1_values+=("$_sut_name")
            _col2_values+=("$_tc_name")
            _col3_values+=("$_test_result")
        done
    done
}

#######################################
# Calculate column widths for the test results table.
#######################################
function _print_test_results__calc_column_widths() {
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

    _col2_width=$((G__TABLE_WIDTH - _col1_width - TABLE_COL_SEPARATOR_LEN))
    _col2_width=$((_col2_width - _col3_width - TABLE_COL_SEPARATOR_LEN))
}

#######################################
# Print a formatted row of the test results table with status-based color styling.
#######################################
function _print_test_results__print_row() {
    local _row_color="$COLOR_RESET"

    local _line

    if [[ "$_col3_value" == "$PASSED" ]]; then
        _row_color="$COLOR_GREEN"
    elif [[ "$_col3_value" == "$FAILED" ]]; then
        _row_color="$COLOR_RED"
    else
        _row_color="$COLOR_YELLOW"
    fi

    _line="${_row_color}$(printf "%-*s" "$_col1_width" "$_col1_value")"
    _line="${_line}${G__TABLE_COL_SEPARATOR}"
    _line="${_line}$(printf "%-*s" "$_col2_width" "$_col2_value")"
    _line="${_line}${G__TABLE_COL_SEPARATOR}"
    _line="${_line}$(printf "%-*s" "$_col3_width" "$_col3_value")${G__COLOR_RESET}"

    echo "${G__TABLE_ROW_PREFIX}${_line}${G__TABLE_ROW_SUFFIX}"
}

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Assert equality between expected and actual values.
#
# Arguments:
#   expected [in]: Expected value.
#   actual [in]: Actual value to compare against expected.
#######################################
function tests__eq() {
    local _expected="$1"
    local _actual="$2"

    if [[ "$_expected" == "$_actual" ]]; then
        return 0
    fi

    g_logging__error "Assertion failed: values are not equal"
    g_logging__info "${G__COLOR_CYAN}  Expected: '${_expected}'${G__COLOR_RESET}"
    g_logging__info "${G__COLOR_MAGENTA}    Actual: '${_actual}'${G__COLOR_RESET}"
}

# =====================================
# Test Entry Point
# =====================================
#######################################
# Execute the main test suite workflow for a given File Under Test (FUT).
#
# Arguments:
#   fut_path [in]: Path to the FUT script.
#   fut_deps [in]: (optional) Paths of dependency scripts required by the FUT.
#
# Returns:
#   G__ERR_OK: The test was run successfully.
#   G__ERR_MISSING_ARG: FUT was not provided.
#######################################
function test_main() {
    local _dependency
    local _dependency_path

    for _dependency in "${LIB_TESTS_DEPS[@]}"; do
        _dependency_path="$(realpath "${LIB_TESTS_PARENT_DIR}/${_dependency}")"

        # shellcheck disable=SC1090,SC1091
        source "$_dependency_path"
    done

    if [[ $# -lt 1 ]]; then
        echo -e "${G__COLOR_RED}Must provide FUT path"
        return "$G__ERR_MISSING_ARG"
    fi

    local _fut_path="${1}"
    shift
    local _fut_deps=("$@")

    local _ret_code

    echo -e "${G__COLOR_BLUE}~~~~~ START TESTS ~~~~~${G__COLOR_RESET}"

    _load_sut "$_fut_path" "${_fut_deps[@]}"
    _ret_code=$?

    if [[ "$_ret_code" -eq "$G__ERR_OK" ]]; then
        _collect_tests
        _ret_code=$?
    fi

    # _run_tests
    # _ret_code=$?
    # _print_test_results "$_fut_path"

    echo -e "${G__COLOR_BLUE}~~~~~ END TESTS ~~~~~${G__COLOR_RESET}"

    if [[ "$_ret_code" -ne "$G__ERR_OK" ]]; then
        echo -e "${G__COLOR_RED}Unexpectedly exit with ${_ret_code}${G__COLOR_RESET}"
    fi

    return "$_ret_code"
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    test_main "$@"
fi
