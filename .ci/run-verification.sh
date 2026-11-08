#!/usr/bin/env bash
#
# Source      : <source-script.sh>
# Dependencies: <dependency-script-1.sh>
#               <dependency-script-2.sh>
# Description : <source-script.sh description>
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__RUN_VERIFICATION_SH_LOADED:-}" ]] && return 0
declare -gr G__RUN_VERIFICATION_SH_LOADED=1

# ===== Source Dependencies =====
PROJECT_DIR="$(realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..")"
readonly PROJECT_DIR

# shellcheck disable=SC1090,SC1091
source "${PROJECT_DIR}/src/lib-base.sh"
# shellcheck disable=SC1090,SC1091
source "${PROJECT_DIR}/src/lib-validation.sh"
# shellcheck disable=SC1090,SC1091
source "${PROJECT_DIR}/src/lib-assertion.sh"
# shellcheck disable=SC1090,SC1091
source "${PROJECT_DIR}/src/lib-layout.sh"

# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# _run_verification__refine_targets     p01
# _run_verification__collect_files      p02
# _run_verification__generate_report    p03
# _run_verification__check_formatting   p04
# _run_verification__check_linting      p05
# _run_verification__check_spelling     p06
# _run_verification__check_testing      p07
# run_verification__main                i01
# -----------------------------------------

# ==================================================================================================
# Global Constants
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====
RESULT_PASSED="${G__COLOR_GREEN}PASSED${G__COLOR_RESET}"
RESULT_FAILED="${G__COLOR_RED}FAILED${G__COLOR_RESET}"
RESULT_SKIPPED="${G__COLOR_YELLOW}SKIPPED${G__COLOR_RESET}"

# ==================================================================================================
# Global Variables
# ==================================================================================================

# ===== Project Scope =====

# ===== File Scope =====

# ==================================================================================================
# Private Functions
# ==================================================================================================
#######################################
# Remove invalid and duplicate targets from the input.
#
# Arguments:
#   refined_targets_ref [out]: Name of array to store refined targets.
#   input_targets_ref    [in]: Name of array that contains input targets.
#
# Returns:
#   G__ERR_OK: Targets were refined successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given variables is not an indexed array.
#######################################
function _run_verification__refine_targets() {
    # Constants

    # Parameters
    local -n _run_verification_p01__refined_targets_ref
    local -n _run_verification_p01__input_targets_ref

    # Variables
    local _run_verification_p01__target

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "2"

    _run_verification_p01__refined_targets_ref="$1"
    _run_verification_p01__input_targets_ref="$2"

    lib_assertion__assert_var_name "${!_run_verification_p01__refined_targets_ref}"
    lib_assertion__assert_array "${!_run_verification_p01__refined_targets_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p01__input_targets_ref}"
    lib_assertion__assert_array "${!_run_verification_p01__input_targets_ref}"

    # Function body
    if [[ "${#_run_verification_i01__input_targets[@]}" -eq "0" ]]; then
        _run_verification_p01__refined_targets_ref=("${_RUN_VERIFICATION_I01__DEFAULT_TARGETS[@]}")
        return "$G__ERR_OK"
    fi

    _run_verification_p01__refined_targets_ref=()

    for _run_verification_p01__target in "${_run_verification_p01__input_targets_ref[@]}"; do
        local _run_verification_p01__target_refined

        # 1. Skip refined targets
        lib_validation__is_in "${!_run_verification_p01__refined_targets_ref}" "$_run_verification_p01__target"
        _run_verification_p01__target_refined="$?"

        if [[ "$_run_verification_p01__target_refined" -eq "$G__ERR_OK" ]]; then
            continue
        fi

        # 2. Skip non-existence targets
        if [[ ! -f "$_run_verification_p01__target" ]] &&
            [[ ! -d "$_run_verification_p01__target" ]]; then
            continue
        fi

        _run_verification_p01__refined_targets_ref+=("$(realpath "$_run_verification_p01__target")")
    done

    return "$G__ERR_OK"
}

