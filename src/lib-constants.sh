#!/usr/bin/env bash
#
# Source      : src/lib-constants.sh
# Dependencies: None
# Description : Global constants used in cross-projects.
#

[[ -n "${G__LIB_CONSTANTS_SH_LOADED:-}" ]] && return 0
export G__LIB_CONSTANTS_SH_LOADED=1

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

export G__TABLE_ROW_PREFIX_LEN=${#G__ROW_PREFIX}
readonly G__TABLE_ROW_PREFIX_LEN

export G__TABLE_ROW_SUFFIX=" |"
readonly G__TABLE_ROW_SUFFIX

export G__TABLE_ROW_SUFFIX_LEN=${#G__ROW_SUFFIX}
readonly G__TABLE_ROW_SUFFIX_LEN

export G__TABLE_HEADER_SEPARATOR=" | "
readonly G__TABLE_HEADER_SEPARATOR

export G__TABLE_HEADER_SEPARATOR_LEN=${#G__HEADER_SEPARATOR}
readonly G__TABLE_HEADER_SEPARATOR_LEN

export G__TABLE_COL_SEPARATOR=" : "
readonly G__TABLE_COL_SEPARATOR

export G__TABLE_COL_SEPARATOR_LEN=${#G__COL_SEPARATOR}
readonly G__TABLE_COL_SEPARATOR_LEN

G__TABLE_WIDTH=$((G__DIVIDER_WIDTH - G__TABLE_ROW_PREFIX_LEN))
G__TABLE_WIDTH=$((G__TABLE_WIDTH - G__TABLE_ROW_SUFFIX_LEN))
export G__TABLE_WIDTH
readonly G__TABLE_WIDTH

# ----- Error Codes -----
export G__ERR_OK=0

# Arguments error codes
export G__ERR_MISSING_ARG=10
export G__ERR_INVALID_ARG=11

# File system error codes
export G__ERR_NOT_FOUND=20
export G__ERR_ALREADY_EXISTS=21
export G__ERR_NOT_FILE=22
export G__ERR_NOT_DIR=23
export G__ERR_READ_FAILED=24
export G__ERR_WRITE_FAILED=25

# ----- Logging level -----
export G__LOG_LEVEL_DEBUG=0
export G__LOG_LEVEL_INFO=1
export G__LOG_LEVEL_WARN=2
export G__LOG_LEVEL_ERROR=3
export -a G__LOG_LEVELS_STR=("DEBUG" "INFO" "WARN" "ERROR")

# ===== File Scope =====

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
