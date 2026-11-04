#!/usr/bin/env bash
#region File Header
#
# Source      : src/lib-base.sh
# Dependencies: None
# Description : Global constants and very basic utilities that can be used in
#               any projects.
#
#endregion File Header

# ----- Source Guard -----
[[ -n "${G__LIB_BASE_SH_LOADED:-}" ]] && return 0
declare -rx G__LIB_BASE_SH_LOADED=1

#region Global Constants
# =============================================================================
# Global Constants
# =============================================================================

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
readonly DEFAULT_TABLE_LEFT_BORDER="| "
readonly DEFAULT_TABLE_RIGHT_BORDER=" |"
readonly DEFAULT_TABLE_HEADER_BORDER=" | "
readonly DEFAULT_TABLE_COLUMN_BORDER=" : "
readonly DEFAULT_TABLE_ALIGN="$G__TEXT_ALIGN_LEFT"

#endregion Global Constants - File Scope
#endregion Global Constants

#region Global Variables
# =============================================================================
# Global Variables
# =============================================================================

#region Global Variables - Project Scope
# ===== Project Scope =====

#endregion Global Variables - Project Scope

#region Global Variables - File Scope
# ===== File Scope =====

#endregion Global Variables - File Scope
#endregion Global Variables

#region Private Functions
# =============================================================================
# Private Functions
# =============================================================================
#region _lib_base__write_log
#######################################
# Write a formatted log message to STDOUT.
#
# Arguments:
#   level_str [in]: Log level string (e.g., "DEBUG", "INFO", "WARN", ...).
#   message   [in]: Message text to print.
#   stack     [in]: (optional) Stack depth. Defaults to 0.
#
# Outputs:
#   Formatted log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
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
    printf '%s %b\n' "$_context" "$_message"

    return "$G__ERR_OK"
}

