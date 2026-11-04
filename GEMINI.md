# Project Guidelines: lib-scripts

## Overview

`lib-scripts` is a foundational Bash library providing modular utilities, standardized logging, and a lightweight unit testing framework for shell scripts.

The codebase emphasizes strict clean-code principles, consistent architecture, dependency isolation, and automated verification across all scripts.

---

## Workspace Layout

```
lib-scripts/
├── .ci/
│   └── run-verification.sh     # Static analysis & verification pipeline
├── .cspell/
│   └── custom-dictionary.txt   # Project-specific spelling dictionary
├── cspell.json                 # CSpell configuration
├── script.sh.tmpl              # Canonical template for library scripts
├── src/
│   ├── lib-base.sh             # Base constants, error codes, and utilities (zero dependencies)
└── test/
    ├── lib-tests.sh            # Lightweight unit testing framework (depends on src/lib-base.sh)
    └── test-script.sh.tmpl     # Canonical template for test suites
```

---

## Architectural & Dependency Rules

1. **Strict Dependency Hierarchy**:
   - `src/lib-base.sh` must remain dependency-free (`Dependencies: None`).
   - `test/lib-tests.sh` depends solely on `src/lib-base.sh`.
2. **No Backward Compatibility**:
   - Do not maintain backward compatibility, legacy shims, wrappers, or aliases.
   - Whenever an API, template, or convention changes, all dependent scripts, callers, and tests must immediately adapt and update to the new design.

---

## Script Templates

Do not duplicate structural boilerplate. Always read the relevant template file on demand:

- **Library / Feature Scripts**: Read `script.sh.tmpl` before implementing library utilities or source scripts to follow the canonical header format, source guard, section dividers, and function structure.
- **Test Suites**: Read `test/test-script.sh.tmpl` before writing tests to follow the test suite header, FUT constants, helper patterns, equivalence class table structure, and runner entry point.

---

## Verification & Testing

Verification applies to code files (`.sh`, `.sh.tmpl`). Verification is not needed when changing non-code files (e.g. Markdown, configuration, or documentation files).

### Static Verification

Run the verification script across any modified shell or test script:

```bash
./.ci/run-verification.sh <file_path>
```

If valid project-specific words or identifiers trigger spelling issues, add them in lowercase/canonical form to `.cspell/custom-dictionary.txt`.

### Test Execution

Run the relevant unit test suites directly:

```bash
./test/test-<target>.sh
```
