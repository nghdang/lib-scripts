#!/usr/bin/env bash
#
# Source      : src/lib-logging.sh
# Dependencies: src/lib-base.sh
#               src/lib-assertion.sh
# Description : Standardized logging utilities for formatted console output.
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__LIB_LOGGING_SH_LOADED:-}" ]] && return 0
declare -gr G__LIB_LOGGING_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-base.sh"
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-assertion.sh"

# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# _lib_logging__write_log               p01
# lib_logging__debug                    i01
# lib_logging__info                     i02
# lib_logging__warn                     i03
# lib_logging__error                    i04
# -----------------------------------------

# ==================================================================================================
# Global Constants
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====
# ----- Logging -----
readonly DEFAULT_LOG_LEVEL="$G__LOG_LEVEL_INFO"
readonly DEFAULT_STACK=1

# ==================================================================================================
# Global Variables
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====

# ==================================================================================================
# Private Functions
# ==================================================================================================
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
function _lib_logging__write_log() {
    # Constants
    local -r _LIB_LOGGING_p01__LOG_LEVEL_NAMES=("DEBUG" "INFO" "WARN" "ERROR" "FATAL")

    # Parameters
    local _lib_logging_p01__level_name
    local _lib_logging_p01__message
    local _lib_logging_p01__stack

    # Variables
    local _lib_logging_p01__timestamp
    local _lib_logging_p01__caller_path
    local _lib_logging_p01__caller_name
    local _lib_logging_p01__func_name
    local _lib_logging_p01__line_no
    local _lib_logging_p01__context
    local -a _lib_logging_p01__lines=()
    local _lib_logging_p01__line

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "3"

    _lib_logging_p01__level_name="$1"
    _lib_logging_p01__message="$2"
    _lib_logging_p01__stack="${3:-$DEFAULT_STACK}"

    lib_assertion__assert_in "_LIB_LOGGING_p01__LOG_LEVEL_NAMES" "$_lib_logging_p01__level_name"
    lib_assertion__assert_number "$_lib_logging_p01__stack" "Log stack level"

    # Function body
    _lib_logging_p01__timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

    _lib_logging_p01__caller_path="${BASH_SOURCE[$((_lib_logging_p01__stack + 1))]:-unknown}"
    _lib_logging_p01__caller_name="${_lib_logging_p01__caller_path##*/}"

    _lib_logging_p01__func_name="${FUNCNAME[$((_lib_logging_p01__stack + 1))]:-unknown}"

    _lib_logging_p01__line_no="${BASH_LINENO[$_lib_logging_p01__stack]:-0}"

    _lib_logging_p01__context="$_lib_logging_p01__timestamp"
    _lib_logging_p01__context+=" $(printf '%5s' "$_lib_logging_p01__level_name")"
    _lib_logging_p01__context+=" $_lib_logging_p01__caller_name"
    _lib_logging_p01__context+=" ${_lib_logging_p01__func_name}:${_lib_logging_p01__line_no}"

    mapfile -t _lib_logging_p01__lines <<<"$_lib_logging_p01__message"

    for _lib_logging_p01__line in "${_lib_logging_p01__lines[@]}"; do
        printf '%s %b\n' "$_lib_logging_p01__context" "$_lib_logging_p01__line"
    done

    return "$G__ERR_OK"
}

# ==================================================================================================
# Public Functions
# ==================================================================================================
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
function lib_logging__debug() {
    # Constants

    # Parameters
    local _lib_logging_i01__message
    local _lib_logging_i01__stack

    # Variables
    local _lib_logging_i01__error_code="$G__ERR_OK"
    local _lib_logging_i01__level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "2"

    _lib_logging_i01__message="$1"
    _lib_logging_i01__stack="${2:-$DEFAULT_STACK}"

    lib_assertion__assert_number "$_lib_logging_i01__stack" "Log stack level"

    # Function body
    lib_validation__is_number "$_lib_logging_i01__level" ||
        _lib_logging_i01__level="$DEFAULT_LOG_LEVEL"

    if [[ "$_lib_logging_i01__level" -le "$G__LOG_LEVEL_DEBUG" ]]; then
        _lib_logging__write_log "DEBUG" "$_lib_logging_i01__message" "$_lib_logging_i01__stack"
        _lib_logging_i01__error_code=$?
    fi

    return "$_lib_logging_i01__error_code"
}

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
function lib_logging__info() {
    # Constants

    # Parameters
    local _lib_logging_i02__message
    local _lib_logging_i02__stack

    # Variables
    local _lib_logging_i02__error_code="$G__ERR_OK"
    local _lib_logging_i02__level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "2"

    _lib_logging_i02__message="$1"
    _lib_logging_i02__stack="${2:-$DEFAULT_STACK}"

    lib_assertion__assert_number "$_lib_logging_i02__stack" "Log stack level"

    # Function body
    lib_validation__is_number "$_lib_logging_i02__level" ||
        _lib_logging_i02__level="$DEFAULT_LOG_LEVEL"

    if [[ "$_lib_logging_i02__level" -le "$G__LOG_LEVEL_INFO" ]]; then
        _lib_logging__write_log "INFO" "$_lib_logging_i02__message" "$_lib_logging_i02__stack"
        _lib_logging_i02__error_code=$?
    fi

    return "$_lib_logging_i02__error_code"
}

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
function lib_logging__warn() {
    # Constants

    # Parameters
    local _lib_logging_i03__message
    local _lib_logging_i03__stack

    # Variables
    local _lib_logging_i03__error_code="$G__ERR_OK"
    local _lib_logging_i03__level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "2"

    _lib_logging_i03__message="$1"
    _lib_logging_i03__stack="${2:-$DEFAULT_STACK}"

    lib_assertion__assert_number "$_lib_logging_i03__stack" "Log stack level"

    # Function body
    lib_validation__is_number "$_lib_logging_i03__level" ||
        _lib_logging_i03__level="$DEFAULT_LOG_LEVEL"

    if [[ "$_lib_logging_i03__level" -le "$G__LOG_LEVEL_WARN" ]]; then
        _lib_logging_i03__message="${G__COLOR_YELLOW}${_lib_logging_i03__message}${G__COLOR_RESET}"
        _lib_logging__write_log "WARN" "$_lib_logging_i03__message" "$_lib_logging_i03__stack"
        _lib_logging_i03__error_code=$?
    fi

    return "$_lib_logging_i03__error_code"
}

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
function lib_logging__error() {
    # Constants

    # Parameters
    local _lib_logging_i04__message
    local _lib_logging_i04__stack

    # Variables
    local _lib_logging_i04__error_code="$G__ERR_OK"
    local _lib_logging_i04__level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "2"

    _lib_logging_i04__message="$1"
    _lib_logging_i04__stack="${2:-$DEFAULT_STACK}"

    lib_assertion__assert_number "$_lib_logging_i04__stack" "Log stack level"

    # Function body
    lib_validation__is_number "$_lib_logging_i04__level" ||
        _lib_logging_i04__level="$DEFAULT_LOG_LEVEL"

    if [[ "$_lib_logging_i04__level" -le "$G__LOG_LEVEL_ERROR" ]]; then
        _lib_logging_i04__message="${G__COLOR_RED}${_lib_logging_i04__message}${G__COLOR_RESET}"
        _lib_logging__write_log "ERROR" "$_lib_logging_i04__message" "$_lib_logging_i04__stack"
        _lib_logging_i04__error_code=$?
    fi

    return "$_lib_logging_i04__error_code"
}
