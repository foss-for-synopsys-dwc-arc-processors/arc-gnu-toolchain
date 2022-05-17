# ARC GNU Compiler Toolchain [![Build Status](https://github.com/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain/actions/workflows/ci.yml/badge.svg)](https://github.com/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain/actions/workflows/ci.yml)

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
cd arc-gnu-toolchain
ln -s /repos/arcgnu/binutils  binutils-gdb
ln -s /repos/arcgnu/gcc       gcc
ln -s /repos/arcgnu/newlib    newlib
ln -s /repos/arcgnu/glibc     glibc
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

| parameter         | default | values                           |
|-------------------|---------|----------------------------------|
| --target          |         | arc64, arc32, arc                |
| --prefix          | ./NONE  | any path string for installation |
| --enable-linux    | no      | yes, no (--disable-linux)        |
| --enable-multilib | no      | yes, no (--disable-multilib)     |
| --enable-qemu     | no      | yes, no (--disable-qemu)         |
| --with-fpu        | none    | none, fpus, fpud                 |
| --with-cpu        | none    | none, hs6x, hs68, hs5x, hs58     |


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

### Running GCC Test Suite

```sh
$ ./configure --target=... --prefix=/path/to/install --disable-linux
$ make newlib
$ make check-gcc-newlib
```
