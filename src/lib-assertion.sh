#!/usr/bin/env bash
#
# Source      : src/lib-assertion.sh
# Dependencies: src/lib-base.sh
#               src/lib-validation.sh
# Description : Assertion utilities for argument counts, variable types, arrays, and values.
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__LIB_ASSERTION_SH_LOADED:-}" ]] && return 0
declare -rx G__LIB_ASSERTION_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-base.sh"
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-validation.sh"

# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# lib_assertion__assert_args_count      i01
# lib_assertion__assert_var_name        i02
# lib_assertion__assert_var             i03
# lib_assertion__assert_array           i04
# lib_assertion__assert_number          i05
# lib_assertion__assert_not_empty       i06
# lib_assertion__assert_in              i07
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
function lib_assertion__assert_args_count() {
    # Constants
    local -r _LIB_ASSERTION_i01__MAX_ARGS="100"

    # Parameters
    local _lib_assertion_i01__args_count
    local _lib_assertion_i01__min_args
    local _lib_assertion_i01__max_args

    # Variables

    # Parse and validate arguments
    if [[ "$#" -lt "2" ]]; then
        lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 2 arguments"
    fi

    _lib_assertion_i01__args_count="$1"
    _lib_assertion_i01__min_args="$2"
    _lib_assertion_i01__max_args="${3:-$_LIB_ASSERTION_i01__MAX_ARGS}"

    lib_validation__is_number "$_lib_assertion_i01__args_count" ||
        lib_base__throw "$G__ERR_TYPE_ERROR" \
            "Argument count must be a number: '$_lib_assertion_i01__args_count'"

    lib_validation__is_number "$_lib_assertion_i01__min_args" ||
        lib_base__throw "$G__ERR_TYPE_ERROR" \
            "Minimum arguments must be a number: '$_lib_assertion_i01__min_args'"

    lib_validation__is_number "$_lib_assertion_i01__max_args" ||
        lib_base__throw "$G__ERR_TYPE_ERROR" \
            "Maximum arguments must be a number: '$_lib_assertion_i01__max_args'"

    # Function body
    if [[ "$_lib_assertion_i01__args_count" -lt "$_lib_assertion_i01__min_args" ]]; then
        lib_base__throw "$G__ERR_MISSING_ARG" \
            "${FUNCNAME[1]} required at least $_lib_assertion_i01__min_args argument(s)"
    fi

    if [[ "$_lib_assertion_i01__args_count" -gt "$_lib_assertion_i01__max_args" ]]; then
        lib_base__throw "$G__ERR_TOO_MANY_ARGS" \
            "${FUNCNAME[1]} allow at most $_lib_assertion_i01__max_args arguments"
    fi

    return "$G__ERR_OK"
}

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
function lib_assertion__assert_var_name() {
    # Constants

    # Parameters
    local _lib_assertion_i02__param

    # Variables

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "1"

    _lib_assertion_i02__param="$1"

    # Function body
    [[ "$_lib_assertion_i02__param" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && return "$G__ERR_OK"
    lib_base__throw "$G__ERR_TYPE_ERROR" \
        "Not a valid variable name: '$_lib_assertion_i02__param'"
}

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
function lib_assertion__assert_var() {
    # Constants

    # Parameters
    local _lib_assertion_i03__param

    # Variables

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "1"

    _lib_assertion_i03__param="$1"

    # Function body
    lib_validation__is_var "$_lib_assertion_i03__param" ||
        lib_base__throw "$G__ERR_TYPE_ERROR" "Not a variable: '$_lib_assertion_i03__param'"

    return "$G__ERR_OK"
}

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
#   G__ERR_TYPE_ERROR: The given parameter is not an indexed array.
#######################################
function lib_assertion__assert_array() {
    # Constants

    # Parameters
    local _lib_assertion_i04__param

    # Variables

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "1"

    _lib_assertion_i04__param="$1"

    # Function body
    lib_validation__is_array "$_lib_assertion_i04__param" ||
        lib_base__throw "$G__ERR_TYPE_ERROR" "Not an array: '$_lib_assertion_i04__param'"

    return "$G__ERR_OK"
}

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
function lib_assertion__assert_number() {
    # Constants

    # Parameters
    local _lib_assertion_i05__param
    local _lib_assertion_i05__label

    # Variables
    local _lib_assertion_i05__message

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "2"

    _lib_assertion_i05__param="$1"
    _lib_assertion_i05__label="${2:-}"

    # Function body
    if [[ -z "$_lib_assertion_i05__label" ]]; then
        _lib_assertion_i05__message="Not a number: '$_lib_assertion_i05__param'"
    else
        _lib_assertion_i05__message="$_lib_assertion_i05__label must be a number: "
        _lib_assertion_i05__message+="'$_lib_assertion_i05__param'"
    fi

    lib_validation__is_number "$_lib_assertion_i05__param" ||
        lib_base__throw "$G__ERR_TYPE_ERROR" "$_lib_assertion_i05__message"

    return "$G__ERR_OK"
}

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
function lib_assertion__assert_not_empty() {
    # Constants

    # Parameters
    local _lib_assertion_i06__param
    local _lib_assertion_i06__label

    # Variables
    local _lib_assertion_i06__message

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "1" "2"

    _lib_assertion_i06__param="$1"
    _lib_assertion_i06__label="${2:-}"

    # Function body
    if [[ -z "$_lib_assertion_i06__label" ]]; then
        _lib_assertion_i06__message="Value is empty"
    else
        _lib_assertion_i06__message="$_lib_assertion_i06__label must not be empty"
    fi

    [[ -n "$_lib_assertion_i06__param" ]] ||
        lib_base__throw "$G__ERR_TYPE_ERROR" "$_lib_assertion_i06__message"

    return "$G__ERR_OK"
}

#######################################
# Assert that an array contains an item.
#
# Arguments:
#   array_ref [in]: Name of array variable to assert.
#   item      [in]: Item to assert.
#
# Returns:
#   G__ERR_OK: The array contains the item.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The array does not contain the item.
#######################################
function lib_assertion__assert_in() {
    # Constants

    # Parameters
    local -n _lib_assertion_i07__array_ref
    local _lib_assertion_i07__item

    # Variables
    local _lib_assertion_i07__message

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "2"

    _lib_assertion_i07__array_ref="$1"
    _lib_assertion_i07__item="$2"

    # Function body
    lib_validation__is_in "${!_lib_assertion_i07__array_ref}" "$_lib_assertion_i07__item" ||
        lib_base__throw "$G__ERR_TYPE_ERROR" \
            "Array does not contain item '$_lib_assertion_i07__item'"

    return "$G__ERR_OK"
}
