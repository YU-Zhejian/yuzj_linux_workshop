# Lab 3: Install C Programs from Source

Before progression, execute `src/reproduce.sh` and `opt/reproduce.sh` to download all external resources.

## Folders inside this Lab

- `src`: External source files.
- `opt`: Built packages.

## Install ZLib

```shell
cd src/zlib-1.3.1
env -i PATH="/usr/bin" ./configure \
    --prefix="$(pwd)/../../opt/lab3"
env -i PATH="/usr/bin" make install -j8
cd ../../
```

## Example of Pure Makefile: BWA

Change working directory into `src/bwa-debian-0.7.17-7`.

For GCC later than or equal to 10 (check through `gcc --version`), apply a required patch by:

```shell
patch < debian/patches/gcc10.patch
```

And build BWA by:

```shell
env -i \
    PATH="/usr/bin" \
    C_INCLUDE_PATH="$(pwd)/../../opt/lab3/include" \
    LD_RUN_PATH="$(pwd)/../../opt/lab3/lib" \
    make -j8
```

Environment variables used here:

- `C_INCLUDE_PATH`: Additional C pre-processor header search path.
- `LD_RUN_PATH`: Additional runtime linker search path. See `man ld`:
    > On an ELF system, for native linkers, if the -rpath and -rpath-link options were not used, search the contents of the environment variable "LD_RUN_PATH".

Manually install `bwa` and its documentations to desired place.

```shell
install -D bwa ../../opt/lab3/bin/bwa
install -D bwa.1 ../../opt/lab3/share/man/man1/bwa.1
```

Now we get back to this directory and see whether `bwa` works.

```shell
env -i PATH="opt/lab3/bin" bwa || true
```

Shows:

```text
Program: bwa (alignment via Burrows-Wheeler transformation)
Version: 0.7.17-r1188
Contact: Heng Li <lh3@sanger.ac.uk>

Usage:   bwa <command> [options]

[...]

Note: To use BWA, you need to first index the genome with `bwa index'.
      There are three alignment algorithms in BWA: `mem', `bwasw', and
      `aln/samse/sampe'. If you are not sure which to use, try `bwa mem'
      first. Please `man ./bwa.1' for the manual.
```

We may further find its manual using:

```shell
env -i PATH="/usr/bin/" MANPATH="opt/lab3/share/man" man -w bwa # Display the path to desired manual file.
# Shows: /home/yuzj/Documents/yuzj_linux_workshop/lab3/opt/lab3/share/man/man1/bwa.1
```

And read it using (VS Code users may see `WARNING: terminal is not fully functional`):

```shell
env -i PATH="/usr/bin/" MANPATH="opt/lab3/share/man" man bwa
```

We may see libraries linked to `bwa` through `ldd`:

```shell
env -i PATH="/usr/bin/" ldd opt/lab3/bin/bwa
```

Shows (`libpthread` is integrated into `libc`):

```text
        linux-vdso.so.1 (0x00007ffde534e000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f32d87ac000)
        libz.so.1 => /home/yuzj/Documents/yuzj_linux_workshop/lab3/src/bwa-debian-0.7.17-7/../../opt/lab3/lib/libz.so.1 (0x00007f32d878d000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f32d85a8000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f32d8926000)
```

Or:

```text
        linux-vdso.so.1 (0x00007fffa5fe8000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f0123cdc000)
        libz.so.1 => /mnt/volume0/yuzj_linux_workshop/lab3/src/bwa-debian-0.7.17-7/../../opt/lab3/lib/libz.so.1 (0x00007f0123cbe000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f0123c9b000)
        librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f0123c91000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f0123a9f000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f0123eac000)
```

Or `readelf`:

```shell
env -i PATH="/usr/bin/" readelf -d opt/lab3/bin/bwa |  grep -e NEEDED -e RUNPATH
```

Shows:

```text
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libz.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000001d (RUNPATH)            Library runpath: [/home/yuzj/Documents/yuzj_linux_workshop/lab3/src/bwa-debian-0.7.17-7/../../opt/lab3/lib]
```

## Example of GNU AutoTools: SAMtools

Although SAMtools have a bundled HTSLib, we will build our own since the default configuration involves libraries that may not have been built. Entering `src/htslib-1.20`, we run:

