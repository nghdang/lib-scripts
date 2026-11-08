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
declare -gr G__TEST_LIB_LAYOUT_SH_LOADED=1

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

#######################################
# Assert that the table layout has identical column widths across rows.
#
# Arguments:
#   table  [in]: Formatted table string.
#   ncols  [in]: Expected column count per data row.
#   border [in]: (optional) Border character. Defaults to "|".
#
# Returns:
#   G__ERR_OK: Table layout is valid and consistent.
#######################################
function _helper__assert_table_layout() {
    # Constants

    # Parameters
    local _table
    local _ncols
    local _border

    # Variables
    local _line
    local _content
    local _row_clean
    local _separator
    local _idx
    local _col_len
    local _verified_rows=0
    local -a _expected_widths=()
    local -a _columns=()

    # Parse and validate arguments
    _table="$1"
    _ncols="$2"
    _border="${3:-|}"

    # Function body
    while IFS= read -r _line; do
        if [[ "$_line" == "$_border "* && "$_line" == *" $_border" ]]; then
            _content="${_line#"$_border "}"
            _content="${_content%" $_border"}"

            _separator=$'\x1f'
            _row_clean="${_content//" $_border "/$_separator}"
            _columns=()
            IFS="$_separator" read -ra _columns <<<"$_row_clean"

            if [[ "${#_columns[@]}" -eq "$_ncols" ]]; then
                _verified_rows=$((_verified_rows + 1))
                for ((_idx = 0; _idx < _ncols; _idx++)); do
                    local _clean_col="${_columns[_idx]//$'\033'\[*([0-9;])[a-zA-Z]/}"
                    _col_len="${#_clean_col}"
                    if [[ -z "${_expected_widths[_idx]:-}" ]]; then
                        _expected_widths[_idx]="$_col_len"
                    else
                        lib_testing__eq "${_expected_widths[_idx]}" "$_col_len" \
                            "Column ${_idx} width mismatch between rows"
                    fi
                done
            fi
        fi
    done <<<"$_table"

    if [[ "$_verified_rows" -eq 0 ]]; then
        lib_testing__eq "1" "0" "Expected at least one data row to validate table layout"
    fi

    return "$G__ERR_OK"
}

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
# ID    ncols   cells       summary     user_widths table_width border  align       Expected Output / Behavior              Return Code
# --    -----   -----       -------     ----------- ----------- ------  -----       --------------------------              ------------------------
# TC1   (miss)  (missing)   (none)      (none)      (none)      (none)  (none)      exits with G__ERR_MISSING_ARG           G__ERR_MISSING_ARG
# TC2   2       3 cells     (none)      (none)      (none)      (none)  (none)      incompatible cell count                 G__ERR_INCOMPATIBLE_ARGS
# TC3   2       4 cells     "Summary"   (none)      (none)      (none)  (none)      table with summary, aligned columns     G__ERR_OK
# TC4   2       4 cells     ""          (none)      (none)      (none)  (none)      table without summary, aligned columns  G__ERR_OK
# TC5   2       2 cells     ""          ()          80          "|"     "left"      (extra) exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC6   "abc"   2 cells     (none)      (none)      (none)      (none)  (none)      exits with G__ERR_TYPE_ERROR            G__ERR_TYPE_ERROR
# TC7   2       6 cells     "Summary"   (15, 15)    50          "#"     "right"     all 8 parameters, aligned columns       G__ERR_OK
# TC8   3       9 cells     ""          ()          60          ":"     "center"    special combinations, aligned columns   G__ERR_OK
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

    _helper__assert_table_layout "$_table" 2
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

    _helper__assert_table_layout "$_table" 2
}

function tc__draw_table__tc5__too_many_args() {
    local _table=""
    local -a _cells=("Col1" "Col2")
    local -a _user_widths=(10 10)
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_table"

    (lib_layout__draw_table _table 2 _cells "" _user_widths 80 "|" \
        "$G__TEXT_ALIGN_LEFT" "extra_arg")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__draw_table__tc6__type_error() {
    local _table=""
    local -a _cells=("Col1" "Col2")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_table"

    (lib_layout__draw_table _table "invalid_ncols" _cells)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__draw_table__tc7__all_parameters() {
    local _table=""
    local -a _cells=("Item" "Quantity" "${G__COLOR_GREEN}Apple${G__COLOR_RESET}" "100" "Banana" "25")
    local -a _user_widths=(15 15)
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_table"

    lib_layout__draw_table _table 2 _cells "Inventory Report" _user_widths 50 \
        "#" "$G__TEXT_ALIGN_RIGHT"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_table" | grep -q "Inventory Report"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected summary text in table output"

    echo "$_table" | grep -q "#"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected custom border '#' in table output"

    _helper__assert_table_layout "$_table" 2 "#"
}

function tc__draw_table__tc8__special_combinations() {
    local _table=""
    local -a _cells=("ID" "Status" "Priority" "1" "Active" "High" "2" "Pending" "Low")
    local -a _user_widths=()
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_layout__draw_table"

    lib_layout__draw_table _table 3 _cells "" _user_widths 60 ":" "$G__TEXT_ALIGN_CENTER"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"

    echo "$_table" | grep -q ":"
    lib_testing__eq "$G__ERR_OK" "$?" "Expected custom border ':' in table output"

    _helper__assert_table_layout "$_table" 3 ":"
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
