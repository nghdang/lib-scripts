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

# ----- Error Codes -----
# Positive error codes
declare -rx G__ERR_OK=0
declare -rx G__ERR_NOT_OK=255

# Arguments error codes
declare -rx G__ERR_MISSING_ARG=10
declare -rx G__ERR_TYPE_ERROR=11

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
    [$G__ERR_TYPE_ERROR]="G__ERR_TYPE_ERROR"

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

# ----- Layout & Table Formatting -----
# Terminal heading dividers and line width
declare -rx G__DIVIDER_WIDTH=80
declare -rx G__DIVIDER_H0_CHAR="@"
declare -rx G__DIVIDER_H1_CHAR="#"
declare -rx G__DIVIDER_H2_CHAR="="
declare -rx G__DIVIDER_H3_CHAR="-"
declare -rx G__DIVIDER_H4_CHAR="."

# Table formatting manifest
declare -rx G__TABLE_ROW_PREFIX="| "
declare -rx G__TABLE_ROW_PREFIX_LEN=${#G__TABLE_ROW_PREFIX}
declare -rx G__TABLE_ROW_SUFFIX=" |"
declare -rx G__TABLE_ROW_SUFFIX_LEN=${#G__TABLE_ROW_SUFFIX}
declare -rx G__TABLE_HEADER_SEPARATOR=" | "
declare -rx G__TABLE_HEADER_SEPARATOR_LEN=${#G__TABLE_HEADER_SEPARATOR}
declare -rx G__TABLE_COL_SEPARATOR=" : "
declare -rx G__TABLE_COL_SEPARATOR_LEN=${#G__TABLE_COL_SEPARATOR}

G__TABLE_WIDTH=$((G__DIVIDER_WIDTH - G__TABLE_ROW_PREFIX_LEN))
G__TABLE_WIDTH=$((G__TABLE_WIDTH - G__TABLE_ROW_SUFFIX_LEN))
declare -rx G__TABLE_WIDTH

#endregion Global Constants - Project Scope

#region Global Constants - File Scope
# ===== File Scope =====
# ----- Logging -----
readonly LOG_LEVEL_NAMES=("DEBUG" "INFO" "WARN" "ERROR" "FATAL")
readonly DEFAULT_LOG_LEVEL="$G__LOG_LEVEL_INFO"
readonly DEFAULT_STACK=1

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
#   level_str [in]: Log level string (e.g., "DEBUG", "INFO", "WARN", "ERROR", "FATAL").
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
    lib_base__assert_min_args "$#" "2"

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

#endregion Private Functions

#region Public Functions
# =============================================================================
# Public Functions
# =============================================================================

# ----- Validations & Assertions -----

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
    declare -p -- "$_param" >/dev/null 2>&1 || return "$G__ERR_NOT_OK"
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
    _param="$1"

    # Function body
    lib_base__is_var "$_param" && return "$G__ERR_OK"

    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "Not a variable: '$_param'"
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
    _param="$1"

    # Function body
    lib_base__is_array "$_param" && return "$G__ERR_OK"
    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "Not an array: '$_param'"
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

    # Parse and validate arguments
    _param="$1"
    _label="${2:-}"

    # Function body
    lib_base__is_number "$_param" && return "$G__ERR_OK"

    if [[ -z "$_label" ]]; then
        lib_base__throw_exception "$G__ERR_TYPE_ERROR" \
            "$_label must be a number: '$_param'"
    else
        lib_base__throw_exception "$G__ERR_TYPE_ERROR" \
            "Not a number: '$_param'"
    fi
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

    # Parse and validate arguments
    _param="$1"
    _label="${2:-}"

    # Function body
    [[ -z "$_param" ]] && return "$G__ERR_OK"

    if [[ -z "$_label" ]]; then
        lib_base__throw_exception "$G__ERR_TYPE_ERROR" "Value is empty"
    else
        lib_base__throw_exception "$G__ERR_TYPE_ERROR" \
            "$_label must be non-empty"
    fi
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
    IFS=' ' read -r -a _array <<<"$_array_str"

    if [[ "${#_array[@]}" -eq 0 ]]; then
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
    _array_str="$1"
    _item="$2"

    # Function body
    lib_base__is_in "$_array_str" "$_item" && return "$G__ERR_OK"
    lib_base__throw_exception "$G__ERR_TYPE_ERROR" "Item '$_item' is not in '$_array_str'"
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
    lib_base__assert_number "$_min_stack" "Min stack"

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

        printf '  File "%s", line %d, in %s\n' "$_file_name" "$_line_no" "$_func_name" >&2
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
#   message    [in]: (optional) Exception message. Defaults to 'An exception occurred!!'.
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
        lib_base__traceback 1

        _message="lib_base__throw_exception required 2 arguments"
        printf '%s (%d): %s\n' "${G__ERR_NAMES[$G__ERR_MISSING_ARG]}" \
            "$G__ERR_MISSING_ARG" \
            "${G__COLOR_RED}${_message}${G__COLOR_RESET}" >&2

        exit "$G__ERR_MISSING_ARG"
    fi

    _error_code="$1"
    _message="${2:-$_DEFAULT_MESSAGE}"

    lib_base__assert_number "$_error_code" "Error code"

    # Function body
    lib_base__traceback "$_TRACEBACK_STACK"
    printf '%s (%d): %s\n' "${G__ERR_NAMES[$_error_code]}" "$_error_code" \
        "${G__COLOR_RED}${_message}${G__COLOR_RESET}" >&2

    exit "$_error_code"
}

#region lib_base__assert_min_args
#######################################
# Validate the minimum argument count.
#
# Arguments:
#   args_count [in]: Number of arguments provided.
#   min_args   [in]: Minimum number of required arguments.
#
# Returns:
#   G__ERR_OK: Minimum argument count is met.
#
# Exits:
#   G__ERR_MISSING_ARG: Argument count is less than the required minimum.
#   G__ERR_TYPE_ERROR: Arguments count or minimum arguments is not a number.
#######################################
#endregion lib_base__assert_min_args
function lib_base__assert_min_args() {
    # Constants

    # Variables
    local _args_count
    local _min_args

    # Parse and validate arguments
    if [[ "$#" -lt "2" ]]; then
        lib_base__throw_exception "$G__ERR_MISSING_ARG" \
            "lib_base__assert_min_args required 2 arguments"
    fi

    _args_count="$1"
    _min_args="$2"

    lib_base__assert_number "$_args_count" "Args count"
    lib_base__assert_number "$_min_args" "Min args"

    # Function body
    if [[ "$_args_count" -lt "$_min_args" ]]; then
        lib_base__throw_exception "$G__ERR_MISSING_ARG" \
            "${FUNCNAME[1]} required $_min_args argument(s)"
    fi

    return "$G__ERR_OK"
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
    lib_base__assert_min_args "$#" "1"

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
    lib_base__assert_min_args "$#" "1"

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
    lib_base__assert_min_args "$#" "1"

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
    lib_base__assert_min_args "$#" "1"

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

# ----- Layout & Table Formatting -----

#region lib_base__gen_divider
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
# Returns:
#   G__ERR_OK: Divider was generated successfully.
#   G__ERR_TYPE_ERROR: Divider character is empty or width is not a number.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#######################################
#endregion lib_base__gen_divider
function lib_base__gen_divider() {
    # Constants

    # Variables
    local _char
    local _width

    local _placeholder

    # Parse and validate arguments
    lib_base__assert_min_args "$#" "2"

    _char="$1"
    _width="$2"

    lib_base__assert_non_empty "$_char" "Divider character"
    lib_base__assert_number "$_width" "Divider width"

    # Function body
    printf -v _placeholder '%*s' "$_width" ''
    echo "${_placeholder// /$_char}"

    return "$G__ERR_OK"
}

#endregion Public Functions
