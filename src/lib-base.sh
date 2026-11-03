#!/usr/bin/env bash
#
# Source      : src/lib-base.sh
# Dependencies: None
# Description : Global constants and very basic utilities that can be used in
#               any projects.
#

# ----- Source Guard -----
[[ -n "${G__LIB_BASE_SH_LOADED:-}" ]] && return 0
export G__LIB_BASE_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================

# ===== Project Scope =====

# ----- Terminal & UI Styling -----
# ANSI escape sequences for terminal output colors
export G__COLOR_RED=$'\033[0;31m'
readonly G__COLOR_RED

export G__COLOR_GREEN=$'\033[0;32m'
readonly G__COLOR_GREEN

export G__COLOR_YELLOW=$'\033[0;33m'
readonly G__COLOR_YELLOW

export G__COLOR_BLUE=$'\033[0;34m'
readonly G__COLOR_BLUE

export G__COLOR_MAGENTA=$'\033[0;35m'
readonly G__COLOR_MAGENTA

export G__COLOR_CYAN=$'\033[0;36m'
readonly G__COLOR_CYAN

export G__COLOR_GRAY=$'\033[0;37m'
readonly G__COLOR_GRAY

export G__COLOR_RESET=$'\033[0m'
readonly G__COLOR_RESET

# ----- Layout & Table Formatting -----
# Terminal heading dividers and line width
export G__DIVIDER_WIDTH=80
readonly G__DIVIDER_WIDTH

export G__DIVIDER_H0_CHAR="@"
readonly G__DIVIDER_H0_CHAR

export G__DIVIDER_H1_CHAR="#"
readonly G__DIVIDER_H1_CHAR

export G__DIVIDER_H2_CHAR="="
readonly G__DIVIDER_H2_CHAR

export G__DIVIDER_H3_CHAR="-"
readonly G__DIVIDER_H3_CHAR

export G__DIVIDER_H4_CHAR="."
readonly G__DIVIDER_H4_CHAR

# Table formatting manifest
export G__TABLE_ROW_PREFIX="| "
readonly G__TABLE_ROW_PREFIX

