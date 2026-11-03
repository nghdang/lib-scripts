#!/usr/bin/env bash
#
# Source      : .ci/run-verification2.sh
# Dependencies: None
# Description : Validate project source against linting and formatting conventions.
#
# cspell:ignore tmpl

# ----- Source Guard -----
[[ -n "${G__RUN_VERIFICATION2_SH_LOADED:-}" ]] && return 0
export G__RUN_VERIFICATION2_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====

# ----- Terminal & UI Styling -----
# ANSI escape sequences for terminal output colors
readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[0;33m'
readonly CYAN=$'\033[0;36m'
readonly WHITE=$'\033[0;37m'
readonly NC=$'\033[0m' # No Color

# ----- Layout & Table Formatting -----
# Terminal heading dividers and default line width
readonly DIVIDER_WIDTH=80

# ----- Tool Info -----
# Tool names, executable locations and versions
SHFMT_EXEC="$(command -v "shfmt" 2>/dev/null)"
readonly SHFMT_EXEC

SHFMT_VERSION="$("$SHFMT_EXEC" --version 2>/dev/null)"
readonly SHFMT_VERSION

# shellcheck disable=SC2034
readonly SHFMT_ARGS=("-i" "4" "-d") # SHFMT_ARGS is used in TOOL_ARGS

SHELLCHECK_EXEC="$(command -v "shellcheck" 2>/dev/null)"
readonly SHELLCHECK_EXEC

SHELLCHECK_VERSION="$("$SHELLCHECK_EXEC" --version | awk 'NR == 2 {print $2}' 2>/dev/null)"
readonly SHELLCHECK_VERSION

# shellcheck disable=SC2034
readonly SHELLCHECK_ARGS=() # SHELLCHECK_ARGS is used in TOOL_ARGS

CSPELL_EXEC="$(command -v "cspell" 2>/dev/null)"
readonly CSPELL_EXEC

CSPELL_VERSION="$("$CSPELL_EXEC" --version 2>/dev/null)"
readonly CSPELL_VERSION

# shellcheck disable=SC2034
readonly CSPELL_ARGS=("--no-progress" "--no-summary") # CSPELL_ARGS is used in TOOL_ARGS

readonly CATEGORIES=("Formatting" "Linting" "Spelling")
readonly TOOL_NAMES=("shfmt" "shellcheck" "cspell")
readonly NUM_TOOLS=${#TOOL_NAMES[@]}
readonly TOOL_EXECS=("$SHFMT_EXEC" "$SHELLCHECK_EXEC" "$CSPELL_EXEC")
readonly TOOL_VERSIONS=("$SHFMT_VERSION" "$SHELLCHECK_VERSION" "$CSPELL_VERSION")
readonly TOOL_ARGS=("SHFMT_ARGS" "SHELLCHECK_ARGS" "CSPELL_ARGS")

# ----- Status & Results -----
readonly SKIPPED="SKIPPED"
readonly PASSED="PASSED"
readonly FAILED="FAILED"

# ----- Error Codes -----
readonly G__ERR_OK=0
readonly G__ERR_NOT_OK=255
readonly G__ERR_MISSING_ARG=1

# =============================================================================
# Global Variables
# =============================================================================

# ===== Project Scope =====

# ===== File Scope =====

# =============================================================================
# Private Functions
# =============================================================================

#######################################
# Collect source and test files from target paths.
#
# Arguments:
#   target_paths_var_name [in]: Name of array variable containing input paths.
#   files_var_name [out]: Name of array variable to store collected file paths.
#
# Returns:
#   G__ERR_OK: Target files were collected successfully.
#   G__ERR_MISSING_ARG: Required argument was not provided.
#######################################
function _run_verification2__collect_files() {
    # Constants

    # Variables
    local _target_paths_var_name
    local _files_var_name

    local -n _target_paths_ref
    local -n _files_ref
    local -A _seen_files=()
    local _target
    local _norm_file
    local _found_file
    local -a _found_files=()

    # Parse and validate arguments
    [[ $# -lt 2 ]] && return "$G__ERR_MISSING_ARG"

    _target_paths_var_name="$1"
    _files_var_name="$2"

    _target_paths_ref="$_target_paths_var_name"
    _files_ref="$_files_var_name"

    # Function body
    for _target in "${_target_paths_ref[@]}"; do
        if [[ -f "$_target" ]]; then
            _norm_file="${_target#./}"
            if [[ -z "${_seen_files[$_norm_file]:-}" ]]; then
                _seen_files["$_norm_file"]=1
                _files_ref+=("$_norm_file")
            fi
        elif [[ -d "$_target" ]]; then
            _found_files=()
            mapfile -t _found_files < <(find "$_target" -type f \( -name "*.sh" -o -name "*.sh.tmpl" \) -not -path "*/.git/*" | sort)
            for _found_file in "${_found_files[@]}"; do
                [[ -z "$_found_file" ]] && continue
                _norm_file="${_found_file#./}"
                if [[ -z "${_seen_files[$_norm_file]:-}" ]]; then
                    _seen_files["$_norm_file"]=1
                    _files_ref+=("$_norm_file")
                fi
            done
        else
            echo -e "${RED}>> No such file or directory: ${_target}${NC}" >&2
        fi
    done

    return "$G__ERR_OK"
}

#######################################
# Execute verification tools on each collected file.
#
# Arguments:
#   files_var_name [in]: Name of array variable containing files to verify.
#   results_var_name [out]: Name of associative array variable for tool results.
#   outputs_var_name [out]: Name of associative array variable for tool outputs.
#   failures_var_name [out]: Name of array variable for file failure flags.
#
# Returns:
#   G__ERR_OK: Tools were executed on all files successfully.
#   G__ERR_MISSING_ARG: Required argument was not provided.
#######################################
function _run_verification2__execute_tools() {
    # Constants

    # Variables
    local _files_var_name
    local _results_var_name
    local _outputs_var_name
    local _failures_var_name

    local -n _files_ref
    local -n _results_ref
    local -n _outputs_ref
    local -n _failures_ref
    local _file_idx
    local _file_path
    local _tool_idx
    local _tool_exec
    local _output
    local _exit_code

    # Parse and validate arguments
    [[ $# -lt 4 ]] && return "$G__ERR_MISSING_ARG"

    _files_var_name="$1"
    _results_var_name="$2"
    _outputs_var_name="$3"
    _failures_var_name="$4"

    _files_ref="$_files_var_name"
    _results_ref="$_results_var_name"
    _outputs_ref="$_outputs_var_name"
    _failures_ref="$_failures_var_name"

    # Function body
    for _file_idx in "${!_files_ref[@]}"; do
        _file_path="${_files_ref[$_file_idx]}"
        _failures_ref[_file_idx]=0

        for _tool_idx in $(seq 0 $((NUM_TOOLS - 1))); do
            _tool_exec="${TOOL_EXECS[$_tool_idx]}"
            local -n _tool_args_ref="${TOOL_ARGS[$_tool_idx]}"

            if [[ -z "$_tool_exec" ]]; then
                _results_ref["${_file_idx},${_tool_idx}"]="$SKIPPED"
                _outputs_ref["${_file_idx},${_tool_idx}"]=""
            else
                _output=""
                _exit_code=0
                _output="$("$_tool_exec" "${_tool_args_ref[@]}" "$_file_path" 2>&1)" || _exit_code=$?

                if [[ $_exit_code -eq 0 && -z "$_output" ]]; then
                    _results_ref["${_file_idx},${_tool_idx}"]="$PASSED"
                    _outputs_ref["${_file_idx},${_tool_idx}"]=""
                else
                    _results_ref["${_file_idx},${_tool_idx}"]="$FAILED"
                    _outputs_ref["${_file_idx},${_tool_idx}"]="$_output"
                    _failures_ref[_file_idx]=1
                fi
            fi
        done
    done

    return "$G__ERR_OK"
}

#######################################
# Print the summary results table for all verified files.
#
# Arguments:
#   files_var_name [in]: Name of array variable containing files.
#   results_var_name [in]: Name of associative array variable containing results.
#
# Returns:
#   G__ERR_OK: Summary table was printed successfully.
#   G__ERR_MISSING_ARG: Required argument was not provided.
#######################################
function _run_verification2__print_summary_table() {
    # Constants

    # Variables
    local _files_var_name
    local _results_var_name

    local -n _files_ref
    local -n _results_ref
    local _num_files
    local _col_no_width=3
    local -a _tool_headers=()
    local -a _tool_col_widths=()
    local _prefix_width
    local _tool_idx
    local _tool_header
    local _col_w
    local _header_line
    local -a _row_lines=()
    local _max_file_len=4
    local _file_idx
    local _file_path
    local _row_num
    local _row_line
    local _res
    local _color
    local _pad_len
    local _cell
    local _max_row_width
    local _divider_len
    local _divider

    # Parse and validate arguments
    [[ $# -lt 2 ]] && return "$G__ERR_MISSING_ARG"

    _files_var_name="$1"
    _results_var_name="$2"

    _files_ref="$_files_var_name"
    _results_ref="$_results_var_name"

    # Function body
    _num_files=${#_files_ref[@]}
    if [[ ${#_num_files} -gt $_col_no_width ]]; then
        _col_no_width=${#_num_files}
    fi

    _prefix_width=$((_col_no_width + 3))

    for _tool_idx in $(seq 0 $((NUM_TOOLS - 1))); do
        if [[ -n "${TOOL_VERSIONS[$_tool_idx]}" ]]; then
            _tool_header="${TOOL_NAMES[$_tool_idx]} (${TOOL_VERSIONS[$_tool_idx]})"
        else
            _tool_header="${TOOL_NAMES[$_tool_idx]}"
        fi
        _tool_headers[_tool_idx]="$_tool_header"

        _col_w=${#_tool_header}
        if [[ $_col_w -lt 7 ]]; then
            _col_w=7
        fi
        _tool_col_widths[_tool_idx]=$_col_w
        _prefix_width=$((_prefix_width + _col_w + 3))
    done

    _header_line="$(printf "%-*s | " "$_col_no_width" "No.")"
    for _tool_idx in $(seq 0 $((NUM_TOOLS - 1))); do
        _header_line="${_header_line}$(printf "%-*s | " "${_tool_col_widths[$_tool_idx]}" "${_tool_headers[$_tool_idx]}")"
    done
    _header_line="${_header_line}File"

    for _file_idx in "${!_files_ref[@]}"; do
        _file_path="${_files_ref[$_file_idx]}"
        if [[ ${#_file_path} -gt $_max_file_len ]]; then
            _max_file_len=${#_file_path}
        fi

        _row_num=$((_file_idx + 1))
        _row_line="$(printf "%-*s | " "$_col_no_width" "$_row_num")"

        for _tool_idx in $(seq 0 $((NUM_TOOLS - 1))); do
            _res="${_results_ref["${_file_idx},${_tool_idx}"]}"
            _color="$NC"
            if [[ "$_res" == "$PASSED" ]]; then
                _color="$GREEN"
            elif [[ "$_res" == "$FAILED" ]]; then
                _color="$RED"
            elif [[ "$_res" == "$SKIPPED" ]]; then
                _color="$YELLOW"
            fi

            _pad_len=$((_tool_col_widths[_tool_idx] - ${#_res}))
            _cell="$(printf "${_color}%s${NC}%*s | " "$_res" "$_pad_len" "")"
            _row_line="${_row_line}${_cell}"
        done
        _row_line="${_row_line}${_file_path}"
        _row_lines+=("$_row_line")
    done

    _max_row_width=$((_prefix_width + _max_file_len))
    _divider_len=$DIVIDER_WIDTH
    if [[ $_max_row_width -gt $_divider_len ]]; then
        _divider_len=$_max_row_width
    fi
    _divider="$(printf "%0.s=" $(seq 1 "$_divider_len"))"

    echo -e "$_divider"
    echo -e "$_header_line"
    echo -e "$_divider"
    for _file_idx in "${!_files_ref[@]}"; do
        echo -e "${_row_lines[$_file_idx]}"
    done
    echo -e "$_divider"

    return "$G__ERR_OK"
}

#######################################
# Print detailed failure outputs grouped by file.
#
# Arguments:
#   files_var_name [in]: Name of array variable containing files.
#   outputs_var_name [in]: Name of associative array variable containing tool outputs.
#   failures_var_name [in]: Name of array variable containing failure flags.
#
# Returns:
#   G__ERR_OK: Failure details were printed successfully.
#   G__ERR_MISSING_ARG: Required argument was not provided.
#######################################
function _run_verification2__print_failure_details() {
    # Constants

    # Variables
    local _files_var_name
    local _outputs_var_name
    local _failures_var_name

    local -n _files_ref
    local -n _outputs_ref
    local -n _failures_ref
    local _file_idx
    local _file_path
    local _tool_idx
    local _output
    local _category
    local -a _lines=()
    local _line

    # Parse and validate arguments
    [[ $# -lt 3 ]] && return "$G__ERR_MISSING_ARG"

    _files_var_name="$1"
    _outputs_var_name="$2"
    _failures_var_name="$3"

    _files_ref="$_files_var_name"
    _outputs_ref="$_outputs_var_name"
    _failures_ref="$_failures_var_name"

    # Function body
    for _file_idx in "${!_files_ref[@]}"; do
        if [[ ${_failures_ref[$_file_idx]} -eq 0 ]]; then
            continue
        fi

        _file_path="${_files_ref[$_file_idx]}"
        echo -e ""
        echo -e "${CYAN}>> '${_file_path}'${NC}"

        for _tool_idx in $(seq 0 $((NUM_TOOLS - 1))); do
            _output="${_outputs_ref["${_file_idx},${_tool_idx}"]}"
            if [[ -z "$_output" ]]; then
                continue
            fi

            _category="${CATEGORIES[$_tool_idx]}"
            echo -e "${YELLOW}>> ${_category}${NC}"

            _lines=()
            mapfile -t _lines <<<"$_output"
            for _line in "${_lines[@]}"; do
                echo -e "  ${WHITE}${_line}${NC}"
            done
        done
    done

    return "$G__ERR_OK"
}

# =============================================================================
# Public Functions
# =============================================================================

# =============================================================================
# Entry Point
# =============================================================================
#######################################
# Entry point for the verification pipeline.
#
# Arguments:
#   Paths of source files or directories to verify (optional).
#   Defaults to 'src' and 'test' if omitted.
#
# Returns:
#   G__ERR_OK: Verification pipeline completed successfully.
#######################################
function main() {
    set -u

    # Constants

    # Variables
    local -a _target_paths=("$@")

    local -a _files=()
    local -A _results=()
    local -A _outputs=()
    local -a _has_failure=()

    # Parse and validate arguments
    if [[ ${#_target_paths[@]} -eq 0 ]]; then
        _target_paths=("src" "test")
    fi

    # Function body
    _run_verification2__collect_files "_target_paths" "_files"
    if [[ ${#_files[@]} -eq 0 ]]; then
        return "$G__ERR_OK"
    fi

    _run_verification2__execute_tools "_files" "_results" "_outputs" "_has_failure"
    _run_verification2__print_summary_table "_files" "_results"
    _run_verification2__print_failure_details "_files" "_outputs" "_has_failure"

    for _file_idx in "${!_has_failure[@]}"; do
        if [[ ${_has_failure[$_file_idx]} -ne 0 ]]; then
            return "$G__ERR_NOT_OK"
        fi
    done

    return "$G__ERR_OK"
}

main "$@"
