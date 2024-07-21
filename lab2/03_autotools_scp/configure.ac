AC_PREREQ([2.71])
AC_INIT([stupid_c_prog], [1], [Zhejian.23@intl.zju.edu.cn])

AC_CONFIG_SRCDIR()
AC_CONFIG_HEADERS([config.h])
# Initialize automake
AM_INIT_AUTOMAKE([-Wall -Werror foreign subdir-objects])
AC_CONFIG_FILES([Makefile])
# Initialize GNU Libtool
AM_PROG_AR
LT_INIT

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADER(
[stdio.h],[],[
echo "Failed to found <stdio.h>!"; exit 1
]
)

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CHECK_LIB([c],[printf],[
echo "Found printf on -lc, nice."
],[
echo "Failed to found printf in -lc!"; exit 1
])

CFLAGS="-DBUILT_UNDER_AUTOTOOLS"

AC_OUTPUT
