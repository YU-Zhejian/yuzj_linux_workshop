---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
fontfamily: noto
colorlinks: true
---

# GNU/Linux Workshop by YU ZJ at 2024/07

The Linux workshop at Zhejiang University for Year 2 \& 3 Bioinformatics BSc students.

> Many scientists and engineers spend much of their lives writing, debugging,
> and maintaining software, but only a handful have ever been taught how to do
> this effectively: after a couple of introductory courses, they are left to
> rediscover (or reinvent) the rest of programming on their own. The result?
> Most spend far too much time wrestling with software, instead of doing
> research, but have no idea how reliable or efficient their programs are.
> -- Greg Wilson

## What to Prepare before the Workshop

### Operating System

You need an accessible working GNU/Linux installation. No root privilege is required. The following options are acceptable:

- GNU/Linux operating system installed on your computer (multi operating system).
  - It can co-exist with Microsoft Windows through [GNU Grub](ttps://www.gnu.org/software/grub) bootloader.
- GNU/Linux operating system installed on a virtual machine. Recommended virtualization platforms:
  - [VMWare Workstation Player](https://www.vmware.com/products/workstation-player/), works on Microsoft Windows. Does not work that well on GNU/Linux.
  - [Oracle VM VirtualBox](https://www.virtualbox.org/), works on Microsoft Windows. Does not work that well on GNU/Linux.
  - [Microsoft Hyper-V](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/), works on Microsoft Windows only.
  - [`virt-manager`](https://virt-manager.org/), works on GNU/Linux.
- SSH over lab server.
- For Microsoft Windows users, install Windows System on Linux (WSL) 2.
  - [Official Instructions](https://learn.microsoft.com/en-us/windows/wsl/install).
  - **WARNING**: WSL2 users may encounter filesystem or permission problems. **You have been warned.**
- For macOS users, install [HomeBrew](https://brew.sh) for packages introduced below.
  - Read [this](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/) for faster internet access.
  - You may use those BSD utils bundled by macOS XCode, but they may generate errors. **You have been warned.**
- For BSD users, install GNU version of your BSD utilities.
- Using [Cygwin](https://www.cygwin.com/), [MSYS2](https://www.msys2.org/), [MinGW](https://osdn.net/projects/mingw), [MinGW-w64](https://www.mingw-w64.org/), or variants is **STRONGLY DISCOURAGED**.

### Packages

For Debian-based systems:

```bash
sudo apt-get install \
    coreutils bash diffutils patch strace \
    gcc g++ cpp binutils libtool libtool-bin \
    build-essential linux-libc-dev libc-bin libc6-dev libc6 \
    make cmake autoconf automake \
    wget tar gzip xz-utils bzip2
sudo apt-get install libgcc-12-dev # Replace 12 with GCC version you just installed
```

Basis:

- [GNU CoreUtils](https://www.gnu.org/software/coreutils/), which provides `mkdir` `ls` `chmod` `rm`, etc.
  - Those provided by \*BSD, macOS, [plan9](http://tools.suckless.org/9base), [`busybox`](https://busybox.net/) may **NOT** work.

  ```bash
  ls --version
  # ls (GNU coreutils) 9.4
  # [...]
  ```

- [GNU Bourne-Again Shell (Bash)](https://www.gnu.org/software/bash/) for `bash`.
  - Require Bash >= 4.4.
  - Using [Z Shell](https://www.zsh.org/) (zsh) or Friendly Interactive Shell (`fish`), **MAY** work; Using POSIX Bourne Shell (`sh`), Almquist Shell (`ash`), Debian Almquist Shell (`dash`), Korn Shell (`ksh`), or C Shell (`csh`) and variants will **NOT** work.

  ````bash
  bash --version
  # GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
  # [...]
  ````

- [GNU DiffUtils](https://www.gnu.org/software/diffutils/) and [GNU Patch](https://www.gnu.org/software/patch/) for `diff` and `patch`. Used in `lab3` only.

  ```bash
  diff --version
  # diff (GNU diffutils) 3.10
  # [...]
  patch --version
  # GNU patch 2.7.6
  # [...]
  ```

- GNU Text processing utils: [GNU Grep](https://www.gnu.org/software/grep/), [GNU Sed](https://www.gnu.org/software/sed/), and [GNU AWK](https://www.gnu.org/software/gawk/).

  ```bash
  grep --version
  # grep (GNU grep) 3.11
  # [...]
  sed --version
  # sed (GNU sed) 4.9
  # [...]
  awk --version
  # GNU Awk 5.2.1, API 3.2, PMA Avon 8-g1, (GNU MPFR 4.2.1, GNU MP 6.3.0)
  # [...]
  ```

- (Optional) [strace](https://strace.io), for `strace` that allows analyzing Linux system calls.

  ```bash
  strace --version
  # strace -- version 6.8
  # [...]
  ```

Compiling \& Linking:

- [GNU Compiler Collection (GCC)](https://gcc.gnu.org/). Need at least `gcc` and `g++`.

  ```bash
  gcc --version
  # gcc (Ubuntu 13.3.0-3ubuntu1) 13.3.0
  # [...]
  g++ --version
  # g++ (Ubuntu 13.3.0-3ubuntu1) 13.3.0
  # [...]
  ```

- (Optional) [LLVM Clang](https://clang.llvm.org/), a GCC alternative.

  ```bash
  clang --version
  # Ubuntu clang version 18.1.8 (1)
  # Target: x86_64-pc-linux-gnu
  # Thread model: posix
  # InstalledDir: /usr/bin
  ```

- [GNU BinUtils](https://www.gnu.org/software/binutils/) for `ld`, `as`, `ar`, `ranlib`, and `readelf`.

  ```bash
  ld --version
  # GNU ld (GNU Binutils for Ubuntu) 2.42.50.20240710
  # [...]
  ```

- (Optional) [LLVM Core](https://llvm.org/) for `llvm-as`, `llvm-ar`, `llvm-ranlib` and `llvm-readelf`; [LLVM LLD](https://lld.llvm.org/) for `ld.lld`.

  ```bash
  llvm-ranlib --version
  # Ubuntu LLVM version 18.1.8
  #   Optimized build.
  ld.lld --version
  # Ubuntu LLD 18.1.8 (compatible with GNU linkers)
  ```

- [GNU LibTool](https://www.gnu.org/software/libtool/) for `libtool` executable. For Debian-based distributions, installing [`libtool`](https://packages.debian.org/stable/libtool) is usually not enough. You also need [`libtool-bin`](https://packages.debian.org/stable/libtool-bin).

  ```bash
  libtool --version
  # libtool (GNU libtool) 2.4.7
  # [...]
  ```

- Essential development libraries. For Debian-based systems, that includes:
  - [`linux-libc-dev`](https://packages.debian.org/stable/linux-libc-dev) for Linux kernel header files.
  - [`libc-bin`](https://packages.debian.org/stable/libc-bin) for `ldd`.
  
    ```bash
    ldd --version
    # ldd (Ubuntu GLIBC 2.39-0ubuntu9) 2.39
    # [...]
    ```

  - [`libc6-dev`](https://packages.debian.org/stable/libc6-dev) for GNU C Library (glibc) headers, share/static libraries, and essential object files.
  - [`libc6`](https://packages.debian.org/stable/libc6) for glibc libraries and loaders.
  - [`libgcc-12-dev`](https://packages.debian.org/stable/libgcc-12-dev) (Replace `12` with your GCC version accordingly) for GCC runtime library.

Test whether you have get all those by running (replace `gcc` by `clang` as your wish):

```bash
echo 'int main(){return 0;}' | gcc -o tmp -Wall -Wextra -fPIE -x c -
./tmp
echo 'int main(){return 0;}' | \
  gcc -o tmp -Wall -Wextra -fPIE -x c - -static -static-libgcc
./tmp
rm -f tmp
```

If any error occurs, your toolchain is not complete!

Building systems:

- [GNU Make](https://www.gnu.org/software/make/) for `make`. BSD Make on macOS and \*BSD will **NOT** work.

  ```bash
  make --version
  # GNU Make 4.3
  # Built for x86_64-pc-linux-gnu
  # [...]
  ```
  
- [CMake](https://cmake.org/) for `cmake`. Requires CMake >= 3.12.

  ```bash
  cmake --version
  # cmake version 3.29.6
  #
  # CMake suite maintained and supported by Kitware (kitware.com/cmake).
  ```

- GNU AutoTools, including [GNU AutoConf](https://www.gnu.org/software/autoconf/) and [GNU AutoMake](https://www.gnu.org/software/automake/).

  ```bash
  autoconf --version
  # autoconf (GNU Autoconf) 2.71
  # [...]
  automake --version
  # automake (GNU automake) 1.16.5
  # [...]
  ```

- (Optional) [GNU TexInfo](https://www.gnu.org/software/texinfo/) and [LaTeX](https://www.latex-project.org/) for compiling GNU TexInfo files to PDF. Installation of LaTeX can be done with ease using [TeXLive](https://tug.org/texlive/), [MacTeX](https://tug.org/mactex/) or [MikTeX](https://miktex.org/) distributions.

  ```bash
  makeinfo --version
  # texi2any (GNU texinfo) 7.1
  # [...]
  pdflatex --version
  # MiKTeX-pdfTeX 4.15 (MiKTeX 23.5)
  # (C) 1982 D. E. Knuth, (C) 1996-2023 Han The Thanh
  # TeX is a trademark of the American Mathematical Society.
  # [...]
  ```

Downloading files:

- [GNU WGet](https://www.gnu.org/software/wget/) for `wget`, which downloads required files.

  ```bash
  wget --version
  # GNU Wget 1.24.5 built on linux-gnu.
  # [...]
  ```

Compression:

- [GNU Tar](https://www.gnu.org/software/tar/) for `tar`.
  
  ```bash
  tar --version
  # tar (GNU tar) 1.35
  # [...]
  ```

- [GNU GZip](https://www.gnu.org/software/gzip/) for `gzip`.

  ```bash
  gzip --version
  # gzip 1.12
  # [...]
  ```

- [XZ Utils](http://tukaani.org/xz/) for `xz`. Beware of the [XZ Backdoor](https://nvd.nist.gov/vuln/detail/CVE-2024-3094).

  ```bash
  xz --version
  # xz (XZ Utils) 5.6.2
  # liblzma 5.6.2
  ```

- [bzip2](https://sourceware.org/bzip2) for `bzip2`.

  ```bash
  bzip2 --version
  # bzip2, a block-sorting file compressor.  Version 1.0.8, 13-Jul-2019.
  # [...]
  ```

If you're using LabW Kiki, all packages should have been installed.

## Organization of Files

- `lab?`: Supporting materials for each lab.
- `.clang-*`: Configurations for clang-format and clang-tidy.
- `fmt.sh`: Automatically format all files.
- `License.md`: The license of the project.
- `Readme.md`: This file.

## How to Use These Labs

The labs should be learnt in a non-linear manner. i.e., the knowledge taught at the front may rely on what is taught next. If you find yourself hard to understand something, skip it, read the docs, search the web, ask generative AI, or find answers on [Stack Overflow](https://stackoverflow.com/) [^ASK].

The labs heavily relies on the official documentation of mentioned software. For example to finish lab1, you may extensively refer to [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html), its manual pages (`man bash`) or info pages (`info bash`).

To read those Markdowns in a more friendly manner, you may compile them to PDF using [`pandoc`](https://pandoc.org/). Note that it requires LaTeX, whose link can be found above.

```bash
pandoc Readme.md -o Readme.pdf
```

For unfamiliar file formats, you are recommended to use [file](https://www.darwinsys.com/file/). For example:

```bash
file lab2/01_shell_scp/*.{a,so,s,o}
# lab2/01_shell_scp/libstupid.a:  current ar archive
# lab2/01_shell_scp/libstupid.so: ELF 64-bit LSB shared object, x86-64, version
# 1 (SYSV), dynamically linked, BuildID[xxHash]=3698f67aecbefcf6, not stripped
# lab2/01_shell_scp/main.s:       assembler source, ASCII text
# lab2/01_shell_scp/main.o:       ELF 64-bit LSB relocatable, x86-64, version 1
# (SYSV), not stripped
# lab2/01_shell_scp/stupid.o:     ELF 64-bit LSB relocatable, x86-64, version 1
# (SYSV), not stripped
```

[^ASK]: You're recommended to read [_How To Ask Questions The Smart Way_](http://www.catb.org/~esr/faqs/smart-questions.html) ([Chinese](https://lug.ustc.edu.cn/wiki/doc/smart-questions/)) before posting questions on public forums, mailing lists, or IRC channels.
