#!/usr/bin/env bash
#region File Header
#
# Source      : src/lib-base.sh
# Dependencies: None
# Description : Global constants and very basic utilities that can be used in any projects.
#
#endregion File Header

# ----- Source Guard -----
[[ -n "${G__LIB_BASE_SH_LOADED:-}" ]] && return 0
declare -rx G__LIB_BASE_SH_LOADED=1

#region Global Constants
# ==================================================================================================
# Global Constants
# ==================================================================================================

#region Global Constants - Project Scope
# ===== Project Scope =====

# ----- Terminal & UI Styling -----
declare -rx G__COLOR_RED=$'\033[0;31m'
declare -rx G__COLOR_GREEN=$'\033[0;32m'
declare -rx G__COLOR_YELLOW=$'\033[0;33m'
declare -rx G__COLOR_BLUE=$'\033[0;34m'
declare -rx G__COLOR_MAGENTA=$'\033[0;35m'
declare -rx G__COLOR_CYAN=$'\033[0;36m'
declare -rx G__COLOR_GRAY=$'\033[0;37m'
declare -rx G__COLOR_RESET=$'\033[0m'

declare -rx G__DIVIDER_H0_CHAR="@"
declare -rx G__DIVIDER_H1_CHAR="#"
declare -rx G__DIVIDER_H2_CHAR="="
declare -rx G__DIVIDER_H3_CHAR="-"
declare -rx G__DIVIDER_H4_CHAR="."

# ----- Error Codes -----
# Positive error codes
declare -rx G__ERR_OK=0
declare -rx G__ERR_NOT_OK=255

# Arguments error codes
declare -rx G__ERR_MISSING_ARG=10
declare -rx G__ERR_TOO_MANY_ARGS=11
declare -rx G__ERR_TYPE_ERROR=12
declare -rx G__ERR_INCOMPATIBLE_ARGS=13

# File system error codes
declare -rx G__ERR_NOT_FOUND=20
declare -rx G__ERR_ALREADY_EXISTS=21
declare -rx G__ERR_NOT_FILE=22
declare -rx G__ERR_NOT_DIR=23
declare -rx G__ERR_READ_FAILED=24
declare -rx G__ERR_WRITE_FAILED=25

declare -rAx G__ERR_NAMES=(
    # Positive error codes
    [$G__ERR_OK]="ERR_OK"
    [$G__ERR_NOT_OK]="ERR_NOT_OK"

    # Arguments error codes
    [$G__ERR_MISSING_ARG]="ERR_MISSING_ARG"
    [$G__ERR_TYPE_ERROR]="ERR_TYPE_ERROR"
    [$G__ERR_TOO_MANY_ARGS]="ERR_TOO_MANY_ARGS"
    [$G__ERR_INCOMPATIBLE_ARGS]="ERR_INCOMPATIBLE_ARGS"

    # File system error codes
    [$G__ERR_NOT_FOUND]="ERR_NOT_FOUND"
    [$G__ERR_ALREADY_EXISTS]="ERR_ALREADY_EXISTS"
    [$G__ERR_NOT_FILE]="ERR_NOT_FILE"
    [$G__ERR_NOT_DIR]="ERR_NOT_DIR"
    [$G__ERR_READ_FAILED]="ERR_READ_FAILED"
    [$G__ERR_WRITE_FAILED]="ERR_WRITE_FAILED"
)

# ----- Logging -----
declare -rx G__LOG_LEVEL_DEBUG=0
declare -rx G__LOG_LEVEL_INFO=1
declare -rx G__LOG_LEVEL_WARN=2
declare -rx G__LOG_LEVEL_ERROR=3
declare -rx G__LOG_LEVEL_FATAL=4

# ----- Text Alignment -----
declare -rx G__TEXT_ALIGN_LEFT="left"
declare -rx G__TEXT_ALIGN_CENTER="center"
declare -rx G__TEXT_ALIGN_RIGHT="right"
declare -rx G__TEXT_ALIGNS=(
    "$G__TEXT_ALIGN_LEFT"
    "$G__TEXT_ALIGN_CENTER"
    "$G__TEXT_ALIGN_RIGHT"
)

#endregion Global Constants - Project Scope

#region Global Constants - File Scope
# ===== File Scope =====
# ----- Logging -----
readonly LOG_LEVEL_NAMES=("DEBUG" "INFO" "WARN" "ERROR" "FATAL")
readonly DEFAULT_LOG_LEVEL="$G__LOG_LEVEL_INFO"
readonly DEFAULT_STACK=1

# ----- Layout & Table Formatting -----
readonly DEFAULT_TABLE_WIDTH=80
readonly DEFAULT_TABLE_BORDER="|"

#endregion Global Constants - File Scope
#endregion Global Constants

#region Global Variables
# ==================================================================================================
# Global Variables
# ==================================================================================================

#region Global Variables - Project Scope
# ===== Project Scope =====

#endregion Global Variables - Project Scope

#region Global Variables - File Scope
# ===== File Scope =====

#endregion Global Variables - File Scope
#endregion Global Variables

