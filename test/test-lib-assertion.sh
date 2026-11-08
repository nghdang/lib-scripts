#!/usr/bin/env bash
#
# Source      : test/test-lib-assertion.sh
# Dependencies: src/lib-testing.sh
# FUT         : src/lib-assertion.sh
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__TEST_LIB_ASSERTION_SH_LOADED:-}" ]] && return 0
declare -gr G__TEST_LIB_ASSERTION_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../src/lib-testing.sh"

# ==================================================================================================
# Global Constants
# ==================================================================================================

TEST_SCRIPT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly TEST_SCRIPT_PARENT_DIR

FUT_RELATIVE_PATH="../src/lib-assertion.sh"
readonly FUT_RELATIVE_PATH

FUT_DEPENDENCY_RELATIVE_PATHS=(
    "../src/lib-base.sh"
    "../src/lib-validation.sh"
)
readonly FUT_DEPENDENCY_RELATIVE_PATHS

# ==================================================================================================
# Global Variables
# ==================================================================================================

# ==================================================================================================
# Helper Functions
# ==================================================================================================

# ==================================================================================================
# Test Cases
# ==================================================================================================

#
# Equivalence class table of `lib_assertion__assert_args_count`
# ID    args_count  min_args    max_args    Expected Output / Behavior      Return Code
# --    ----------  --------    --------    --------------------------      --------------------
# TC1   (missing)   (missing)   (missing)   exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "abc"       1           5           exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC3   1           "abc"       5           exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC4   1           1           "abc"       exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC5   0           1           5           args_count < min_args           G__ERR_MISSING_ARG
# TC6   6           1           5           args_count > max_args           G__ERR_TOO_MANY_ARGS
# TC7   3           1           5           in range                        G__ERR_OK
# TC8   2           2           (default)   in range with default max_args  G__ERR_OK
#

function tc__assert_args_count__tc1__missing_arguments() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_args_count"

    (lib_assertion__assert_args_count 1)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__assert_args_count__tc2__non_numeric_args_count() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_args_count"

    (lib_assertion__assert_args_count "abc" 1 5)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__assert_args_count__tc3__non_numeric_min_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_args_count"

    (lib_assertion__assert_args_count 1 "abc" 5)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__assert_args_count__tc4__non_numeric_max_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_args_count"

    (lib_assertion__assert_args_count 1 1 "abc")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__assert_args_count__tc5__count_below_min() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_args_count"

    (lib_assertion__assert_args_count 0 1 5)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__assert_args_count__tc6__count_above_max() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_args_count"

    (lib_assertion__assert_args_count 6 1 5)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__assert_args_count__tc7__count_in_range() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_args_count"

    lib_assertion__assert_args_count 3 1 5
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_args_count__tc8__default_max_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_args_count"

    lib_assertion__assert_args_count 2 2
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

#
# Equivalence class table of `lib_assertion__assert_var_name`
# ID    param           Expected Output / Behavior      Return Code
# --    -----------     --------------------------      --------------------
# TC1   (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "a" "b"         exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   "valid_var_1"   valid variable name             G__ERR_OK
# TC4   "_private_var"  valid variable name with _      G__ERR_OK
# TC5   "123_invalid"   exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC6   "kebab-case"    exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
#

function tc__assert_var_name__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var_name"

    (lib_assertion__assert_var_name)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__assert_var_name__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var_name"

    (lib_assertion__assert_var_name "arg1" "arg2")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__assert_var_name__tc3__valid_name() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var_name"

    lib_assertion__assert_var_name "valid_var_1"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_var_name__tc4__underscore_prefix() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var_name"

    lib_assertion__assert_var_name "_private_var"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_var_name__tc5__starts_with_number() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var_name"

    (lib_assertion__assert_var_name "123_invalid")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__assert_var_name__tc6__invalid_characters() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var_name"

    (lib_assertion__assert_var_name "kebab-case")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

#
# Equivalence class table of `lib_assertion__assert_var`
# ID    param           Expected Output / Behavior      Return Code
# --    -----------     --------------------------      --------------------
# TC1   (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "a" "b"         exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   declared var    is a declared variable          G__ERR_OK
# TC4   undeclared var  exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
#