#######################################
# Collect source and test files from target paths.
#
# Arguments:
#   files_ref  [out]: Name of array to store collected file paths.
#   targets_ref [in]: Name of array that contains refined targets.
#
# Returns:
#   G__ERR_OK: Target files were collected successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given variables is not an indexed array.
#######################################
function _run_verification__collect_files() {
    # Constants

    # Parameters
    local -n _run_verification_p02__files_ref
    local -n _run_verification_p02__targets_ref

    # Variables
    local _run_verification_p02__target

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "2"

    _run_verification_p02__files_ref="$1"
    _run_verification_p02__targets_ref="$2"

    lib_assertion__assert_var_name "${!_run_verification_p02__files_ref}"
    lib_assertion__assert_array "${!_run_verification_p02__files_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p02__targets_ref}"
    lib_assertion__assert_array "${!_run_verification_p02__targets_ref}"

    # Function body
    for _run_verification_p02__target in "${_run_verification_p02__targets_ref[@]}"; do
        local -a _run_verification_p02__target_files=()

        echo "Collecting files of target '$_run_verification_p02__target'"
        mapfile -t "_run_verification_p02__target_files" <<<"$(find "$_run_verification_p02__target" -type f -name "*.sh")"

        if [[ "${#_run_verification_p02__target_files[@]}" -eq "1" ]] && [[ -z "${_run_verification_p02__target_files[0]}" ]]; then
            _run_verification_p02__target_files=()
        fi

        echo "Collected ${#_run_verification_p02__target_files[@]} files from target '$_run_verification_p02__target'"
        _run_verification_p02__files_ref+=("${_run_verification_p02__target_files[@]}")
    done

    return "$G__ERR_OK"
}