```shell
env -i PATH="/usr/bin" ./configure \
    --prefix="$(pwd)/../../opt/lab3" \
    --disable-bz2 \
    --disable-gcs \
    --disable-libcurl \
    --disable-lzma \
    --disable-plugins \
    --disable-s3 \
    --without-libdeflate \
    LDFLAGS="-L$(pwd)/../../opt/lab3/lib -Wl,-rpath=$(pwd)/../../opt/lab3/lib" \
    CFLAGS="-I$(pwd)/../../opt/lab3/include"
env -i PATH="/usr/bin" make -j8
env -i PATH="/usr/bin" make -j8 install
```

Note the `LDFLAGS` and `CFLAGS` variable we added.

Now HTSLib is installed to `opt/lab3`. Go back to current directory, observe its linked libraries using:

```shell
ldd opt/lab3/lib/libhts.so.1.20
```

Generates:

```text
        linux-vdso.so.1 (0x00007ffefb896000)
        libz.so.1 => /home/yuzj/Documents/yuzj_linux_workshop/lab3/src/htslib-1.20/../../opt/lab3/lib/libz.so.1 (0x00007fb0052af000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fb00518d000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb004fa8000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fb005420000
```

Let's build SAMtools. Entering `src/samtools-1.20`, we run:

```shell
env -i PATH="/usr/bin" ./configure \
    --prefix="$(pwd)/../../opt/lab3" \
    --with-htslib="$(pwd)/../../opt/lab3" \
    --without-curses \
    --without-ncursesw \
    LDFLAGS="-L$(pwd)/../../opt/lab3/lib -Wl,-rpath=$(pwd)/../../opt/lab3/lib" \
    CFLAGS="-I$(pwd)/../../opt/lab3/include"
env -i PATH="/usr/bin" make -j8 install
```

Now SAMtools should be installed. Let's see whether it works.

```shell
env -i PATH="opt/lab3/bin/" samtools version
```

Gives:

```text
samtools 1.20
Using htslib 1.20
Copyright (C) 2024 Genome Research Ltd.

Samtools compilation details:
    Features:       build=configure curses=no 
    CC:             gcc
    CPPFLAGS:       
    CFLAGS:         -Wall -I/home/yuzj/Documents/yuzj_linux_workshop/lab3/src/samtools-1.20/../../opt/lab3/include
    LDFLAGS:        -L/home/yuzj/Documents/yuzj_linux_workshop/lab3/src/samtools-1.20/../../opt/lab3/lib -Wl,-rpath=/home/yuzj/Documents/yuzj_linux_workshop/lab3/src/samtools-1.20/../../opt/lab3/lib
    HTSDIR:         
    LIBS:           
    CURSES_LIB:     

HTSlib compilation details:
    Features:       build=configure libcurl=no S3=no GCS=no libdeflate=no lzma=no bzip2=no plugins=no htscodecs=1.6.0
    CC:             gcc
    CPPFLAGS:       
    CFLAGS:         -Wall -I/home/yuzj/Documents/yuzj_linux_workshop/lab3/src/htslib-1.20/../../opt/lab3/include -fvisibility=hidden
    LDFLAGS:        -L/home/yuzj/Documents/yuzj_linux_workshop/lab3/src/htslib-1.20/../../opt/lab3/lib -Wl,-rpath=/home/yuzj/Documents/yuzj_linux_workshop/lab3/src/htslib-1.20/../../opt/lab3/lib -fvisibility=hidden 

HTSlib URL scheme handlers present:
    built-in:    preload, data, file
    crypt4gh-needed:     crypt4gh
    mem:         mem
```

## Example of CMake: kAlign

Enter `src/kalign-debian-1%3.4.0-1`, and run:

```shell
mkdir -p build
cd build
env -i PATH="$(pwd)/../../../opt/cmake-3.30.0-linux-x86_64/bin:/usr/bin" \
    cmake .. \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/../../../opt/kalign-debian-1_3.4.0"
env -i PATH="$(pwd)/../../../opt/cmake-3.30.0-linux-x86_64/bin:/usr/bin" \
    make -j8 install
```

Get back to the current directory and test whether kAlign is working using:

```shell
opt/kalign-debian-1_3.4.0/bin/kalign --version
```

## Homework

Re-build samtools with support of `libdeflate`, `libbz2` and `liblzma`.
