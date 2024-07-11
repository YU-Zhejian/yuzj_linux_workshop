# GNU/Linux Workshop by YU ZJ at 2024/07

## What to Prepare

### The System

You need an accessible working GNU/Linux installation. No root privilege is required. The following options are acceptable:

- Linux operating system installed on your computer. It can co-exist with Microsoft Windows through Grub.
- SSH over lab server.
- For Microsoft Windows users, install Windows System on Linux (WSL) 2 \[1\].
- For MacOS users, install HomeBrew \[2\] for packages introduced below.

Using Cygwin, MSYS, MSYS2, MinGW, MinGW64, or variants is strongly discouraged.

Required packages:

- GNU CoreUtils.
- GNU Bash.
- GNU Compiler Collection (GCC).
- GNU Make.
- Cmake.
- Git.

### Download External Resources

Execute `src/reproduce.sh` to fetch all external resources.

## References

- \[1\]: <https://learn.microsoft.com/en-us/windows/wsl/install>
- \[2\]: <https://brew.sh>. See also: <https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/> for faster internet access.
