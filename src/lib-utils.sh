#!/usr/bin/env bash
#
# Source      : src/lib-utils.sh
# Dependencies: src/lib-base.sh
#               src/lib-logging.sh
# Description : General utility helpers for cross-projects.
#

# ----- Source Guard -----
[[ -n "${G__LIB_UTILS_SH_LOADED:-}" ]] && return 0
export G__LIB_UTILS_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====

# =============================================================================
# Global Variables
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====

# =============================================================================
# Private Functions
# =============================================================================
#######################################
# Print the table summary header and outer divider.
#
# Arguments:
#   summary [in]: (optional) Summary text to print centered.
#   log_stack [in]: (optional) Stack depth for log output (default: 2).
#
# Returns:
#   G__ERR_OK: Table summary was printed successfully.
#######################################
function _lib_utils__print_table_summary() {
    # Constants

    # Variables
    local _summary
    local _log_stack

    local _pad_len
    local _pad=""
    local _line
    local _divider_h2

    # Parse and validate arguments
    _summary="${1:-}"
    _log_stack="${2:-2}"

    # Function body
    _divider_h2="$(lib_base__gen_divider "$G__DIVIDER_H2_CHAR")"

    lib_logging__info "" "$_log_stack"
    lib_logging__info "$_divider_h2" "$_log_stack"

    if [[ -z "$_summary" ]]; then
        return "$G__ERR_OK"
    fi

    _pad_len=$(((G__TABLE_WIDTH - ${#_summary}) / 2))
    if [[ $_pad_len -gt 0 ]]; then
        _pad="$(printf "%0.s " $(seq 1 "$_pad_len"))"
    fi
    _line="$(printf "%-*s" "$G__TABLE_WIDTH" "${_pad}${_summary}")"

    lib_logging__info "${G__TABLE_ROW_PREFIX}${_line}${G__TABLE_ROW_SUFFIX}" "$_log_stack"
    lib_logging__info "$_divider_h2" "$_log_stack"

    return "$G__ERR_OK"
}

#######################################
# Calculate column widths and adjust the full-width column to fit G__TABLE_WIDTH.
#
# Arguments:
#   headers_var_name [in]: Name of array variable containing header titles.
#   rows_var_name [in]: Name of array variable containing flattened row cells.
#   col_widths_var_name [out]: Name of array variable to store column widths.
#   full_width_colx [in]: (optional) Index of column to expand (default: last column).
#
# Returns:
#   G__ERR_OK: Column widths were calculated successfully.
#   G__ERR_MISSING_ARG: Required argument was not provided.
#######################################
function _lib_utils__print_table_calc_col_widths() {
    # Constants

    # Variables
    local _headers_var_name
    local _rows_var_name
    local _col_widths_var_name
    local _full_width_colx

    local -n _headers_ref
    local -n _rows_ref
    local -n _col_widths_ref
    local _ncols
    local _ncells
    local _i
    local _colx
    local _col_width=0
    local _row_width=0
    local _col_value
    local _col_value_line
    local -a _col_value_lines=()

    # Parse and validate arguments
    [[ $# -lt 3 ]] && return "$G__ERR_MISSING_ARG"

    _headers_var_name="$1"
    _rows_var_name="$2"
    _col_widths_var_name="$3"

    _headers_ref="$_headers_var_name"
    _rows_ref="$_rows_var_name"
    _col_widths_ref="$_col_widths_var_name"

    _ncols=${#_headers_ref[@]}
    _ncells=${#_rows_ref[@]}
    _full_width_colx="${4:-$((_ncols - 1))}"

    # Function body
    _col_widths_ref=()
    [[ $_ncols -eq 0 ]] && return "$G__ERR_OK"

    # 1. Collect header lengths
    for _colx in $(seq 0 $((_ncols - 1))); do
        _col_widths_ref[_colx]=${#_headers_ref[_colx]}
    done

    # 2. Collect the maximum width of each column
    for _i in $(seq 0 $((_ncells - 1))); do
        _colx=$((_i % _ncols))

        _col_value="${_rows_ref[_i]}"

        if [[ "$_col_value" == *$'\n'* ]]; then
            mapfile -t _col_value_lines <<<"$_col_value"

            for _col_value_line in "${_col_value_lines[@]}"; do
                if [[ ${#_col_value_line} -gt ${_col_widths_ref[_colx]} ]]; then
                    _col_widths_ref[_colx]=${#_col_value_line}
                fi
            done
        elif [[ ${#_col_value} -gt ${_col_widths_ref[_colx]} ]]; then
            _col_widths_ref[_colx]=${#_col_value}
        fi
    done

    # 3. Calculate width of the entire row
    for _colx in $(seq 0 $((_ncols - 1))); do
        _col_width=${_col_widths_ref[_colx]}
        _row_width=$((_row_width + _col_width))
    done
    _row_width=$((_row_width + (_ncols - 1) * G__TABLE_COL_SEPARATOR_LEN))

    # 4. Make selected columns full width
    if [[ $_row_width -lt $G__TABLE_WIDTH ]]; then
        ((_col_widths_ref[_full_width_colx] += (G__TABLE_WIDTH - _row_width)))
    fi

    return "$G__ERR_OK"
}

#######################################
# Print a single table row, wrapping or trimming lines as needed.
#
# Arguments:
#   col_widths_var_name [in]: Name of array variable containing column widths (-w).
#   log_stack [in]: Stack depth for log output (-s).
#   col_values [in]: Values of columns in the row.
#
# Returns:
#   G__ERR_OK: Table row was printed successfully.
#   G__ERR_MISSING_ARG: Column widths variable was not provided.
#######################################
function _lib_utils__print_table_print_row() {
    # Constants

    # Variables
    local _col_widths_var_name=""
    local _log_stack=2
    local -a _col_values=()

    local -n _col_widths_ref
    local -a _col_value_lines=()
    local _nsub_rows=1
    local _line=""
    local _colx
    local _col_value
    local _rowx
    local _col_width
    local _col_value_line
    local _trimmed_width

    # Parse and validate arguments
    [[ $# -eq 0 ]] && return "$G__ERR_OK"

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -s | --stack)
            _log_stack="$2"
            shift 2
            ;;
        -w | --widths)
            _col_widths_var_name="$2"
            shift 2
            ;;
        *)
            _col_values+=("$1")
            shift
            ;;
        esac
    done

    [[ -z "$_col_widths_var_name" ]] && return "$G__ERR_MISSING_ARG"
    _col_widths_ref="$_col_widths_var_name"

    # Function body
    for _col_value in "${_col_values[@]}"; do
        if [[ "$_col_value" == *$'\n'* ]]; then
            mapfile -t _col_value_lines <<<"$_col_value"
            if [[ ${#_col_value_lines[@]} -gt $_nsub_rows ]]; then
                _nsub_rows=${#_col_value_lines[@]}
            fi
        fi
    done

    for _rowx in $(seq 0 $((_nsub_rows - 1))); do
        for _colx in "${!_col_widths_ref[@]}"; do
            _col_width="${_col_widths_ref[$_colx]}"
            _col_value="${_col_values[$_colx]}"

            mapfile -t _col_value_lines <<<"$_col_value"

            _col_value_line=""
            if [[ ${#_col_value_lines[@]} -gt $_rowx ]]; then
                _col_value_line="${_col_value_lines[$_rowx]}"
            fi

            if [[ ${#_col_value_line} -gt $_col_width ]]; then
                _trimmed_width=$((_col_width - G__TABLE_COL_SEPARATOR_LEN))
                _col_value_line="...${_col_value_line: -_trimmed_width}"
            fi

            if [[ "$_colx" -eq 0 ]]; then
                _line="$(printf "%-*s" "$_col_width" "$_col_value_line")"
            else
                _line="${_line}${G__TABLE_COL_SEPARATOR}$(printf "%-*s" "$_col_width" "$_col_value_line")"
            fi
        done

        lib_logging__info "${G__TABLE_ROW_PREFIX}${_line}${G__TABLE_ROW_SUFFIX}" "$_log_stack"
    done

    return "$G__ERR_OK"
}

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Find the maximum string length across an array of strings.
#
# Arguments:
#   items [in]: Array of string items to measure.
#
# Returns:
#   G__ERR_OK: Max length was determined successfully.
#   G__ERR_MISSING_ARG: No items were provided.
#######################################
function lib_utils__find_max_len() {
    # Constants

    # Variables
    local -a _items=()

    local _max_len=0
    local _item

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _items=("$@")

    # Function body
    for _item in "${_items[@]}"; do
        if [[ ${#_item} -gt $_max_len ]]; then
            _max_len=${#_item}
        fi
    done

    echo "$_max_len"

    return "$G__ERR_OK"
}

#######################################
# Print an ASCII table with headers, rows, and borders.
#
# Arguments:
#   summary [in]: Summary text centered at the top of the table.
#   headers_var_name [in]: Name of array variable containing header titles.
#   rows_var_name [in]: Name of array variable containing flattened row cells.
#   log_stack [in]: (optional) Stack depth for log output (default: 3).
#
# Returns:
#   G__ERR_OK: Table was printed successfully.
#   G__ERR_MISSING_ARG: Required argument was not provided.
#######################################
function lib_utils__print_table() {
    # Constants

    # Variables
    local _summary
    local _headers_var_name
    local _rows_var_name
    local _log_stack

    local -n _headers_ref
    local -n _rows_ref
    local -a _col_widths=()
    local _ncols
    local _ncells
    local _nrows=0
    local _has_header=0
    local _header
    local _rowx
    local _divider_h2
    local _divider_h3
    local _divider_h4

    # Parse and validate arguments
    [[ $# -lt 3 ]] && return "$G__ERR_MISSING_ARG"

    _summary="$1"
    _headers_var_name="$2"
    _rows_var_name="$3"
    _log_stack="${4:-3}"

    _headers_ref="$_headers_var_name"
    _rows_ref="$_rows_var_name"

    _ncols=${#_headers_ref[@]}
    _ncells=${#_rows_ref[@]}
    [[ $_ncols -gt 0 ]] && _nrows=$((_ncells / _ncols))

    # Function body
    _divider_h2="$(lib_base__gen_divider "$G__DIVIDER_H2_CHAR")"
    _divider_h3="$(lib_base__gen_divider "$G__DIVIDER_H3_CHAR")"
    _divider_h4="$(lib_base__gen_divider "$G__DIVIDER_H4_CHAR")"

    _lib_utils__print_table_summary "$_summary" "$_log_stack"
    _lib_utils__print_table_calc_col_widths "$_headers_var_name" "$_rows_var_name" "_col_widths"

    for _header in "${_headers_ref[@]}"; do
        if [[ -n "$_header" ]]; then
            _has_header=1
            break
        fi
    done

    if [[ $_has_header -ne 0 ]]; then
        _lib_utils__print_table_print_row -w "_col_widths" -s "$_log_stack" "${_headers_ref[@]}"
    fi

    for _rowx in $(seq 0 $((_nrows - 1))); do
        if [[ $_rowx -eq 0 ]]; then
            if [[ $_has_header -ne 0 ]]; then
                lib_logging__info "$_divider_h3" $((_log_stack - 1))
            fi
        else
            lib_logging__info "$_divider_h4" $((_log_stack - 1))
        fi

        _lib_utils__print_table_print_row -w "_col_widths" -s "$_log_stack" "${_rows_ref[@]:_rowx*_ncols:_ncols}"
    done
    lib_logging__info "$_divider_h2" $((_log_stack - 1))

    return "$G__ERR_OK"
}

#######################################
# Print a table with environment variables in a predefined format.
#
# Arguments:
#   summary [in]: (optional) Summary title displayed above the table.
#   var_names [in]: Additional variable names to display.
#
# Returns:
#   G__ERR_OK: Environment variables table was printed successfully.
#######################################
function lib_utils__print_env_vars() {
    # Constants
    local -a _table_headers=("Name" "Value")

    # Variables
    local -a _var_names=()
    local -a _table_rows=()
    local _log_stack=4
    local _summary=""

    local _var_name
    local _is_var
    local _is_array

    # Parse and validate arguments
    [[ $# -eq 0 ]] && return "$G__ERR_OK"

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -n | --summary)
            _summary="$2"
            shift 2
            ;;
        -s | --stack)
            _log_stack="$2"
            shift 2
            ;;
        *)
            _var_names+=("$1")
            shift
            ;;
        esac
    done

    # Function body
    for _var_name in "${_var_names[@]}"; do
        lib_base__is_var "$_var_name"
        _is_var=$?

        lib_base__is_array "$_var_name"
        _is_array=$?

        if [[ "$_is_array" -eq 0 ]]; then
            declare -n _arr_iref="$_var_name"
            _table_rows+=("$_var_name" "$(
                IFS=$'\n'
                echo "${_arr_iref[*]}"
            )")
        elif [[ "$_is_var" -eq 0 ]]; then
            _table_rows+=("$_var_name" "${!_var_name}")
        fi
    done

    lib_utils__print_table "$_summary" "_table_headers" "_table_rows" "$_log_stack"

    return "$G__ERR_OK"
}

#######################################
# Execute the given command or print it if dry-run mode is active.
#
# Arguments:
#   cmd [in]: Command string to run.
#   stdout_var_name [out]: (optional) Name of variable to store STDOUT.
#
# Returns:
#   G__ERR_OK: Command executed successfully or dry-run mode is active.
#   G__ERR_MISSING_ARG: No command was provided.
#   G__ERR_INVALID_ARG: Output variable name is invalid.
#   <exit code>: Exit code of the executed command on failure.
#######################################
function lib_utils__run_command() {
    # Constants

    # Variables
    local _cmd
    local _stdout_var_name

    local -n _stdout_ref
    local _ret_code=$G__ERR_OK

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    _cmd="$1"
    _stdout_var_name="${2:-}"

    [[ -n "$_stdout_var_name" && ! "$_stdout_var_name" =~ ^[_a-zA-Z][_a-zA-Z0-9]*$ ]] && return "$G__ERR_INVALID_ARG"

    # Function body
    if [[ -n "$_stdout_var_name" ]]; then
        _stdout_ref="$_stdout_var_name"
        _stdout_ref=""
    fi

    if [[ -z "${DRY_RUN:-}" ]]; then
        if [[ -n "$_stdout_var_name" ]]; then
            _stdout_ref="$(eval "$_cmd")"
            _ret_code=$?
        else
            eval "$_cmd"
            _ret_code=$?
        fi
    else
        lib_logging__info "Running: $_cmd" 2
        _ret_code=$?
    fi

    return "$_ret_code"
}
