#!/usr/bin/env bash
#
# Source      : src/lib-layout.sh
# Dependencies: src/lib-base.sh
#               src/lib-validation.sh
#               src/lib-assertion.sh
#               src/lib-text.sh
# Description : Layout and table formatting utilities for console output.
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__LIB_LAYOUT_SH_LOADED:-}" ]] && return 0
declare -gr G__LIB_LAYOUT_SH_LOADED=1

shopt -s extglob

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-base.sh"
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-validation.sh"
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-assertion.sh"
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/lib-text.sh"

# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# _lib_layout__draw_table_summary       p01
# _lib_layout__calc_column_widths       p02
# _lib_layout__draw_table_row           p03
# lib_layout__draw_divider              i01
# lib_layout__draw_table                i02
# -----------------------------------------

# ==================================================================================================
# Global Constants
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====
readonly DEFAULT_TABLE_WIDTH=80
readonly DEFAULT_TABLE_BORDER="|"

# ==================================================================================================
# Global Variables
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====

# ==================================================================================================
# Private Functions
# ==================================================================================================
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
function _lib_layout__draw_table_summary() {
    # Constants

    # Parameters
    local -n _lib_layout_p01__ret_val_ref
    local _lib_layout_p01__summary
    local _lib_layout_p01__table_width
    local _lib_layout_p01__border
    local _lib_layout_p01__align

    # Variables
    local _lib_layout_p01__line_width
    local _lib_layout_p01__summary_line=""

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "5"

    _lib_layout_p01__ret_val_ref="$1"
    _lib_layout_p01__summary="$2"
    _lib_layout_p01__table_width="${3:-$DEFAULT_TABLE_WIDTH}"
    _lib_layout_p01__border="${4:-$DEFAULT_TABLE_BORDER}"
    _lib_layout_p01__align="${5:-$G__TEXT_ALIGN_CENTER}"

    lib_assertion__assert_var_name "${!_lib_layout_p01__ret_val_ref}"
    lib_assertion__assert_number "$_lib_layout_p01__table_width" "Table width"

    # Function body
    _lib_layout_p01__line_width=$((_lib_layout_p01__table_width - 2 * (${#_lib_layout_p01__border} + 1)))
    lib_text__align "_lib_layout_p01__summary_line" "$_lib_layout_p01__summary" "$_lib_layout_p01__line_width" "$_lib_layout_p01__align"

    _lib_layout_p01__ret_val_ref="$_lib_layout_p01__border "
    _lib_layout_p01__ret_val_ref+="$_lib_layout_p01__summary_line $_lib_layout_p01__border"
    return "$G__ERR_OK"
}

#######################################
# Calculate column widths based on cells and user-defined widths.
#
# Arguments:
#   ret_val_ref     [out]: Name of array variable to store calculated column widths.
#   ncols            [in]: Number of columns.
#   cells_ref        [in]: Name of array variable containing cell values.
#   user_widths_ref  [in]: Name of array variable containing user-defined widths.
#   table_width      [in]: (optional) Table width. Defaults to 80.
#   border           [in]: (optional) Table border character. Defaults to '|'.
#
# Returns:
#   G__ERR_OK: Column widths were calculated successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 4 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 6 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, output, cell, or user widths variable
#                      is not an array, column count is not a number,
#                      or table width is not a number.
#   G__ERR_INCOMPATIBLE_ARGS: Number of cells does not match column count.
#######################################
function _lib_layout__calc_column_widths() {
    # Constants

    # Parameters
    local -n _lib_layout_p02__ret_val_ref
    local _lib_layout_p02__ncols
    local -n _lib_layout_p02__cells_ref
    local -n _lib_layout_p02__user_widths_ref
    local _lib_layout_p02__table_width
    local _lib_layout_p02__border

    # Variables
    local -a _lib_layout_p02__user_widths=()
    local -a _lib_layout_p02__max_lens=()
    local -a _lib_layout_p02__column_widths=()
    local _lib_layout_p02__nrows=0
    local _lib_layout_p02__colx
    local _lib_layout_p02__rowx
    local _lib_layout_p02__fixed_cols_width=0
    local _lib_layout_p02__filled_ncols=0
    local _lib_layout_p02__borders_width
    local _lib_layout_p02__available_widths
    local _lib_layout_p02__message
    local _lib_layout_p02__column_max_len
    local _lib_layout_p02__cell
    local _lib_layout_p02__clean_cell
    local _lib_layout_p02__width
    local _lib_layout_p02__max_len
    local _lib_layout_p02__filled_cols_width
    local _lib_layout_p02__filled_width
    local _lib_layout_p02__last_filled_width
    local _lib_layout_p02__filled_count
    local _lib_layout_p02__total_cols_width
    local _lib_layout_p02__diff

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "4" "6"

    _lib_layout_p02__ret_val_ref="$1"
    _lib_layout_p02__ncols="$2"
    _lib_layout_p02__cells_ref="$3"
    _lib_layout_p02__user_widths_ref="$4"
    _lib_layout_p02__table_width="${5:-$DEFAULT_TABLE_WIDTH}"
    _lib_layout_p02__border="${6:-$DEFAULT_TABLE_BORDER}"

    lib_assertion__assert_var_name "${!_lib_layout_p02__ret_val_ref}"
    lib_assertion__assert_array "${!_lib_layout_p02__ret_val_ref}"
    lib_assertion__assert_var_name "${!_lib_layout_p02__cells_ref}"
    lib_assertion__assert_array "${!_lib_layout_p02__cells_ref}"
    lib_assertion__assert_var_name "${!_lib_layout_p02__user_widths_ref}"
    lib_assertion__assert_array "${!_lib_layout_p02__user_widths_ref}"
    lib_assertion__assert_number "$_lib_layout_p02__ncols" "Number of columns"
    lib_assertion__assert_number "$_lib_layout_p02__table_width" "Table width"

    _lib_layout_p02__user_widths=("${_lib_layout_p02__user_widths_ref[@]}")

    if [[ "$_lib_layout_p02__ncols" -gt 0 ]]; then
        _lib_layout_p02__nrows=$((${#_lib_layout_p02__cells_ref[@]} / _lib_layout_p02__ncols))
    fi

    if [[ "$_lib_layout_p02__ncols" -le 0 || "${#_lib_layout_p02__cells_ref[@]}" -eq 0 ||
        "$((_lib_layout_p02__nrows * _lib_layout_p02__ncols))" -ne "${#_lib_layout_p02__cells_ref[@]}" ]]; then
        _lib_layout_p02__message="Number of cells and columns are not matched: "
        _lib_layout_p02__message+="$_lib_layout_p02__ncols columns vs "
        _lib_layout_p02__message+="${#_lib_layout_p02__cells_ref[@]} cells"
        lib_base__throw "$G__ERR_INCOMPATIBLE_ARGS" "$_lib_layout_p02__message"
    fi

    # Function body
    # 1. Determine maximum column value length for each column
    for ((_lib_layout_p02__colx = 0; _lib_layout_p02__colx < _lib_layout_p02__ncols; _lib_layout_p02__colx++)); do
        _lib_layout_p02__column_max_len=0

        for ((_lib_layout_p02__rowx = 0; _lib_layout_p02__rowx < _lib_layout_p02__nrows; _lib_layout_p02__rowx++)); do
            _lib_layout_p02__cell="${_lib_layout_p02__cells_ref[_lib_layout_p02__colx + _lib_layout_p02__ncols * _lib_layout_p02__rowx]}"
            _lib_layout_p02__clean_cell="${_lib_layout_p02__cell//$'\033'\[*([0-9;])[a-zA-Z]/}"
            if [[ "${#_lib_layout_p02__clean_cell}" -gt "$_lib_layout_p02__column_max_len" ]]; then
                _lib_layout_p02__column_max_len="${#_lib_layout_p02__clean_cell}"
            fi
        done

        _lib_layout_p02__max_lens+=("$_lib_layout_p02__column_max_len")
    done

    # 2. Normalize user-defined widths to column count
    if [[ "${#_lib_layout_p02__user_widths[@]}" -lt "$_lib_layout_p02__ncols" ]]; then
        for ((_lib_layout_p02__colx = ${#_lib_layout_p02__user_widths[@]}; _lib_layout_p02__colx < _lib_layout_p02__ncols; _lib_layout_p02__colx++)); do
            _lib_layout_p02__user_widths+=("-1")
        done
    elif [[ "${#_lib_layout_p02__user_widths[@]}" -gt "$_lib_layout_p02__ncols" ]]; then
        _lib_layout_p02__user_widths=(
            "${_lib_layout_p02__user_widths[@]:0:$_lib_layout_p02__ncols}")
    fi

    # 3. Classify widths into fixed and filled values
    for ((_lib_layout_p02__colx = 0; _lib_layout_p02__colx < _lib_layout_p02__ncols; _lib_layout_p02__colx++)); do
        _lib_layout_p02__width="${_lib_layout_p02__user_widths[_lib_layout_p02__colx]}"
        _lib_layout_p02__max_len="${_lib_layout_p02__max_lens[_lib_layout_p02__colx]}"

        if [[ "$_lib_layout_p02__width" -gt 0 ]]; then
            if [[ "$_lib_layout_p02__width" -lt "$_lib_layout_p02__max_len" ]]; then
                _lib_layout_p02__width="$_lib_layout_p02__max_len"
            fi
            _lib_layout_p02__fixed_cols_width=$((_lib_layout_p02__fixed_cols_width + _lib_layout_p02__width))
        else
            _lib_layout_p02__width="-1"
            _lib_layout_p02__filled_ncols=$((_lib_layout_p02__filled_ncols + 1))
        fi

        _lib_layout_p02__column_widths+=("$_lib_layout_p02__width")
    done

    _lib_layout_p02__borders_width=$(((_lib_layout_p02__ncols + 1) * (${#_lib_layout_p02__border} + 1) + (_lib_layout_p02__ncols - 1)))
    _lib_layout_p02__available_widths=$((_lib_layout_p02__table_width - _lib_layout_p02__borders_width))

    # 4. Distribute available width to filled columns or scale last column
    if [[ "$_lib_layout_p02__filled_ncols" -gt 0 ]]; then
        _lib_layout_p02__filled_cols_width=$((_lib_layout_p02__available_widths - _lib_layout_p02__fixed_cols_width))
        _lib_layout_p02__filled_width=$((_lib_layout_p02__filled_cols_width / _lib_layout_p02__filled_ncols))
        _lib_layout_p02__last_filled_width=$((_lib_layout_p02__filled_cols_width - (_lib_layout_p02__filled_ncols - 1) * _lib_layout_p02__filled_width))
        _lib_layout_p02__filled_count=0

        for ((_lib_layout_p02__colx = 0; _lib_layout_p02__colx < _lib_layout_p02__ncols; _lib_layout_p02__colx++)); do
            if [[ "${_lib_layout_p02__column_widths[_lib_layout_p02__colx]}" -eq "-1" ]]; then
                _lib_layout_p02__filled_count=$((_lib_layout_p02__filled_count + 1))

                local _colx="$_lib_layout_p02__colx"
                if [[ "$_lib_layout_p02__filled_count" -eq "$_lib_layout_p02__filled_ncols" ]]; then
                    _lib_layout_p02__column_widths[_colx]="$_lib_layout_p02__last_filled_width"
                else
                    _lib_layout_p02__column_widths[_colx]="$_lib_layout_p02__filled_width"
                fi
            fi
        done
    else
        _lib_layout_p02__total_cols_width=0

        for ((_lib_layout_p02__colx = 0; _lib_layout_p02__colx < _lib_layout_p02__ncols; _lib_layout_p02__colx++)); do
            _lib_layout_p02__total_cols_width=$((_lib_layout_p02__total_cols_width + _lib_layout_p02__column_widths[_lib_layout_p02__colx]))
        done

        if [[ "$_lib_layout_p02__total_cols_width" -lt "$_lib_layout_p02__available_widths" ]]; then
            _lib_layout_p02__diff=$((_lib_layout_p02__available_widths - _lib_layout_p02__total_cols_width))
            _lib_layout_p02__column_widths[_lib_layout_p02__ncols - 1]=$((_lib_layout_p02__column_widths[_lib_layout_p02__ncols - 1] + _lib_layout_p02__diff))
        fi
    fi

    _lib_layout_p02__ret_val_ref=("${_lib_layout_p02__column_widths[@]}")
    return "$G__ERR_OK"
}

#######################################
# Draw a bordered table row.
#
# Arguments:
#   ret_val_ref        [out]: Name of variable to store the formatted row.
#   columns_ref         [in]: Name of array variable containing column values.
#   column_widths_ref   [in]: Name of array variable containing column widths.
#   table_width         [in]: (optional) Table width. Defaults to 80.
#   border              [in]: (optional) Table border character. Defaults to '|'.
#   align               [in]: (optional) Text alignment ('left', 'center',
#                             'right'). Defaults to 'left'.
#
# Returns:
#   G__ERR_OK: Row was created successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 3 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 6 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, columns or widths variable is not an array,
#                      table width is not a number, or alignment is invalid.
#   G__ERR_INCOMPATIBLE_ARGS: Column value and column width counts do not match.
#######################################
function _lib_layout__draw_table_row() {
    # Constants

    # Parameters
    local -n _lib_layout_p03__ret_val_ref
    local -n _lib_layout_p03__columns_ref
    local -n _lib_layout_p03__column_widths_ref
    local _lib_layout_p03__table_width
    local _lib_layout_p03__border
    local _lib_layout_p03__align

    # Variables
    local _lib_layout_p03__idx
    local _lib_layout_p03__columns_line=""
    local _lib_layout_p03__column_value
    local _lib_layout_p03__message

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "3" "6"

    _lib_layout_p03__ret_val_ref="$1"
    _lib_layout_p03__columns_ref="$2"
    _lib_layout_p03__column_widths_ref="$3"
    _lib_layout_p03__table_width="${4:-$DEFAULT_TABLE_WIDTH}"
    _lib_layout_p03__border="${5:-$DEFAULT_TABLE_BORDER}"
    _lib_layout_p03__align="${6:-$G__TEXT_ALIGN_LEFT}"

    lib_assertion__assert_var_name "${!_lib_layout_p03__ret_val_ref}"
    lib_assertion__assert_var_name "${!_lib_layout_p03__columns_ref}"
    lib_assertion__assert_array "${!_lib_layout_p03__columns_ref}"
    lib_assertion__assert_var_name "${!_lib_layout_p03__column_widths_ref}"
    lib_assertion__assert_array "${!_lib_layout_p03__column_widths_ref}"
    lib_assertion__assert_number "$_lib_layout_p03__table_width" "Table width"

    if [[ "${#_lib_layout_p03__columns_ref[@]}" -ne "${#_lib_layout_p03__column_widths_ref[@]}" ]]; then
        _lib_layout_p03__message="Number of headers and column widths are not equal: "
        _lib_layout_p03__message+="${#_lib_layout_p03__columns_ref[@]} headers vs "
        _lib_layout_p03__message+="${#_lib_layout_p03__column_widths_ref[@]} column widths"
        lib_base__throw "$G__ERR_INCOMPATIBLE_ARGS" "$_lib_layout_p03__message"
    fi

    # Function body
    for _lib_layout_p03__idx in "${!_lib_layout_p03__columns_ref[@]}"; do
        if [[ "$_lib_layout_p03__idx" -gt "0" ]]; then
            _lib_layout_p03__columns_line+=" $_lib_layout_p03__border "
        fi

        lib_text__align "_lib_layout_p03__column_value" "${_lib_layout_p03__columns_ref[$_lib_layout_p03__idx]}" "${_lib_layout_p03__column_widths_ref[$_lib_layout_p03__idx]}" "$_lib_layout_p03__align"

        _lib_layout_p03__columns_line+="${_lib_layout_p03__column_value}"
    done

    _lib_layout_p03__ret_val_ref="$_lib_layout_p03__border "
    _lib_layout_p03__ret_val_ref+="$_lib_layout_p03__columns_line $_lib_layout_p03__border"
    return "$G__ERR_OK"
}

# ==================================================================================================
# Public Functions
# ==================================================================================================
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
function lib_layout__draw_divider() {
    # Constants

    # Parameters
    local -n _lib_layout_i01__ret_val_ref
    local _lib_layout_i01__char
    local _lib_layout_i01__width

    # Variables
    local _lib_layout_i01__divider

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "3"

    _lib_layout_i01__ret_val_ref="$1"
    _lib_layout_i01__char="$2"
    _lib_layout_i01__width="${3:-$DEFAULT_TABLE_WIDTH}"

    lib_assertion__assert_var_name "${!_lib_layout_i01__ret_val_ref}"
    lib_assertion__assert_not_empty "$_lib_layout_i01__char" "Divider character"
    lib_assertion__assert_number "$_lib_layout_i01__width" "Divider width"

    # Function body
    printf -v "_lib_layout_i01__divider" '%*s' "$_lib_layout_i01__width" ''
    _lib_layout_i01__divider="${_lib_layout_i01__divider// /$_lib_layout_i01__char}"

    _lib_layout_i01__ret_val_ref="$_lib_layout_i01__divider"
    return "$G__ERR_OK"
}

#######################################
# Draw a complete bordered table.
#
# Arguments:
#   ret_val_ref      [out]: Name of variable to store the formatted table.
#   ncols             [in]: Number of columns.
#   cells             [in]: Name of array variable containing cell values.
#   summary           [in]: (optional) Table summary text. Defaults to ''.
#   user_widths_ref   [in]: (optional) Name of array variable containing user-defined widths.
#   table_width       [in]: (optional) Total table width. Defaults to 80.
#   border            [in]: (optional) Table border character. Defaults to '|'.
#   align             [in]: (optional) Column text alignment ('left', 'center', 'right').
#                           Defaults to 'left'.
#
# Returns:
#   G__ERR_OK: Table was created successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 3 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 8 arguments were provided.
#   G__ERR_TYPE_ERROR: Variable name is invalid, cell or user widths variable is not an array,
#                      column count is not a number, table width is not a number,
#                      or alignment is invalid.
#   G__ERR_INCOMPATIBLE_ARGS: Number of cells does not match column count.
#######################################
function lib_layout__draw_table() {
    # Constants
    local -ra _LIB_LAYOUT_i02__DEFAULT_USER_WIDTHS=()

    # Parameters
    local -n _lib_layout_i02__ret_val_ref
    local _lib_layout_i02__ncols
    local -n _lib_layout_i02__cells_ref
    local _lib_layout_i02__summary
    local -n _lib_layout_i02__user_widths_ref
    local _lib_layout_i02__table_width
    local _lib_layout_i02__border
    local _lib_layout_i02__align

    # Variables
    local -a _lib_layout_i02__user_widths=()
    local -a _lib_layout_i02__max_lens=()
    local -a _lib_layout_i02__calc_widths=()
    local _lib_layout_i02__nrows=0
    local _lib_layout_i02__colx
    local _lib_layout_i02__rowx
    local _lib_layout_i02__min_cols_width=0
    local _lib_layout_i02__borders_width=0
    local _lib_layout_i02__min_table_width=0
    local _lib_layout_i02__total_row_width=0
    local _lib_layout_i02__divider_h2=""
    local _lib_layout_i02__divider_h3=""
    local _lib_layout_i02__summary_row=""
    local _lib_layout_i02__row=""
    local _lib_layout_i02__table_lines=""
    local _lib_layout_i02__column_max_len
    local _lib_layout_i02__cell
    local _lib_layout_i02__clean_cell
    local _lib_layout_i02__u_width
    local _lib_layout_i02__diff
    local _lib_layout_i02__message

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "3" "8"

    _lib_layout_i02__ret_val_ref="$1"
    _lib_layout_i02__ncols="$2"
    _lib_layout_i02__cells_ref="$3"
    _lib_layout_i02__summary="${4:-}"
    _lib_layout_i02__user_widths_ref="${5:-_LIB_LAYOUT_i02__DEFAULT_USER_WIDTHS}"
    _lib_layout_i02__table_width="${6:-$DEFAULT_TABLE_WIDTH}"
    _lib_layout_i02__border="${7:-$DEFAULT_TABLE_BORDER}"
    _lib_layout_i02__align="${8:-$G__TEXT_ALIGN_LEFT}"

    lib_assertion__assert_var_name "${!_lib_layout_i02__cells_ref}"
    lib_assertion__assert_var_name "${!_lib_layout_i02__ret_val_ref}"
    lib_assertion__assert_array "${!_lib_layout_i02__cells_ref}"
    lib_assertion__assert_var_name "${!_lib_layout_i02__user_widths_ref}"
    lib_assertion__assert_array "${!_lib_layout_i02__user_widths_ref}"
    lib_assertion__assert_number "$_lib_layout_i02__ncols" "Number of columns"
    lib_assertion__assert_number "$_lib_layout_i02__table_width" "Table width"

    if [[ "$_lib_layout_i02__ncols" -gt 0 ]]; then
        _lib_layout_i02__nrows=$((${#_lib_layout_i02__cells_ref[@]} / _lib_layout_i02__ncols))
    fi

    if [[ "$_lib_layout_i02__ncols" -le 0 || "${#_lib_layout_i02__cells_ref[@]}" -eq 0 ||
        "$((_lib_layout_i02__nrows * _lib_layout_i02__ncols))" -ne "${#_lib_layout_i02__cells_ref[@]}" ]]; then
        _lib_layout_i02__message="Number of cells and columns are not matched: "
        _lib_layout_i02__message+="$_lib_layout_i02__ncols columns vs "
        _lib_layout_i02__message+="${#_lib_layout_i02__cells_ref[@]} cells"
        lib_base__throw "$G__ERR_INCOMPATIBLE_ARGS" "$_lib_layout_i02__message"
    fi

    # Function body
    _lib_layout_i02__user_widths=("${_lib_layout_i02__user_widths_ref[@]}")

    for ((_lib_layout_i02__colx = 0; _lib_layout_i02__colx < _lib_layout_i02__ncols; _lib_layout_i02__colx++)); do
        _lib_layout_i02__column_max_len=0
        for ((_lib_layout_i02__rowx = 0; _lib_layout_i02__rowx < _lib_layout_i02__nrows; _lib_layout_i02__rowx++)); do
            _lib_layout_i02__cell="${_lib_layout_i02__cells_ref[_lib_layout_i02__colx + _lib_layout_i02__ncols * _lib_layout_i02__rowx]}"
            _lib_layout_i02__clean_cell="${_lib_layout_i02__cell//$'\033'\[*([0-9;])[a-zA-Z]/}"
            if [[ "${#_lib_layout_i02__clean_cell}" -gt "$_lib_layout_i02__column_max_len" ]]; then
                _lib_layout_i02__column_max_len="${#_lib_layout_i02__clean_cell}"
            fi
        done
        _lib_layout_i02__max_lens+=("$_lib_layout_i02__column_max_len")

        _lib_layout_i02__u_width="${_lib_layout_i02__user_widths[_lib_layout_i02__colx]:--1}"
        if [[ "$_lib_layout_i02__u_width" -gt "$_lib_layout_i02__column_max_len" ]]; then
            _lib_layout_i02__min_cols_width=$((_lib_layout_i02__min_cols_width + _lib_layout_i02__u_width))
        else
            _lib_layout_i02__min_cols_width=$((_lib_layout_i02__min_cols_width + _lib_layout_i02__column_max_len))
        fi
    done

    _lib_layout_i02__borders_width=$(((_lib_layout_i02__ncols + 1) * (${#_lib_layout_i02__border} + 1) + (_lib_layout_i02__ncols - 1)))
    _lib_layout_i02__min_table_width=$((_lib_layout_i02__min_cols_width + _lib_layout_i02__borders_width))
    if [[ "$_lib_layout_i02__min_table_width" -gt "$_lib_layout_i02__table_width" ]]; then
        _lib_layout_i02__table_width="$_lib_layout_i02__min_table_width"
    fi

    _lib_layout__calc_column_widths "_lib_layout_i02__calc_widths" "$_lib_layout_i02__ncols" "${!_lib_layout_i02__cells_ref}" "_lib_layout_i02__user_widths" "$_lib_layout_i02__table_width" "$_lib_layout_i02__border"

    for ((_lib_layout_i02__colx = 0; _lib_layout_i02__colx < _lib_layout_i02__ncols; _lib_layout_i02__colx++)); do
        local _colx="$_lib_layout_i02__colx"
        if [[ "${_lib_layout_i02__calc_widths[_colx]}" -lt "${_lib_layout_i02__max_lens[_colx]}" ]]; then
            _lib_layout_i02__calc_widths[_colx]="${_lib_layout_i02__max_lens[_colx]}"
        fi
        _lib_layout_i02__total_row_width=$((_lib_layout_i02__total_row_width + _lib_layout_i02__calc_widths[_colx]))
    done

    _lib_layout_i02__total_row_width=$((_lib_layout_i02__total_row_width + _lib_layout_i02__borders_width))
    if [[ "$_lib_layout_i02__total_row_width" -gt "$_lib_layout_i02__table_width" ]]; then
        _lib_layout_i02__table_width="$_lib_layout_i02__total_row_width"
    fi

    lib_layout__draw_divider "_lib_layout_i02__divider_h2" "$G__DIVIDER_H2_CHAR" "$_lib_layout_i02__table_width"
    lib_layout__draw_divider "_lib_layout_i02__divider_h3" "$G__DIVIDER_H3_CHAR" "$_lib_layout_i02__table_width"

    if [[ -n "$_lib_layout_i02__summary" ]]; then
        _lib_layout__draw_table_summary "_lib_layout_i02__summary_row" "$_lib_layout_i02__summary" "$_lib_layout_i02__table_width" "$_lib_layout_i02__border" "$G__TEXT_ALIGN_CENTER"
        _lib_layout_i02__table_lines="${_lib_layout_i02__divider_h2}"$'\n'
        _lib_layout_i02__table_lines+="${_lib_layout_i02__summary_row}"$'\n'
        _lib_layout_i02__table_lines+="${_lib_layout_i02__divider_h2}"
    else
        _lib_layout_i02__table_lines="${_lib_layout_i02__divider_h3}"
    fi

    for ((_lib_layout_i02__rowx = 0; _lib_layout_i02__rowx < _lib_layout_i02__nrows; _lib_layout_i02__rowx++)); do
        local _start_idx=$((_lib_layout_i02__rowx * _lib_layout_i02__ncols))
        local -a _lib_layout_i02__cell_slice=(
            "${_lib_layout_i02__cells_ref[@]:_start_idx:_lib_layout_i02__ncols}")
        _lib_layout__draw_table_row "_lib_layout_i02__row" "_lib_layout_i02__cell_slice" "_lib_layout_i02__calc_widths" "$_lib_layout_i02__table_width" "$_lib_layout_i02__border" "$_lib_layout_i02__align"
        _lib_layout_i02__table_lines+=$'\n'"${_lib_layout_i02__row}"
        _lib_layout_i02__table_lines+=$'\n'"${_lib_layout_i02__divider_h3}"
    done

    _lib_layout_i02__ret_val_ref="$_lib_layout_i02__table_lines"
    return "$G__ERR_OK"
}
