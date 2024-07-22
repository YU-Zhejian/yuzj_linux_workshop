# Stupid C Program using GNU AutoTools

The presence of `configure.ac` or `configure` indicates that the underlying project is built under GNU AutoTools.

Before this tutorial, we need to copy the source code into this directory.

```bash
cp -v ../src/*.c ../src/*.h .
```

Firstly, we need to examine whether `configure` script is presented. If not, we may generate a `configure` using `autoreconf` (An executable from GNU AutoConf):

```bash
autoreconf -f -v -i
# autoreconf: export WARNINGS=
# autoreconf: Entering directory '.'
# autoreconf: configure.ac: not using Gettext
# autoreconf: running: aclocal --force 
# autoreconf: configure.ac: tracing
# autoreconf: running: libtoolize --copy --force
# libtoolize: putting auxiliary files in '.'.
# libtoolize: copying file './ltmain.sh'
# libtoolize: Consider adding 'AC_CONFIG_MACRO_DIRS([m4])' to configure.ac,
# libtoolize: and rerunning libtoolize and aclocal.
# libtoolize: Consider adding '-I m4' to ACLOCAL_AMFLAGS in Makefile.am.
# autoreconf: configure.ac: not using Intltool
# autoreconf: configure.ac: not using Gtkdoc
# autoreconf: running: aclocal --force 
# autoreconf: running: /usr/bin/autoconf --force
# autoreconf: running: /usr/bin/autoheader --force
# autoreconf: running: automake --add-missing --copy --force-missing
# configure.ac:10: installing './ar-lib'
# configure.ac:10: installing './compile'
# configure.ac:11: installing './config.guess'
# configure.ac:11: installing './config.sub'
# configure.ac:7: installing './install-sh'
# configure.ac:7: installing './missing'
# Makefile.am: installing './depcomp'
# Makefile.am:13: installing './texinfo.tex'
# parallel-tests: installing './test-driver'
# autoreconf: Leaving directory '.'
```

Note that this also generates `Makefile.in` from `Makefile.am` since we require GNU AutoMake in `configure.ac`. It also generates `ltmain.sh`, a Shell script containing GNU LibTool under the current platform. If your `configure.ac` does not require above modules, they may not be presented.

Now we have `configure`. Let's do the configuration. The script will turn `Makefile.in` into `Makefile`, allowing us to build the program using GNU Make.

```bash
env -i PATH="/usr/bin" ./configure --prefix="$(pwd)/opt"
# checking for a BSD-compatible install... /usr/bin/install -c
# checking whether build environment is sane... yes
# checking for a race-free mkdir -p... /usr/bin/mkdir -p
# checking for gawk... gawk
# checking whether make sets $(MAKE)... yes
# checking whether make supports nested variables... yes
# checking whether make supports the include directive... yes (GNU style)
# checking for gcc... gcc
# checking whether the C compiler works... yes
# checking for C compiler default output file name... a.out
# checking for suffix of executables... 
# checking whether we are cross compiling... no
# checking for suffix of object files... o
# checking whether the compiler supports GNU C... yes
# checking whether gcc accepts -g... yes
# checking for gcc option to enable C11 features... none needed
# checking whether gcc understands -c and -o together... yes
# checking dependency style of gcc... gcc3
# checking for ar... ar
# checking the archiver (ar) interface... ar
# checking build system type... x86_64-pc-linux-gnu
# checking host system type... x86_64-pc-linux-gnu
# checking how to print strings... printf
# checking for a sed that does not truncate output... /usr/bin/sed
# checking for grep that handles long lines and -e... /usr/bin/grep
# checking for egrep... /usr/bin/grep -E
# checking for fgrep... /usr/bin/grep -F
# checking for ld used by gcc... /usr/bin/ld
# checking if the linker (/usr/bin/ld) is GNU ld... yes
# checking for BSD- or MS-compatible name lister (nm)... /usr/bin/nm -B
# checking the name lister (/usr/bin/nm -B) interface... BSD nm
# checking whether ln -s works... yes
# checking the maximum length of command line arguments... 1572864
# checking how to convert x86_64-pc-linux-gnu file names to
# x86_64-pc-linux-gnu format... func_convert_file_noop
# checking how to convert x86_64-pc-linux-gnu file names to toolchain
# format... func_convert_file_noop
# checking for /usr/bin/ld option to reload object files... -r
# checking for file... file
# checking for objdump... objdump
# checking how to recognize dependent libraries... pass_all
# checking for dlltool... no
# checking how to associate runtime and link libraries... printf %s\n
# checking for archiver @FILE support... @
# checking for strip... strip
# checking for ranlib... ranlib
# checking command to parse /usr/bin/nm -B output from gcc object... ok
# checking for sysroot... no
# checking for a working dd... /usr/bin/dd
# checking how to truncate binary pipes... /usr/bin/dd bs=4096 count=1
# checking for mt... mt
# checking if mt is a manifest tool... no
# checking for stdio.h... yes
# checking for stdlib.h... yes
# checking for string.h... yes
# checking for inttypes.h... yes
# checking for stdint.h... yes
# checking for strings.h... yes
# checking for sys/stat.h... yes
# checking for sys/types.h... yes
# checking for unistd.h... yes
# checking for dlfcn.h... yes
# checking for objdir... .libs
# checking if gcc supports -fno-rtti -fno-exceptions... no
# checking for gcc option to produce PIC... -fPIC -DPIC
# checking if gcc PIC flag -fPIC -DPIC works... yes
# checking if gcc static flag -static works... yes
# checking if gcc supports -c -o file.o... yes
# checking if gcc supports -c -o file.o... (cached) yes
# checking whether the gcc linker (/usr/bin/ld -m elf_x86_64) supports
# shared libraries... yes
# checking whether -lc should be explicitly linked in... no
# checking dynamic linker characteristics... GNU/Linux ld.so
# checking how to hardcode library paths into programs... immediate
# checking whether stripping libraries is possible... yes
# checking if libtool supports shared libraries... yes
# checking whether to build shared libraries... yes
# checking whether to build static libraries... yes
# checking for gcc... (cached) gcc
# checking whether the compiler supports GNU C... (cached) yes
# checking whether gcc accepts -g... (cached) yes
# checking for gcc option to enable C11 features... (cached) none needed
# checking whether gcc understands -c and -o together... (cached) yes
# checking dependency style of gcc... (cached) gcc3
# checking for stdio.h... (cached) yes
# checking for printf in -lc... yes
# Found printf on -lc, nice.
# checking that generated files are newer than configure... done
# configure: creating ./config.status
# config.status: creating Makefile
# config.status: creating config.h
# config.status: executing depfiles commands
# config.status: executing libtool commands
```

Now we have `Makefile`. We may use `make install` to build and install the executables and libraries:

```bash
env -i PATH="/usr/bin" make -j8 install
# [...]
```

If you have GNU TexInfo installed, you may also build documentations in such format (`stupid.texi`) to GNU Info, Postscript (PS), PDF, DVI, and HTML through:

```bash
make doc
```

If you encountered problems during `make` and wish to re-configure the project, you should firstly clean up intemediate files through:

```bash
env -i PATH="/usr/bin" make distclean
# [...]
```