#######################################
# Generate the summary report for all verified files.
#
# Arguments:
#   files_ref              [in]: Name of array that contains collected file paths.
#   formatting_results_ref [in]: Name of array that contains formatting results.
#   linting_results_ref    [in]: Name of array that contains linting results.
#   spelling_results_ref   [in]: Name of array that contains spelling results.
#   testing_results_ref    [in]: Name of array that contains testing results.
#
# Returns:
#   G__ERR_OK: Summary report were generated successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 5 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 5 arguments were provided.
#   G__ERR_TYPE_ERROR: The given variables is not an indexed array.
#######################################
function _run_verification__generate_report() {
    # Constants

    # Parameters
    local -n _run_verification_p03__files_ref
    local -n _run_verification_p03__formatting_results_ref
    local -n _run_verification_p03__linting_results_ref
    local -n _run_verification_p03__spelling_results_ref
    local -n _run_verification_p03__testing_results_ref

    # Variables
    local -a _run_verification_p03__result_table_headers=()
    local _run_verification_p03__result_table_ncols
    local -a _run_verification_p03__result_table_column_widths=()
    local _run_verification_p03__idx
    local -a _run_verification_p03__result_table_cells=()
    local _run_verification_p03__result_table

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "5" "5"

    _run_verification_p03__files_ref="$1"
    _run_verification_p03__formatting_results_ref="$2"
    _run_verification_p03__linting_results_ref="$3"
    _run_verification_p03__spelling_results_ref="$4"
    _run_verification_p03__testing_results_ref="$5"

    lib_assertion__assert_var_name "${!_run_verification_p03__files_ref}"
    lib_assertion__assert_array "${!_run_verification_p03__files_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p03__formatting_results_ref}"
    lib_assertion__assert_array "${!_run_verification_p03__formatting_results_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p03__linting_results_ref}"
    lib_assertion__assert_array "${!_run_verification_p03__linting_results_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p03__spelling_results_ref}"
    lib_assertion__assert_array "${!_run_verification_p03__spelling_results_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p03__testing_results_ref}"
    lib_assertion__assert_array "${!_run_verification_p03__testing_results_ref}"

    # Function body
    _run_verification_p03__result_table_headers=("No.")
    _run_verification_p03__result_table_column_widths=("3")

    if [[ "${#_run_verification_p03__formatting_results_ref[@]}" -gt "0" ]]; then
        _run_verification_p03__result_table_headers+=("Formatting")
        _run_verification_p03__result_table_column_widths+=("10")
    fi

    if [[ "${#_run_verification_p03__linting_results_ref[@]}" -gt "0" ]]; then
        _run_verification_p03__result_table_headers+=("Linting")
        _run_verification_p03__result_table_column_widths+=("10")
    fi

    if [[ "${#_run_verification_p03__spelling_results_ref[@]}" -gt "0" ]]; then
        _run_verification_p03__result_table_headers+=("Spelling")
        _run_verification_p03__result_table_column_widths+=("10")
    fi

    if [[ "${#_run_verification_p03__testing_results_ref[@]}" -gt "0" ]]; then
        _run_verification_p03__result_table_headers+=("Testing")
        _run_verification_p03__result_table_column_widths+=("10")
    fi

    _run_verification_p03__result_table_headers+=("File")
    _run_verification_p03__result_table_column_widths+=("-1")

    _run_verification_p03__result_table_ncols="${#_run_verification_p03__result_table_headers[@]}"

    _run_verification_p03__result_table_cells=("${_run_verification_p03__result_table_headers[@]}")

    for _run_verification_p03__idx in "${!_run_verification_p03__files_ref[@]}"; do
        _run_verification_p03__result_table_cells+=("$((_run_verification_p03__idx + 1))")

        if [[ "${#_run_verification_p03__formatting_results_ref[@]}" -gt "0" ]]; then
            _run_verification_p03__result_table_cells+=("${_run_verification_p03__formatting_results_ref[$_run_verification_p03__idx]}")
        fi

        if [[ "${#_run_verification_p03__linting_results_ref[@]}" -gt "0" ]]; then
            _run_verification_p03__result_table_cells+=("${_run_verification_p03__linting_results_ref[$_run_verification_p03__idx]}")
        fi

        if [[ "${#_run_verification_p03__spelling_results_ref[@]}" -gt "0" ]]; then
            _run_verification_p03__result_table_cells+=("${_run_verification_p03__spelling_results_ref[$_run_verification_p03__idx]}")
        fi

        if [[ "${#_run_verification_p03__testing_results_ref[@]}" -gt "0" ]]; then
            _run_verification_p03__result_table_cells+=("${_run_verification_p03__testing_results_ref[$_run_verification_p03__idx]}")
        fi

        _run_verification_p03__result_table_cells+=("${_run_verification_p03__files_ref[$_run_verification_p03__idx]}")
    done

    lib_layout__draw_table "_run_verification_p03__result_table" "$_run_verification_p03__result_table_ncols" "_run_verification_p03__result_table_cells" "CI Verification Results" "_run_verification_p03__result_table_column_widths"

    echo -e "$_run_verification_p03__result_table"

    return "$G__ERR_OK"
}

