AC_INIT([arc-toolchain],[1.0])

AC_PROG_CC
AC_PROG_FGREP
AC_PROG_GREP

AC_PATH_PROG([BASH], [bash],
	[AC_MSG_ERROR([bash not found])])

AC_PATH_PROGS_FEATURE_CHECK([GAWK], [gawk awk],
	[AS_IF([$ac_path_GAWK --version 2>&1 | $FGREP GNU >/dev/null],
		[ac_cv_path_GAWK=$ac_path_GAWK ac_path_GAWK_found=:])],
	[AC_MSG_ERROR([GNU Awk not found])])
AC_SUBST([GAWK], [$ac_cv_path_GAWK])

AC_PATH_PROGS_FEATURE_CHECK([GSED], [gsed sed],
	[AS_IF([$ac_path_GSED --version 2>&1 | $FGREP GNU >/dev/null],
		[ac_cv_path_GSED=$ac_path_GSED ac_path_GSED_found=:])],
	[AC_MSG_ERROR([GNU sed not found])])
AC_SUBST([GSED], [$ac_cv_path_GSED])

need_gcc_external_libraries="no"
AC_CHECK_LIB(gmp, __gmpz_init, ,
        [need_gcc_external_libraries="yes"])
AC_CHECK_LIB(mpfr, mpfr_init, ,
        [need_gcc_external_libraries="yes"])
AC_CHECK_LIB(mpc, mpc_init2, ,
        [need_gcc_external_libraries="yes"])
AS_IF([test x"$need_gcc_external_libraries" != xno],
      [AC_SUBST(NEED_GCC_EXTERNAL_LIBRARIES,true)],
      [AC_SUBST(NEED_GCC_EXTERNAL_LIBRARIES,false)])

AC_PATH_PROG([CURL], [curl], [no])
AC_PATH_PROG([WGET], [wget], [no])
AC_PATH_PROG([FTP], [ftp], [no])
AS_IF([test x"$CURL" != xno], [FETCHER="$CURL -L -o - --ftp-pasv --retry 10"],
	[test x"$WGET" != xno], [FETCHER="$WGET -O -"],
	[test x"$FTP" != xno], [FETCHER="$FTP -o - -p"],
	[AC_MSG_ERROR([no file transfer utility found])])
AC_SUBST(FETCHER)

AC_ARG_ENABLE(linux,
        [AS_HELP_STRING([--enable-linux],
		[set linux as the default make target @<:@--disable-linux@:>@])],
        [],
        [enable_linux=no]
        )

AS_IF([test "x$enable_linux" != xno],
	[AC_SUBST(default_target, linux)],
	[AC_SUBST(default_target, baremetal)])

AC_ARG_ENABLE(qemu,
        [AS_HELP_STRING([--enable-qemu],
		[enable building ARC QEMU @<:@--disable-qemu@:>@])],
        [],
        [enable_qemu=no]
        )

AS_IF([test "x$enable_qemu" != xno],
	[AC_SUBST(qemu_build, qemu)],
	[])

AC_ARG_WITH(sim,
		[AS_HELP_STRING([--with-sim=SIM],
		[Sets the base ARC Simulator @<:@--with-cpu=qemu@:>@])],
		[],
		[with_sim=default]
		)

AS_IF([test "x$with_sim" != xdefault],
	    [AC_SUBST(with_sim, $with_sim)],
	    [AC_SUBST(with_sim,"qemu")])


AC_ARG_ENABLE(werror,
        [AS_HELP_STRING([--enable-werror],
		[controls if build is compiled with werror or not @<:@--disable-werror@:>@])],
        [],
        [enable_werror=yes]
        )

AS_IF([test "x$enable_werror" != xno],
	[AC_SUBST(werror_flag, --enable-werror)],
	[AC_SUBST(werror_flag, --disable-werror)])

AC_ARG_WITH(cpu,
	[AS_HELP_STRING([--with-cpu=CPU],
		[Sets the base ARC ISA @<:@--with-cpu=archs@:>@])],
	[],
	[with_cpu=default]
	)

