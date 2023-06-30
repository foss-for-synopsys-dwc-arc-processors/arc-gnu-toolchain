# ARC GNU Compiler Toolchain [![Build Status](https://github.com/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain/actions/workflows/ci.yml/badge.svg)](https://github.com/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain/actions/workflows/ci.yml) [![Downloads Satus](https://img.shields.io/github/downloads/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain/total?longCache=true&style=flat&label=Downloads&logoColor=fff&logo=GitHub)](https://github.com/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain/releases)

This is the ARC C and C++ cross-compiler, based on the [RISC-V scripts](https://github.com/riscv/riscv-gnu-toolchain). It supports two build modes: a generic ELF/Newlib toolchain.

## Getting the sources

```sh
git clone https://github.com/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain
```

This repository checks for the existance of the following directories:

```sh
binutils-gdb
gcc
newlib
glibc
```

If they do not exist, it will clone them. You can link your source directories
from other palces as well:

```sh
cd    /repos/arc-gnu-toolchain
ln -s /repos/tools/binutils  binutils-gdb
ln -s /repos/tools/gcc       gcc
ln -s /repos/tools/newlib    newlib
ln -s /repos/tools/glibc     glibc

cd    /build/arc64
/repos/arc-gnu-toolchain/configure ...
```

For a 64-bit linux build, you will need the following branches:

| repo         | branch |
|--------------|--------|
| binutils-gdb | arc64  |
| gcc          | arc64  |
| newlib       | arc64  |
| glibc        | arc64  |

For a 64-bit baremetal build, you don't need the glibc.

Last but not least, if you plan to run DejaGnu later, you must use:

| repo         | branch  |
|--------------|---------|
| toolchain    | arc-dev |

## Prerequisites

Several standard packages are needed to build the toolchain.  On Ubuntu,
executing the following command should suffice:

```sh
sudo apt-get install -y --no-install-recommends \
    autoconf        \
    automake        \
    autotools-dev   \
    curl            \
    libmpc-dev      \
    libmpfr-dev     \
    libgmp-dev      \
    libexpat1-dev   \
    gawk            \
    build-essential \
    libncurses-dev  \
    bison           \
    flex            \
    texinfo         \
    gperf           \
    libtool         \
    patchutils      \
    bc              \
    zlib1g-dev
```

On Fedora/CentOS/RHEL OS, executing the following command should suffice:

```sh
sudo yum install autoconf automake libmpc-devel mpfr-devel gmp-devel gawk ncurses-devel bison flex texinfo patchutils gcc gcc-c++ zlib-devel
```

On OS X, you can use [Homebrew](http://brew.sh) to install the dependencies:

```sh
brew install gawk gnu-sed gmp mpfr libmpc isl zlib
```

On Void Linux, at least these packages are required:

```sh
xbps-install libmpc-devel ncurses-devel texinfo bison flex
```

This process will start by downloading about 200 MiB of upstream sources, then
will patch, build, and install the toolchain.  If a local cache of the
upstream sources exists in $(DISTDIR), it will be used; the default location
is /var/cache/distfiles.  Your computer will need about 8 GiB of disk space to
complete the process.

## Configure generation

You can (re)generate the `configure` script with:

```sh
cd arc-gnu-toolchain
autoconf
```

## Building and installing

Configure and build with:

```sh
cd arc-gnu-toolchain
./configure --prefix=/path/to/install/toolchain
make -j $(nproc)
make install
```

Some of parameters you can pass to the configure script:

| parameter           | default | values                                                                          |
|---------------------|---------|---------------------------------------------------------------------------------|
| --target            |         | arc64, arc32, arc                                                               |
| --prefix            |         | any path string for installation                                                |
| --enable-linux      | no      | yes, no (--disable-linux)                                                       |
| --enable-multilib   | no      | yes, no (--disable-multilib)                                                    |
| --enable-qemu       | no      | yes, no (--disable-qemu)                                                        |
| --enable-debug-info | no      | yes, no (--disable-debug-info)                                                  |
| --with-fpu          | none    | none, fpus, fpud                                                                |
| --with-cpu          | none    | none, hs6x, hs68, hs5x, hs58, archs, (more at binutils/include/elf/arc-cpu.def) |
| --with-sim          | qemu    | qemu, nsim                                                                      |

### Advanced Options

There are a number of additional options that may be passed to
configure.  See `./configure --help` for more details.

## Recipes

### Baremetal

```sh
$ ./configure --target=arc64 --prefix=/path/to/install
```

```sh
$ ./configure --target=arc32            \
              --prefix=/path/to/install \
              --disable-qemu            \
              --enable-multilib         \
              --disable-werror
```

### Linux

```sh
$ ./configure --target=arc64            \
              --prefix=/path/to/install \
              --enable-linux
```

## Running Test Suite

At present, the testing environment comprises three integrated testsuites: `gcc/g++`, `binutils`, and `newlib`. Testing is possible for both Baremetal Toolchain Distribution and Linux Toolchain Distribution (user-mode), via two simulators, QEMU and nSIM.

### Setting up the Simulator

During the toolchain compilation process, you can choose the simulator to use for testing. There are two options available: QEMU, an open-source simulator, and nSIM, a proprietary simulator provided by Synopsys. By default, QEMU is the chosen simulator.

1. If the selected simulator is QEMU, the testing will clone QEMU’s repository from the official Synopsys QEMU repository and build it  by   according to the branch specified in the Makefile file. The simulator will be installed based on the prefix path provided during the toolchain distribution’s configuration stage.
```sh
$ ./configure --target=... --prefix=/path/to/install --with-sim=qemu
```
2. If nSIM is preferred over QEMU, ensure that the simulator is defined in the PATH environment variable before executing the testing.
```sh
$ ./configure --target=... --prefix=/path/to/install --with-sim=nsim
```


### Reporting GCC/C++, Binutils, and Newlib

To execute toolchain tests, running the command `make report` will run all the tests in the GCC regression test suite. This command automatically invokes the GCC/G++, Binutils and Newlib testsuites to perform the respective tests. At the end of the execution, a report is generated by a testsuite filter script. This report filters known errors and displays only the unknown ones. Depending on the testsuite tool and CPU used, different filters with JSON format files are utilized. These files can be found in the `arc-gnu-toolchain/test/allowlist` folder.

To generate the report and perform the testing, use the following command:
```bash
$ make report -j$(nproc)
```
Running this command in parallel (e.g., “make report -j32”) will significantly speed up the execution time on multi-processor systems.

### Selecting the tests to run in GCC's regression test suite

By default, DejaGNU runs all tests in its regression test suite. However, executing all these tests can take a significant amount of time, which is impractical for typical development cycles. To address this, DejaGNU provides the option to select specific tests using the environment variable `RUNTESTFLAGS`.

For instance, if you want to run only the tests related to `tls`, you can use the following command:
```bash
RUNTESTFLAGS="tls.exp" make report
```

Likewise, if you wish to run a specific test, such as `thread_local-order2.C` within the `tls` tests, you can use the following command:
```bash
RUNTESTFLAGS="tls.exp=thread_local-order2.C" make report
```

These commands allow you to focus on specific test cases and streamline the execution time accordingly.



### Testing GCC/C++, Binutils, and Newlib

Alternatevely to the `report` command, in order to **only** execute all the associated test suite with the toolchain distribution, execute the following command:

```sh
$ make check -j $(nproc)
```

Refer to the table below to determine the suitable command for running an individual testsuite based on the current toolchain distribution.

| Toolchain Distribution | Test Suite | Command                           |
|:-----------------------|:-----------|:----------------------------------|
| Baremetal              | gcc        | `$ make check-gcc-baremetal`      |
| Baremetal              | binutils   | `$ make check-binutils-baremetal` |
| Baremetal              | newlib     | `$ make check-newlib-baremetal`   |
| Linux                  | gcc        | `$ make check-gcc-linux`          |
| Linux                  | binutils   | `$ make check-binutils-linux`     |

