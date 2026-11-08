#!/usr/bin/env bash
#
# Source      : test/test-lib-validation.sh
# Dependencies: src/lib-testing.sh
# FUT         : src/lib-validation.sh
#

# ==================================================================================================
# Initialization
# ==================================================================================================

# ===== Source Guard =====
[[ -n "${G__TEST_LIB_VALIDATION_SH_LOADED:-}" ]] && return 0
declare -rx G__TEST_LIB_VALIDATION_SH_LOADED=1

# ===== Source Dependencies =====
# shellcheck disable=SC1090,SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../src/lib-testing.sh"

# ==================================================================================================
# Global Constants
# ==================================================================================================

TEST_SCRIPT_PARENT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly TEST_SCRIPT_PARENT_DIR

FUT_RELATIVE_PATH="../src/lib-validation.sh"
readonly FUT_RELATIVE_PATH

FUT_DEPENDENCY_RELATIVE_PATHS=(
    "../src/lib-base.sh"
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
# Equivalence class table of `lib_validation__is_var_name`
# ID    param           Expected Output / Behavior      Return Code
# --    -----------     --------------------------      --------------------
# TC1   (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "a" "b"         exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   "valid_var_1"   valid variable name             G__ERR_OK
# TC4   "_private_var"  valid variable name with _      G__ERR_OK
# TC5   "123_invalid"   starts with number              G__ERR_NOT_OK
# TC6   "kebab-case"    contains invalid hyphen         G__ERR_NOT_OK
#

function tc__is_var_name__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var_name"

    (lib_validation__is_var_name)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__is_var_name__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var_name"

    (lib_validation__is_var_name "arg1" "arg2")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__is_var_name__tc3__valid_name() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var_name"

    lib_validation__is_var_name "valid_var_1"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__is_var_name__tc4__underscore_prefix() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var_name"

    lib_validation__is_var_name "_private_var"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__is_var_name__tc5__starts_with_number() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var_name"

    lib_validation__is_var_name "123_invalid"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

function tc__is_var_name__tc6__invalid_characters() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var_name"

    lib_validation__is_var_name "kebab-case"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

#
# Equivalence class table of `lib_validation__is_var`
# ID    var_name        Expected Output / Behavior      Return Code
# --    -----------     --------------------------      --------------------
# TC1   (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "a" "b"         exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   declared var    is a declared variable          G__ERR_OK
# TC4   undeclared var  is not a declared variable      G__ERR_NOT_OK
# TC5   invalid name    is not a valid variable name    G__ERR_NOT_OK
#

function tc__is_var__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var"

    (lib_validation__is_var)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__is_var__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var"

    (lib_validation__is_var "arg1" "arg2")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__is_var__tc3__declared_variable() {
    local _test_declared_var="hello"
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var"

    lib_validation__is_var "_test_declared_var"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__is_var__tc4__undeclared_variable() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var"

    lib_validation__is_var "_test_nonexistent_var_xyz"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

function tc__is_var__tc5__invalid_variable_name() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_var"

    lib_validation__is_var "123-bad-name"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

#
# Equivalence class table of `lib_validation__is_array`
# ID    var_name        Expected Output / Behavior      Return Code
# --    -----------     --------------------------      --------------------
# TC1   (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "a" "b"         exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   indexed array   is an indexed array             G__ERR_OK
# TC4   scalar variable not an indexed array            G__ERR_NOT_OK
# TC5   assoc array     not an indexed array            G__ERR_NOT_OK
# TC6   undeclared var  not a declared variable         G__ERR_NOT_OK
#

function tc__is_array__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_array"

    (lib_validation__is_array)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__is_array__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_array"

    (lib_validation__is_array "arg1" "arg2")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__is_array__tc3__indexed_array() {
    local -a _test_indexed_arr=("item1" "item2")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_array"

    lib_validation__is_array "_test_indexed_arr"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__is_array__tc4__scalar_variable() {
    local _test_scalar="not_an_array"
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_array"

    lib_validation__is_array "_test_scalar"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

function tc__is_array__tc5__associative_array() {
    local -A _test_assoc_arr=(["key"]="val")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_array"

    lib_validation__is_array "_test_assoc_arr"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

function tc__is_array__tc6__undeclared_variable() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_array"

    lib_validation__is_array "_test_nonexistent_arr_xyz"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

#
# Equivalence class table of `lib_validation__is_number`
# ID    param           Expected Output / Behavior      Return Code
# --    -----------     --------------------------      --------------------
# TC1   (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "1" "2"         exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   "123"           positive number                 G__ERR_OK
# TC4   "-42"           negative number                 G__ERR_OK
# TC5   "+10"           signed positive number          G__ERR_OK
# TC6   "abc"           non-numeric string              G__ERR_NOT_OK
# TC7   "12.34"         floating point number           G__ERR_NOT_OK
#

function tc__is_number__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_number"

    (lib_validation__is_number)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__is_number__tc2__too_many_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_number"

    (lib_validation__is_number "1" "2")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__is_number__tc3__positive_integer() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_number"

    lib_validation__is_number "123"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__is_number__tc4__negative_integer() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_number"

    lib_validation__is_number "-42"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__is_number__tc5__signed_positive_integer() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_number"

    lib_validation__is_number "+10"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__is_number__tc6__non_numeric() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_number"

    lib_validation__is_number "not_a_number"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

function tc__is_number__tc7__floating_point() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_number"

    lib_validation__is_number "12.34"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
}

#
# Equivalence class table of `lib_validation__is_in`
# ID    array_ref       item            Expected Output / Behavior      Return Code
# --    -----------     ------------    --------------------------      -------------------
# TC1   (missing)       (missing)       exits with G__ERR_MISSING_ARG   G__ERR_MISSING_ARG
# TC2   "arr" "a" "b"   (extra)         exits with G__ERR_TOO_MANY_ARGS G__ERR_TOO_MANY_ARGS
# TC3   scalar_var      "val"           exits with G__ERR_TYPE_ERROR    G__ERR_TYPE_ERROR
# TC4   array_var       existing_item   item exists in array            G__ERR_OK
# TC5   array_var       missing_item    item does not exist in array    G__ERR_NOT_OK
#

function tc__is_in__tc1__missing_args() {
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_in"

    (lib_validation__is_in)
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_MISSING_ARG" "$_error_code"
}

function tc__is_in__tc2__too_many_args() {
    local -a _test_arr=("a" "b")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_in"

    (lib_validation__is_in "_test_arr" "a" "extra")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TOO_MANY_ARGS" "$_error_code"
}

function tc__is_in__tc3__not_an_array() {
    local _test_not_arr="scalar"
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_in"

    (lib_validation__is_in "_test_not_arr" "scalar")
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_TYPE_ERROR" "$_error_code"
}

function tc__is_in__tc4__item_found() {
    local -a _test_items=("apple" "banana" "cherry")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_in"

    lib_validation__is_in "_test_items" "banana"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_OK" "$_error_code"
}

function tc__is_in__tc5__item_not_found() {
    local -a _test_items=("apple" "banana" "cherry")
    local _error_code="$G__ERR_OK"

    lib_testing__sut_existence "lib_validation__is_in"

    lib_validation__is_in "_test_items" "durian"
    _error_code=$?
    lib_testing__error_code_eq "$G__ERR_NOT_OK" "$_error_code"
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