#######################################
# Check formatting of collected files.
#
# Arguments:
#   results_ref [out]: Name of array to store formatting check results.
#   files_ref    [in]: Name of array that contains files to check.
#
# Returns:
#   G__ERR_OK: Formatting check completed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given variables is not an indexed array.
#######################################
function _run_verification__check_formatting() {
    # Constants

    # Parameters
    local -n _run_verification_p04__results_ref
    local -n _run_verification_p04__files_ref

    # Variables
    local _run_verification_p04__tool_exec
    local _run_verification_p04__tool_version
    local _run_verification_p04__file

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "2"

    _run_verification_p04__results_ref="$1"
    _run_verification_p04__files_ref="$2"

    lib_assertion__assert_var_name "${!_run_verification_p04__results_ref}"
    lib_assertion__assert_array "${!_run_verification_p04__results_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p04__files_ref}"
    lib_assertion__assert_array "${!_run_verification_p04__files_ref}"

    # Function body
    _run_verification_p04__tool_exec="$(command -v "shfmt" 2>/dev/null)"
    if [[ -z "$_run_verification_p04__tool_exec" ]]; then
        echo -e "${G__COLOR_RED}Failed to check formatting: shfmt is not installed or accessible${G__COLOR_RESET}"
        return "$G__ERR_NOT_OK"
    fi

    _run_verification_p04__tool_version="$("$_run_verification_p04__tool_exec" --version 2>/dev/null)"

    echo "Checking formatting with 'shfmt (${_run_verification_p04__tool_version})': '$_run_verification_p04__tool_exec'"

    for _run_verification_p04__file in "${_run_verification_p04__files_ref[@]}"; do
        local _run_verification_p04__result="$RESULT_PASSED"

        "$_run_verification_p04__tool_exec" -i 4 -d "$_run_verification_p04__file" || _run_verification_p04__result="$RESULT_FAILED"

        # awk 'length($0) > 100 {print NR ":" $0; found = 1} END { exit found }' "$_run_verification_p04__file" || _run_verification_p04__result="$RESULT_FAILED"

        echo "  - $_run_verification_p04__file: '$_run_verification_p04__result'"
        _run_verification_p04__results_ref+=("$_run_verification_p04__result")
    done

    return "$G__ERR_OK"
}

#######################################
# Check linting of collected files.
#
# Arguments:
#   results_ref [out]: Name of array to store linting check results.
#   files_ref    [in]: Name of array that contains files to check.
#
# Returns:
#   G__ERR_OK: Linting check completed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given variables is not an indexed array.
#######################################
function _run_verification__check_linting() {
    # Constants

    # Parameters
    local -n _run_verification_p05__results_ref
    local -n _run_verification_p05__files_ref

    # Variables
    local _run_verification_p05__tool_exec
    local _run_verification_p05__tool_version
    local _run_verification_p05__file

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "2"

    _run_verification_p05__results_ref="$1"
    _run_verification_p05__files_ref="$2"

    lib_assertion__assert_var_name "${!_run_verification_p05__results_ref}"
    lib_assertion__assert_array "${!_run_verification_p05__results_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p05__files_ref}"
    lib_assertion__assert_array "${!_run_verification_p05__files_ref}"

    # Function body
    _run_verification_p05__tool_exec="$(command -v "shellcheck" 2>/dev/null)"
    if [[ -z "$_run_verification_p05__tool_exec" ]]; then
        echo -e "${G__COLOR_RED}Failed to check linting: shellcheck is not installed or accessible${G__COLOR_RESET}"
        return "$G__ERR_NOT_OK"
    fi

    _run_verification_p05__tool_version="$("$_run_verification_p05__tool_exec" --version | awk 'NR == 2 {print $2}' 2>/dev/null)"

    echo "Checking linting with 'shellcheck (${_run_verification_p05__tool_version})': '$_run_verification_p05__tool_exec'"

    for _run_verification_p05__file in "${_run_verification_p05__files_ref[@]}"; do
        local _run_verification_p05__result="$RESULT_PASSED"

        "$_run_verification_p05__tool_exec" "$_run_verification_p05__file" || _run_verification_p05__result="$RESULT_FAILED"

        echo "  - $_run_verification_p05__file: '$_run_verification_p05__result'"
        _run_verification_p05__results_ref+=("$_run_verification_p05__result")
    done

    return "$G__ERR_OK"
}

