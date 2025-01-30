AC_INIT(DESCRIPTION)

AC_CONFIG_FILES(src/Makevars)

AC_PATH_PROGS(PKG_CONFIG, pkg-config)

${PKG_CONFIG} --exists nss

# Need both nss and nspr as the nss .pc file doesn't pick up the
# dependency on nspr.

if test $? = 0 ; then
  PKG_CPPFLAGS="$PKG_CPPFLAGS `${PKG_CONFIG} --cflags nss nspr`"
  PKG_LIBS="$PKG_LIBS `${PKG_CONFIG} --libs nss nspr`"
  echo "Found lib nss"
else
  echo "pkg-config didn't find the nss library. Using /usr/local/include"
fi


if test -n "$PKG_CPPFLAGS" ; then
  echo "setting HAVE_NSS - $PKG_CPPFLAGS"
  PKG_CPPFLAGS="$PKG_CPPFLAGS  -DHAVE_NSS=1"
fi


AC_SUBST(PKG_CPPFLAGS)
AC_SUBST(PKG_LIBS)

AC_OUTPUT()



