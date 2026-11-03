#!/usr/bin/env bash
#
# Source      : lib-layout.sh
# Dependencies: src/lib-base.sh
#               src/lib-logging.sh
# Description : General utility for drawing on terminal.
#

# ----- Source Guard -----
[[ -n "${G__LIB_LAYOUT_SH_LOADED:-}" ]] && return 0
export G__LIB_LAYOUT_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================

# ===== Project Scope =====
export G__TABLE_CONFIG_ROW_PREFIX="row-prefix"
readonly G__TABLE_CONFIG_ROW_PREFIX

export G__TABLE_ALIGN_LEFT="left"
readonly G__TABLE_ALIGN_LEFT

export G__TABLE_ALIGN_CENTER="center"
readonly G__TABLE_ALIGN_CENTER

export G__TABLE_ALIGN_RIGHT="right"
readonly G__TABLE_ALIGN_RIGHT

# ===== File Scope =====
readonly TABLE_ALIGNS=(
    "$G__TABLE_ALIGN_LEFT"
    "$G__TABLE_ALIGN_CENTER"
    "$G__TABLE_ALIGN_RIGHT"
)

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
function lib_layout__draw_table_with_summary() {
    # Constants

    # Variables
    local _summary
    local _width="$G__DIVIDER_WIDTH"
    local _prefix="$G__TABLE_ROW_PREFIX"
    local _suffix="$G__TABLE_ROW_SUFFIX"
    local _align="$G__TABLE_ALIGN_LEFT"

    local _ret_code="$G__ERR_OK"
    local _divider_h2

    # Parse and validate arguments
    [[ $# -lt 1 ]] && return "$G__ERR_MISSING_ARG"

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --summary)
            _summary="$2"
            shift 2
            ;;
        --width)
            _width="$2"
            shift 2
            ;;
        --prefix)
            _prefix="$2"
            shift 2
            ;;
        --suffix)
            _suffix="$2"
            shift 2
            ;;
        --align)
            _align="$2"
            shift 2
            ;;
        *)
            shift
            ;;
        esac
    done

    lib_base__is_number "$_width" || return "$G__ERR_INVALID_ARG"
    lib_base__is_in "${TABLE_ALIGNS[*]}" "$_align" || return "$G__ERR_INVALID_ARG"

    lib_logging__debug "Summary: '$_summary'"
    lib_logging__debug "Width: '$_width'"
    lib_logging__debug "Prefix: '$_prefix'"
    lib_logging__debug "Suffix: '$_suffix'"
    lib_logging__debug "Align: '$_align'"

    # Function body
    _divider_h2="$(lib_base__gen_divider "$G__DIVIDER_H2_CHAR")"
    _ret_code=$?

    if [[ "$G__ERR_OK" -eq "$_ret_code" ]]; then
        lib_logging__info "$_divider_h2"
        # lib_logging__info "$_summary"
        # lib_logging__info "$(lib_base__gen_divider "$G__DIVIDER_H2_CHAR")"
    fi

    return "$_ret_code"
}

# =============================================================================
# Entry Point
# =============================================================================
function main() {
    set -u

    LIB_LAYOUT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    readonly LIB_LAYOUT_PARENT_DIR

    LIB_BASE_PATH="$(realpath "${LIB_LAYOUT_PARENT_DIR}/../src/lib-base.sh")"
    readonly LIB_BASE_PATH

    LIB_LOGGING_PATH="$(realpath "${LIB_LAYOUT_PARENT_DIR}/../src/lib-logging.sh")"
    readonly LIB_LOGGING_PATH

    # shellcheck disable=SC1090,SC1091
    source "$LIB_BASE_PATH"

    # shellcheck disable=SC1090,SC1091
    source "$LIB_LOGGING_PATH"

    lib_layout__draw_table_with_summary "$@"
    ec=$?
    echo "Exit code: $(lib_base__error_code_to_string "$ec")"
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
