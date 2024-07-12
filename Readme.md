# GNU/Linux Workshop by YU ZJ at 2024/07

The Linux workshop at Zhejiang University for Year 2 \& 3 Bioinformatics BsC students.

## What to Prepare before the Workshop

### Operating System

You need an accessible working GNU/Linux installation. No root privilege is required. The following options are acceptable:

- Linux operating system installed on your computer. It can co-exist with Microsoft Windows through Grub.
- SSH over lab server.
- For Microsoft Windows users, install Windows System on Linux (WSL) 2. [Instructions](https://learn.microsoft.com/en-us/windows/wsl/install).
- For macOS users, install [HomeBrew](https://brew.sh) for packages introduced below. Read [this](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/) for faster internet access.

Using [Cygwin](https://www.cygwin.com/), [MSYS2](https://www.msys2.org/), [MinGW](https://osdn.net/projects/mingw), [MinGW-w64](https://www.mingw-w64.org/), or variants is **STRONGLY DISCOURAGED**.

## Packages

Basis:

- [GNU CoreUtils](https://www.gnu.org/software/coreutils/), which provides `mkdir` `ls` `chmod` `rm`, etc. Those provided by \*BSD and macOS may **NOT** work.
- [GNU Bourne-Again Shell (Bash)](https://www.gnu.org/software/bash/) for `bash`. Using [Z Shell](https://www.zsh.org/) (zsh) **MAY** work; Using POSIX Bourne Shell, Korn Shell (ksh), or C Shell (csh) will **NOT** work.
- [GNU DiffUtils](https://www.gnu.org/software/diffutils/) and [GNU Patch](https://www.gnu.org/software/patch/) for `diff` and `patch`.

Compiling \& Linking:

- [GNU Compiler Collection (GCC)](https://gcc.gnu.org/). Need at least `gcc` and `g++`.
- [GNU BinUtils](https://www.gnu.org/software/binutils/) for linker (`ln`) and ELF executable reader (`readelf`).

Building systems:

- [GNU Make](https://www.gnu.org/software/make/) for `make`. BSD Make on macOS and \*BSD will not work.
- [CMake](https://cmake.org/) for `cmake`.

Downloading files:

- [Git](https://git-scm.com) for cloning this repository.
- [GNU Wget](https://www.gnu.org/software/wget/) for `wget`, which downloads required files.

Compression:

- [GNU Tar](https://www.gnu.org/software/tar/) for `tar`.
- [GNU GZip](https://www.gnu.org/software/gzip/) for `gzip`.
- [XZ Utils](http://tukaani.org/xz/) for `xz`. Beware of the [XZ Backdoor](https://nvd.nist.gov/vuln/detail/CVE-2024-3094).
- [bzip2](https://sourceware.org/bzip2) for `bzip2`.

### Download External Resources

After installing all packages, execute `src/reproduce.sh` in `src` to fetch all external resources.
