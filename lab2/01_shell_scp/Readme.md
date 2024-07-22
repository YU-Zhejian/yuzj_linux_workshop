---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
fontfamily: noto
colorlinks: true
---

# Compiling Stupid C Program using Plain Shell Script

Compilation of source codes can of course done by shell scripts. For all-in-one script, use:

```bash
# Compiling using GCC
env -i PATH="/usr/bin/" CC=gcc ./build.sh
# Compiling using Clang
env -i PATH="/usr/bin/" \
    CC=clang \
    LDFLAGS="-fuse-ld=lld -L$(pwd) --rtlib=compiler-rt" \
    CFLAGS="-O2 -Wall -Wextra -DBUILT_UNDER_SHEL -fPIC -fPIE" \
    AR=llvm-ar \
    RANLIB=llvm-ranlib \
    ./build.sh
```

For cleanup, use:

```bash
rm -f *main* *stupid*
```

The step-by-step instruction is as follows. Create a new clean shell, and follow the guide:

## Set Required Variables

```bash
# Where we are.
PWD="$(pwd)"
# CC: Path to the C compiler. Will use gcc (GCC) or clang (LLVM).
[ -n "${CC:-}" ] || CC="$(which gcc)"
# AR: Path to static library archive manipulator.
# Will use ar (GNU BinUtils) or llvm-ar (LLVM).
[ -n "${AR:-}" ] || AR="$(which ar)"
# RANLIB: Path to index generator for static libraries.
# Will use ranlib (GNU BinUtils) or llvm-ranlib (LLVM).
[ -n "${RANLIB:-}" ] || RANLIB="$(which ranlib)"

# Default C compiler arguments.
[ -n "${CFLAGS:-}" ] && \
    CFLAGS=(${CFLAGS}) || \
    CFLAGS=("-O2" "-Wall" "-Wextra" "-DBUILT_UNDER_SHELL" "-fPIC" "-fPIE")
# Default linker flags
[ -n "${LDFLAGS:-}" ] &&  LDFLAGS=(${LDFLAGS}) || LDFLAGS=("-L${PWD}")
```

Explanation of used C compiler flags:

- `-O2`: Optimize for speed, level 2. This allows generation of applications that runs faster. Compielrs are usually smarter than you.
- `-Wall`: Generate all warnings. Useful for development.
- `-Wextra`: Generate extra warnings. Useful for development.
- `-DBUILT_UNDER_SHELL`: Define `BUILT_UNDER_SHELL` macro for C pre-processor.
- `-fPIC`: Generate position-independent code. Required for building shared library.
- `-fPIE`: Generate position-independent executable. Required for building shared library.

For the LLVM flavor, additional linker flags will be added to ensure usage of LLVM toolchain. They are:

- `-fuse-ld=lld`: Use LLVM LLD linker instead of `ld` from GNU BinUtils.
- `--rtlib=compiler-rt`: Use LLVM compiler runtime instead of GCC runtime library (`libgcc`).

The linker flags used will be introduced below.

## Compilation Process

### The Pre-Processing Phase

During the pre-processing phase, the C source code is consumed with pre-processor most macros started with `#` expanded, replaced, and eliminated. An example will be:

```bash
"${CC}" "${CFLAGS[@]}" -E -o main.i ../src/main.c
```

The `-E` flag instructs the compiler to stop after pre-processing. The generated file, `main.i`, is a C source file that contains no pre-processor macros (Those started with `#`).

#### A More Detailed Pre-Processing Example

The file `test.c` defines macro `CONDITION_INT` on whether the macro `CONDITION_ONE` is defined. Following is an example where `CONDITION_ONE` is not defined:

```bash
gcc -E -o /dev/stdout cond_comp/test.c | grep -vE '^#|^$'
```

Generates:

```c
int main(){
    return 0;
}
```

where the macro `CONDITION_INT` in function `main` was replaced by its value `0`. On the contrary, after defining macro `CONDITION_ONE` through `-D` parameter:

```bash
gcc -E -DCONDITION_ONE -o /dev/stdout cond_comp/test.c | grep -vE '^#|^$'
```

We will have:

```c
int main(){
    return 1;
}
```

