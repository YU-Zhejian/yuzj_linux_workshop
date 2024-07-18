# Compiling Stupid C Program using Plain Shell Script

Compilation of source codes can of course done by shell scripts. Following is the step-to-step guide of the compilation, linking and loading process. For all-in-one script, use:

```bash
# For GCC flavor
CC=gcc ./build.sh
# For Clang
CC=clang \
  LDFLAGS="-fuse-ld=lld -L$(pwd) --rtlib=compiler-rt" \
  CFLAGS="-O2 -Wall -Wextra -DBUILT_UNDER_SHEL -fPIC -fPIE" \
  AR=llvm-ar RANLIB=llvm-ranlib ./build.sh
```

Now we begin step-to-step tutorial. Create a new clean shell, and follow the guide:

## Set Required Variables

```bash
PWD="$(pwd)"
# CC: Path to the C compiler. Will use gcc (GCC) or clang (LLVM).
[ -n "${CC:-}" ] || CC="$(which gcc)"
# AR: Path to static library archive manipulator. Will use ar (GNU BinUtils) or llvm-ar (LLVM).
[ -n "${AR:-}" ] || AR="$(which ar)"
# RANLIB: Path to index generator for static libraries. Will use ranlib (GNU BinUtils) or llvm-ranlib (LLVM).
[ -n "${RANLIB:-}" ] || RANLIB="$(which ranlib)"

# Default C compiler arguments.
[ -n "${CFLAGS:-}" ] && CFLAGS=(${CFLAGS}) || CFLAGS=("-O2" "-Wall" "-Wextra" "-DBUILT_UNDER_SHELL" "-fPIC" "-fPIE")
# Default linker flags
[ -n "${LDFLAGS:-}" ] && LDFLAGS=(${LDFLAGS}) || LDFLAGS=("-L${PWD}")
```

Explanation of used C compiler flags:

- `-O2`: Optimize for speed, level 2. This allows generation of applications that runs faster. Compielrs are usually smarter than you.
- `-Wall`: Generate all warnings. Useful for development.
- `-Wextra`: Generate extra warnings. Useful for development.
- `-DBUILT_UNDER_SHELL`: Define `BUILT_UNDER_SHELL` macro for C pre-processor.
- `-fPIC`: Generate position-independent code. Required for building shared library.
- `-fPIE`: Generate position-independent executable. Required for building shared library.

The linker flags used will be introduced below.

## Compilation Process

### The Pre-Processing Phase

```bash
"${CC}" "${CFLAGS[@]}" --verbose -E -o main.i ../src/main.c &>main.i.log
```

The `-E` flag instructs GCC to stop after pre-processing.

The generated file, `main.i`, is a C source file that contains no pre-processor macros (Those started with `#`).

A common error here is failure in finding inclusion files. For example,

```bash
echo '#include <some_nasty_file.h>' | gcc -E -x c - -o /dev/null
# <stdin>:1:10: fatal error: some_nasty_file.h: No such file or directory
# compilation terminated.
```

To solve this issue, we need to firstly find `NON_EXIST.h`, and append it to inclusion search paths. It can be done through `-I` pre-processor argument:

```bash
echo '#include <some_nasty_file.h>' | gcc -E -x c - -o /dev/null -I"$(pwd)/includes"
```

Or through `C_INCLUDE_PATH` environment variable:

```bash
echo '#include <some_nasty_file.h>' | C_INCLUDE_PATH="$(pwd)/includes" gcc -E -x c - -o /dev/null
```

See manual of `cpp` for more details.

See `main.i.log` to see what GCC's actually doing. You may also found a list of inclusion search paths.

GCC actually invokes:

```bash
# CPP is the GCC C pre-processor.
cpp -DBUILT_UNDER_SHELL -o main.i ../src/main.c
```

### The Compile and Assemble Phase

This phase converts pre-processed file to assembly code, and converts assembly code to binary file (object file). If error occurs here, it may not be recoverable.

```bash
"${CC}" "${CFLAGS[@]}" --verbose -S -o main.s main.i &>main.s.log
"${CC}" "${CFLAGS[@]}" --verbose -c -o main.o main.s &>main.o.log
```

GCC actually invokes:

```bash
# CC1 is the GCC compiler, but normally not exposed to $PATH.
# So invoke it with absolute path.
# See <https://unix.stackexchange.com/questions/77779/relationship-between-cc1-and-gcc> for details.
"$(gcc -print-prog-name=cc1)" -quiet "${CFLAGS[@]}" main.i -o main.s
# AS is the GCC assembler.
as -o main.o main.s
```

For faster code, you may set both `-O2` and `-mtune=native` in `CFLAGS`.

The object file, `main.o`, is commonly in Executable and Linkable Format (ELF). We may poke its properties using `file`:

```bash
file main.o
# main.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
```

See `man elf` for more details.

### Creating `libstupid` Library

Compile `stupid.c` into relocatable ELF `stupid.o`.

```bash
"${CC}" "${CFLAGS[@]}" --verbose -c -o stupid.o ../src/stupid.c &>stupid.o.log
```

Archive the `stupid.o` into static library `libstupid.a`. The static library is in fact an archive of ELF relocatables.

```bash
"${AR}" rvcs libstupid.a stupid.o &>libstupid.a.log
"${RANLIB}" libstupid.a &>>libstupid.a.log
```
Link the `stupid.o` into shared library `libstupid.so`.

```bash
"${CC}" "${LDFLAGS[@]}" --verbose \
    -shared \
    -Wl,-rpath="${PWD}" \
    -o libstupid.so stupid.o \
    &>libstupid.so.log
```

Arguments used here:

- `-shared`: Instructs GCC to build shared library.
- Arguments started with `-Wl` will be passed to GNU BinUtils linker, `ld`. They are:
  - `-rpath`, which defines static loader search path introduced below.

The GCC actually invokes:

```bash
ld "${LDFLAGS[@]}" -shared -rpath="${PWD}" -soname=libstupid.so -o libstupid.so stupid.o
```

See `man ld` for more details.

### Link the Library to Executables

```bash
LIBC_PATH="/usr/lib/x86_64-linux-gnu/"
LIBGCC_PATH="/usr/lib/gcc/x86_64-linux-gnu/11"
ld \
    -dynamic-linker /lib64/ld-linux-x86-64.so.2 \
    -rpath="${PWD}" \
    -pie \
    -z now \
    -z relro \
    -o main \
    -L. \
    -L"${LIBGCC_PATH}" \
    -L"${LIBC_PATH}" \
    "${LIBC_PATH}/Scrt1.o" \
    "${LIBC_PATH}/crti.o" \
    "${LIBGCC_PATH}/crtbeginS.o" \
    main.o \
    -lstupid \
    -lgcc \
    -lgcc_s \
    -lc \
    "${LIBGCC_PATH}/crtendS.o" \
    "${LIBC_PATH}/crtn.o"
ld \
    -static \
    -o main_static \
    -L. \
    -L"${LIBGCC_PATH}" \
    -L"${LIBC_PATH}" \
    "${LIBC_PATH}/crt1.o" \
    "${LIBC_PATH}/crti.o" \
    "${LIBGCC_PATH}/crtbeginT.o" \
    main.o \
    -lstupid \
    --start-group \
    -lgcc -lgcc_eh -lc \
    --end-group \
    "${LIBGCC_PATH}/crtend.o" \
    "${LIBC_PATH}/crtn.o"
```
