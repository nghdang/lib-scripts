# Coding Guidelines

This document defines the coding standards, conventions, and architectural rules for Bash library and feature scripts in this project. Conventions are categorized into **Naming Conventions (`NAME`)**, **Structure Conventions (`STRUCT`)**, **Documentation Conventions (`DOC`)**, and **Testing Conventions (`TEST`)**.

---

## 1. Naming Conventions

### [NAME.1] Script Files

- Script files must be named in `kebab-case` with the `.sh` extension (or `.sh.tmpl` for template files).
- Examples: `src/lib-utils.sh`, `script.sh.tmpl`.

### [NAME.2] Source Guard Variable

- The source guard variable must be named in `UPPER_CASE` with the prefix `G__` and the suffix `_LOADED`.
- Hyphens and periods from the filename must be replaced with underscores.
- Format: `G__<FILENAME_WITHOUT_EXTENSION>_<EXTENSION>_LOADED`
- Example: For `src/lib-utils.sh`, the guard variable is `G__LIB_UTILS_SH_LOADED`.

### [NAME.3] Project-Scope Global Constants

- Constants accessible across multiple scripts must be named in `UPPER_CASE` prefixed with `G__`.
- Example: `G__DIVIDER_WIDTH`, `G__COLOR_RED`.

### [NAME.4] File-Scope Global Constants

- Constants used exclusively within the declaring script must be named in `UPPER_CASE` without any prefix.
- Example: `DEFAULT_TABLE_WIDTH`, `LOG_LEVEL_NAMES`.

### [NAME.5] Project-Scope Global Variables

- Variables shared across multiple scripts must be named in `snake_case` prefixed with `g__`.
- Example: `g__active_session_id`.

### [NAME.6] File-Scope Global Variables

- Variables used exclusively within the declaring script must be named in `snake_case` without any prefix.
- Example: `file_counter`, `temp_buffer`.

### [NAME.7] Name Reference Variables

- Any variable storing a variable name reference (nameref) must append the suffix `_ref`.
- Normal variables (strings, numbers, indexed arrays) must not use this suffix.
- Examples: `g__target_var_ref`, `_ret_val_ref`.

### [NAME.8] Private Functions

- Functions used only within the declaring script must be named in `snake_case` with the prefix `_<module>__`, where `<module>` is the script module name.
- Example: `_lib_logging__write_log`, `_lib_table__calc_column_widths`.

### [NAME.9] Public Functions

- Functions accessible to other scripts must be named in `snake_case` with the prefix `<module>__` (no leading underscore), where `<module>` is the script module name.
- Example: `lib_assertion__assert_number`, `lib_table__draw_table`.

### [NAME.10] Function ID

- Every function within a script must be assigned a unique sequential ID:
  - **Public functions**: Prefixed with `i` followed by a two-digit number (e.g. `i01`, `i02`).
  - **Private functions**: Prefixed with `p` followed by a two-digit number (e.g. `p01`, `p02`).
- Function IDs are mapped to function names in the script's Function ID Mapping table.

### [NAME.11] Local Constants

- Local constants declared within functions must be named in `UPPER_CASE` prefixed with `_<MODULE>_<ID>__`, where `<MODULE>` is the script module name in uppercase and `<ID>` is the function ID.
- Example: For function `lib_base__traceback` with ID `i01`, a constant is named `_LIB_BASE_i01__DEFAULT_STACK`.

### [NAME.12] Local Variables and Function Parameters

- Function parameter variables and local variables must be named in `snake_case` prefixed with `_<module>_<id>__`, where `<module>` is the script module name and `<id>` is the function ID.
- Name references within functions must combine the prefix `_<module>_<id>__` and suffix `_ref`.
- Examples: `_lib_base_i01__min_stack`, `_lib_base_i01__file_path`, `_module_name_i01__target_ref`.

---

## 2. Structure Conventions

### [STRUCT.1] File Section Organization

Every script must be organized into the following canonical sections in exact order:

1. File Header
2. Initialization (containing Source Guard, Source Dependencies, and Function ID Mapping sub-sections)
3. Global Constants (containing Project Scope and File Scope sub-sections)
4. Global Variables (containing Project Scope and File Scope sub-sections)
5. Private Functions
6. Public Functions
7. Entry Point

