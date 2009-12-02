# Process this file with autoconf to produce a configure script.
# Configure template for pkgserv
#
# $Id: configure.ac,v 1.5 2009-12-02 11:03:42 oops Exp $

#
AC_PREREQ(2.53)

AC_SUBST(filterdir)
AC_SUBST(perlpath)
AC_SUBST(procpath)

AC_INIT([byspam], [1.0.3], [http://devel.oops.org])
AC_CONFIG_SRCDIR([README])
AC_CONFIG_HEADERS(config.h)
AC_PREFIX_DEFAULT([/usr/local/byspam])

AC_ARG_WITH(filter,
[  --with-filter=PATH      byspam filter path (default @sysconfdir@/Filter)])

AC_ARG_WITH(procrc,
[  --with-procrc=PATH      procmailrc path (default /etc/procmailrc)])

AC_ARG_WITH(perl,
[  --with-perl=PATH        perl path (system default)])

# Checks for programs.
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_AWK

AC_PATH_PROG(RM, rm)
if test ! -f "$ac_cv_path_RM"; then
  AC_MSG_ERROR(Can't not found rm)
fi

AC_PATH_PROG(SED, sed)
if test ! -f "$ac_cv_path_SED"; then
  AC_MSG_ERROR(Can't not found sed)
fi

AC_PATH_PROG(LS, ls)
if test ! -f "$ac_cv_path_LS"; then
  AC_MSG_ERROR(Can't not found ls)
fi

AC_PATH_PROG(MKDIR, mkdir)
if test ! -f "$ac_cv_path_MKDIR"; then
  AC_MSG_ERROR(Can't not found mkdir)
fi

AC_PATH_PROG(GREP, grep)
if test ! -f "$ac_cv_path_GREP"; then
  AC_MSG_ERROR(Can't not found grep)
fi

if test "x$with_perl" != "x"; then
  if test -f $with_perl ; then
    AC_MSG_CHECKING(for perl)
    AC_MSG_RESULT([$with_perl])
    perlpath=$with_perl
  else
    AC_PATH_PROG(PERL, perl)
    if test "x$ac_cv_path_PERL " != "x"; then
      perlpath=$ac_cv_path_PERL
    else
      AC_MSG_ERROR(Can't not found perl)
    fi
  fi
else
  AC_PATH_PROG(PERL, perl)
  if test "x$ac_cv_path_PERL " != "x"; then
    perlpath=$ac_cv_path_PERL
  else
    AC_MSG_ERROR(Can't not found perl)
  fi
fi

if test "x$with_procrc" != "x"; then
  if test -f "$with_procrc" ; then
    procpath=$with_procrc
  else
    AC_MSG_ERROR(Can't not found procmailrc)
  fi
else
  procpath="/etc/procmailrc"
fi

if test "x$with_filter" != "x"; then
  filterdir=$with_filter
else
  filterdir=$sysconfdir/Filter
fi

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
