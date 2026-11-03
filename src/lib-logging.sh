#!/usr/bin/env bash
#
# Source      : src/lib-logging.sh
# Dependencies: src/lib-base.sh
# Description : Logging utility.
#

# ----- Source Guard -----
[[ -n "${G__LIB_LOGGING_SH_LOADED:-}" ]] && return 0
export G__LIB_LOGGING_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====

readonly LOG_LEVEL_NAMES=("DEBUG" "INFO" "WARN" "ERROR" "FATAL")
readonly DEFAULT_LOG_LEVEL="$G__LOG_LEVEL_INFO"
readonly DEFAULT_STACK=0

# =============================================================================
# Global Variables
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====

# =============================================================================
# Private Functions
# =============================================================================
#######################################
# Write a formatted log message to STDOUT.
#
# Arguments:
#   level_str [in]: Log level string (e.g., "ERROR", "WARN ", "INFO ", "DEBUG").
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: $DEFAULT_STACK).
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#   G__ERR_MISSING_ARG: Log level or message was not provided.
#   G__ERR_INVALID_ARG: Invalid log level string or stack level number.
#######################################
function _lib_logging__write_log() {
    # Constants

    # Variables
    local _level_str
    local _message
    local _stack

    local _idx
    local _timestamp
    local _caller_path
    local _caller_name
    local _func_name
    local _line_no
    local _context

    # Parse and validate arguments
    [[ $# -lt 2 ]] && return "$G__ERR_MISSING_ARG"

    _message="$2"
    _stack="${3:-$DEFAULT_STACK}"

    for _idx in "${!LOG_LEVEL_NAMES[@]}"; do
        if [[ "$1" == "${LOG_LEVEL_NAMES[$_idx]}" ]]; then
            _level_str="$1"
        fi
    done

    if [[ -z "$_level_str" ]]; then
        return "$G__ERR_INVALID_ARG"
    fi

    lib_base__is_number "$_stack" || return "$G__ERR_INVALID_ARG"

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

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Log a debug message to STDOUT.
#
# Arguments:
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: $DEFAULT_STACK).
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#   G__ERR_MISSING_ARG: Log message was not provided.
#   G__ERR_INVALID_ARG: Invalid stack level number.
#######################################
function lib_logging__debug() {
    # Constants

    # Variables
    local _message
    local _stack

    local _ret_code="$G__ERR_OK"
    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _message="$1"
    _stack="${2:-$DEFAULT_STACK}"

    # Function body
    lib_base__is_number "$_level" || _level="$DEFAULT_LOG_LEVEL"

    if [[ "$_level" -le "$G__LOG_LEVEL_DEBUG" ]]; then
        _lib_logging__write_log "DEBUG" "$_message" "$_stack"
        _ret_code=$?
    fi

    return "$_ret_code"
}

#######################################
# Log an info message to STDOUT.
#
# Arguments:
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: $DEFAULT_STACK).
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#   G__ERR_MISSING_ARG: Log message was not provided.
#   G__ERR_INVALID_ARG: Invalid stack level number.
#######################################
function lib_logging__info() {
    # Constants

    # Variables
    local _message
    local _stack

    local _ret_code="$G__ERR_OK"
    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _message="$1"
    _stack="${2:-$DEFAULT_STACK}"

    # Function body
    lib_base__is_number "$_level" || _level="$DEFAULT_LOG_LEVEL"

    if [[ "$_level" -le "$G__LOG_LEVEL_INFO" ]]; then
        _lib_logging__write_log "INFO" "$_message" "$_stack"
        _ret_code=$?
    fi

    return "$_ret_code"
}

#######################################
# Log a warning message to STDOUT with yellow color.
#
# Arguments:
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: $DEFAULT_STACK).
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#   G__ERR_MISSING_ARG: Log message was not provided.
#   G__ERR_INVALID_ARG: Invalid stack level number.
#######################################
function lib_logging__warn() {
    # Constants

    # Variables
    local _message
    local _stack

    local _ret_code="$G__ERR_OK"
    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _message="$1"
    _stack="${2:-$DEFAULT_STACK}"

    # Function body
    lib_base__is_number "$_level" || _level="$DEFAULT_LOG_LEVEL"

    if [[ "$_level" -le "$G__LOG_LEVEL_WARN" ]]; then
        _message="${G__COLOR_YELLOW}${_message}${G__COLOR_RESET}"
        _lib_logging__write_log "WARN" "$_message" "$_stack"
        _ret_code=$?
    fi

    return "$_ret_code"
}

#######################################
# Log an error message to STDOUT with red color.
#
# Arguments:
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: $DEFAULT_STACK).
#
# Returns:
#   G__ERR_OK: Log message was printed successfully.
#   G__ERR_MISSING_ARG: Log  message was not provided.
#   G__ERR_INVALID_ARG: Invalid stack level number.
#######################################
function lib_logging__error() {
    # Constants

    # Variables
    local _message
    local _stack

    local _ret_code="$G__ERR_OK"
    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _message="$1"
    _stack="${2:-$DEFAULT_STACK}"

    # Function body
    lib_base__is_number "$_level" || _level="$DEFAULT_LOG_LEVEL"

    if [[ "$_level" -le "$G__LOG_LEVEL_ERROR" ]]; then
        _message="${G__COLOR_RED}${_message}${G__COLOR_RESET}"
        _lib_logging__write_log "ERROR" "$_message" "$_stack"
        _ret_code=$?
    fi

    return "$_ret_code"
}

#######################################
# Log a fatal message to STDOUT with red color.
#
# Arguments:
#   message [in]: Message text to print.
#   exit_code [in]: Exit code to terminate the process with.
#   stack [in]: (optional) Stack depth (default: $DEFAULT_STACK).
#
# Returns:
#   G__ERR_MISSING_ARG: Log message or exit code was not provided.
#   G__ERR_INVALID_ARG: Invalid exit code number.
#######################################
function lib_logging__fatal() {
    # Constants

    # Variables
    local _message
    local _exit_code
    local _stack

    local _ret_code="$G__ERR_OK"
    local _ret_code_str
    local _sub_message

    # Parse and validate arguments
    [[ $# -lt 2 ]] && return "$G__ERR_MISSING_ARG"

    _message="$1"
    _exit_code="$2"
    _stack="${3:-$DEFAULT_STACK}"

    lib_base__is_number "$_exit_code" || return "$G__ERR_INVALID_ARG"

    # Function body
    _message="${G__COLOR_RED}${_message}${G__COLOR_RESET}"
    _lib_logging__write_log "FATAL" "$_message" "$_stack"
    _ret_code=$?

    if [[ "$G__ERR_OK" -ne "$_ret_code" ]]; then
        _ret_code_str="$(lib_base__error_code_to_string "$_ret_code")"

        _sub_message="Unexpected error occurred while log was being written"
        _sub_message="${_sub_message}: ${_ret_code_str}"

        echo -e "${G__COLOR_RED}${_sub_message}${G__COLOR_RESET}"
        echo -e "${G__COLOR_RED}FATAL: ${_message}${G__COLOR_RESET}"

        _exit_code="$_ret_code"
    fi

    exit "$_exit_code"
}