### [STRUCT.2] Source Guard Pattern

Reusable scripts must include a source guard within the `Initialization` section to prevent duplicate sourcing:

```bash
# ===== Source Guard =====
[[ -n "${G__<SCRIPT_NAME>_SH_LOADED:-}" ]] && return 0
declare -rx G__<SCRIPT_NAME>_SH_LOADED=1
```

### [STRUCT.3] Function ID Mapping Table

Every script containing functions must include a Function ID Mapping table within the `Initialization` section. The table maps every function to its unique sequential function ID (`i01`, `i02`, ... for public functions, `p01`, `p02`, ... for private functions):

```bash
# ===== Function ID Mapping =====
#
# Function                              ID
# -----------------------------------------
# _<module>__<private_function>         p01
# <module>__<public_function>           i01
# -----------------------------------------
```

### [STRUCT.4] Global Constants Declaration

- Project-scope constants must be declared using `declare -rx`.
- File-scope constants must be declared using `readonly`.
- Related constants must be grouped into logical categories using sub-dividers (e.g. `# ----- Category -----`).
- If a constant scope contains no declarations, the section must remain empty.

### [STRUCT.5] Global Variables Declaration

- Project-scope variables must be declared using `export`.
- File-scope variables must be declared with standard assignments (`<name>="<value>"`).
- If a variable scope contains no declarations, the section must remain empty.

### [STRUCT.6] Function Internal Layout

Every function body must be organized into exactly five distinct sections in the following order:

1. `# Constants`: Local constants declared as read-only local variables (`local -r`) prefixed with `_<MODULE>_<ID>__` (e.g. `local -r _MODULE_NAME_i01__DEFAULT_TIMEOUT=10`).
2. `# Parameters`: Function parameter variables declared with `local` prefixed with `_<module>_<id>__` (e.g. `local _module_name_i01__file_path`).
3. `# Variables`: Local variables declared with `local` prefixed with `_<module>_<id>__` (e.g. `local _module_name_i01__error_code="$G__ERR_OK"`).
4. `# Parse and validate arguments`: Argument count checks (`lib_assertion__assert_args_count`) and value assertions.
5. `# Function body`: Main execution logic and return statement.

```bash
function <module>__<function_name>() {
    # Constants
    local -r _<MODULE>_<ID>__<CONSTANT_NAME>="<value>"

    # Parameters
    local _<module>_<id>__<param_name>

    # Variables
    local _<module>_<id>__<var_name>

    # Parse and validate arguments
    [[ $# -lt 1 ]] && lib_base__throw "$G__ERR_MISSING_ARG" "${FUNCNAME[0]} required 1 argument"

    _<module>_<id>__<param_name>="$1"

    # Function body
    <execution_logic>

    return "$G__ERR_OK"
}
```

### [STRUCT.7] Block-Scoped Local Variables

Local variables used exclusively within an isolated block (e.g. inside a `for`-loop or `if`-block) may be declared locally immediately after the block opening statement rather than at the top of the function.

### [STRUCT.8] Return Code and Error Handling

- All return and exit codes must standardize on constants defined in `src/lib-base.sh` (`G__ERR_*`).
- **Non-mutating functions**: Return `$G__ERR_OK` directly without declaring an unused `_error_code` variable.
- **Mutating functions**: Initialize `local _error_code="$G__ERR_OK"`, update it upon failure, and return `return "$_error_code"`.

### [STRUCT.9] Entry Point Execution Guard

Commands executed upon script invocation must reside in a `main()` function guarded by:

```bash
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
```

This section is optional and must be omitted for reusable library scripts intended only to be sourced.

### [STRUCT.10] Line Length Limit