#######################################
# Check spelling of collected files.
#
# Arguments:
#   results_ref [out]: Name of array to store spelling check results.
#   files_ref    [in]: Name of array that contains files to check.
#
# Returns:
#   G__ERR_OK: Spelling check completed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given variables is not an indexed array.
#######################################
function _run_verification__check_spelling() {
    # Constants

    # Parameters
    local -n _run_verification_p06__results_ref
    local -n _run_verification_p06__files_ref

    # Variables
    local _run_verification_p06__tool_exec
    local _run_verification_p06__tool_version
    local _run_verification_p06__file

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "2"

    _run_verification_p06__results_ref="$1"
    _run_verification_p06__files_ref="$2"

    lib_assertion__assert_var_name "${!_run_verification_p06__results_ref}"
    lib_assertion__assert_array "${!_run_verification_p06__results_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p06__files_ref}"
    lib_assertion__assert_array "${!_run_verification_p06__files_ref}"

    # Function body
    _run_verification_p06__tool_exec="$(command -v "cspell" 2>/dev/null)"
    if [[ -z "$_run_verification_p06__tool_exec" ]]; then
        echo -e "${G__COLOR_RED}Failed to check spelling: cspell is not installed or accessible${G__COLOR_RESET}"
        return "$G__ERR_NOT_OK"
    fi

    _run_verification_p06__tool_version="$("$_run_verification_p06__tool_exec" --version 2>/dev/null)"

    echo "Checking spelling with 'cspell (${_run_verification_p06__tool_version})': '$_run_verification_p06__tool_exec'"

    for _run_verification_p06__file in "${_run_verification_p06__files_ref[@]}"; do
        local _run_verification_p06__result="$RESULT_PASSED"

        "$_run_verification_p06__tool_exec" "$_run_verification_p06__file" || _run_verification_p06__result="$RESULT_FAILED"

        echo "  - $_run_verification_p06__file: '$_run_verification_p06__result'"
        _run_verification_p06__results_ref+=("$_run_verification_p06__result")
    done

    return "$G__ERR_OK"
}

#######################################
# Check testing of collected files.
#
# Arguments:
#   results_ref [out]: Name of array to store testing check results.
#   files_ref    [in]: Name of array that contains files to check.
#
# Returns:
#   G__ERR_OK: Testing check completed successfully.
#
# Exits:
#   G__ERR_MISSING_ARG: Fewer than 2 arguments were provided.
#   G__ERR_TOO_MANY_ARGS: More than 2 arguments were provided.
#   G__ERR_TYPE_ERROR: The given variables is not an indexed array.
#######################################
function _run_verification__check_testing() {
    # Constants

    # Parameters
    local -n _run_verification_p07__results_ref
    local -n _run_verification_p07__files_ref

    # Variables
    local _run_verification_p07__tool_exec
    local _run_verification_p07__tool_version
    local _run_verification_p07__file

    # Parse and validate arguments
    lib_assertion__assert_args_count "$#" "2" "2"

    _run_verification_p07__results_ref="$1"
    _run_verification_p07__files_ref="$2"

    lib_assertion__assert_var_name "${!_run_verification_p07__results_ref}"
    lib_assertion__assert_array "${!_run_verification_p07__results_ref}"

    lib_assertion__assert_var_name "${!_run_verification_p07__files_ref}"
    lib_assertion__assert_array "${!_run_verification_p07__files_ref}"

    # Function body
    _run_verification_p07__tool_exec="$(command -v "bash" 2>/dev/null)"
    if [[ -z "$_run_verification_p07__tool_exec" ]]; then
        echo -e "${G__COLOR_RED}Failed to check testing: bash is not installed or accessible${G__COLOR_RESET}"
        return "$G__ERR_NOT_OK"
    fi

    _run_verification_p07__tool_version="$("$_run_verification_p07__tool_exec" --version | awk 'NR == 1 {print $4}' 2>/dev/null)"

    echo "Checking testing with 'bash (${_run_verification_p07__tool_version})': '$_run_verification_p07__tool_exec'"

    for _run_verification_p07__file in "${_run_verification_p07__files_ref[@]}"; do
        local _run_verification_p07__file_name
        local _run_verification_p07__common_dir
        local _run_verification_p07__test_file
        local _run_verification_p07__result="$RESULT_PASSED"

        _run_verification_p07__file_name="$(basename "$_run_verification_p07__file")"
        _run_verification_p07__common_dir="$(dirname "$(dirname "$_run_verification_p07__file")")"
        _run_verification_p07__test_file="$(find "$_run_verification_p07__common_dir" -type f -name "test-${_run_verification_p07__file_name}")"

        if [[ -z "$_run_verification_p07__test_file" ]]; then
            _run_verification_p07__result="$RESULT_SKIPPED"
        else
            "$_run_verification_p07__tool_exec" "$_run_verification_p07__test_file" || _run_verification_p07__result="$RESULT_FAILED"
        fi

        echo "  - $_run_verification_p07__file: '$_run_verification_p07__result'"
        _run_verification_p07__results_ref+=("$_run_verification_p07__result")
    done

    return "$G__ERR_OK"
}

