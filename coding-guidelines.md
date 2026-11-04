# Coding Guidelines

This document defines the coding standards, conventions, and architectural rules for Bash library and feature scripts in this project. Conventions are categorized into **Naming Conventions (`NAME`)**, **Structure Conventions (`STRUCT`)**, and **Documentation Conventions (`DOC`)**.

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
- Example: `_lib_base__write_log`, `_lib_base__calc_column_widths`.

### [NAME.9] Public Functions
- Functions accessible to other scripts must be named in `snake_case` with the prefix `<module>__` (no leading underscore), where `<module>` is the script module name.
- Example: `lib_base__assert_number`, `lib_base__draw_table`.

### [NAME.10] Local Variables and Function Parameters
- Local variables and function parameter variables must be named in `snake_case` prefixed with an underscore `_`.
- Name references within functions must combine the prefix `_` and suffix `_ref`.
- Examples: `_file_path`, `_error_code`, `_target_array_ref`.

---

## 2. Structure Conventions

### [STRUCT.1] File Section Organization
Every script must be organized into the following canonical sections in exact order:
1. File Header (`#region File Header` ... `#endregion File Header`)
2. Source Guard
3. Global Constants (`#region Global Constants` containing Project Scope and File Scope sub-regions)
4. Global Variables (`#region Global Variables` containing Project Scope and File Scope sub-regions)
5. Private Functions (`#region Private Functions` ... `#endregion Private Functions`)
6. Public Functions (`#region Public Functions` ... `#endregion Public Functions`)
7. Entry Point (`#region Entry Point` ... `#endregion Entry Point`)

### [STRUCT.2] Source Guard Pattern
Reusable scripts must include a source guard immediately following the file header to prevent duplicate sourcing:
```bash
# ----- Source Guard -----
[[ -n "${G__<SCRIPT_NAME>_SH_LOADED:-}" ]] && return 0
declare -rx G__<SCRIPT_NAME>_SH_LOADED=1
```

### [STRUCT.3] Global Constants Declaration
- Project-scope constants must be declared using `declare -rx`.
- File-scope constants must be declared using `readonly`.
- Related constants must be grouped into logical categories using sub-dividers (e.g. `# ----- Category -----`).
- If a constant scope contains no declarations, the region must remain empty.

### [STRUCT.4] Global Variables Declaration
- Project-scope variables must be declared using `export`.
- File-scope variables must be declared with standard assignments (`<name>="<value>"`).
- If a variable scope contains no declarations, the region must remain empty.

### [STRUCT.5] Function Internal Layout
Every function body must be organized into exactly four distinct sections in the following order:
1. `# Constants`: Local constants declared as read-only local variables (e.g. `local -r _DEFAULT_TIMEOUT=10`).
2. `# Variables`: Local variable declarations (`local`). Parameter variables must be declared at the top, followed by a single blank line, then remaining local variables.
3. `# Parse and validate arguments`: Argument count checks (`lib_base__assert_args_count`) and value assertions.
4. `# Function body`: Main execution logic and return statement.

### [STRUCT.6] Block-Scoped Local Variables
Local variables used exclusively within an isolated block (e.g. inside a `for`-loop or `if`-block) may be declared locally immediately after the block opening statement rather than at the top of the function.

### [STRUCT.7] Return Code and Error Handling
- All return and exit codes must standardize on constants defined in `src/lib-base.sh` (`G__ERR_*`).
- **Non-mutating functions**: Return `$G__ERR_OK` directly without declaring an unused `_error_code` variable.
- **Mutating functions**: Initialize `local _error_code="$G__ERR_OK"`, update it upon failure, and return `return "$_error_code"`.

### [STRUCT.8] Entry Point Execution Guard
Commands executed upon script invocation must reside in a `main()` function guarded by:
```bash
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    main "$@"
fi
```
This section is optional and must be omitted for reusable library scripts intended only to be sourced.

---

## 3. Documentation Conventions

### [DOC.1] File Header
Every script must include a file header enclosed in `#region File Header` and `#endregion File Header` containing:
- `Source`: Relative path of this script to the project root directory.
- `Dependencies`: Relative paths of all scripts sourced by this script, one per line (or `None` if zero dependencies).
- `Description`: A concise one-sentence summary of the script's purpose without mentioning implementation details.

### [DOC.2] Function Docstring Wrapper
Every function must be preceded by a docstring block wrapped in `#######################################` lines, placed immediately below the `#region <function_name>` marker and above the function definition:
```bash
#region <function_name>
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
#endregion <function_name>
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
All exit codes that terminate the entire shell process (e.g. via `lib_base__throw_exception` or `exit`) must be documented under the `Exits:` header:
`<ERROR_CODE>: <condition under which the shell process exits>`
If the function never terminates the shell process, this section must be omitted.
