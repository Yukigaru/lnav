AC_DEFUN([LNAV_ENABLE_LTO], [
    AC_ARG_ENABLE([lto],
        AS_HELP_STRING([--enable-lto],
            [enable ThinLTO (default unless --enable-debug)]),
        [lto_is_explicit=yes],
        [AS_IF([test "x$1" = "xyes"],
            [enable_lto=no],
            [enable_lto=yes])
         lto_is_explicit=no])

    AS_CASE([$enable_lto],
        [yes|no], [],
        [AC_MSG_ERROR([invalid value '$enable_lto' for --enable-lto])])

    AS_IF([test "x$enable_lto" = "xyes"], [
        lto_flags="-flto=thin"
        AS_CASE([$host_os], [darwin*], [
            lto_ar=`$CC -print-prog-name=ar`
            lto_ranlib=`$CC -print-prog-name=ranlib`
        ], [
            lto_ar=`$CC -print-prog-name=llvm-ar`
            lto_ranlib=`$CC -print-prog-name=llvm-ranlib`
        ])
        AS_IF([test -z "$AR"], [AR=$lto_ar])
        AS_IF([test -z "$RANLIB"], [RANLIB=$lto_ranlib])

        AC_MSG_CHECKING([whether the ThinLTO toolchain works])
        echo 'int lto_probe(void) { return 0; }' > conftest-lto.c
        echo 'extern "C" int lto_probe(void); int main() { return lto_probe(); }' \
            > conftest-lto.cc
        AS_IF([$CC $CPPFLAGS $CFLAGS $lto_flags -c conftest-lto.c \
                   -o conftest-lto.o >>config.log 2>&1 &&
               $AR cr conftest-lto.a conftest-lto.o >>config.log 2>&1 &&
               $RANLIB conftest-lto.a >>config.log 2>&1 &&
               $CXX $CPPFLAGS $CXXFLAGS $lto_flags conftest-lto.cc \
                   conftest-lto.a $LDFLAGS $lto_flags $LIBS \
                   -o conftest-lto$ac_exeext >>config.log 2>&1],
            [lto_supported=yes],
            [lto_supported=no])
        AC_MSG_RESULT([$lto_supported])
        rm -f conftest-lto.c conftest-lto.cc conftest-lto.o \
              conftest-lto.a conftest-lto$ac_exeext

        AS_IF([test "x$lto_supported" = "xyes"], [
            CFLAGS="$CFLAGS $lto_flags"
            CXXFLAGS="$CXXFLAGS $lto_flags"
            LDFLAGS="$LDFLAGS $lto_flags"
            ac_cv_prog_AR=$AR
            ac_cv_prog_RANLIB=$RANLIB
            AS_UNSET([am_cv_ar_interface])
            AC_MSG_NOTICE([link-time optimization enabled: thin])
        ], [
            AS_IF([test "x$lto_is_explicit" = "xyes"],
                [AC_MSG_ERROR([ThinLTO is not supported])],
                [AC_MSG_WARN([ThinLTO is not supported; disabling it])])
        ])
    ])
])