# ==================================================================================================
# Public Functions
# ==================================================================================================

# ==================================================================================================
# Entry Point
# ==================================================================================================
#######################################
# Entry point for the verification pipeline.
#
# Arguments:
#   Paths of source files or directories to verify (optional).
#   Defaults to 'src' and 'test' if omitted.
#
# Returns:
#   G__ERR_OK: Verification pipeline completed successfully.
#   G__ERR_NOT_OK: One or more verification checks failed.
#######################################
function main() {
    set -u

    # Constants
    local -ra _RUN_VERIFICATION_I01__DEFAULT_TARGETS=("${PROJECT_DIR}/src" "${PROJECT_DIR}/test")

    # Parameters
    local -a _run_verification_i01__input_targets

    # Variables
    local _run_verification_i01__retcode="$G__ERR_OK"
    local -a _run_verification_i01__refined_targets=()
    local -a _run_verification_i01__files=()
    local -a _run_verification_i01__formatting_results=()
    local -a _run_verification_i01__linting_results=()
    local -a _run_verification_i01__spelling_results=()
    local -a _run_verification_i01__testing_results=()

    # Parse and validate arguments
    _run_verification_i01__input_targets=("$@")

    # Function body
    echo "Requested targets[${#_run_verification_i01__input_targets[@]}]: '${_run_verification_i01__input_targets[*]}'"

    _run_verification__refine_targets "_run_verification_i01__refined_targets" "_run_verification_i01__input_targets"
    echo "Refined targets[${#_run_verification_i01__refined_targets[@]}]: '${_run_verification_i01__refined_targets[*]}'"

    _run_verification__collect_files "_run_verification_i01__files" "_run_verification_i01__refined_targets"
    echo "Total files: ${#_run_verification_i01__files[@]}"

    _run_verification__check_formatting "_run_verification_i01__formatting_results" "_run_verification_i01__files"
    echo "Formatting result: ${#_run_verification_i01__formatting_results[@]}"

    _run_verification__check_linting "_run_verification_i01__linting_results" "_run_verification_i01__files"
    echo "Linting result: ${#_run_verification_i01__linting_results[@]}"

    _run_verification__check_spelling "_run_verification_i01__spelling_results" "_run_verification_i01__files"
    echo "Spelling result: ${#_run_verification_i01__spelling_results[@]}"

    _run_verification__check_testing "_run_verification_i01__testing_results" "_run_verification_i01__files"
    echo "Testing result: ${#_run_verification_i01__testing_results[@]}"

    _run_verification__generate_report "_run_verification_i01__files" "_run_verification_i01__formatting_results" "_run_verification_i01__linting_results" "_run_verification_i01__spelling_results" "_run_verification_i01__testing_results"

    lib_validation__is_in "_run_verification_i01__formatting_results" "$RESULT_FAILED" && _run_verification_i01__retcode="$G__ERR_NOT_OK"
    lib_validation__is_in "_run_verification_i01__linting_results" "$RESULT_FAILED" && _run_verification_i01__retcode="$G__ERR_NOT_OK"
    lib_validation__is_in "_run_verification_i01__spelling_results" "$RESULT_FAILED" && _run_verification_i01__retcode="$G__ERR_NOT_OK"
    lib_validation__is_in "_run_verification_i01__testing_results" "$RESULT_FAILED" && _run_verification_i01__retcode="$G__ERR_NOT_OK"

    return "$_run_verification_i01__retcode"
}

main "$@"