function tc__assert_var__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var"

    (lib_assertion__assert_var)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__assert_var__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var"

    (lib_assertion__assert_var "arg1" "arg2")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__assert_var__tc3__declared_variable() {
    local _test_var="declared"
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var"

    lib_assertion__assert_var "_test_var"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_var__tc4__undeclared_variable() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_var"

    (lib_assertion__assert_var "_test_nonexistent_var_abc")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

#
# Equivalence class table of `lib_assertion__assert_array`
# ID    param           Expected Output / Behavior      Return Code
# --    -----------     --------------------------      --------------------
# TC1   (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "a" "b"         exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   indexed array   is an indexed array             G__ERR_OK
# TC4   scalar variable exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC5   undeclared var  exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
#

function tc__assert_array__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_array"

    (lib_assertion__assert_array)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__assert_array__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_array"

    (lib_assertion__assert_array "arg1" "arg2")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__assert_array__tc3__indexed_array() {
    local -a _test_arr=("item1" "item2")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_array"

    lib_assertion__assert_array "_test_arr"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_array__tc4__scalar_variable() {
    local _test_scalar="scalar_val"
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_array"

    (lib_assertion__assert_array "_test_scalar")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__assert_array__tc5__undeclared_variable() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_array"

    (lib_assertion__assert_array "_test_nonexistent_array_abc")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

#
# Equivalence class table of `lib_assertion__assert_number`
# ID    param       label       Expected Output / Behavior      Return Code
# --    -----       -----       --------------------------      --------------------
# TC1   (missing)   (missing)   exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   1 2 3       (extra)     exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   "123"       (none)      valid integer                   G__ERR_OK
# TC4   "-42"       "Count"     valid signed integer            G__ERR_OK
# TC5   "abc"       (none)      exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC6   "abc"       "Port"      exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
#

function tc__assert_number__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_number"

    (lib_assertion__assert_number)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__assert_number__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_number"

    (lib_assertion__assert_number 1 2 3)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__assert_number__tc3__valid_integer() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_number"

    lib_assertion__assert_number "123"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_number__tc4__valid_signed_integer() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_number"

    lib_assertion__assert_number "-42" "Count"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_number__tc5__non_number() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_number"

    (lib_assertion__assert_number "abc")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__assert_number__tc6__non_number_with_label() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_number"

    (lib_assertion__assert_number "abc" "Port")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

#
# Equivalence class table of `lib_assertion__assert_not_empty`
# ID    param       label       Expected Output / Behavior      Return Code
# --    -----       -----       --------------------------      --------------------
# TC1   (missing)   (missing)   exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   1 2 3       (extra)     exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   "hello"     (none)      non-empty string                G__ERR_OK
# TC4   "hello"     "Name"      non-empty string with label     G__ERR_OK
# TC5   ""          (none)      exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC6   ""          "Username"  exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
#

function tc__assert_not_empty__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_not_empty"

    (lib_assertion__assert_not_empty)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__assert_not_empty__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_not_empty"

    (lib_assertion__assert_not_empty 1 2 3)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__assert_not_empty__tc3__non_empty_value() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_not_empty"

    lib_assertion__assert_not_empty "hello"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_not_empty__tc4__non_empty_with_label() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_not_empty"

    lib_assertion__assert_not_empty "hello" "Name"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_not_empty__tc5__empty_value() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_not_empty"

    (lib_assertion__assert_not_empty "")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__assert_not_empty__tc6__empty_value_with_label() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_not_empty"

    (lib_assertion__assert_not_empty "" "Username")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

#
# Equivalence class table of `lib_assertion__assert_in`
# ID    array_ref   item        Expected Output / Behavior      Return Code
# --    ---------   ----        --------------------------      -------------------
# TC1   (missing)   (missing)   exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "a" "b" "c" (extra)     exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   scalar_var  "foo"       exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC4   array_var   "banana"    item exists in array            G__ERR_OK
# TC5   array_var   "durian"    exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
#

function tc__assert_in__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_in"

    (lib_assertion__assert_in "arr")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__assert_in__tc2__too_many_args() {
    local -a _test_arr=("a" "b")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_in"

    (lib_assertion__assert_in "_test_arr" "a" "extra")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__assert_in__tc3__not_an_array() {
    local _test_not_arr="scalar"
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_in"

    (lib_assertion__assert_in "_test_not_arr" "scalar")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__assert_in__tc4__item_in_array() {
    local -a _fruits=("apple" "banana" "cherry")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_in"

    lib_assertion__assert_in "_fruits" "banana"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__assert_in__tc5__item_not_in_array() {
    local -a _fruits=("apple" "banana" "cherry")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_assertion__assert_in"

    (lib_assertion__assert_in "_fruits" "durian")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

# ==================================================================================================
# Entry Point
# ==================================================================================================
function main() {
    set -u

    local _fut_path=""
    local _fut_relative_path=""
    local -a fut_dependency_paths=()

    _fut_path="$(realpath "${TEST_SCRIPT_PARENT_DIR}/${FUT_RELATIVE_PATH}")"

    for _fut_relative_path in "${FUT_DEPENDENCY_RELATIVE_PATHS[@]}"; do
        fut_dependency_paths+=("$(realpath "${TEST_SCRIPT_PARENT_DIR}/${_fut_relative_path}")")
    done

    lib_testing__test_main "$_fut_path" "${fut_dependency_paths[@]}"
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
