---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
fontfamily: noto
colorlinks: true
---

# Lab 3: Compiling and Installing C Programs from Source

Before progression, execute the following to download all external resources:

```bash
src/reproduce.sh
opt/reproduce.sh
```

## Learning Objectives

Compile existing bioinformatics programs in different building systems.

## Files in this Directory

- `src`: External source files.
- `opt`: Built packages. Which should contain:
  - `cmake-3.30.0-linux-x86_64`: Binary of a recent version of CMake. The version installed on LabW Kiki is too low to support kAlign.

## Install ZLib

ZLib is required for BWA, HTSlib and SAMtools, so we will have it installed in advance. You may skip this step to use ZLib installed on your operating system. For Debian-based systems, it will be [`zlib1g`](https://packages.debian.org/stable/zlib1g) and [`zlib1g-dev`](https://packages.debian.org/stable/zlib1g-dev).

```bash
env -i -C src/zlib-1.3.1 PATH="/usr/bin" \
    ./configure --prefix="$(pwd)/opt/lab3"
env -i -C src/zlib-1.3.1 PATH="/usr/bin" make install -j8
```

Now ZLib will be installed to `./opt/lab3`. Let's have a look at the contents inside.

- `include`: Contains header files for zlib (`zconf.h` and `zlib.h`).
- `lib`: Contains shared and static library files for ZLib (`libz.a` and `libz.so`). 
  - `pkgconfig/zlib.pc`: Contains package configurations which specifies library path, linker flags, compiler flags, etc. This file can be read by [`pkg-config`](https://www.freedesktop.org/wiki/Software/pkg-config/) or [`pkgconf`](http://pkgconf.org/), which is often employed in building systems like CMake and GNU AutoTools.
- `share/man`: Contains manual pages. You may read them using (VS Code/IDEA users may see `WARNING: terminal is not fully functional` in their built-in terminal):

  ```bash
  env -i PATH="/usr/bin/" MANPATH="opt/lab3/share/man" man zlib
  ```
  
  **HINT**: Do not try to read manual pages using text editor. Those pages are written in [ROFF](https://www.man7.org/linux/man-pages/man7/roff.7.html)/[TROFF](https://www.troff.org/)/[GROFF](https://www.gnu.org/software/groff/), an ancient (Older than my grandfather, I suppose) markup format that is extremely hard to read.

## Example of Pure Makefile: BWA

Burrows-Wheeler Aligner (BWA) ([SourceForge](https://bio-bwa.sourceforge.net/), [GitHub](https://github.com/lh3/bwa)) is one of the most popular read aligner for next-generation sequencing reads. Here we will try to compile it from source.

For GCC later than or equal to 10 (check through `gcc --version`), you need to apply a patch:

```bash
env -i -C src/bwa-debian-0.7.17-7 PATH="/usr/bin/" \
    patch < src/bwa-debian-0.7.17-7/debian/patches/gcc10.patch
# patching file rle.h
```

And build BWA by:

```bash
env -i -C src/bwa-debian-0.7.17-7 \
    PATH="/usr/bin" \
    C_INCLUDE_PATH="$(pwd)/opt/lab3/include" \
    LD_RUN_PATH="$(pwd)/opt/lab3/lib" \
    make -j8
```

Environment variables used here:

- `C_INCLUDE_PATH`: Additional C pre-processor header search path. The paths specified by environment variables are often prioritized over system defaults so the `zlib.h` we just installed instead of the system one (if presented) will be used first.
- `LD_RUN_PATH`: Additional loader search path, like `-Wl,-rpath`.

Manually install `bwa` and its documentations to desired place:

```bash
install -D src/bwa-debian-0.7.17-7/bwa opt/lab3/bin/bwa
install -D src/bwa-debian-0.7.17-7/bwa.1 opt/lab3/share/man/man1/bwa.1
```

The `install` command is provided by GNU CoreUtils. See [here](https://unix.stackexchange.com/questions/218673/how-is-install-different-from-cp), [here](https://superuser.com/questions/229883/how-is-install-c-different-from-cp) and [here](https://unix.stackexchange.com/questions/104982/why-use-install-rather-than-cp-and-mkdir) for why `install` instead of `cp` were used here.

Now let's see whether `bwa` works.

```bash
env -i PATH="opt/lab3/bin" bwa || true
# Program: bwa (alignment via Burrows-Wheeler transformation)
# Version: 0.7.17-r1188
# Contact: Heng Li <lh3@sanger.ac.uk>
#
# Usage:   bwa <command> [options]
#
# [...]
#
# Note: To use BWA, you need to first index the genome with `bwa index'.
#       There are three alignment algorithms in BWA: `mem', `bwasw', and
#       `aln/samse/sampe'. If you are not sure which to use, try `bwa mem'
#       first. Please `man ./bwa.1' for the manual.
env -i PATH="/usr/bin/" \
    readelf -d opt/lab3/bin/bwa |  grep -e NEEDED -e RUNPATH
# 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
# 0x0000000000000001 (NEEDED)             Shared library: [libz.so.1]
# 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
# 0x000000000000001d (RUNPATH)            Library runpath:
# [/home/yuzj/Documents/yuzj_linux_workshop/lab3/opt/lab3/lib]
```

## Example of GNU AutoTools: SAMtools

SAMtools ([Official](http://www.htslib.org), [GitHub](https://github.com/samtools/samtools), [SourceForge](https://sourceforge.net/projects/samtools)) is a swiss-army knife for manipulating alignment files. Although SAMtools have a bundled HTSLib, we will build our own since the default configuration involves libraries that may not have been built. The `configure` script had already been generated, so we only need to:

```bash
env -i -C src/htslib-1.20 PATH="/usr/bin" \
    ./configure \
    --prefix="$(pwd)/opt/lab3" \
    --disable-bz2 \
    --disable-gcs \
    --disable-libcurl \
    --disable-lzma \
    --disable-plugins \
    --disable-s3 \
    --without-libdeflate \
    LDFLAGS="-L$(pwd)/opt/lab3/lib -Wl,-rpath=$(pwd)/opt/lab3/lib" \
    CFLAGS="-I$(pwd)/opt/lab3/include"
env -i -C src/htslib-1.20 PATH="/usr/bin" make -j8
# Here, make and make install needs to be executed separately.
# Otherwise issues may emerge.
env -i -C src/htslib-1.20 PATH="/usr/bin" make -j8 install
```

Note the `LDFLAGS` and `CFLAGS` variable we added. At current stage, libraries needed are:

```bash
env -i PATH="/usr/bin/" \
    readelf -d opt/lab3/lib/libhts.so.1.20 |  grep -e NEEDED -e RUNPATH
#  0x0000000000000001 (NEEDED)             Shared library: [libz.so.1]
#  0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
#  0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
#  0x000000000000001d (RUNPATH)            Library runpath:
#  [/home/yuzj/Documents/yuzj_linux_workshop/lab3/opt/lab3/lib]
```

Let's build SAMtools. Entering `src/samtools-1.20`, we run:

```bash
env -i -C src/samtools-1.20 PATH="/usr/bin" ./configure \
    --prefix="$(pwd)/opt/lab3" \
    --with-htslib="$(pwd)/opt/lab3" \
    --without-curses \
    --without-ncursesw \
    LDFLAGS="-L$(pwd)/opt/lab3/lib -Wl,-rpath=$(pwd)/opt/lab3/lib" \
    CFLAGS="-I$(pwd)/opt/lab3/include"
env -i -C src/samtools-1.20 PATH="/usr/bin" make -j8 install
```

Now SAMtools should be installed. Let's see whether it works.

```bash
env -i PATH="opt/lab3/bin/" samtools version
# samtools 1.20
# Using htslib 1.20
# Copyright (C) 2024 Genome Research Ltd.
#
# Samtools compilation details:
#     Features:       build=configure curses=no 
#     [...]
#     CURSES_LIB:     
#
# HTSlib compilation details:
#     Features:       build=configure libcurl=no [...] plugins=no htscodecs=1.6.0
#     [...]
#     LDFLAGS:        [...]
#
# HTSlib URL scheme handlers present:
#     built-in:    preload, data, file
#     crypt4gh-needed:     crypt4gh
#     mem:         mem
env -i PATH="/usr/bin/" \
    readelf -d opt/lab3/bin/samtools |  grep -e NEEDED -e RUNPATH
#  0x0000000000000001 (NEEDED)             Shared library: [libhts.so.3]
#  0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
#  0x0000000000000001 (NEEDED)             Shared library: [libz.so.1]
#  0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
#  0x000000000000001d (RUNPATH)            Library runpath:
#  [/home/yuzj/Documents/yuzj_linux_workshop/lab3/opt/lab3/lib]
```

## Example of CMake: kAlign

kAlign ([GitHub](https://github.com/timolassmann/kalign)) is an ultrafast multi sequence aligner that is commonly used in phylogeny inference for large libraries. We may build this using:

```bash
env -C src/kalign-debian-1%3.4.0-1 mkdir -p build
# A more recent CMake is used
env -C src/kalign-debian-1%3.4.0-1/build -i \
    PATH="$(pwd)/opt/cmake-3.30.0-linux-x86_64/bin:/usr/bin" \
    cmake .. \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/opt/kalign-debian-1_3.4.0"
env -C src/kalign-debian-1%3.4.0-1/build -i \
    PATH="$(pwd)/opt/cmake-3.30.0-linux-x86_64/bin:/usr/bin" \
    make -j8 install
```

Get back to the current directory and test whether kAlign is working using:

```bash
opt/kalign-debian-1_3.4.0/bin/kalign --version
```

## Homework

Re-build samtools with support of `libdeflate`, `libbz2` and `liblzma`. You need to download and build those libraries manually.
