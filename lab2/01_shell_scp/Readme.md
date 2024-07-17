# Compiling Stupid C Program using Plain Shell Script

Create a new clean shell, and do as follows:

## Set Required Variables

```shell
PWD="$(pwd)"
# CC: Path to the C compiler. Will use gcc (GCC) or clang (LLVM).
[ -n "${CC:-}" ] || CC="$(which gcc)"
# AR: Path to static library archive manipulator. Will use ar (GNU BinUtils) or llvm-ar (LLVM).
[ -n "${AR:-}" ] || AR="$(which ar)"
# RANLIB: Path to index generator for static libraries. Will use ranlib (GNU BinUtils) or llvm-ranlib (LLVM).
[ -n "${RANLIB:-}" ] || RANLIB="$(which ranlib)"
# Default C compiler arguments.
[ -n "${CFLAFS:-}" ] || CFLAFS=("-O2" "-Wall" "-Wextra" "-DBUILT_UNDER_SHELL" "-fPIC" "-fPIE")
# Default linker flags
[ -n "${LDFLAGS:-}" ] || LDFLAGS=("-L${PWD}")
```

Explaination of used C compiler flags:

- `-O2`: Optimize for speed, level 2,
- `-Wall`: Generate all warnings.
- `-Wextra`: Generate extra warnings.
- `-DBUILT_UNDER_SHELL`: Define `BUILT_UNDER_SHELL` macro for C pre-processor.
- `-fPIC`: Generate position-independent code. Required for building shared library.
- `-fPIE`: Generate position-independent executable. Required for building shared library.

## Compilation Process

### The Pre-Processing Phase

```shell
"${CC}" "${CFLAFS[@]}" --verbose -E -o main.i ../src/main.c &>main.i.log
```

The `-E` flag instructs GCC to stop after pre-processing.

The generated file, `main.i`, is a C source file that contains no pre-processor macros (Those started with `#`).

A common error here is failure in finding inclusion files. For example,

```shell
echo '#include <some_nasty_file.h>' | gcc -E -x c - -o /dev/null
# <stdin>:1:10: fatal error: some_nasty_file.h: No such file or directory
# compilation terminated.
```

To solve this issue, we need to firstly find `NON_EXIST.h`, and append it to inclusion search paths. It can be done through `-I` pre-processor argument:

```shell
echo '#include <some_nasty_file.h>' | gcc -E -x c - -o /dev/null -I"$(pwd)/includes"
```

Or through `C_INCLUDE_PATH` environment variable:

```shell
echo '#include <some_nasty_file.h>' | C_INCLUDE_PATH="$(pwd)/includes" gcc -E -x c - -o /dev/null
```

See manual of `cpp` for more details.

See `main.i.log` to see what GCC's actually doing. You may also found a list of inclusion search paths.

GCC actually invokes:

```shell
# CPP is the GCC C pre-processor.
cpp -DBUILT_UNDER_SHELL -o main.i ../src/main.c
```

### The Compile and Assemble Phase

This phase converts pre-processed file to assembly code, and converts assembly code to binary file (object file). If error occurs here, it may not be recoverable.

```shell
"${CC}" "${CFLAFS[@]}" --verbose -S -o main.s main.i &>main.s.log
"${CC}" "${CFLAFS[@]}" --verbose -c -o main.o main.s &>main.o.log
```

GCC actually invokes:

```shell
# CC1 is the GCC compiler, but normally not exposed to $PATH.
# So invoke it with absolute path.
# See <https://unix.stackexchange.com/questions/77779/relationship-between-cc1-and-gcc> for details.
"$(gcc -print-prog-name=cc1)" -quiet "${CFLAFS[@]}" main.i -o main.s
# AS is the GCC assembler.
as -o main.o main.s
```

For faster code, you may set both `-O2` and `-mtune=native` in `CFLAGS`.

The object file, `main.o`, is commonly in Executable and Linkable Format (ELF). We may poke its properties using `file`:

```shell
file main.o
# main.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
```

See `man elf` for more details.

### Creating `libstupid` Library

Compile `stupid.c` into relocatable ELF `stupid.o`.

```shell
"${CC}" "${CFLAFS[@]}" --verbose -c -o stupid.o ../src/stupid.c &>stupid.o.log
```

Archive the `stupid.o` into static library `libstupid.a`. The static library is in fact an archive of ELF relocatables.

```shell
"${AR}" rvcs libstupid.a stupid.o &>libstupid.a.log
"${RANLIB}" libstupid.a &>>libstupid.a.log
```
Link the `stupid.o` into shared library `libstupid.so`.

```shell
"${CC}" "${LDFLAGS[@]}" --verbose \
    -shared \
    -Wl,-rpath="${PWD}" \
    -Wl,-soname,libstupid.so \
    -o libstupid.so stupid.o \
    &>libstupid.so.log
```

Arguments used here:

- `-shared`: Instructs GCC to build shared library.
- Arguments started with `-Wl` will be passed to GNU BinUtils linker, `ld`. They are:
  - `-rpath`, which defines static loader search path introduced below.
  - `-soname`, which is name of the shared object.

The GCC actually invokes:

```shell
ld "${LDFLAGS[@]}" -shared -rpath="${PWD}" -soname=libstupid.so -o libstupid.so stupid.o
```

See `man ld` for more details.

### Link the Library to Executables


