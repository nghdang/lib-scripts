#!/usr/bin/env bash
#
# Source      : .ci/run-verification.sh
# Description : Validate project source against linting and formatting conventions.
#

# =============================================================================
# Global Constants
# =============================================================================
# ----- Terminal & UI Styling -----
# ANSI escape sequences for terminal output colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
WHITE=$'\033[0;37m'
NC=$'\033[0m' # No Color

# ----- Layout & Table Formatting -----
# Terminal heading dividers and line width
DIVIDER_WIDTH=80
DIVIDER_H2="$(printf "%0.s=" $(seq 1 $DIVIDER_WIDTH))"
DIVIDER_H3="$(printf "%0.s-" $(seq 1 $DIVIDER_WIDTH))"
COL_WIDTHS=(15 25)

# ----- Tool info -----
# Tool names, executable locations and versions
SHFMT_EXEC="$(command -v "shfmt" 2>/dev/null)"
SHFMT_VERSION="$("$SHFMT_EXEC" --version 2>/dev/null)"
# shellcheck disable=SC2034
SHFMT_ARGS=("-i" "4" "-d") # SHFMT_ARGS is used in TOOL_ARGS

SHELLCHECK_EXEC="$(command -v "shellcheck" 2>/dev/null)"
SHELLCHECK_VERSION="$("$SHELLCHECK_EXEC" --version | awk 'NR == 2 {print $2}' 2>/dev/null)"
# shellcheck disable=SC2034
SHELLCHECK_ARGS=() # SHELLCHECK_ARGS is used in TOOL_ARGS

CSPELL_EXEC="$(command -v "cspell" 2>/dev/null)"
CSPELL_VERSION="$("$CSPELL_EXEC" --version 2>/dev/null)"
# shellcheck disable=SC2034
CSPELL_ARGS=("--no-progress" "--no-summary") # CSPELL_ARGS is used in TOOL_ARGS

CATEGORIES=("Formatting" "Linting" "Spelling")
NCATEGORIES=${#CATEGORIES[@]}
TOOL_EXECS=("$SHFMT_EXEC" "$SHELLCHECK_EXEC" "$CSPELL_EXEC")
TOOL_VERSIONS=("$SHFMT_VERSION" "$SHELLCHECK_VERSION" "$CSPELL_VERSION")
TOOL_ARGS=("SHFMT_ARGS" "SHELLCHECK_ARGS" "CSPELL_ARGS")

# ----- Status & Results -----
SKIPPED="SKIPPED"
PASSED="PASSED"
FAILED="FAILED"

# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Private Functions
# =============================================================================
#######################################
# Helper to print preformatted row.
#
# Arguments:
#   col1_value [in]: Value of the 1st column
#   col2_value [in]: Value of the 2nd column
#   col3_value [in]: Value of the 3rd column
#######################################
function _print_row() {
    local col1_value="$1"
    local col2_value="$2"
    local col3_value="$3"

    printf '%-*s | %-*s | %-s\n' "${COL_WIDTHS[0]}" "$col1_value" "${COL_WIDTHS[1]}" "$col2_value" "$col3_value"
}

# =============================================================================
# Entry Point
# =============================================================================
#######################################
# Main function.
#
# Arguments:
#   file_path [in]: Path of the source file to verify
#######################################
function main() {
    set -u

    local _file_path="$1"

    local _idx
    local _category
    local _tool_exec
    local -a _tool_results=()
    local -a _tool_stdouts=()

    # 1. Validate inputs
    if [[ ! -f "$_file_path" ]]; then
        echo -e "${RED}>> No such file or directory: ${_file_path}${NC}"
    fi

    for _idx in $(seq 0 $((NCATEGORIES - 1))); do
        _tool_exec="${TOOL_EXECS[$_idx]}"
        local -n _tool_args_ref="${TOOL_ARGS[$_idx]}"

        if [[ -z "$_tool_exec" ]]; then
            _tool_results[_idx]="${YELLOW}${SKIPPED} (Tool was not installed)${NC}"
        else
            cmd="\"$_tool_exec\" ${_tool_args_ref[*]} \"$_file_path\""

            _tool_stdouts[_idx]="$(eval "$cmd")"
            if [[ -z "${_tool_stdouts[$_idx]}" ]]; then
                _tool_results[_idx]="${GREEN}${PASSED}${NC}"
            else
                _tool_results[_idx]="${RED}${FAILED}${NC}"
            fi
        fi
    done

    echo -e "$DIVIDER_H2"
    echo -e "${CYAN}>> '${_file_path}'${NC}"
    echo -e "$DIVIDER_H2"

    _print_row "Category" "Tool" "Result"
    echo -e "$DIVIDER_H3"

    for _idx in $(seq 0 $((NCATEGORIES - 1))); do
        _category="${CATEGORIES[$_idx]}"
        _tool_exec="${TOOL_EXECS[$_idx]}"
        _tool_version="${TOOL_VERSIONS[$_idx]}"

        _print_row "$_category" "$(basename "$_tool_exec") ($_tool_version)" "${_tool_results[$_idx]}"

        if [[ "$_idx" -eq $((NCATEGORIES - 1)) ]]; then
            echo -e "$DIVIDER_H2"
        else
            echo -e "$DIVIDER_H3"
        fi
    done

    for _idx in $(seq 0 $((NCATEGORIES - 1))); do
        local -a _lines=()

        _category="${CATEGORIES[$_idx]}"

        if [[ -z "${_tool_stdouts[$_idx]}" ]]; then
            continue
        fi

        echo -e ""
        echo -e "${YELLOW}>> ${_category}${NC}"

        mapfile -t _lines <<<"${_tool_stdouts[$_idx]}"
        for _line in "${_lines[@]}"; do
            echo -e "  ${WHITE}${_line}${NC}"
        done
    done

}

main "$@"