export G__TABLE_ROW_PREFIX_LEN=${#G__TABLE_ROW_PREFIX}
readonly G__TABLE_ROW_PREFIX_LEN

export G__TABLE_ROW_SUFFIX=" |"
readonly G__TABLE_ROW_SUFFIX

export G__TABLE_ROW_SUFFIX_LEN=${#G__TABLE_ROW_SUFFIX}
readonly G__TABLE_ROW_SUFFIX_LEN

export G__TABLE_HEADER_SEPARATOR=" | "
readonly G__TABLE_HEADER_SEPARATOR

export G__TABLE_HEADER_SEPARATOR_LEN=${#G__TABLE_HEADER_SEPARATOR}
readonly G__TABLE_HEADER_SEPARATOR_LEN

export G__TABLE_COL_SEPARATOR=" : "
readonly G__TABLE_COL_SEPARATOR

export G__TABLE_COL_SEPARATOR_LEN=${#G__TABLE_COL_SEPARATOR}
readonly G__TABLE_COL_SEPARATOR_LEN

G__TABLE_WIDTH=$((G__DIVIDER_WIDTH - G__TABLE_ROW_PREFIX_LEN))
G__TABLE_WIDTH=$((G__TABLE_WIDTH - G__TABLE_ROW_SUFFIX_LEN))
export G__TABLE_WIDTH
readonly G__TABLE_WIDTH

# ----- Error Codes -----
# Positive error codes
export G__ERR_OK=0
readonly G__ERR_OK

export G__ERR_NOT_OK=255
readonly G__ERR_NOT_OK

# Arguments error codes
export G__ERR_MISSING_ARG=10
readonly G__ERR_MISSING_ARG

export G__ERR_INVALID_ARG=11
readonly G__ERR_INVALID_ARG

# File system error codes
export G__ERR_NOT_FOUND=20
readonly G__ERR_NOT_FOUND

export G__ERR_ALREADY_EXISTS=21
readonly G__ERR_ALREADY_EXISTS

export G__ERR_NOT_FILE=22
readonly G__ERR_NOT_FILE

export G__ERR_NOT_DIR=23
readonly G__ERR_NOT_DIR

export G__ERR_READ_FAILED=24
readonly G__ERR_READ_FAILED

export G__ERR_WRITE_FAILED=25
readonly G__ERR_WRITE_FAILED

# ----- Logging level -----
export G__LOG_LEVEL_DEBUG=0
readonly G__LOG_LEVEL_DEBUG

export G__LOG_LEVEL_INFO=1
readonly G__LOG_LEVEL_INFO

export G__LOG_LEVEL_WARN=2
readonly G__LOG_LEVEL_WARN

export G__LOG_LEVEL_ERROR=3
readonly G__LOG_LEVEL_ERROR

export G__LOG_LEVEL_FATAL=4
readonly G__LOG_LEVEL_FATAL

# ===== File Scope =====

# ----- Error Codes -----
declare -A ERR_STRINGS=(
    # Positive error codes
    [$G__ERR_OK]="G__ERR_OK"
    [$G__ERR_NOT_OK]="G__ERR_NOT_OK"

    # Arguments error codes
    [$G__ERR_MISSING_ARG]="G__ERR_MISSING_ARG"
    [$G__ERR_INVALID_ARG]="G__ERR_INVALID_ARG"

    # File system error codes
    [$G__ERR_NOT_FOUND]="G__ERR_NOT_FOUND"
    [$G__ERR_ALREADY_EXISTS]="G__ERR_ALREADY_EXISTS"
    [$G__ERR_NOT_FILE]="G__ERR_NOT_FILE"
    [$G__ERR_NOT_DIR]="G__ERR_NOT_DIR"
    [$G__ERR_READ_FAILED]="G__ERR_READ_FAILED"
    [$G__ERR_WRITE_FAILED]="G__ERR_WRITE_FAILED"
)
readonly ERR_STRINGS

# =============================================================================
# Global Variables
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====

# =============================================================================
# Private Functions
# =============================================================================

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Check whether the given parameter is a number or not.
#
# Arguments:
#   param [in]: Value to check.
#
# Returns:
#   G__ERR_OK: The given parameter is a number.
#   G__ERR_NOT_OK: The given parameter is not a number.
#   G__ERR_MISSING_ARG: No param was provided.
#######################################
function lib_base__is_number() {
    # Constants

    # Variables
    local _param

    local _ret_code=$G__ERR_OK

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _param="$1"

    # Function body
    if [[ ! "$_param" =~ ^0*[0-9][0-9]*$ ]]; then
        _ret_code=$G__ERR_NOT_OK
    fi

    return "$_ret_code"
}

#######################################
# Translate error code from number to string.
#
# Arguments:
#   error_code [in]: Number form of error code to translate.
#
# Returns:
#   G__ERR_OK: Error code was translated successfully.
#   G__ERR_MISSING_ARG: No error code was provided.
#   G__ERR_INVALID_ARG: Error code was not a number.
#######################################
function lib_base__error_code_to_string() {
    # Constants

    # Variables
    local _error_code

    local _error_str

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _error_code="$1"

    lib_base__is_number "$_error_code" || return "$G__ERR_INVALID_ARG"

    # Function body
    _error_str=${ERR_STRINGS[$_error_code]:-Unknown}
    echo "$_error_str ($_error_code)"

    return "$G__ERR_OK"
}

#######################################
# Check whether the given parameter is an indexed array variable name or not.
#
# Arguments:
#   var_name [in]: Name of the variable to check.
#
# Returns:
#   G__ERR_OK: The given variable is an indexed array.
#   G__ERR_NOT_OK: The given variable is not an indexed array or does not exist.
#   G__ERR_MISSING_ARG: No variable name was provided.
#######################################
function lib_base__is_array() {
    # Constants

    # Variables
    local _var_name

    local _decl=""
    local _ret_code=$G__ERR_OK

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _var_name="$1"

    # Function body
    _decl="$(declare -p -- "$_var_name" 2>/dev/null)" || return "$G__ERR_NOT_OK"

    if [[ ! "$_decl" =~ ^declare\ -[a-z]*a[a-z]*\  ]]; then
        _ret_code=$G__ERR_NOT_OK
    fi

    return "$_ret_code"
}

#######################################
# Generate a divider.
#
# Arguments:
#   char [in]: Divider character to paint.
#
# Returns:
#   G__ERR_OK: Divider was generated successfully.
#   G__ERR_MISSING_ARG: Divider char was not provided.
#   G__ERR_INVALID_ARG: Divider char is empty.
#######################################
function lib_base__gen_divider() {
    # Constants

    # Variables
    local _char

    local _placeholder

    # Parse and validate arguments
    [[ $# -eq 0 ]] && return "$G__ERR_MISSING_ARG"

    _char="$1"
    [[ -z "$_char" ]] && return "$G__ERR_INVALID_ARG"

    # Function body
    printf -v _placeholder '%*s' "$G__DIVIDER_WIDTH" ''
    echo "${_placeholder// /$_char}"

    return "$G__ERR_OK"
}
