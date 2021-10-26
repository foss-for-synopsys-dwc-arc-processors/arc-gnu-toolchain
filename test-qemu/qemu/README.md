Requirements:
- QEMU simulator build for ARCv1/v2 and/or ARCv3:64
- DEJAGNU environment
- ARC's GCC compiler
- ARC `toolchain` repository

Steps to run the DG QEMU tests:
- Have the above tools in path
- Optional: Have environment variable `COMPSRC` defined and pointing to the rooth of `test-qemu`
- In a folder, create a temporary folder (e.g., `mkdir tmp`)
- In the same folder, create the `site.exp` file as described below
- Execute dejagnu (i.e., `runtest`)

Example site.exp for runnint ARC64 QEMU specific tests

```
set tool qemu
set srcdir "$env(COMPSRC)/test-qemu/qemu/testsuite/"
set objdir ./
set tmpdir ./tmp/
set target_alias arc64-elf
set target_triplet arc64-unknown-elf
set arc_board_dir "$env(COMPSRC)/toolchain"
set qemu_serial_io 1

if ![info exists boards_dir] {
    set boards_dir {}
}
lappend boards_dir "$arc_board_dir/dejagnu"
lappend boards_dir "$arc_board_dir/dejagnu/baseboards"

verbose "Global Config File: target_triplet is $target_triplet" 2

set target_list "arc-sim-qemu"

set verbose 0
```

Example site.exp for runnint ARCv1/v2 QEMU specific tests

```
set tool qemu
set srcdir "$env(COMPSRC)/test-qemu/qemu/testsuite/"
set objdir ./
set tmpdir ./tmp/
set target_alias arc-elf32
set target_triplet arc-unknown-elf32
set arc_board_dir "$env(COMPSRC)/toolchain"
set qemu_serial_io 1

if ![info exists boards_dir] {
    set boards_dir {}
}
lappend boards_dir "$arc_board_dir/dejagnu"
lappend boards_dir "$arc_board_dir/dejagnu/baseboards"

verbose "Global Config File: target_triplet is $target_triplet" 2

set target_list "arc-sim-qemu"

set verbose 0
```