#region Private Functions
# ==================================================================================================
# Private Functions
# ==================================================================================================
#region _lib_base__write_log
#######################################
# Write a formatted log message to STDOUT.
#
# Arguments:
#   level_str [in]: Log level string (e.g., "DEBUG", "INFO", "WARN", ...).
#   message   [in]: Message text to print.
#   stack     [in]: (optional) Stack depth. Defaults to 1.
#
# Outputs:
#   Formatted log message written to STDOUT.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 3 arguments were provided.
#   G__ERR_TYPE_ERROR: Invalid log level string or stack level number.
#######################################
#endregion _lib_base__write_log
function _lib_base__write_log() {
    # Constants

    # Variables
    local _level_str
    local _message
    local _stack

    local _timestamp
    local _caller_path
    local _caller_name
    local _func_name
    local _line_no
    local _context
    local -a _lines=()
    local _line

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2" "3"

    _level_str="$1"
    _message="$2"
    _stack="${3:-$DEFAULT_STACK}"

    lib_base__assert_in "${LOG_LEVEL_NAMES[*]}" "$_level_str"
    lib_base__assert_number "$_stack" "Log stack level"

    # Function body
    _timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

    _caller_path="${BASH_SOURCE[$((_stack + 1))]:-unknown}"
    _caller_name="${_caller_path##*/}"

    _func_name="${FUNCNAME[$((_stack + 1))]:-unknown}"

    _line_no="${BASH_LINENO[$_stack]:-0}"

    _context="$_timestamp $(printf '%5s' "$_level_str")"
    _context="$_context $_caller_name ${_func_name}:${_line_no}"

    mapfile -t _lines <<<"$_message"

    for _line in "${_lines[@]}"; do
        printf '%s %b\n' "$_context" "$_line"
    done

    return "$G__ERR_OK"
}

