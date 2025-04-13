---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
colorlinks: true
---
# Lab 2: Understanding C Build Systems

## Why Learn This Course?

There are lots of bioinformatics tools that are written in C. However, since the writer and maintainer of those tools are not professional software engineers, they often come with not-human-readable (or even absent) documentations and may contain bugs. Good news is that most of those bugs comes with improper use of the building system, which can easily be fixed without learning the C/C++ programming language. In this course, we will learn how those build systems work and how to solve commonly-seen bugs inside those systems.

## Learning Objectives

- Understand the compiling process: Pre-processing, compile, assemble, link and load.
- Understand what a build system is and why it is important.
- Build software that uses representative build systems.

## Preparation

1. GNU Bash >= 4.4.
2. GNU CoreUtils, GNU Grep, GNU Sed, and GNU AWK.
3. A valid C compiler. Both GCC and Clang will work.
4. GNU BinUtils.
5. GNU Make, GNU AutoConf, GNU AutoMake, GNU LibTool.
6. CMake.

The C compiler from Microsoft Visual Studio is not covered in this workshop. Again, using [Cygwin](https://www.cygwin.com/), [MSYS2](https://www.msys2.org/), [MinGW](https://osdn.net/projects/mingw), [MinGW-w64](https://www.mingw-w64.org/), or variants is **STRONGLY DISCOURAGED**.

## Files in this Directory

- `src`: The source code.
- `01_shell_scp`: Compilation script in pure shell.
- `02_libtool_scp`: Compilation script in GNU Makefile and GNU Libtool.
- `03_autotools_scp`: Compilation script in GNU AutoTools.
- `04_cmake_scp`: Compilation script in CMake.

Now let's pace into `src` and get see what we will build.

## What's Next?

If you're interested in learn yourself a C programming language, you may consider the following resources:

- S. Prata, _C primer plus_, Sixth edition. Upper Saddle River, NJ: Addison-Wesley, 2014. ISBN: 978-0-321-92842-9
- K. A. Reek, _Pointers on C_. Reading, Mass: Addison-Wesley Longman, 1998. ISBN: 978-0-673-99986-3
- B. W. Kernighan and D. M. Ritchie, _The C programming language_, 2nd ed. Englewood Cliffs, N.J: Prentice Hall, 1988. ISBN: 978-0-13-110370-2 978-0-13-110362-7
