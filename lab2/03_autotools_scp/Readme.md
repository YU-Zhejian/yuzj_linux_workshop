---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
colorlinks: true
---
# Stupid C Program using GNU AutoTools

## Why Learning This Course?

The presence of `configure.ac` or `configure` indicates that the underlying project is built under GNU AutoTools. It used to be a common practice to use GNU AutoTools to build C programs for cross-platform compatibility (i.e., on diverse UNIX(-like) operating systems **NOT** including Windows).

## Learning Objectives

- Learn how to build a C program using GNU AutoTools.

## Building the Program

Here, the required files for GNU AutoTools are located in the `proj` directory. We also need to copy the source code into this directory.

```bash
cd proj
cp -v ../../src/*.c ../../src/*.h .
```

Firstly, we need to examine whether `configure` script is presented. If not, we may generate a `configure` using `autoreconf` (An executable from GNU AutoConf):

```bash
autoreconf -f -v -i
# autoreconf: export WARNINGS=
# autoreconf: Entering directory '.'
# [...]
# parallel-tests: installing './test-driver'
# autoreconf: Leaving directory '.'
```

Note that this also generates `Makefile.in` from `Makefile.am` since we require GNU AutoMake in `configure.ac`. It also generates `ltmain.sh`, a shell script containing GNU LibTool under the current platform. If your `configure.ac` does not require above modules, they may not be presented.

Now we have `configure`. Let's do the configuration. The script will turn `Makefile.in` into `Makefile`, allowing us to build the program using GNU Make.

```bash
env -i PATH="/usr/bin" ./configure --prefix="$(pwd)/opt"
# checking for a BSD-compatible install... /usr/bin/install -c
# checking whether build environment is sane... yes
# checking for a race-free mkdir -p... /usr/bin/mkdir -p
# [...]
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
# I installed LaTeX to /usr/local/bin
env -i PATH="/usr/bin:/usr/local/bin" make doc
```

If you encountered problems during `make` and wish to re-configure the project, you should firstly clean up intermediate files through:

```bash
env -i PATH="/usr/bin" make distclean
# [...]
```

## What's Next?

GNU AutoTools are a complicated boilerplate of Shell, [GNU M4](https://www.gnu.org/software/m4/), C/C++, LaTeX/GNU TexInfo, and Make. Its complexity can be peeked from the code of [GNU AutoConf Archive](https://www.gnu.org/software/autoconf-archive/) and [GNU Portability Library (Gnulib)](https://www.gnu.org/software/gnulib/). Those features make projects built by GNU AutoTools slow and hard to understand. For newer projects, using CMake is a better choice.
