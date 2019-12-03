export CURRENT_PATH=`pwd`/../
export WORKSPACE_DIR=${CURRENT_PATH}/workspace
export SOURCE_DIR=${CURRENT_PATH}
export BUILD_DIR=${WORKSPACE_DIR}/build
export INSTALL_DIR=$(cat ${CURRENT_PATH}/stamps/install_dir)
export QEMU_HOME=${INSTALL_DIR}

export PATH=${INSTALL_DIR}/bin:${PATH}

export DEJAGNU=${SOURCE_DIR}/arc-toolchain/site.exp
export ARC_MULTILIB_OPTIONS=archs
export ARC_NSIM_OPTS="-p nsim_isa_code_density_option=2"

export SYSROOT_DIR=${INSTALL_DIR}/arc-snps-linux-gnu/sysroot

export USE_NEWLIB=0
export CONFIGURATION_OPTIONS="--disable-multilib --disable-threads"
