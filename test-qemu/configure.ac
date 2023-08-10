AC_INIT([QEMU-TESTSUITE], [1.0])

AC_SUBST([SRCDIR], ["$srcdir"])

AC_ARG_WITH([triplet],
  [AS_HELP_STRING([--with-triplet],
                  [specify the target triplet])],
  [target_triplet="$withval"],
  [target_triplet=""])

AS_IF([test "x$target_triplet" != ""],
	    [AC_SUBST(target_triplet, $target_triplet)])

AC_ARG_WITH([alias],
  [AS_HELP_STRING([--with-alias],
                  [specify the target alias])],
  [target_alias="$withval"],
  [target_alias=""])

AS_IF([test "x$target_alias" != ""],
	    [AC_SUBST(target_alias, $target_alias)])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
