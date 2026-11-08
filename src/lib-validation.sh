#!/usr/bin/env bash
#
# Source      : src/lib-validation.sh
# Dependencies: src/lib-base.sh
# Description : Validation functions for Bash variables, arrays, and values.
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__LIB_VALIDATION_SH_LOADED:-}" ]] && return 0
declare -gr G__LIB_VALIDATION_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../src/lib-base.sh"

# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# lib_validation__is_var_name           i01
# lib_validation__is_var                i02
# lib_validation__is_array              i03
# lib_validation__is_number             i04
# lib_validation__is_in                 i05
# -----------------------------------------

# ==================================================================================================
# Global Constants
# ==================================================================================================

# ===== Project Scope =====

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
# Check whether the given parameter is a valid Bash variable name.
#
# Arguments:
#   param [in]: Variable name to assert.
#
# Returns:
#   G__ERR_OK: The given parameter is a valid variable name.
#   G__ERR_NOT_OK: The given parameter is not a valid variable name.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 1 argument was provided.
#######################################
function lib_validation__is_var_name() {
    # Constants

    # Parameters
    local _lib_validation_i01__param

    # Variables

    # Parse and validate arguments
    if [[ "$#" -lt "1" ]]; then
        lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 1 argument"
    elif [[ "$#" -gt "1" ]]; then
        lib_base__throw "$G__ERR_TOO_MANY_ARGS" "${FUNCNAME[0]} required 1 argument"
    fi

    _lib_validation_i01__param="$1"

    # Function body
    [[ "$_lib_validation_i01__param" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && return "$G__ERR_OK"
    return "$G__ERR_NOT_OK"
}

#######################################
# Check whether the given parameter is a declared variable.
#
# Arguments:
#   var_name [in]: Name of the variable to check.
#
# Returns:
#   G__ERR_OK: The given parameter is a declared variable.
#   G__ERR_NOT_OK: The given parameter is not a declared variable.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 1 argument was provided.
#######################################
function lib_validation__is_var() {
    # Constants

    # Parameters
    local _lib_validation_i02__var_name

    # Variables

    # Parse and validate arguments
    if [[ "$#" -lt "1" ]]; then
        lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 1 argument"
    elif [[ "$#" -gt "1" ]]; then
        lib_base__throw "$G__ERR_TOO_MANY_ARGS" "${FUNCNAME[0]} required 1 argument"
    fi

    _lib_validation_i02__var_name="$1"

    # Function body
    lib_validation__is_var_name "$_lib_validation_i02__var_name" || return "$G__ERR_NOT_OK"
    declare -p -- "$_lib_validation_i02__var_name" >/dev/null 2>&1 || return "$G__ERR_NOT_OK"
    return "$G__ERR_OK"
}

#######################################
# Check whether the given parameter is an indexed array.
#
# Arguments:
#   var_name [in]: Name of the variable to check.
#
# Returns:
#   G__ERR_OK: The given variable is an indexed array.
#   G__ERR_NOT_OK: The given variable is not declared or an indexed array.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 1 argument was provided.
#######################################
function lib_validation__is_array() {
    # Constants

    # Parameters
    local _lib_validation_i03__var_name

    # Variables
    local _lib_validation_i03__declaration=""

    # Parse and validate arguments
    if [[ "$#" -lt "1" ]]; then
        lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 1 argument"
    elif [[ "$#" -gt "1" ]]; then
        lib_base__throw "$G__ERR_TOO_MANY_ARGS" "${FUNCNAME[0]} required 1 argument"
    fi

    _lib_validation_i03__var_name="$1"

    # Function body
    lib_validation__is_var "$_lib_validation_i03__var_name" || return "$G__ERR_NOT_OK"
    _lib_validation_i03__declaration="$(declare -p -- "$_lib_validation_i03__var_name")" ||
        return "$G__ERR_NOT_OK"
    [[ "$_lib_validation_i03__declaration" =~ ^declare\ -[a-z]*a[a-z]*\  ]] && return "$G__ERR_OK"
    return "$G__ERR_NOT_OK"
}

#######################################
# Check whether the given parameter is a number.
#
# Arguments:
#   param [in]: Value to check.
#
# Returns:
#   G__ERR_OK: The given parameter is a number.
#   G__ERR_NOT_OK: The given parameter is not a number.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 1 argument was provided.
#   G__ERR_TOO_MANY_ARGS: More than 1 argument was provided.
#######################################
function lib_validation__is_number() {
    # Constants

    # Parameters
    local _lib_validation_i04__param

    # Variables

    # Parse and validate arguments
    if [[ "$#" -lt "1" ]]; then
        lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 1 argument"
    elif [[ "$#" -gt "1" ]]; then
        lib_base__throw "$G__ERR_TOO_MANY_ARGS" "${FUNCNAME[0]} required 1 argument"
    fi

    _lib_validation_i04__param="$1"

    # Function body
    [[ "$_lib_validation_i04__param" =~ ^[-+]?[0-9][0-9]*$ ]] && return "$G__ERR_OK"
    return "$G__ERR_NOT_OK"
}

#######################################
# Check whether an array contains an item.
#
# Arguments:
#   array_ref [in]: Name of array variable to check.
#   item      [in]: Item to check.
#
# Returns:
#   G__ERR_OK: The array contains the item.
#   G__ERR_NOT_OK: The array does not contain the item.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given variable is not an indexed array.
#######################################
function lib_validation__is_in() {
    # Constants

    # Parameters
    local -n _lib_validation_i05__array_ref
    local _lib_validation_i05__item

    # Variables
    local _lib_validation_i05__element
    local _lib_validation_i05__message

    # Parse and validate arguments
    if [[ "$#" -lt "2" ]]; then
        lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 2 arguments"
    elif [[ "$#" -gt "2" ]]; then
        lib_base__throw "$G__ERR_TOO_MANY_ARGS" "${FUNCNAME[0]} required 2 arguments"
    fi

    _lib_validation_i05__message="The given variable is not an indexed array: '$1'"
    lib_validation__is_array "$1" ||
        lib_base__throw "$G__ERR_TYPE_ERROR" "$_lib_validation_i05__message"

    _lib_validation_i05__array_ref="$1"
    _lib_validation_i05__item="$2"

    # Function body
    for _lib_validation_i05__element in "${_lib_validation_i05__array_ref[@]}"; do
        [[ "$_lib_validation_i05__element" == "$_lib_validation_i05__item" ]] && return "$G__ERR_OK"
    done

    return "$G__ERR_NOT_OK"
}