function _lib_base__draw_refine_column_widths() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _ncols
    local _table_width
    local _widths_str
    local _left_border
    local _right_border
    local _separator

    local -a _widths=()

    local _idx

    local _borders_len
    local _separators_len
    local _available_widths

    local _fixed_cols_width=0

    local _filled_ncols=0
    local _filled_cols_width
    local _filled_width
    local _last_filled_width
    local _filled_count=0

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2" "7"
    lib_base__assert_var "$1"

    _ret_val_ref="$1"
    _ncols="$2"
    _table_width="${3:-$DEFAULT_TABLE_WIDTH}"
    _widths_str="${4:-}"
    _left_border="${5:-$DEFAULT_TABLE_LEFT_BORDER}"
    _right_border="${6:-$DEFAULT_TABLE_RIGHT_BORDER}"
    _separator="${7:-$DEFAULT_TABLE_HEADER_BORDER}"

    lib_base__assert_number "$_ncols" "Number of columns"
    lib_base__assert_number "$_table_width" "Table width"

    if [[ -n "$_widths_str" ]]; then
        IFS=' ' read -r -a "_widths" <<<"$_widths_str"
    fi

    # Function body
    # 1. Normalize number of columns
    if [[ "$_ncols" -lt "${#_widths[@]}" ]]; then
        _widths=("${_widths[@]:0:$_ncols}")
    elif [[ "$_ncols" -gt "${#_widths[@]}" ]]; then
        _widths=("${_widths[@]}")
        for _idx in $(seq "${#_widths[@]}" "$((_ncols - 1))"); do
            _widths+=("-1")
        done
    fi

    # 2. Calculate filled column widths
    for _idx in "${!_widths[@]}"; do
        local _width="${_widths[$_idx]}"

        if [[ "$_width" -eq "-1" ]]; then
            _filled_ncols=$((_filled_ncols + 1))
        else
            _fixed_cols_width=$((_fixed_cols_width + _width))
        fi
    done

    _borders_len=$((${#_left_border} + ${#_right_border}))
    _separators_len=$(((_ncols - 1) * ${#_separator}))
    _available_widths=$((_table_width - _borders_len - _separators_len))

    _filled_cols_width=$((_available_widths - _fixed_cols_width))
    _filled_width=$((_filled_cols_width / _filled_ncols))
    _last_filled_width=$(((_filled_ncols - 1) * _filled_width))
    _last_filled_width=$((_filled_cols_width - _last_filled_width))

    # 3. Replace filled column width placeholders with the actual values
    for _idx in "${!_widths[@]}"; do
        local _width="${_widths[$_idx]}"

        if [[ "$_width" -eq "-1" ]]; then
            _filled_count=$((_filled_count + 1))

            if [[ "$_filled_count" -eq "$_filled_ncols" ]]; then
                _widths[_idx]="$_last_filled_width"
            else
                _widths[_idx]="$_filled_width"
            fi
        fi
    done

    _ret_val_ref="${_widths[*]}"
}

#endregion Private Functions

#region Public Functions
# =============================================================================
# Public Functions
# =============================================================================

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
    [[ -z "$_param" ]] && s return "$G__ERR_NOT_OK"
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
    [[ "$_param" =~ ^0*[0-9][0-9]*$ ]] && return "$G__ERR_OK"
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
# Print the call stack traceback.
#
# Arguments:
#   min_stack [in]: (optional) Minimum stack level to trace. Defaults to 1.
#
# Exits:
#   G__ERR_TYPE_ERROR: Minimum stack level is not a number.
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
    printf '%s\n' "Traceback (most recent call last):"
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
}

#region lib_base__throw_exception
#######################################
# Throw an exception and exit the current shell.
#
# Arguments:
#   error_code [in]: Exit code of the current shell.
#   message    [in]: (optional) Exception message.
#                    Defaults to 'An exception occurred!!'.
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
        lib_base__throw_exception "$G__ERR_MISSING_ARG" \
            "${FUNCNAME[0]} required 2 arguments"
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
#   max_args   [in]: (optional) Maximum number of allowed arguments.
#                    Default is 100.
#
# Returns:
#   G__ERR_OK: Argument count is in range.
#
# Exits:
#   G__ERR_MISSING_ARG: Argument count is less than the required minimum.
#   G__ERR_TOO_MANY_ARGS: Argument count is greater than the allowed maximum.
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
        lib_base__throw_exception "$G__ERR_MISSING_ARG" \
            "${FUNCNAME[0]} required 2 arguments"
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
    lib_base__throw_exception "$G__ERR_TYPE_ERROR" \
        "Item '$_item' is not in '$_array_str'"
}

# ----- Logging -----
#region lib_base__debug
#######################################
# Log a debug message to STDOUT.
#
# Arguments:
#   message [in]: Message text to print.
#   stack   [in]: (optional) Stack depth. Defaults to 0.
#
# Outputs:
#   Formatted debug log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Log message was not provided.
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
#   stack   [in]: (optional) Stack depth. Defaults to 0.
#
# Outputs:
#   Formatted info log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Log message was not provided.
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
#   stack   [in]: (optional) Stack depth. Defaults to 0.
#
# Outputs:
#   Formatted warning log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Log message was not provided.
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
#   stack   [in]: (optional) Stack depth. Defaults to 0.
#
# Outputs:
#   Formatted error log message.
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Log message was not provided.
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
function lib_base__align() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _text
    local _width
    local _align

    local _aligned_text

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2" "4"
    lib_base__assert_var "$1"

    _ret_val_ref="$1"
    _text="$2"
    _width="${3:-$DEFAULT_TABLE_WIDTH}"
    _align="${4:-$DEFAULT_TABLE_ALIGN}"

    lib_base__assert_number "$_width"
    lib_base__assert_in "${G__TEXT_ALIGNS[*]}" "$_align"

    # Function body
    if [[ "$G__TEXT_ALIGN_LEFT" == "$_align" ]]; then
        printf -v "_aligned_text" '%-*s' "$_width" "$_text"
    elif [[ "$G__TEXT_ALIGN_RIGHT" == "$_align" ]]; then
        printf -v "_aligned_text" '%*s' "$_width" "$_text"
    else
        local _padding_width
        local _padding

        _padding_width=$(((_width - ${#_text}) / 2))
        if [[ "$_padding_width" -gt 0 ]]; then
            printf -v "_padding" '%*s' "$_padding_width" ''
        fi
        printf -v "_aligned_text" '%-*s' "$_width" "${_padding}${_text}"
    fi

    _ret_val_ref="$_aligned_text"
}

# ----- Layout & Table Formatting -----

#region lib_base__draw_divider
#######################################
# Generate a divider.
#
# Arguments:
#   char  [in]: Divider character to paint.
#   width [in]: Divider width to paint.
#
# Outputs:
#   Generated divider string.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: Divider character is empty or width is not a number.
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
    lib_base__assert_var "$1"

    _ret_val_ref="$1"
    _char="$2"
    _width="${3:-$DEFAULT_TABLE_WIDTH}"

    lib_base__assert_not_empty "$_char" "Divider character"
    lib_base__assert_number "$_width" "Divider width"

    # Function body
    printf -v "_divider" '%*s' "$_width" ''
    _divider="${_divider// /$_char}"

    _ret_val_ref="$_divider"
}

#region lib_base__draw_table_summary
#######################################
# Draw a bordered single-row table with summary text.
#
# Arguments:
#   --summary      [in]: Summary text to display in the table.
#   --width        [in]: (optional) Table width. Defaults to 80.
#   --left-border  [in]: (optional) Table left border. Defaults to '| '.
#   --right-border [in]: (optional) Table right border. Defaults to ' |'.
#   --align        [in]: (optional) Text alignment ('left', 'center', 'right').
#                        Defaults to 'left'.
#
# Outputs:
#   Formatted table logged to STDOUT.
#
# Exits:
#   G__ERR_MISSING_ARG: Summary is missing.
#   G__ERR_TYPE_ERROR: Table width is not a number or alignment is invalid.
#######################################
#endregion lib_base__draw_table_summary
function lib_base__draw_table_summary() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _summary
    local _table_width
    local _left_border
    local _right_border
    local _align

    local _line_width
    local _summary_line=""

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "2" "6"
    lib_base__assert_var "$1"

    _ret_val_ref="$1"
    _summary="$2"
    _table_width="${3:-$DEFAULT_TABLE_WIDTH}"
    _left_border="${4:-$DEFAULT_TABLE_LEFT_BORDER}"
    _right_border="${5:-$DEFAULT_TABLE_RIGHT_BORDER}"
    _align="${6:-$DEFAULT_TABLE_ALIGN}"

    lib_base__assert_number "$_table_width" "Table width"
    lib_base__assert_in "${G__TEXT_ALIGNS[*]}" "$_align"

    # Function body
    _line_width=$((_table_width - ${#_left_border} - ${#_right_border}))
    lib_base__align "_summary_line" "$_summary" "$_line_width" "$_align"

    _ret_val_ref="${_left_border}${_summary_line}${_right_border}"
}

function lib_base__draw_table_headers() {
    # Constants

    # Variables
    local -n _ret_val_ref
    local _headers_str
    local _table_width
    local _column_widths_str
    local _left_border
    local _right_border
    local _separator
    local _align

    local -a _headers
    local _ncols
    local -a _column_widths=()

    local -a _padding_lens=()
    local _idx
    local _headers_line=""

    # Parse and validate arguments
    lib_base__assert_args_count "$#" "1" "8"
    lib_base__assert_var "$1"

    _ret_val_ref="$1"
    _headers_str="$2"
    _table_width="${3:-$DEFAULT_TABLE_WIDTH}"
    _column_widths_str="${4:-}"
    _left_border="${5:-$DEFAULT_TABLE_LEFT_BORDER}"
    _right_border="${6:-$DEFAULT_TABLE_RIGHT_BORDER}"
    _separator="${7:-$DEFAULT_TABLE_HEADER_BORDER}"
    _align="${8:-$DEFAULT_TABLE_ALIGN}"

    lib_base__assert_not_empty "$_headers_str" "Table headers"
    lib_base__assert_number "$_table_width" "Table width"
    lib_base__assert_in "${G__TEXT_ALIGNS[*]}" "$_align"

    IFS=' ' read -r -a "_headers" <<<"$_headers_str"

    # Function body
    local _ncols=${#_headers[@]}

    _lib_base__draw_refine_column_widths "_column_widths_str" "$_ncols" \
        "$_table_width" "$_column_widths_str" "$_left_border" \
        "$_right_border" "$_separator"
    IFS=' ' read -r -a "_column_widths" <<<"$_column_widths_str"

    for _idx in "${!_headers[@]}"; do
        local _column_value

        if [[ "$_idx" -gt "0" ]]; then
            _headers_line="${_headers_line}${_separator}"
        fi

        lib_base__align "_column_value" "${_headers[$_idx]}" \
            "${_column_widths[$_idx]}" "$_align"

        _headers_line="${_headers_line}${_column_value}"
    done

    _ret_val_ref="${_left_border}${_headers_line}${_right_border}"
}

#endregion Public Functions

#region Entry Point
# =============================================================================
# Entry Point
# =============================================================================
function main() {
    set -u

    local _ret_val=""
    local _divider_h2=""
    local _divider_h3=""

    lib_base__draw_divider _divider_h2 "$G__DIVIDER_H2_CHAR"
    lib_base__draw_divider _divider_h3 "$G__DIVIDER_H3_CHAR"

    echo "$_divider_h2"
    lib_base__draw_table_summary _ret_val "Table Summary"
    echo "$_ret_val"
    echo "$_divider_h2"

    lib_base__draw_table_headers _ret_val "Header1 Header2 Header3" "" "$@"
    echo "$_ret_val"
    echo "$_divider_h3"

    ec=$?
    echo "Exit code   : ${G__ERR_NAMES[$ec]} ($ec)"
    echo "Return value: '$_ret_val'"
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
#endregion Entry Point
