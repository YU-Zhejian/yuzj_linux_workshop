# ...

```shell
cp ../src/* .
```

```shell
autoreconf -f -v -i
autoheader
```

```text
autoreconf: export WARNINGS=
autoreconf: Entering directory '.'
autoreconf: configure.ac: not using Gettext
autoreconf: running: aclocal --force 
autoreconf: configure.ac: tracing
autoreconf: configure.ac: not using Libtool
autoreconf: configure.ac: not using Intltool
autoreconf: configure.ac: not using Gtkdoc
autoreconf: running: /usr/bin/autoconf --force
configure.ac:3: warning: AM_INIT_AUTOMAKE: two- and three-arguments forms are deprecated.
./lib/autoconf/general.m4:2434: AC_DIAGNOSE is expanded from...
aclocal.m4:429: AM_INIT_AUTOMAKE is expanded from...
configure.ac:3: the top level
autoreconf: running: /usr/bin/autoheader --force
autoreconf: running: automake --add-missing --copy --force-missing
configure.ac:3: warning: AM_INIT_AUTOMAKE: two- and three-arguments forms are deprecated.  For more info, see:
configure.ac:3: https://www.gnu.org/software/automake/manual/automake.html#Modernize-AM_005fINIT_005fAUTOMAKE-invocation
configure.ac:8: installing './compile'
configure.ac:3: installing './install-sh'
configure.ac:3: installing './missing'
automake: error: no 'Makefile.am' found for any configure output
autoreconf: error: automake failed with exit status: 
```

```shell
./configure
```

```text
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a race-free mkdir -p... /usr/bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether the compiler supports GNU C... yes
checking whether make supports the include directive... yes (GNU style)
checking dependency style of gcc... none
checking that generated files are newer than configure... done
configure: creating ./config.status
config.status: creating config.h
config.status: executing depfiles commands
```
