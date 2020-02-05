ARC GNU Compiler Toolchain [![Build Status](https://travis-ci.org/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain.svg?branch=master)](https://travis-ci.org/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain)
=============================

This is the ARC C and C++ cross-compiler, based on the [RISC-V scripts](https://github.com/riscv/riscv-gnu-toolchain). It supports two build modes: a generic ELF/Newlib toolchain.

###  Getting the sources

    $ git clone https://github.com/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain

This repository checks for the existance of the following directories:

    arc-binutils-gdb
    arc-gcc
    arc-newlib

If they do not exist, it will clone them. You can link your source directories
from other palces as well:

    $ cd arc-gnu-toolchain
    $ ln -s /repos/arcgnu/binutils  arc-binutils-gdb
    $ ln -s /repos/arcgnu/gcc       arc-gcc
    $ ln -s /repos/arcgnu/newlib    arc-newlib

For a 64-bit build, you will need the following branches:

| repo         | branch |
|--------------|--------|
| binutils-gdb | arc64  |
| gcc          | arc64  |
| newlib       | arc64  |

Last but not least, if you plan to run DejaGnu later, you must use:

| repo         | branch    |
|--------------|-----------|
| toolchain    | arc64-dev |


### Prerequisites

Several standard packages are needed to build the toolchain.  On Ubuntu,
executing the following command should suffice:

    $ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential libncurses-dev bison flex texinfo gperf libtool patchutils bc zlib1g-dev

On Fedora/CentOS/RHEL OS, executing the following command should suffice:

    $ sudo yum install autoconf automake libmpc-devel mpfr-devel gmp-devel gawk ncurses-devel bison flex texinfo patchutils gcc gcc-c++ zlib-devel

On OS X, you can use [Homebrew](http://brew.sh) to install the dependencies:

    $ brew install gawk gnu-sed gmp mpfr libmpc isl zlib

This process will start by downloading about 200 MiB of upstream sources, then
will patch, build, and install the toolchain.  If a local cache of the
upstream sources exists in $(DISTDIR), it will be used; the default location
is /var/cache/distfiles.  Your computer will need about 8 GiB of disk space to
complete the process.

### Configure generation
You can (re)generate the `configure` script with:

    $ cd arc-gnu-toolchain
    $ autoconf

### Building and installing
Configure and build with:

    $ cd arc-gnu-toolchain
    $ ./configure --prefix=/path/to/install/toolchain
    $ make -j $(nproc)
    $ make install
 
Some of parameters you can pass to the configure script:

| parameter         | default   | values                           |
|-------------------|-----------|----------------------------------|
| --target          | arc64-elf | arc64-elf, arc-elf32             |
| --prefix          |           | any path string for installation |
| --enable-multilib | no        | yes, no (--disable-multilib)     |
| --enable-qemu     | no        | yes, no (--disable-qemu)         |

### Advanced Options

There are a number of additional options that may be passed to
configure.  See './configure --help' for more details.

### Test Suite

To test GCC, run the following commands:

    ./configure --prefix=$ARC --disable-linux
    make newlib
    make check-gcc-newlib