#region _lib_base__draw_table_summary
#######################################
# Draw a bordered single-row table with summary text.
#
# Arguments:
#   ret_val_ref [out]: Name of variable to store the formatted summary row.
#   summary      [in]: Summary text to display in the table.
#   table_width  [in]: (optional) Table width. Defaults to 80.
#   border       [in]: (optional) Table border character. Defaults to '|'.
#   align        [in]: (optional) Text alignment ('left', 'center', 'right'). Defaults to 'center'.
#
# Returns:
#   G__ERR_OK: Summary row was created successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 5 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, table width is not a number,
#                      or alignment is invalid.
#######################################
#endregion _lib_base__draw_table_summary
function _lib_base__draw_table_summary() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _summary
    local _table_width
    local _border
    local _align

    local _line_width
    local _summary_line=""

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2" "5"

    _ret_val_ref="$1"
    _summary="$2"
    _table_width="${3:-$DEFAULT_TABLE_WIDTH}"
    _border="${4:-$DEFAULT_TABLE_BORDER}"
    _align="${5:-$G__TEXT_ALIGN_CENTER}"

    lib_base__assert_var_name "${!_ret_val_ref}"
    lib_base__assert_number "$_table_width" "Table width"
    lib_base__assert_in "${G__TEXT_ALIGNS[*]}" "$_align"

    # Function body
    _line_width=$((_table_width - 2 * (${#_border} + 1)))
    lib_base__align "_summary_line" "$_summary" "$_line_width" "$_align"

    _ret_val_ref="$_border $_summary_line $_border"
    return "$G__ERR_OK"
}

#region _lib_base__calc_column_widths
#######################################
# Calculate column widths based on headers, cells, and user-defined widths.
#
# Arguments:
#   ret_val_ref     [out]: Name of variable to store column widths string.
#   ncols            [in]: Number of columns.
#   headers_str      [in]: Space-separated list of column headers.
#   cells_str        [in]: Space-separated list of cell values.
#   user_widths_str  [in]: Space-separated list of user-defined widths.
#   table_width      [in]: (optional) Table width. Defaults to 80.
#   border           [in]: (optional) Table border character. Defaults to '|'.
#
# Returns:
#   G__ERR_OK: Column widths were calculated successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 5 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 7 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, column count is not a number,
#                      or table width is not a number.
#   G__ERR_INCOMPATIBLE_ARGS: Header or cell count does not match column count.
#######################################
#endregion _lib_base__calc_column_widths
function _lib_base__calc_column_widths() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _ncols
    local _headers_str
    local _cells_str
    local _user_widths_str
    local _table_width
    local _border

    local -a _headers=()
    local -a _cells=()
    local -a _user_widths=()
    local -a _max_lens=()
    local -a _column_widths=()

    local _nrows=0
    local _colx
    local _rowx
    local _fixed_cols_width=0
    local _filled_ncols=0
    local _borders_width
    local _available_widths

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "5" "7"

    _ret_val_ref="$1"
    _ncols="$2"
    _headers_str="$3"
    _cells_str="$4"
    _user_widths_str="$5"
    _table_width="${6:-$DEFAULT_TABLE_WIDTH}"
    _border="${7:-$DEFAULT_TABLE_BORDER}"

    lib_base__assert_var_name "${!_ret_val_ref}"
    lib_base__assert_number "$_ncols" "Number of columns"

    IFS=' ' read -r -a "_headers" <<<"$_headers_str"
    IFS=' ' read -r -a "_cells" <<<"$_cells_str"
    IFS=' ' read -r -a "_user_widths" <<<"$_user_widths_str"

    lib_base__assert_number "$_table_width" "Table width"

    if [[ "$_ncols" -ne "${#_headers[@]}" ]]; then
        local _message="Number of headers and columns are not equal:"
        _message="${_message} $_ncols columns vs ${#_headers[@]} headers"
        lib_base__throw_exception "$G__ERR_INCOMPATIBLE_ARGS" "$_message"
    fi

    if [[ "$_ncols" -gt 0 ]]; then
        _nrows=$((${#_cells[@]} / _ncols))
    fi

    if [[ "$((_nrows * _ncols))" -ne "${#_cells[@]}" ]]; then
        local _message="Number of cells and columns are not matched:"
        _message="${_message} $_ncols columns vs ${#_cells[@]} cells"
        lib_base__throw_exception "$G__ERR_INCOMPATIBLE_ARGS" "$_message"
    fi

    # Function body
    # 1. Determine maximum column value length for each column
    for ((_colx = 0; _colx < _ncols; _colx++)); do
        local _column_max_len="${#_headers[_colx]}"

        for ((_rowx = 0; _rowx < _nrows; _rowx++)); do
            local _cell="${_cells[_colx + _ncols * _rowx]}"
            if [[ "${#_cell}" -gt "$_column_max_len" ]]; then
                _column_max_len="${#_cell}"
            fi
        done

        _max_lens+=("$_column_max_len")
    done

    # 2. Normalize user-defined widths to column count
    if [[ "${#_user_widths[@]}" -lt "$_ncols" ]]; then
        for ((_colx = ${#_user_widths[@]}; _colx < _ncols; _colx++)); do
            _user_widths+=("-1")
        done
    elif [[ "${#_user_widths[@]}" -gt "$_ncols" ]]; then
        _user_widths=("${_user_widths[@]:0:$_ncols}")
    fi

    # 3. Classify widths into fixed and filled values
    for ((_colx = 0; _colx < _ncols; _colx++)); do
        local _width="${_user_widths[_colx]}"
        local _max_len="${_max_lens[_colx]}"

        if [[ "$_width" -gt 0 ]]; then
            if [[ "$_width" -lt "$_max_len" ]]; then
                _width="$_max_len"
            fi
            _fixed_cols_width=$((_fixed_cols_width + _width))
        else
            _width="-1"
            _filled_ncols=$((_filled_ncols + 1))
        fi

        _column_widths+=("$_width")
    done

    _borders_width=$(((_ncols + 1) * (${#_border} + 1) + (_ncols - 1)))
    _available_widths=$((_table_width - _borders_width))

    # 4. Distribute available width to filled columns or scale last column
    if [[ "$_filled_ncols" -gt 0 ]]; then
        local _filled_cols_width
        local _filled_width
        local _last_filled_width
        local _filled_count=0

        _filled_cols_width=$((_available_widths - _fixed_cols_width))
        _filled_width=$((_filled_cols_width / _filled_ncols))
        _last_filled_width=$((_filled_cols_width - (_filled_ncols - 1) * _filled_width))

        for ((_colx = 0; _colx < _ncols; _colx++)); do
            if [[ "${_column_widths[_colx]}" -eq "-1" ]]; then
                _filled_count=$((_filled_count + 1))

                if [[ "$_filled_count" -eq "$_filled_ncols" ]]; then
                    _column_widths[_colx]="$_last_filled_width"
                else
                    _column_widths[_colx]="$_filled_width"
                fi
            fi
        done
    else
        local _total_cols_width=0

        for ((_colx = 0; _colx < _ncols; _colx++)); do
            _total_cols_width=$((_total_cols_width + _column_widths[_colx]))
        done

        if [[ "$_total_cols_width" -lt "$_available_widths" ]]; then
            local _diff=$((_available_widths - _total_cols_width))
            _column_widths[_ncols - 1]=$((_column_widths[_ncols - 1] + _diff))
        fi
    fi

    _ret_val_ref="${_column_widths[*]}"
    return "$G__ERR_OK"
}

#region _lib_base__draw_table_row
#######################################
# Draw a bordered table row.
#
# Arguments:
#   ret_val_ref       [out]: Name of variable to store the formatted row.
#   columns_str        [in]: Space-separated list of column values.
#   column_widths_str  [in]: Space-separated list of column widths.
#   table_width        [in]: (optional) Table width. Defaults to 80.
#   border             [in]: (optional) Table border character. Defaults to '|'.
#   align              [in]: (optional) Text alignment ('left', 'center', 'right'). Defaults to 'left'.
#
# Returns:
#   G__ERR_OK: Row was created successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 3 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 6 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, column values or widths are empty,
#                      table width is not a number, or alignment is invalid.
#   G__ERR_INCOMPATIBLE_ARGS: Column value and column width counts do not match.
#######################################
#endregion _lib_base__draw_table_row
function _lib_base__draw_table_row() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _columns_str
    local _column_widths_str
    local _table_width
    local _border
    local _align

    local -a _headers=()
    local -a _column_widths=()
    local _idx
    local _columns_line=""

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "3" "6"

    _ret_val_ref="$1"
    _columns_str="$2"
    _column_widths_str="$3"
    _table_width="${4:-$DEFAULT_TABLE_WIDTH}"
    _border="${5:-$DEFAULT_TABLE_BORDER}"
    _align="${6:-$G__TEXT_ALIGN_LEFT}"

    lib_base__assert_var_name "${!_ret_val_ref}"
    lib_base__assert_not_empty "$_columns_str" "Table column values"
    lib_base__assert_not_empty "$_column_widths_str" "Table column widths"
    lib_base__assert_number "$_table_width" "Table width"
    lib_base__assert_in "${G__TEXT_ALIGNS[*]}" "$_align"

    IFS=' ' read -r -a "_headers" <<<"$_columns_str"
    IFS=' ' read -r -a "_column_widths" <<<"$_column_widths_str"

    if [[ "${#_headers[@]}" -ne "${#_column_widths[@]}" ]]; then
        local _message="Number of headers and column widths are not equal:"
        _message="${_message} ${#_headers[@]} headers vs"
        _message="${_message} ${#_column_widths[@]} column widths"
        lib_base__throw_exception "$G__ERR_INCOMPATIBLE_ARGS" "$_message"
    fi

    # Function body
    for _idx in "${!_headers[@]}"; do
        local _column_value

        if [[ "$_idx" -gt "0" ]]; then
            _columns_line="$_columns_line $_border "
        fi

        lib_base__align "_column_value" "${_headers[$_idx]}" \
            "${_column_widths[$_idx]}" "$_align"

        _columns_line="${_columns_line}${_column_value}"
    done

    _ret_val_ref="$_border $_columns_line $_border"
    return "$G__ERR_OK"
}

#endregion Private Functions

#region Public Functions
# ==================================================================================================
# Public Functions
# ==================================================================================================

# ----- Validations -----

#region lib_base__is_var
#######################################
# Check whether the given parameter is a declared variable.
#
# Arguments:
#   param [in]: Name of the variable to check.
#
# Returns:
#   G__ERR_OK: The given parameter is a declared variable.
#   G__ERR_NOT_OK: The given parameter is not a declared variable.
#######################################
#endregion lib_base__is_var
function lib_base__is_var() {
    # Constants

    # Variables
    local _param

    # Parse and validate arguments
    _param="$1"

    # Function body
    [[ -z "$_param" ]] && return "$G__ERR_NOT_OK"
    declare -p -- "$_param" >/dev/null 2>&1 || return "$G__ERR_NOT_OK"
    return "$G__ERR_OK"
}

#region lib_base__is_array
#######################################
# Check whether the given parameter is an indexed array.
#
# Arguments:
#   param [in]: Name of the variable to check.
#
# Returns:
#   G__ERR_OK: The given variable is an indexed array.
#   G__ERR_NOT_OK: The given variable is not declared or an indexed array.
#######################################
#endregion lib_base__is_array
function lib_base__is_array() {
    # Constants

    # Variables
    local _param

    local _declaration=""

    # Parse and validate arguments
    _param="$1"

    # Function body
    lib_base__is_var "$_param" || return "$G__ERR_NOT_OK"
    _declaration="$(declare -p -- "$_param")" || return "$G__ERR_NOT_OK"
    [[ "$_declaration" =~ ^declare\ -[a-z]*a[a-z]*\  ]] && return "$G__ERR_OK"
    return "$G__ERR_NOT_OK"
}

#region lib_base__is_number
#######################################
# Check whether the given parameter is a number.
#
# Arguments:
#   param [in]: Value to check.
#
# Returns:
#   G__ERR_OK: The given parameter is a number.
#   G__ERR_NOT_OK: The given parameter is not a number.
#######################################
#endregion lib_base__is_number
function lib_base__is_number() {
    # Constants

    # Variables
    local _param

    # Parse and validate arguments
    _param="$1"

    # Function body
    [[ "$_param" =~ ^-*0*[0-9][0-9]*$ ]] && return "$G__ERR_OK"
    return "$G__ERR_NOT_OK"
}

#region lib_base__is_in
#######################################
# Check whether an array contains an item.
#
# Arguments:
#   array [in]: Space-separated list of items to check.
#   item  [in]: Item to check.
#
# Returns:
#   G__ERR_OK: The array contains the item.
#   G__ERR_NOT_OK: The array does not contain the item.
#######################################
#endregion lib_base__is_in
function lib_base__is_in() {
    # Constants

    # Variables
    local _array_str
    local _item

    local -a _array
    local _element

    # Parse and validate arguments
    _array_str="$1"
    _item="$2"

    # Function body
    IFS=' ' read -r -a "_array" <<<"$_array_str"

    if [[ "${#_array[@]}" -eq "0" ]]; then
        if [[ -z "$_item" ]]; then
            return "$G__ERR_OK"
        fi

        return "$G__ERR_NOT_OK"
    fi

    for _element in "${_array[@]}"; do
        [[ "$_element" == "$_item" ]] && return "$G__ERR_OK"
    done

    return "$G__ERR_NOT_OK"
}

# ----- Exceptions & Traceback -----

#region lib_base__traceback
#######################################
# Print the call stack traceback to STDERR.
#
# Arguments:
#   min_stack [in]: (optional) Minimum stack level to trace. Defaults to 1.
#
# Outputs:
#   Call stack traceback written to STDERR.
#
# Returns:
#   G__ERR_OK: Traceback was printed successfully.
#######################################
#endregion lib_base__traceback
function lib_base__traceback() {
    # Constants
    local -r _DEFAULT_STACK="1"

    # Variables
    local _min_stack

    local _stack
    local _file_path
    local _file_name
    local _line_no
    local _line
    local _func_name

    # Parse and validate arguments
    _min_stack="${1:-$_DEFAULT_STACK}"
    lib_base__is_number "$_min_stack" || _min_stack="$_DEFAULT_STACK"

    # Function body
    printf '%s\n' "Traceback (most recent call last):" >&2
    _stack="${#BASH_SOURCE[@]}"
    _stack="$((_stack - 1))"

    while [[ "$_min_stack" -lt "$_stack" ]]; do
        _file_path="$(realpath "${BASH_SOURCE[$_stack]}")"
        _file_name="$(basename "$_file_path")"
        _line_no="${BASH_LINENO[$((_stack - 1))]}"
        _func_name="${FUNCNAME[$_stack]}"

        _line="$(sed -n "${_line_no}p" "$_file_path")"
        _line="${_line#"${_line%%[![:space:]]*}"}"
        _line="${_line%"${_line##*[![:space:]]}"}"

        printf '  File "%s", line %d, in %s\n' "$_file_name" "$_line_no" \
            "$_func_name" >&2
        printf '    %s\n' "$_line" >&2

        _stack=$((_stack - 1))
    done

    return "$G__ERR_OK"
}

#region lib_base__throw_exception
#######################################
# Throw an exception and exit the current shell.
#
# Arguments:
#   error_code [in]: Exit code of the current shell.
#   message    [in]: Exception message. Defaults to 'An exception occurred!!' if empty.
#
# Outputs:
#   Exception message and call stack traceback written to STDERR.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: Error code is not a number.
#   <error_code>: Exception is thrown with the specified error code.
#######################################
#endregion lib_base__throw_exception
function lib_base__throw_exception() {
    # Constants
    local -r _DEFAULT_MESSAGE="An exception occurred!!"
    local -r _TRACEBACK_STACK="2"

    # Variables
    local _error_code
    local _message

    # Parse and validate arguments
    if [[ "$#" -lt "2" ]]; then
        lib_base__traceback
        lib_base__throw_exception "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 2 arguments"
    fi

    _error_code="$1"
    _message="${2:-$_DEFAULT_MESSAGE}"

    lib_base__is_number "$_error_code" || lib_base__throw_exception \
        "$G__ERR_TYPE_ERROR" "Error code must be a number: '$_error_code'"

    # Function body
    lib_base__traceback "$_TRACEBACK_STACK"
    printf '%s (%d): %s\n' "${G__ERR_NAMES[$_error_code]:-Unknown}" \
        "$_error_code" "${G__COLOR_RED}${_message}${G__COLOR_RESET}" >&2

    exit "$_error_code"
}

# ----- Assertions -----

#region lib_base__assert_args_count
#######################################
# Validate the argument count.
#
# Arguments:
#   args_count [in]: Number of arguments provided.
#   min_args   [in]: Minimum number of required arguments.
#   max_args   [in]: (optional) Maximum number of allowed arguments. Defaults to 100.
#
# Returns:
#   G__ERR_OK: Argument count is in range.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided, or argument count
#                       is less than min_args.
#   G__ERR_TOO_MANY_ARGS: Argument count is greater than max_args.
#   G__ERR_TYPE_ERROR: Any of parameters is not a number.
#######################################
#endregion lib_base__assert_args_count
function lib_base__assert_args_count() {
    # Constants
    local -r _MAX_ARGS="100"

    # Variables
    local _args_count
    local _min_args
    local _max_args

    # Parse and validate arguments
    if [[ "$#" -lt "2" ]]; then
        lib_base__throw_exception "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 2 arguments"
    fi

    _args_count="$1"
    _min_args="$2"
    _max_args="${3:-$_MAX_ARGS}"

    lib_base__is_number "$_args_count" || lib_base__throw_exception \
        "$G__ERR_TYPE_ERROR" "Argument count must be a number: '$_args_count'"

    lib_base__is_number "$_min_args" || lib_base__throw_exception \
        "$G__ERR_TYPE_ERROR" "Minimum arguments must be a number: '$_min_args'"

    lib_base__is_number "$_max_args" || lib_base__throw_exception \
        "$G__ERR_TYPE_ERROR" "Maximum arguments must be a number: '$_max_args'"

    # Function body
    if [[ "$_args_count" -lt "$_min_args" ]]; then
        lib_base__throw_exception "$G__ERR_MISSING_ARG" \
            "${FUNCNAME[1]} required at least $_min_args argument(s)"
    fi

    if [[ "$_args_count" -gt "$_max_args" ]]; then
        lib_base__throw_exception "$G__ERR_TOO_MANY_ARGS" \
            "${FUNCNAME[1]} allow at most $_max_args arguments"
    fi

    return "$G__ERR_OK"
}

#region lib_base__assert_var_name
#######################################
# Assert that the given parameter is a valid Bash variable name.
#
# Arguments:
#   param [in]: Variable name to assert.
#
# Returns:
#   G__ERR_OK: The given parameter is a valid variable name.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 1 argument was provided.
#   G__ERR_TYPE_ERROR: The given parameter is not a valid variable name.
#######################################
#endregion lib_base__assert_var_name
function lib_base__assert_var_name() {
    # Constants

    # Variables
    local _param

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "1"

    _param="$1"

    # Function body
    [[ "$_param" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && return "$G__ERR_OK"
    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "Not a valid variable name: '$_param'"
}

#region lib_base__assert_var
#######################################
# Assert that the given parameter is a declared variable.
#
# Arguments:
#   param [in]: Name of the variable to assert.
#
# Returns:
#   G__ERR_OK: The given parameter is a declared variable.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 1 argument was provided.
#   G__ERR_TYPE_ERROR: The given parameter is not a declared variable.
#######################################
#endregion lib_base__assert_var
function lib_base__assert_var() {
    # Constants

    # Variables
    local _param

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "1"

    _param="$1"

    # Function body
    lib_base__is_var "$_param" && return "$G__ERR_OK"
    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "Not a variable: '$_param'"
}

#region lib_base__assert_array
#######################################
# Assert that the given parameter is an indexed array.
#
# Arguments:
#   param [in]: Name of the variable to assert.
#
# Returns:
#   G__ERR_OK: The given variable is an indexed array.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 1 argument was provided.
#   G__ERR_TYPE_ERROR: The given variable is not an indexed array.
#######################################
#endregion lib_base__assert_array
function lib_base__assert_array() {
    # Constants

    # Variables
    local _param

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "1"

    _param="$1"

    # Function body
    lib_base__is_array "$_param" && return "$G__ERR_OK"
    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "Not an array: '$_param'"
}

#region lib_base__assert_number
#######################################
# Assert that the given parameter is a number.
#
# Arguments:
#   param [in]: Value to assert.
#   label [in]: (optional) Label of the param for assertion message.
#
# Returns:
#   G__ERR_OK: The given parameter is a number.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given parameter is not a number.
#######################################
#endregion lib_base__assert_number
function lib_base__assert_number() {
    # Constants

    # Variables
    local _param
    local _label

    local _message

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "2"

    _param="$1"
    _label="${2:-}"

    # Function body
    lib_base__is_number "$_param" && return "$G__ERR_OK"

    if [[ -z "$_label" ]]; then
        _message="Not a number: '$_param'"
    else
        _message="$_label must be a number: '$_param'"
    fi

    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "$_message"
}

#region lib_base__assert_not_empty
#######################################
# Assert that the given parameter is not empty.
#
# Arguments:
#   param [in]: Value to assert.
#   label [in]: (optional) Label of the param for assertion message.
#
# Returns:
#   G__ERR_OK: The given parameter is not empty.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given parameter is empty.
#######################################
#endregion lib_base__assert_not_empty
function lib_base__assert_not_empty() {
    # Constants

    # Variables
    local _param
    local _label

    local _message

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "2"

    _param="$1"
    _label="${2:-}"

    # Function body
    [[ -n "$_param" ]] && return "$G__ERR_OK"

    if [[ -z "$_label" ]]; then
        _message="Value is empty"
    else
        _message="$_label must not be empty"
    fi

    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "$_message"
}

#region lib_base__assert_in
#######################################
# Assert that an array contains an item.
#
# Arguments:
#   array [in]: Space-separated list of items.
#   item  [in]: Item to assert.
#
# Returns:
#   G__ERR_OK: The array contains the item.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The array does not contain the item.
#######################################
#endregion lib_base__assert_in
function lib_base__assert_in() {
    # Constants

    # Variables
    local _array_str
    local _item

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2" "2"

    _array_str="$1"
    _item="$2"

    # Function body
    lib_base__is_in "$_array_str" "$_item" && return "$G__ERR_OK"
    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "Item '$_item' is not in '$_array_str'"
}

# ----- Logging -----
#region lib_base__debug
#######################################
# Log a debug message to STDOUT.
#
# Arguments:
#   message [in]: Message text to print.
#   stack   [in]: (optional) Stack depth. Defaults to 1.
#
# Outputs:
#   Formatted debug log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Log message was not provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: Invalid stack level number.
#######################################
#endregion lib_base__debug
function lib_base__debug() {
    # Constants

    # Variables
    local _message
    local _stack

    local _error_code="$G__ERR_OK"
    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "2"

    _message="$1"
    _stack="${2:-$DEFAULT_STACK}"

    lib_base__assert_number "$_stack"

    # Function body
    lib_base__is_number "$_level" || _level="$DEFAULT_LOG_LEVEL"

    if [[ "$_level" -le "$G__LOG_LEVEL_DEBUG" ]]; then
        _lib_base__write_log "DEBUG" "$_message" "$_stack"
        _error_code=$?
    fi

    return "$_error_code"
}

#region lib_base__info
#######################################
# Log an info message to STDOUT.
#
# Arguments:
#   message [in]: Message text to print.
#   stack   [in]: (optional) Stack depth. Defaults to 1.
#
# Outputs:
#   Formatted info log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Log message was not provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: Invalid stack level number.
#######################################
#endregion lib_base__info
function lib_base__info() {
    # Constants

    # Variables
    local _message
    local _stack

    local _error_code="$G__ERR_OK"
    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "2"

    _message="$1"
    _stack="${2:-$DEFAULT_STACK}"

    lib_base__assert_number "$_stack"

    # Function body
    lib_base__is_number "$_level" || _level="$DEFAULT_LOG_LEVEL"

    if [[ "$_level" -le "$G__LOG_LEVEL_INFO" ]]; then
        _lib_base__write_log "INFO" "$_message" "$_stack"
        _error_code=$?
    fi

    return "$_error_code"
}

#region lib_base__warn
#######################################
# Log a warning message to STDOUT with yellow color.
#
# Arguments:
#   message [in]: Message text to print.
#   stack   [in]: (optional) Stack depth. Defaults to 1.
#
# Outputs:
#   Formatted warning log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Log message was not provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: Invalid stack level number.
#######################################
#endregion lib_base__warn
function lib_base__warn() {
    # Constants

    # Variables
    local _message
    local _stack

    local _error_code="$G__ERR_OK"
    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "2"

    _message="$1"
    _stack="${2:-$DEFAULT_STACK}"

    lib_base__assert_number "$_stack"

    # Function body
    lib_base__is_number "$_level" || _level="$DEFAULT_LOG_LEVEL"

    if [[ "$_level" -le "$G__LOG_LEVEL_WARN" ]]; then
        _message="${G__COLOR_YELLOW}${_message}${G__COLOR_RESET}"
        _lib_base__write_log "WARN" "$_message" "$_stack"
        _error_code=$?
    fi

    return "$_error_code"
}

#region lib_base__error
#######################################
# Log an error message to STDOUT with red color.
#
# Arguments:
#   message [in]: Message text to print.
#   stack   [in]: (optional) Stack depth. Defaults to 1.
#
# Outputs:
#   Formatted error log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Log message was not provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: Invalid stack level number.
#######################################
#endregion lib_base__error
function lib_base__error() {
    # Constants

    # Variables
    local _message
    local _stack

    local _error_code="$G__ERR_OK"
    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "2"

    _message="$1"
    _stack="${2:-$DEFAULT_STACK}"

    lib_base__assert_number "$_stack"

    # Function body
    lib_base__is_number "$_level" || _level="$DEFAULT_LOG_LEVEL"

    if [[ "$_level" -le "$G__LOG_LEVEL_ERROR" ]]; then
        _message="${G__COLOR_RED}${_message}${G__COLOR_RESET}"
        _lib_base__write_log "ERROR" "$_message" "$_stack"
        _error_code=$?
    fi

    return "$_error_code"
}

# ----- String Operations -----
#region lib_base__align
#######################################
# Align text within a specified width (left, center, or right).
#
# Arguments:
#   ret_val_ref [out]: Name of variable to store the aligned text.
#   text         [in]: Text to align.
#   width        [in]: (optional) Target width. Defaults to 80.
#   align        [in]: (optional) Text alignment ('left', 'center', 'right'). Defaults to 'left'.
#
# Returns:
#   G__ERR_OK: Text was aligned successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 4 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, target width is not a number,
#                      or alignment is invalid.
#######################################
#endregion lib_base__align
function lib_base__align() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _text
    local _width
    local _align

    local _padding_width=0
    local _padding=""
    local _aligned_text=""

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2" "4"

    _ret_val_ref="$1"
    _text="$2"
    _width="${3:-$DEFAULT_TABLE_WIDTH}"
    _align="${4:-$G__TEXT_ALIGN_LEFT}"

    lib_base__assert_var_name "${!_ret_val_ref}"
    lib_base__assert_number "$_width" "Target width"
    lib_base__assert_in "${G__TEXT_ALIGNS[*]}" "$_align"

    # Function body
    if [[ "$_align" == "$G__TEXT_ALIGN_LEFT" ]]; then
        printf -v "_aligned_text" '%-*s' "$_width" "$_text"
    elif [[ "$_align" == "$G__TEXT_ALIGN_RIGHT" ]]; then
        printf -v "_aligned_text" '%*s' "$_width" "$_text"
    elif [[ "$_align" == "$G__TEXT_ALIGN_CENTER" ]]; then
        _padding_width=$(((_width - ${#_text}) / 2))
        if [[ "$_padding_width" -gt 0 ]]; then
            printf -v "_padding" '%*s' "$_padding_width" ''
        fi
        printf -v "_aligned_text" '%-*s' "$_width" "${_padding}${_text}"
    fi

    _ret_val_ref="$_aligned_text"
    return "$G__ERR_OK"
}

#region lib_base__find_max_len
#######################################
# Find the maximum string length across an array of strings.
#
# Arguments:
#   ret_val_ref [out]: Name of variable to store the maximum length.
#   items        [in]: String items to measure.
#
# Returns:
#   G__ERR_OK: Max length was determined successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 100 arguments were provided.
#   G__ERR_TYPE_ERROR: Output variable name is invalid.
#######################################
#endregion lib_base__find_max_len
function lib_base__find_max_len() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local -a _items=()

    local _max_len=0
    local _item

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2"

    _ret_val_ref="$1"
    _items=("${@:2}")

    lib_base__assert_var_name "${!_ret_val_ref}"

    # Function body
    for _item in "${_items[@]}"; do
        if [[ "${#_item}" -gt "$_max_len" ]]; then
            _max_len="${#_item}"
        fi
    done

    _ret_val_ref="$_max_len"
    return "$G__ERR_OK"
}

# ----- Layout & Table Formatting -----

#region lib_base__draw_divider
#######################################
# Generate a divider.
#
# Arguments:
#   ret_val_ref [out]: Name of variable to store the generated divider.
#   char         [in]: Divider character to paint.
#   width        [in]: (optional) Divider width to paint. Defaults to 80.
#
# Returns:
#   G__ERR_OK: Divider was generated successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 3 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, divider character is empty,
#                      or width is not a number.
#######################################
#endregion lib_base__draw_divider
function lib_base__draw_divider() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _char
    local _width

    local _divider

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2" "3"

    _ret_val_ref="$1"
    _char="$2"
    _width="${3:-$DEFAULT_TABLE_WIDTH}"

    lib_base__assert_var_name "${!_ret_val_ref}"
    lib_base__assert_not_empty "$_char" "Divider character"
    lib_base__assert_number "$_width" "Divider width"

    # Function body
    printf -v "_divider" '%*s' "$_width" ''
    _divider="${_divider// /$_char}"

    _ret_val_ref="$_divider"
    return "$G__ERR_OK"
}

#region lib_base__draw_table
#######################################
# Draw a complete bordered table.
#
# Arguments:
#   ret_val_ref     [out]: Name of variable to store the formatted table.
#   ncols            [in]: Number of columns.
#   cells_str        [in]: Space-separated list of cell values.
#   summary          [in]: (optional) Table summary text. Defaults to ''.
#   user_widths_str  [in]: (optional) Space-separated list of user-defined widths. Defaults to ''.
#   table_width      [in]: (optional) Total table width. Defaults to 80.
#   border           [in]: (optional) Table border character. Defaults to '|'.
#   align            [in]: (optional) Column text alignment ('left', 'center', 'right').
#                          Defaults to 'left'.
#
# Returns:
#   G__ERR_OK: Table was created successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 3 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 8 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, column count is not a number,
#                      table width is not a number, or alignment is invalid.
#   G__ERR_INCOMPATIBLE_ARGS: Number of cells does not match column count.
#######################################
#endregion lib_base__draw_table
function lib_base__draw_table() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _ncols
    local _cells_str
    local _summary
    local _user_widths_str
    local _table_width
    local _border
    local _align

    local -a _cells=()
    local -a _user_widths=()
    local -a _max_lens=()
    local -a _calc_widths=()
    local _nrows=0
    local _colx
    local _rowx
    local _min_cols_width=0
    local _borders_width=0
    local _min_table_width=0
    local _total_row_width=0
    local _headers_slice=""
    local _rest_cells=""
    local _column_widths_str=""
    local _divider_h2=""
    local _divider_h3=""
    local _summary_row=""
    local _row=""
    local _table_lines=""

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "3" "8"

    _ret_val_ref="$1"
    _ncols="$2"
    _cells_str="$3"
    _summary="${4:-}"
    _user_widths_str="${5:-}"
    _table_width="${6:-$DEFAULT_TABLE_WIDTH}"
    _border="${7:-$DEFAULT_TABLE_BORDER}"
    _align="${8:-$G__TEXT_ALIGN_LEFT}"

    lib_base__assert_var_name "${!_ret_val_ref}"
    lib_base__assert_number "$_ncols" "Number of columns"
    lib_base__assert_number "$_table_width" "Table width"
    lib_base__assert_in "${G__TEXT_ALIGNS[*]}" "$_align"

    IFS=' ' read -r -a "_cells" <<<"$_cells_str"

    if [[ "$_ncols" -gt 0 ]]; then
        _nrows=$((${#_cells[@]} / _ncols))
    fi

    if [[ "$_ncols" -le 0 || "${#_cells[@]}" -eq 0 ||
        "$((_nrows * _ncols))" -ne "${#_cells[@]}" ]]; then
        local _message="Number of cells and columns are not matched:"
        _message="${_message} $_ncols columns vs ${#_cells[@]} cells"
        lib_base__throw_exception "$G__ERR_INCOMPATIBLE_ARGS" "$_message"
    fi

    # Function body
    IFS=' ' read -r -a "_user_widths" <<<"$_user_widths_str"

    for ((_colx = 0; _colx < _ncols; _colx++)); do
        local _column_max_len=0
        for ((_rowx = 0; _rowx < _nrows; _rowx++)); do
            local _cell="${_cells[_colx + _ncols * _rowx]}"
            if [[ "${#_cell}" -gt "$_column_max_len" ]]; then
                _column_max_len="${#_cell}"
            fi
        done
        _max_lens+=("$_column_max_len")

        local _u_width="${_user_widths[_colx]:--1}"
        if [[ "$_u_width" -gt "$_column_max_len" ]]; then
            _min_cols_width=$((_min_cols_width + _u_width))
        else
            _min_cols_width=$((_min_cols_width + _column_max_len))
        fi
    done

    _borders_width=$(((_ncols + 1) * (${#_border} + 1) + (_ncols - 1)))
    _min_table_width=$((_min_cols_width + _borders_width))
    if [[ "$_min_table_width" -gt "$_table_width" ]]; then
        _table_width="$_min_table_width"
    fi

    _headers_slice="${_cells[*]:0:_ncols}"
    _rest_cells="${_cells[*]:_ncols}"
    _lib_base__calc_column_widths "_column_widths_str" "$_ncols" "$_headers_slice" \
        "$_rest_cells" "$_user_widths_str" "$_table_width" "$_border"

    IFS=' ' read -r -a "_calc_widths" <<<"$_column_widths_str"

    for ((_colx = 0; _colx < _ncols; _colx++)); do
        if [[ "${_calc_widths[_colx]}" -lt "${_max_lens[_colx]}" ]]; then
            _calc_widths[_colx]="${_max_lens[_colx]}"
        fi
        _total_row_width=$((_total_row_width + _calc_widths[_colx]))
    done

    _total_row_width=$((_total_row_width + _borders_width))
    if [[ "$_total_row_width" -gt "$_table_width" ]]; then
        _table_width="$_total_row_width"
    fi
    _column_widths_str="${_calc_widths[*]}"

    lib_base__draw_divider "_divider_h2" "$G__DIVIDER_H2_CHAR" "$_table_width"
    lib_base__draw_divider "_divider_h3" "$G__DIVIDER_H3_CHAR" "$_table_width"

    if [[ -n "$_summary" ]]; then
        _lib_base__draw_table_summary "_summary_row" "$_summary" "$_table_width" \
            "$_border" "$G__TEXT_ALIGN_CENTER"
        _table_lines="${_divider_h2}"$'\n'"${_summary_row}"$'\n'"${_divider_h2}"
    else
        _table_lines="${_divider_h3}"
    fi

    for ((_rowx = 0; _rowx < _nrows; _rowx++)); do
        local _cell_slice="${_cells[*]:_rowx*_ncols:_ncols}"
        _lib_base__draw_table_row "_row" "$_cell_slice" "$_column_widths_str" \
            "$_table_width" "$_border" "$_align"
        _table_lines="${_table_lines}"$'\n'"${_row}"$'\n'"${_divider_h3}"
    done

    _ret_val_ref="$_table_lines"
    return "$G__ERR_OK"
}

#endregion Public Functions

#region Entry Point
# ==================================================================================================
# Entry Point
# ==================================================================================================

#endregion Entry Point