An example of using such property is conditional compilation. For example, both [`zlib`](http://www.zlib.net/) and [`libdeflate`](https://github.com/ebiggers/libdeflate) can compress files. The former is more popular while the latter is usually faster. So, after detecting whether those libraries are installed, we may:

```c
// Prioritize libdeflate for its fast speed.
#if defined (HAVE_LINDEFLATE)
#include <libdeflate.h>
[...] // Functions written using libdeflate

#elif defined(HAVE_ZLIB) // Fallback to zlib.
#include <zlib.h>
[...] // Functions written using zlib

#else // Have nothing!
#error "Either zlib or libdeflate should be installed!"
#endif
```

and define macros `HAVE_ZLIB` or `HAVE_LINDEFLATE` accordingly.

#### Common Failures at Pre-Processing

A common error here is failure in finding inclusion files. For example,

```bash
echo '#include <some_nasty_file.h>' | gcc -E -x c - -o /dev/null
# <stdin>:1:10: fatal error: some_nasty_file.h: No such file or directory
# compilation terminated.
```

To solve this issue, we need to firstly find `some_nasty_file.h`, and append it to inclusion search paths. It can be done through `-I` pre-processor argument:

```bash
echo '#include <some_nasty_file.h>' | \
    gcc -E -x c - -o /dev/null -I"$(pwd)/includes"
```

Or through `C_INCLUDE_PATH` environment variable:

```bash
echo '#include <some_nasty_file.h>' | \
    C_INCLUDE_PATH="$(pwd)/includes" gcc -E -x c - -o /dev/null
```

See `main.i.log` to see what GCC's actually doing. You may also found a list of inclusion search paths.

#### Useful Links

- [_The C Preprocessor_](https://gcc.gnu.org/onlinedocs/cpp/): Official documentation for GNU CPP.
- [_CPP(1)_](https://www.man7.org/linux/man-pages/man1/cpp.1.html): Manual pages for GNU CPP.

### The Compile and Assemble Phase

This phase converts pre-processed file to assembly code, and converts assembly code to binary file (object file). If error occurs here, it may not be recoverable.

```bash
"${CC}" "${CFLAGS[@]}" -S -o main.s main.i
"${CC}" "${CFLAGS[@]}" -c -o main.o main.s
```

For GCC, it actually invokes `cc1` (Can be found through `"gcc -print-prog-name=cc1`) for compilation and `as` (Part of GNU BinUtils) for assembly. For faster code, you may set `-O2` during compilation and `-mtune=native` during assembly. Note that the latter generates less portable code.

Among those steps, two files are generated: `main.s` contains human-readable assembly code and `main.o` contains machine code. The latter is called "object file" and is commonly in a format named Executable and Linkable Format (ELF). This file is important since it contains all our code from `main.c` and the header it uses and can be used for linking purposes.

#### Useful Links

- [_Relationship between cc1 and gcc? - Unix & Linux Stack Exchange_](https://unix.stackexchange.com/questions/77779/relationship-between-cc1-and-gcc): A StackOverflow question on relationship between GCC and `cc1`.
- [_AS(1)_](https://www.man7.org/linux/man-pages/man1/as.1.html): Manual page of GNU Assembler.
- [_Options That Control Optimization_](https://gcc.gnu.org/onlinedocs/gcc-14.1.0/gcc/Optimize-Options.html): GCC help on generating faster programs.
- [_ELF(5)_](https://www.man7.org/linux/man-pages/man5/elf.5.html): Manual page for ELF, the binary format for executables, shared libraries, and object files.
- [_Options Controlling the Kind of Output_](https://gcc.gnu.org/onlinedocs/gcc-14.1.0/gcc/Overall-Options.html#Options-Controlling-the-Kind-of-Output) for GCC options that controls the type of output (Assembly code? Object file? Executables? Or others?)

## The Linking Process

### Creating `libstupid` Library

Before packing `libstupid` into a library we should get its object file.

```bash
"${CC}" "${CFLAGS[@]}" -c -o stupid.o ../src/stupid.c
```

#### Static Library

Static library is usually in format of `libXXXX.a`. It is an archive of object files involved with an index. It can be created using `ar` and `ranlib` from GNU BinUtils. For example:

```bash
"${AR}" rvcs libstupid.a stupid.o
# r - stupid.o
"${RANLIB}" libstupid.a
```

GNU `ar` understands `tar`-like commandline arguments. For example, the object files inside an archive can be listed using:

```bash
ar tvf libstupid.a
# rw-r--r-- 0/0   1216 Jan  1 08:00 1970 stupid.o

# The following is an example of an archive that contains multiple object files.
ar tvf /usr/lib/x86_64-linux-gnu/libz.a
# rw-r--r-- 0/0   3648 Jan  1 08:00 1970 adler32.o
# rw-r--r-- 0/0  12104 Jan  1 08:00 1970 crc32.o
# rw-r--r-- 0/0  28112 Jan  1 08:00 1970 deflate.o
# [...]
# rw-r--r-- 0/0   9408 Jan  1 08:00 1970 gzlib.o
# rw-r--r-- 0/0   8976 Jan  1 08:00 1970 gzread.o
# rw-r--r-- 0/0   9512 Jan  1 08:00 1970 gzwrite.o
```

See:

- [_AR(1)_](https://www.man7.org/linux/man-pages/man1/ar.1.html): Manual page of GNU Archiver.
- [_RANLIB(1)_](https://www.man7.org/linux/man-pages/man1/ranlib.1.html): Manual page of GNU Ranlib, the program that generates index for an archive.

#### Shared Library

Shared library is usually in the form of `libXXXX.so`. Unlike static libraries, they can be loaded at run time. The following code links the `stupid.o` into shared library `libstupid.so`:

```bash
"${CC}" "${LDFLAGS[@]}" -shared -o libstupid.so stupid.o
```

Arguments used here:

- `-shared`: Instructs GCC to build shared library.

### Creation of Executables

The following example generates `main` that is linked to shared libraries and `main_static` that is linked to static libraries.

```bash
"${CC}" "${LDFLAGS[@]}" -Wl,-rpath="${PWD}" -o main main.o -lstupid
"${CC}" "${LDFLAGS[@]}" -static -static-libgcc -o main_static main.o -lstupid
```

- `-lXXXX` is the common form of linking library `XXXX` to the executable. For example, to link zlib (`libz.so`), we uses `-lz`; to like HTSlib (`libhts.so`), we uses `-lhts`.
- `-L${PWD}` sets the linker search path.
- Arguments started with `-Wl` will be passed to GNU BinUtils linker, `ld`. They are:
  - `-rpath`, which defines the path where the loader may search. It should be set to where `libstupid.so` will be installed.
- `-static` and `-static-libgcc` requires static linking of targeted libraries (`-lstupid` and implicitly `-lc`, etc.) and GCC runtime library (`-lgcc` and `-lgcc_s`) where code in static libraries will be copied to the executable, thus creating no runtime dependencies.

### Common Failures at Link Time

The linker may fail to find a library. For example:

```bash
gcc -o main_with_unknown_libs main.o -lstupid1
# /usr/bin/ld: cannot find -lstupid1: No such file or directory
# collect2: error: ld returned 1 exit status
```

At this time, you should check whether the package that provides `libstupid1.so` is installed. If not, have it installed.

A common scenario using Conda or other PMS is that a different version of required library is installed. Here, you may create a symbolic link to cheat the linker. This also works for the loader.

### Useful Links

- [_Static Linking Considered Harmful_](https://www.akkadia.org/drepper/no_static_linking.html): A blog criticising static linking.
- [_c++ - Static linking vs dynamic linking - Stack Overflow_](https://stackoverflow.com/questions/1993390/static-linking-vs-dynamic-linking): A StackOverflow question on difference between shared and static linking.
- [_Dynamic Linking_](http://harmful.cat-v.org/software/dynamic-linking/): An e-mail that criticising dynamic linking.
- [_LD(1)_](https://www.man7.org/linux/man-pages/man1/ld.1.html): Manual page of GNU Linker, `ld`.

## The Loading Process

The `main_static` file is a static executable, and no loading of exytra libraries are needed. However, `main` file requires loading of additional libraries. This can be inspected using `readelf` command provided by GNU BinUtils:

```bash
readelf -d main | grep -e NEEDED -e RUNPATH -
#  0x0000000000000001 (NEEDED)             Shared library: [libstupid.so]
#  0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
#  0x000000000000001d (RUNPATH)            Library runpath:
#  [/home/yuzj/Documents/yuzj_linux_workshop/lab2/01_shell_scp]
```

`readelf` also told us the `RUNPATH` bundled to the executable, which is previously specified using `-Wl, -rpath`. You may roughly understand that the shared libraries (`libstupid.so` and `libc.so.6`) will be searched in directories specified in `RUNPATH` and then standard system directories.

### Common Failures at Load Time

An example of not specifying `RUNATH`:

```bash
gcc -o main_no_rpath main.o -lstupid -L.
cp main_no_rpath /tmp
env -i -C /tmp/ /tmp/main_no_rpath
# /tmp/main_no_rpath: error while loading shared libraries:
# libstupid.so: cannot open shared object file: No such file or directory
```

See? Without `RUNPATH`, the `libstupid.so` cannot be found.

What can we do if the application is already compiled but lacks `RPATH`? The extra paths for searching shared libraries **AT LOAD TIME** can be specified in `LD_LIBRARY_PATH` environment variable. For example:

```bash
env -i -C /tmp/ LD_LIBRARY_PATH=$(pwd) /tmp/main_no_rpath
# Hello world from the stupid C program. Built under shell scripts.
```

### Useful Links

- [_LD(1)_](https://www.man7.org/linux/man-pages/man1/ld.1.html): Manual pages for GNU BinUtils linker.
- [_LD.SO(8)_](https://www.man7.org/linux/man-pages/man8/ld.so.8.html): Manual pages for GNU dynamic loader.
- [_RPATH issue_](https://wiki.debian.org/RpathIssue): Debian explaination on why specifying `RUNPATH` is a bad practice.
- [_Shared Libraries: Understanding Dynamic Loading_](https://amir.rachum.com/shared-libraries/): A great introduction on shared library and loading.
- [_Shared Libraries: The Dynamic Linker_ (PDF)](https://www.man7.org/training/download/shlib_dynlinker_slides.pdf): An intermediate-level course on linkers. Written by the author of [_The Linux Programming Interface_](https://www.man7.org/tlpi/index.html) (TLPI book).
