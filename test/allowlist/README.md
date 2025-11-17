
The files in this folder are the allowlists for the testsuite results that are passed as an argument for the `arc-gnu-toolchain/scripts/testsuite-filter` script.

## Format

Allowlists use a simple log file format with `.log` extensions. This format aligns with the approach used by [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain).

### Log File Structure

Each allowlist directory contains separate log files for different C libraries:
- `common.log` - Tests common to all C libraries
- `newlib.log` - Tests specific to newlib
- `glibc.log` - Tests specific to glibc

### Log File Format

Log files follow these rules:
- Lines starting with `#` are treated as comments
- Empty lines are ignored
- Test entries follow the format: `STATUS: test.name ...`

Valid status values include: `FAIL`, `XPASS`, `ERROR`, `UNRESOLVED`

### Example

Here is an example of how a log file may be structured:

```
#
# Common tests that fail on all configurations
#
FAIL: folder/test_01.S compilation
XPASS: folder/test_02.S compilation
FAIL: folder/test_03.S compilation

#
# Tests related to optimization flags
#
FAIL: folder/test_04.S   -O2  execution test
XPASS: folder/test_05.S   -O3  execution test

#
# Known issues with specific test cases
#
FAIL: folder/test_06.S scan-assembler pattern
```

## Directory Structure

```
test/allowlist/
├── gcc/
│   ├── archs/
│   │   ├── common.log
│   │   ├── newlib.log
│   │   └── glibc.log
│   └── hs6x/
│       ├── common.log
│       ├── newlib.log
│       └── glibc.log
├── binutils/
│   ├── archs/
│   │   ├── common.log
│   │   ├── newlib.log
│   │   └── glibc.log
│   └── hs6x/
│       └── ...
└── qemu/
    ├── archs/
    │   ├── ...
    └── hs6x/
        └── ...
```

## Usage

The `testsuite-filter` script automatically loads:
1. `common.log` (if it exists) - applied to all libc configurations
2. `<libc>.log` (e.g., `newlib.log` or `glibc.log`) - libc-specific tests

Both files are combined to create the complete allowlist for filtering.

Example:
```bash
scripts/testsuite-filter gcc newlib test/allowlist/gcc/archs/ gcc.sum,g++.sum
```

This will load:
- `test/allowlist/gcc/archs/common.log`
- `test/allowlist/gcc/archs/newlib.log`
