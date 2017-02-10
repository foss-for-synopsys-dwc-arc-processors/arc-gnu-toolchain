AC_INIT(arc-toolchain, 1.0)

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
	[AC_SUBST(default_target, newlib)])

AC_ARG_WITH(cpu,
	[AS_HELP_STRING([--with-cpu=archs],
		[Sets the base ARC ISA, defaults to archs])],
	[],
	[with_cpu=archs]
	)

AC_SUBST(WITH_ARCH, --with-cpu=$with_cpu)

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
        [enable_gcc_checking=yes]
        )
AS_IF([test "x$enable_gcc_checking" != xno],
	[AC_SUBST(gcc_checking, --enable-checking=yes)],
	[AC_SUBST(gcc_checking, --enable-checking=release)])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([scripts/wrapper/awk/awk], [chmod +x scripts/wrapper/awk])
AC_CONFIG_FILES([scripts/wrapper/sed/sed], [chmod +x scripts/wrapper/sed])

AC_OUTPUT