AS_IF([test "x$with_cpu" != xdefault],
	    [AC_SUBST(with_cpu, --with-cpu=$with_cpu)],
	    [AC_SUBST(with_cpu,"")])

AC_ARG_WITH(fpu,
	[AS_HELP_STRING([--with-fpu=FPU],
		[Sets default FPU support @<:@--with-fpu=fpus@:>@])],
	[],
	[with_fpu=none]
	)

AS_IF([test "x$with_fpu" != xnone],
	    [AC_SUBST(with_fpu, --with-fpu=$with_fpu)],
	    [AC_SUBST(with_fpu,"")])

AS_IF([test "x$with_host" != xdefault],
	[AC_SUBST(configure_host,--host=$with_host)],
	[AC_SUBST(configure_host,"")])

AC_ARG_WITH(system-zlib,
	[AS_HELP_STRING([--with-system-zlib],
		[use zlib from the system instead of the builtin copy from GCC @<:@--with-system-zlib@:>@])],
	[],
	[with_system_zlib=yes]
	)

AS_IF([test "x$with_system_zlib" != xno],
	[AC_SUBST(with_system_zlib,--with-system-zlib)],
	[AC_SUBST(with_system_zlib,--without-system-zlib)])

AC_ARG_ENABLE(multilib,
	[AS_HELP_STRING([--enable-multilib],
		[build all ARC runtime libraries @<:@--disable-multilib@:>@])],
	[],
	[enable_multilib=no]
	)

AS_IF([test "x$enable_multilib" != xno],
        [AC_SUBST(multilib_flags,--enable-multilib)],
	[AC_SUBST(multilib_flags,--disable-multilib)])

AC_ARG_ENABLE(gcc-checking,
        [AS_HELP_STRING([--enable-gcc-checking],
		[Enable gcc internal checking, it will make gcc very slow, only enable it when developing gcc @<:@--disable-gcc-checking@:>@])],
        [],
        [enable_gcc_checking=no]
        )
AS_IF([test "x$enable_gcc_checking" != xno],
	[AC_SUBST(gcc_checking, --enable-checking=yes)],
	[AC_SUBST(gcc_checking, --enable-checking=release)])

AC_ARG_WITH(cmodel,
	[AS_HELP_STRING([--with-cmodel],
		[Select the code model to use when building libc and libgcc @<:@--with-cmodel=medlow@:>@])],
	[],
	[]
	)
AS_IF([test "x$with_cmodel" != x],
      	[AC_SUBST(cmodel, -mcmodel=$with_cmodel)],
	[AC_SUBST(cmodel, "")])
#	[AC_SUBST(cmodel, -mcmodel=medlow)])

AC_ARG_WITH(target_cflags,
	[AS_HELP_STRING([--with-target-cflags],
		[Add extra target flags for C for library code])],
	[],
	[]
	)
AC_SUBST(target_cflags, $with_target_cflags)
AC_ARG_WITH(target_cxxflags,
	[AS_HELP_STRING([--with-target-cxxflags],
		[Add extra target flags for C++ for library code])],
	[],
	[]
	)
AC_SUBST(target_cxxflags, $with_target_cxxflags)


AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([scripts/wrapper/awk/awk], [chmod +x scripts/wrapper/awk])
AC_CONFIG_FILES([scripts/wrapper/sed/sed], [chmod +x scripts/wrapper/sed])

AC_ARG_WITH(linux-headers-src,
	[AS_HELP_STRING([--with-linux-headers-src],[Set linux-headers source path, use builtin source by default])],
	[],
	[with_linux_headers_src=default]
	)

AS_IF([test "x$with_linux_headers_src" != xdefault],
	[AC_SUBST(with_linux_headers_src,$with_linux_headers_src)],
	[AC_SUBST(with_linux_headers_src,"\$(srcdir)/linux-headers/include")])


AC_OUTPUT

AC_OUTPUT
