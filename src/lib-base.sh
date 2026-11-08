#!/usr/bin/env bash
#
# Source      : src/lib-base.sh
# Dependencies: None
# Description : Base constants, error codes, and exception utilities.
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__LIB_BASE_SH_LOADED:-}" ]] && return 0
declare -gr G__LIB_BASE_SH_LOADED=1

shopt -s extglob

# ===== Source Dependencies =====

# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# lib_base__traceback                   i01
# lib_base__throw                       i02
# -----------------------------------------

# ==================================================================================================
# Global Constants
# ==================================================================================================

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

# ===== File Scope =====

# ==================================================================================================
# Global Variables
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====

# ==================================================================================================
# Private Functions
# ==================================================================================================

# ==================================================================================================
# Public Functions
# ==================================================================================================
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
function lib_base__traceback() {
    # Constants
    local -r _LIB_BASE_i01__DEFAULT_STACK="1"

    # Parameters
    local _lib_base_i01__min_stack

    # Variables
    local _lib_base_i01__stack
    local _lib_base_i01__file_path
    local _lib_base_i01__file_name
    local _lib_base_i01__line_no
    local _lib_base_i01__line
    local _lib_base_i01__func_name

    # Parse and validate arguments
    _lib_base_i01__min_stack="${1:-$_LIB_BASE_i01__DEFAULT_STACK}"

    if [[ ! "$_lib_base_i01__min_stack" =~ ^[-+]?[0-9][0-9]*$ ]]; then
        _lib_base_i01__min_stack="$_LIB_BASE_i01__DEFAULT_STACK"
    fi

    # Function body
    printf '%s\n' "Traceback (most recent call last):" >&2

    _lib_base_i01__stack="${#BASH_SOURCE[@]}"
    _lib_base_i01__stack="$((_lib_base_i01__stack - 1))"

    while [[ "$_lib_base_i01__min_stack" -lt "$_lib_base_i01__stack" ]]; do
        _lib_base_i01__file_path="$(realpath "${BASH_SOURCE[$_lib_base_i01__stack]}")"
        _lib_base_i01__file_name="$(basename "$_lib_base_i01__file_path")"
        _lib_base_i01__line_no="${BASH_LINENO[$((_lib_base_i01__stack - 1))]}"
        _lib_base_i01__func_name="${FUNCNAME[$_lib_base_i01__stack]}"

        _lib_base_i01__line="$(sed -n "${_lib_base_i01__line_no}p" "$_lib_base_i01__file_path")"
        _lib_base_i01__line="${_lib_base_i01__line#"${_lib_base_i01__line%%[![:space:]]*}"}"
        _lib_base_i01__line="${_lib_base_i01__line%"${_lib_base_i01__line##*[![:space:]]}"}"

        printf '  File "%s", line %d, ' "$_lib_base_i01__file_name" "$_lib_base_i01__line_no" >&2
        printf 'in %s\n' "$_lib_base_i01__func_name" >&2
        printf '    %s\n' "$_lib_base_i01__line" >&2

        _lib_base_i01__stack=$((_lib_base_i01__stack - 1))
    done

    return "$G__ERR_OK"
}

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
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: Error code is not a number.
#   <error_code>: Exception is thrown with the specified error code.
#######################################
function lib_base__throw() {
    # Constants
    local -rA _EXCEPTION_i02__ERR_NAMES=(
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

    local -r _EXCEPTION_i02__DEFAULT_MESSAGE="An exception occurred!!"
    local -r _EXCEPTION_i02__TRACEBACK_STACK="2"

    # Parameters
    local _lib_base_i02__error_code
    local _lib_base_i02__message

    # Variables

    # Parse and validate arguments
    if [[ "$#" -lt "2" ]]; then
        lib_base__traceback
        lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 2 arguments"
    elif [[ "$#" -gt "2" ]]; then
        lib_base__traceback
        lib_base__throw "$G__ERR_TOO_MANY_ARGS" "${FUNCNAME[0]} required 2 arguments"
    fi

    _lib_base_i02__error_code="$1"
    _lib_base_i02__message="${2:-$_EXCEPTION_i02__DEFAULT_MESSAGE}"

    if [[ ! "$_lib_base_i02__error_code" =~ ^[-+]?[0-9][0-9]*$ ]]; then
        local _lib_base_i02__message="Error code must be a number: '$_lib_base_i02__error_code'"
        lib_base__throw "$G__ERR_TYPE_ERROR" "$_lib_base_i02__message"
    fi

    # Function body
    lib_base__traceback "$_EXCEPTION_i02__TRACEBACK_STACK"

    printf '%s ' "${_EXCEPTION_i02__ERR_NAMES[$_lib_base_i02__error_code]:-Unknown}" >&2
    printf '(%d): ' "$_lib_base_i02__error_code" >&2
    printf '%s\n' "${G__COLOR_RED}${_lib_base_i02__message}${G__COLOR_RESET}" >&2

    exit "$_lib_base_i02__error_code"
}