- Line length must not exceed 100 characters.
- For code lines, using line continuation backslashes (`\`) is not recommended, but it can still be used if there are no other ways.

---

## 3. Documentation Conventions

### [DOC.1] File Header

Every script must include a file header containing:

- `Source`: Relative path of this script to the project root directory.
- `Dependencies`: Relative paths of all scripts sourced by this script, one per line (or `None` if zero dependencies).
- `Description`: A concise one-sentence summary of the script's purpose without mentioning implementation details.

### [DOC.2] Function Docstring Wrapper

Every function must be preceded by a docstring block wrapped in `#######################################` lines, placed immediately above the function definition:

```bash
#######################################
# <Summary>
#
# Arguments:
#   <param_name> [in | out | inout]: <description>
#
# Outputs:
#   <description of data written to STDOUT>
#
# Returns:
#   <ERROR_CODE>: <condition>
#
# Exits:
#   <ERROR_CODE>: <condition>
#######################################
function <function_name>() { ... }
```

### [DOC.3] Function Summary

The line immediately following the opening `#######################################` comment must be exactly one sentence describing the function's purpose. The keyword `Summary:` must be omitted.

### [DOC.4] Function Arguments Section

Function parameters must be documented under the `Arguments:` header. Each parameter must follow the format:
`<param_name> [in | out | inout]: <description>`

### [DOC.5] Function Outputs Section

Data written to `STDOUT` must be documented under the `Outputs:` header:
`<description of data written to STDOUT>`
Diagnostic, debug, or informational messages must not be listed in this section. If the function writes nothing to `STDOUT`, this section must be omitted.

### [DOC.6] Function Returns Section

All error codes returned when the function terminates without exiting the shell process must be documented under the `Returns:` header:
`<ERROR_CODE>: <condition under which this code is returned>`

### [DOC.7] Function Exits Section

All exit codes that terminate the entire shell process (e.g. via `lib_base__throw` or `exit`) must be documented under the `Exits:` header:
`<ERROR_CODE>: <condition under which the shell process exits>`
If the function never terminates the shell process, this section must be omitted.

---

## 4. Testing Conventions

### [TEST.1] Test Script Files

- Test suite files must be named in `kebab-case` with the format `test-<fut_name>.sh` (or `.sh.tmpl` for template files).
- Examples: `test/test-lib-base.sh`, `test/test-script.sh.tmpl`.

### [TEST.2] Test Suite Header

- Test suite scripts must include a `FUT` (File Under Test) tag in the file header specifying the relative path to the script under test.
- Example:

```bash
#
# Source      : test/test-lib-base.sh
# Dependencies: src/lib-testing.sh
# FUT         : src/lib-base.sh
#
```

### [TEST.3] Test Section Organization

Every test suite script must be organized into the following canonical sections in exact order:

1. File Header
2. Initialization (`Source Guard` and `Source Dependencies`)
3. Global Constants (`TEST_SCRIPT_PARENT_DIR`, `FUT_RELATIVE_PATH`, `FUT_DEPENDENCY_RELATIVE_PATHS`)
4. Global Variables
5. Helper Functions
6. Test Cases
7. Entry Point

### [TEST.4] Test Helper Functions

- Helper functions used exclusively by test cases within the declaring script must be named in `snake_case` with the prefix `_helper__`.
- Example: `_helper__assert_file`.
- Helper functions must include a docstring block with Summary, Arguments, and Returns sections.

### [TEST.5] Equivalence Class Table

- Each software under test (SUT) must be preceded by an equivalence class table describing input groups, expectations, and return codes:

```bash
#
# Equivalence class table of `<sut_name>`
# ID    <Param 1>   <Param 2>   ...     Expected    Return Code
# --    ---------   ---------           --------    -----------
# TC1   <value>     <value>             <expected>  <code>
#
```

### [TEST.6] Test Case Functions

- Test case functions must be named in `snake_case` with the format:
  `tc__<sut_name>__<tc_id>__<tc_name>`
  where `<tc_id>` is retrieved from the corresponding equivalence class table (e.g. `tc1`, `tc2`).
- Example: `tc__load_file__tc1__success`.
- Test case functions must not have docstrings.
- Inside test cases, use standard assertion APIs from `src/lib-testing.sh`:
  - `lib_testing__sut_existence "<sut_name>"`: Verify existence of SUT before running assertions.
  - `lib_testing__eq "<expected>" "<actual>" "<message>"`: Value equality.
  - `lib_testing__error_code_eq "<expected_code>" "<actual_code>" "<message>"`: Return / exit code equality.

### [TEST.7] Test Suite Entry Point

- The test suite entry point resides in a `main()` function with `set -u` that resolves `_fut_path` and `fut_dependency_paths`, then invokes `lib_testing__test_main "$_fut_path" "${fut_dependency_paths[@]}"`.
- The execution guard must invoke `main`:

```bash
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
```
