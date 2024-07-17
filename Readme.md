# GNU/Linux Workshop by YU ZJ at 2024/07

The Linux workshop at Zhejiang University for Year 2 \& 3 Bioinformatics BsC students.

## What to Prepare before the Workshop

### Operating System

You need an accessible working GNU/Linux installation. No root privilege is required. The following options are acceptable:

- Linux operating system installed on your computer. It can co-exist with Microsoft Windows through Grub.
- SSH over lab server.
- For Microsoft Windows users, install Windows System on Linux (WSL) 2. [Instructions](https://learn.microsoft.com/en-us/windows/wsl/install).
  - **WARNING**: WSL2 users may encounter filesystem or permission problems. **You have been warned.**
- For macOS users, install [HomeBrew](https://brew.sh) for packages introduced below. Read [this](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/) for faster internet access.
  - You may use those BSD utils bundled by macOS XCode, but they may generate errors. **You have been warned.**

Using [Cygwin](https://www.cygwin.com/), [MSYS2](https://www.msys2.org/), [MinGW](https://osdn.net/projects/mingw), [MinGW-w64](https://www.mingw-w64.org/), or variants is **STRONGLY DISCOURAGED**.

### Packages

Basis:

- [GNU CoreUtils](https://www.gnu.org/software/coreutils/), which provides `mkdir` `ls` `chmod` `rm`, etc. Those provided by \*BSD, macOS, plan9, `busybox` may **NOT** work.
- [GNU Bourne-Again Shell (Bash)](https://www.gnu.org/software/bash/) for `bash`. Using [Z Shell](https://www.zsh.org/) (zsh) **MAY** work; Using POSIX Bourne Shell (`sh`), Almquist Shell (`ash`), Debian Almquist Shell (`dash`), Korn Shell (`ksh`), or C Shell (`csh`) and variants will **NOT** work.
- [GNU DiffUtils](https://www.gnu.org/software/diffutils/) and [GNU Patch](https://www.gnu.org/software/patch/) for `diff` and `patch`. Used in `lab3` only.
- GNU Text processing utils: [GNU Grep](https://www.gnu.org/software/grep/), [GNU Sed](https://www.gnu.org/software/sed/), and [GNU AWK](https://www.gnu.org/software/gawk/).
- [strace](https://strace.io), for `strace` that allows analyzing Linux system calls.

Compiling \& Linking:

- [GNU Compiler Collection (GCC)](https://gcc.gnu.org/). Need at least `gcc` and `g++`.
- [LLVM Clang](https://clang.llvm.org/), a GCC alternative.
- [GNU BinUtils](https://www.gnu.org/software/binutils/) for linker (`ln`), ELF executable reader (`readelf`), and more.
- [GNU LibTool](https://www.gnu.org/software/libtool/) for `libtool` executable. For Debian-based distributions, installing [`libtool`](https://packages.debian.org/stable/libtool) is usually not enough. You also need [`libtool-bin`](https://packages.debian.org/stable/libtool-bin).
- Essential development libraries. For Debian-based systems, that includes:
  - [`linux-libc-dev`](https://packages.debian.org/stable/linux-libc-dev)
  - [`libc-bin`](https://packages.debian.org/stable/libc-bin)
  - [`libc6-dev`](https://packages.debian.org/stable/libc6-dev)
  - [`libc6`](https://packages.debian.org/stable/libc6)
  - [`libgcc-12-dev`](https://packages.debian.org/stable/libgcc-12-dev) (Replace `12` with your GCC version accordingly)

Test whether you have get all those by running (replace `gcc` by `clang` as your wish):

```shell
echo 'int main(){return 0;}' | gcc -o tmp -Wall -Wextra -fPIE -x c -
./tmp
echo 'int main(){return 0;}' | gcc -o tmp -Wall -Wextra -fPIE -x c - -static -static-libgcc
./tmp
rm -f tmp
```

If any error occurs, your toolchain is not complete!

Building systems:

- [GNU Make](https://www.gnu.org/software/make/) for `make`. BSD Make on macOS and \*BSD will **NOT** work.
- [CMake](https://cmake.org/) for `cmake`.
- GNU AutoTools, including [GNU AutoConf](https://www.gnu.org/software/autoconf/) and [GNU AutoMake](https://www.gnu.org/software/automake/).
- (Optional) [GNU TexInfo](https://www.gnu.org/software/texinfo/) and [LaTeX](https://www.latex-project.org/) for compiling GNU TexInfo files to PDF.

Downloading files:

- [GNU WGet](https://www.gnu.org/software/wget/) for `wget`, which downloads required files.

Compression:

- [GNU Tar](https://www.gnu.org/software/tar/) for `tar`.
- [GNU GZip](https://www.gnu.org/software/gzip/) for `gzip`.
- [XZ Utils](http://tukaani.org/xz/) for `xz`. Beware of the [XZ Backdoor](https://nvd.nist.gov/vuln/detail/CVE-2024-3094).
- [bzip2](https://sourceware.org/bzip2) for `bzip2`.

If you're using LabW Kiki, all packages should have been installed.

## Organization of Files

- `lab?`: Supporting materials for each lab.
- `.clang-*`: Configurations for clang-format and clang-tidy.
- `fmt.sh`: Automatically format all files.
- `License.md`: The license of the project.
- `Readme.md`: This file.

## How to Use These Labs

The labs should be learnt in a non-linear manner. i.e., the knowledge taught at the front may rely on what is taught next. If you find yourself hard to understand something, skip it, read the docs, ask generative AI, or find answers on [Stack Overflow](https://stackoverflow.com/).

The labs heavily relies on the official documentation of mentioned software. For example to finish lab1, you may extensively refer to [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html), its manual pages (`man bash`) or info pages (`info bash`).

lab4 is **OPTIONAL**. Do not waste time there if you're busy.
