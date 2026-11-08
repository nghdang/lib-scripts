#!/usr/bin/env bash
#
# Source      : src/lib-text.sh
# Dependencies: src/lib-base.sh
#               src/lib-assertion.sh
# Description : Text formatting, alignment, and measurement utilities.
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__LIB_TEXT_SH_LOADED:-}" ]] && return 0
declare -gr G__LIB_TEXT_SH_LOADED=1

shopt -s extglob

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-base.sh"
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-assertion.sh"

# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# lib_text__align                       i01
# lib_text__find_max_len                i02
# -----------------------------------------

# ==================================================================================================
# Global Constants
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====
readonly DEFAULT_TEXT_WIDTH=80

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
function lib_text__align() {
    # Constants
    local -ra _LIB_TEXT_i01__TEXT_ALIGNS=(
        "$G__TEXT_ALIGN_LEFT"
        "$G__TEXT_ALIGN_CENTER"
        "$G__TEXT_ALIGN_RIGHT"
    )

    # Parameters
    local -n _lib_text_i01__ret_val_ref
    local _lib_text_i01__text
    local _lib_text_i01__width
    local _lib_text_i01__align

    # Variables
    local _lib_text_i01__clean_text
    local _lib_text_i01__visible_len
    local _lib_text_i01__padding_width=0
    local _lib_text_i01__padding=""
    local _lib_text_i01__left_pad_width=0
    local _lib_text_i01__right_pad_width=0
    local _lib_text_i01__left_pad=""
    local _lib_text_i01__right_pad=""
    local _lib_text_i01__aligned_text=""

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "4"

    _lib_text_i01__ret_val_ref="$1"
    _lib_text_i01__text="$2"
    _lib_text_i01__width="${3:-$DEFAULT_TEXT_WIDTH}"
    _lib_text_i01__align="${4:-$G__TEXT_ALIGN_LEFT}"

    lib_assertion__assert_var_name "${!_lib_text_i01__ret_val_ref}"
    lib_assertion__assert_number "$_lib_text_i01__width" "Target width"
    lib_assertion__assert_in "_LIB_TEXT_i01__TEXT_ALIGNS" "$_lib_text_i01__align"

    # Function body
    _lib_text_i01__clean_text="${_lib_text_i01__text//$'\033'\[*([0-9;])[a-zA-Z]/}"
    _lib_text_i01__visible_len="${#_lib_text_i01__clean_text}"
    _lib_text_i01__padding_width=$((_lib_text_i01__width - _lib_text_i01__visible_len))

    if [[ "$_lib_text_i01__padding_width" -gt 0 ]]; then
        printf -v "_lib_text_i01__padding" '%*s' "$_lib_text_i01__padding_width" ''
    fi

    if [[ "$_lib_text_i01__align" == "$G__TEXT_ALIGN_LEFT" ]]; then
        _lib_text_i01__aligned_text="${_lib_text_i01__text}${_lib_text_i01__padding}"
    elif [[ "$_lib_text_i01__align" == "$G__TEXT_ALIGN_RIGHT" ]]; then
        _lib_text_i01__aligned_text="${_lib_text_i01__padding}${_lib_text_i01__text}"
    elif [[ "$_lib_text_i01__align" == "$G__TEXT_ALIGN_CENTER" ]]; then
        if [[ "$_lib_text_i01__padding_width" -gt 0 ]]; then
            _lib_text_i01__left_pad_width=$((_lib_text_i01__padding_width / 2))
            _lib_text_i01__right_pad_width=$((_lib_text_i01__padding_width - _lib_text_i01__left_pad_width))
            if [[ "$_lib_text_i01__left_pad_width" -gt 0 ]]; then
                printf -v "_lib_text_i01__left_pad" '%*s' "$_lib_text_i01__left_pad_width" ''
            fi
            if [[ "$_lib_text_i01__right_pad_width" -gt 0 ]]; then
                printf -v "_lib_text_i01__right_pad" '%*s' "$_lib_text_i01__right_pad_width" ''
            fi
        fi
        _lib_text_i01__aligned_text="${_lib_text_i01__left_pad}${_lib_text_i01__text}${_lib_text_i01__right_pad}"
    fi

    _lib_text_i01__ret_val_ref="$_lib_text_i01__aligned_text"
    return "$G__ERR_OK"
}

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
function lib_text__find_max_len() {
    # Constants

    # Parameters
    local -n _lib_text_i02__ret_val_ref
    local -a _lib_text_i02__items=()

    # Variables
    local _lib_text_i02__max_len=0
    local _lib_text_i02__item
    local _lib_text_i02__clean_item

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2"

    _lib_text_i02__ret_val_ref="$1"
    _lib_text_i02__items=("${@:2}")

    lib_assertion__assert_var_name "${!_lib_text_i02__ret_val_ref}"

    # Function body
    for _lib_text_i02__item in "${_lib_text_i02__items[@]}"; do
        _lib_text_i02__clean_item="${_lib_text_i02__item//$'\033'\[*([0-9;])[a-zA-Z]/}"
        if [[ "${#_lib_text_i02__clean_item}" -gt "$_lib_text_i02__max_len" ]]; then
            _lib_text_i02__max_len="${#_lib_text_i02__clean_item}"
        fi
    done

    _lib_text_i02__ret_val_ref="$_lib_text_i02__max_len"
    return "$G__ERR_OK"
}
