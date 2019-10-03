ARC GNU Compiler Toolchain [![Build Status](https://travis-ci.org/foss-for-synopsys-dwc-arc-processors/arc-gnu-toolchain.svg?branch=master)](https://travis-ci.org/claziss/arc-gnu-toolchain)
=============================

This is the ARC C and C++ cross-compiler, based on the [RISC-V scripts](https://github.com/riscv/riscv-gnu-toolchain). It supports two build modes: a generic ELF/Newlib toolchain.

###  Getting the sources

This repository uses submodules. You need the --recursive option to fetch the submodules automatically

    $ git clone --recursive https://github.com/claziss/arc-gnu-toolchain

Alternatively :

    $ git clone https://github.com/claziss/arc-gnu-toolchain
    $ cd src-gnu-toolchain
    $ git submodule update --init --recursive



### Prerequisites

Several standard packages are needed to build the toolchain.  On Ubuntu,
executing the following command should suffice:

    $ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev

On Fedora/CentOS/RHEL OS, executing the following command should suffice:

    $ sudo yum install autoconf automake libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel

On OS X, you can use [Homebrew](http://brew.sh) to install the dependencies:

    $ brew install gawk gnu-sed gmp mpfr libmpc isl zlib

This process will start by downloading about 200 MiB of upstream sources, then
will patch, build, and install the toolchain.  If a local cache of the
upstream sources exists in $(DISTDIR), it will be used; the default location
is /var/cache/distfiles.  Your computer will need about 8 GiB of disk space to
complete the process.

### Installation (Newlib)

To build the Newlib cross-compiler, pick an install path.  If you choose,
say, `/opt/arc`, then add `/opt/arc/bin` to your `PATH` now.  Then, simply
run the following command:

    ./configure --prefix=/opt/arc
    make

You should now be able to use arc-gcc and its cousins.

### Advanced Options

There are a number of additional options that may be passed to
configure.  See './configure --help' for more details.

### Test Suite

To test GCC, run the following commands:

    ./configure --prefix=$ARC --disable-linux
    make newlib
    make check-gcc-newlib
