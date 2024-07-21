---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
fontfamily: noto
colorlinks: true
---

# Stupid C Program using CMake

The presence of `CMakeLists.txt` indicates that this project can be built using [CMake](https://cmake.org/), which is a convenient build system for C/C++. Please note that here the executables and libraries were not named `main` and `libstupid`.

## Simple Tutorial

Here we will demonstrate how to build our program using CMake and GNU Make. Firstly, we need to create a separate directory for CMake build:

```bash
mkdir -p build_make
```

Then, run CMake flavor of `configure`:

```bash
env -i -C build_make PATH="/usr/bin" cmake .. \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/opt"
# -- The C compiler identification is GNU 11.4.0
# -- Detecting C compiler ABI info
# -- Detecting C compiler ABI info - done
# -- Check for working C compiler: /usr/bin/cc - skipped
# -- Detecting C compile features
# -- Detecting C compile features - done
# -- Configuring done
# -- Generating done
# -- Build files have been written to: [...]/build_make
```

Note the `-D` argument. Similar to how we define C pre-processor macros, this specifies the initial state of CMake internal variables. The `CMAKE_INSTALL_PREFIX` variable adjusts the installation path, similar to `--prefix` in GNU AutoTools.

Now the project is configured. We may use `make` to build it:

```bash
env -i -C build_make PATH="/usr/bin" make -j8
# [ 12%] Building C object CMakeFiles/main_lib.dir/[...]/stupid.c.o
# [ 25%] Building C object CMakeFiles/main_lib_static.dir/[...]/stupid.c.o
# [ 50%] Linking C shared library libmain_lib.so
# [ 50%] Linking C static library libmain_lib_static.a
# [ 50%] Built target main_lib
# [ 62%] Building C object CMakeFiles/main_exe.dir/[...]/main.c.o
# [ 62%] Built target main_lib_static
# [ 75%] Building C object CMakeFiles/main_exe_static.dir/[...]/main.c.o
# [ 87%] Linking C executable main_exe
# [100%] Linking C executable main_exe_static
# [100%] Built target main_exe
# [100%] Built target main_exe_static
env -i -C build_make PATH="/usr/bin" make -j8 install
# Install the project...
# -- Install configuration: ""
# -- Up-to-date: [...]/opt/include/stupid.h
# -- Installing: [...]/opt/lib/libmain_lib.so
# -- Set runtime path of "[...]/opt/lib/libmain_lib.so" to "[...]/opt/lib"
# -- Installing: [...]/opt/lib/libmain_lib_static.a
# -- Installing: [...]/opt/bin/main_exe
# -- Set runtime path of "[...]/opt/bin/main_exe" to "[...]/opt/lib"
# -- Installing: [...]/opt/bin/main_exe_static
```

If a CMake program comes with tests, we may easily test it using `ctest`, which is a part of CMake:

```bash
env -i -C build_make PATH="/usr/bin" ctest
# Test project [...]/build_make
#     Start 1: main_exe
# 1/2 Test #1: main_exe .........................   Passed    0.00 sec
#     Start 2: main_exe_static
# 2/2 Test #2: main_exe_static ..................   Passed    0.00 sec
#
# 100% tests passed, 0 tests failed out of 2
#
# Total Test time (real) =   0.01 sec
```

## Using Ninja and Clang

Alternate to GNU Make, CMake supports [Ninja](https://ninja-build.org/), another build system that is smaller and faster. Its advantage is more obvious while compiling programs that is extremely large (like [LLVM](https://llvm.org/), which contains thousands of object files). Using Ninja can be specified via `-G`.

```bash
mkdir -p build_ninja
env -i -C build_ninja PATH="/usr/bin" cmake \
    -DCMAKE_C_COMPILER=clang \
    -G Ninja \
    ..
# -- The C compiler identification is Clang 14.0.0
# [...]
# -- Build files have been written to: [...]/build_ninja
env -i -C build_ninja PATH="/usr/bin" ninja -j8
# [1/8] Building C object CMakeFiles/main_lib_static.dir/[...]/stupid.c.o
# [2/8] Building C object CMakeFiles/main_lib.dir/[...]/stupid.c.o
# [3/8] Building C object CMakeFiles/main_exe_static.dir/[...]/main.c.o
# [4/8] Building C object CMakeFiles/main_exe.dir/[...]/main.c.o
# [5/8] Linking C shared library libmain_lib.so
# [6/8] Linking C static library libmain_lib_static.a
# [7/8] Linking C executable main_exe
# [8/8] Linking C executable main_exe_static
```

Another excellent feature supported by Ninja is generation of dependency graphs in combination with [GraphViz](https://graphviz.org/). For example:

```bash
env -i -C build_ninja PATH="/usr/bin" ninja -t graph | \
    dot -Tpdf -ocmake_ninja.pdf
```
