---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
colorlinks: true
---

# Lab 4: Build Linux Kernel from Scratch

Version 1.0.

This lab allows you to build a Linux kernel from scratch and run it using PC emulators.

**WARNING**: This lab is **OPTIONAL**. Do not waste time there if you're busy.

**WARNING**: This lab will be extremely tough for those who do not have sufficient experience in operating systems.

**WARNING**: This lab assumes X86\_64 hosts, which usually have [Intel](https://www.intel.com/content/www/us/en/homepage.html) or [AMD](https://www.amd.com/en.html) CPU(s). If you're on machine of other architectures (e.g., [Apple Silicon](https://support.apple.com/en-us/116943), [Raspberry Pi](https://www.raspberrypi.com/) and other [ARM](https://www.arm.com), [Loongson](https://www.loongson.cn/EN/), etc.), you may experience difficulties.

**NOTE**: The success construction of the Linux kernel largely depends on multiple factors like the version of compilers, the kernel version of the hosting system, and architecture of the host machine, etc.

**NOTE**: This version uses the earliest supporting LTS kernel, 4.19, whose End-Of-Life is at 2024/12. In case of errors, consult documentation [here](https://www.kernel.org/doc/html/v4.19/).

**Also see**: The [Linux from Scratch](https://www.linuxfromscratch.org/) (LFS) Project, which provides extensive documentations on how to build a working Linux distribution from scratch.

## Learning Objectives

- Understand the relationship between the filesystem, kernel, and shell.
- Knowing the basis of Linux booting process.
- Gain experience on compiling large C projects.

## Files in this Directory

- `linux.ini`: Configuration file for building the Linux kernel.
- `busybox.ini`: Configuration file for building static BusyBox.
- `hello.c`: A hello world program in C.
- `logs`: Kernel logs from QEMU.
- `busybox_initramfs`: File system tree for BusyBox initramfs. Where:
  - `init`: Script for `init` process.
  - `etc/fstab`: Filesystem mounts.
- `src`: External source files.
- `opt`: Installation path of various packages.

## Preparation

- Get files using `src/reproduce.sh`.
- Get additional dependencies from [_Minimal requirements to compile the Kernel_](https://www.kernel.org/doc/html/v4.19/process/changes.html#minimal-requirements-to-compile-the-kernel).
- For running the generated kernel and initramfs using virtual machine, install [QEMU](https://www.qemu.org) and [GNU cpio](https://www.gnu.org/software/cpio/).

## Configure the Linux Kernel

The Linux kernel is bundled with diverse drivers that are not needed for this small lab. A pre-configured version can be used via:

```bash
cp linux.ini src/linux-4.19.317/.config
```

This configuration is based on the default configuration (see below) and customized by removing network, graphics and sound related drivers.

If you prefer to configure your own kernel, first generate a default configuration using:

```bash
make -j8 -C src/linux-4.19.317 x86_64_defconfig
```

Then customize in a terminal user interface (TUI) with:

```bash
make -j8 -C src/linux-4.19.317 menuconfig
```

## Build Linux Kernel

Now we build the kernel and install Linux headers for developmental purposes. `env -i` was used to execute building process in a clean environment.

```bash
env -i PATH="/usr/bin" \
    make -j8 -C src/linux-4.19.317 bzImage
env -i PATH="/usr/bin"  \
    make -j8 -C src/linux-4.19.317 headers_install \
    ARCH=x86_64 \
    INSTALL_HDR_PATH="$(pwd)/opt/linux_headers"
```

Now the Linux kernel boot image will be available at `src/linux-4.19.317/arch/x86/boot/bzImage` with its headers installed to `opt/linux_headers`. The kernel could be booted via QEMU. Try:

```bash
KERNEL_PARAMS="nokaslr console=tty0 console=ttyS0,115200"
qemu-system-x86_64 \
    -m 2048 \
    -smp 1 \
    -machine pc \
    -kernel ./src/linux-4.19.317/arch/x86/boot/bzImage \
    -append "${KERNEL_PARAMS}" \
    -nographic
```

The additional command-line arguments to QEMU are:

- `-m 2048`: Specifies 2048 MiB of memory.
- `-smp`: With 1 CPU.
- `-machine pc`: Emulate a X86\_64 device.
- `-kernel`: The kernel boot image.
- `-append ${KERNEL_PARAMS}`: Parameters appended to the kernel. They are:
  - `nokaslr`: Disable kernel randomization.
  - `console=tty0`: Add screen (`tty0`) as console.
  - `console=ttyS0,115200`: Use serial port 0 as console with 115,200 baud.
- `-nographic`: Disable graphics and emulate a serial port instead.

The kernel will boot and panic since no root filesystem was specified. See `logs/kernel.1.log` for the log on my system. Don't forget to terminate the QEMU emulator with `kill`.

## Building a Small C Library on the Kernel

Almost all applications would work a C library (`libc`), so building such is important. For simplicity and size, we choose [Musl](https://musl.libc.org/) as our C library. Run:

```bash
env -C src/musl-1.2.5 -i PATH="/usr/bin" \
    ./configure  --prefix="$(pwd)/opt/musl-1.2.5"
env -C src/musl-1.2.5 -i PATH="/usr/bin" make -j8 install
```

and a Musl C library together with its development tools and headers will be installed to `opt/musl-1.2.5`.

## The Hello World Initial RAM Filesystem (initramfs)

An initial RAM filesystem is a Linux filesystem that exists as a memory image and is supported by QEMU. We will use it as our root filesystem. Consult [here](https://www.kernel.org/doc/html/v4.19/admin-guide/initrd.html) for a more detailed introduction. To get started, we will try to build an initramfs that prints hello world and then reboot the system.

Now we will compile a static hello world program against the installed Musl C library.

```bash
mkdir -p opt/hello_world_initramfs
env -i PATH="/usr/bin" \
    opt/musl-1.2.5/bin/musl-gcc \
    -static -static-libgcc \
    hello.c \
    -o opt/hello_world_initramfs/init
# Optional: Strip the compiled binary to reduce size.
strip opt/hello_world_initramfs/init
```

And pack it into an initramfs:

```bash
echo -e "init" | \
    cpio -ov -D opt/hello_world_initramfs -H newc | \
    gzip -9 > opt/hello_world_initramfs.cpio.gz
```

Now run the kernel with our newly packed initramfs:

```bash
KERNEL_PARAMS="${KERNEL_PARAMS} root=/dev/ram rootfstype=ramfs"
qemu-system-x86_64 \
    -m 2048 \
    -smp 1 \
    -machine pc \
    -kernel ./src/linux-4.19.317/arch/x86_64/boot/bzImage \
    -initrd opt/hello_world_initramfs.cpio.gz \
    -append "${KERNEL_PARAMS}" \
    -nographic \
    -no-reboot
```

The additional `-no-reboot` parameter will force QEMU to exit when a reboot is issues. The init process successfully printed "Hello world!" and reboots the guest (which will be trapped by QEMU). See `logs/kernel.2.log` for details.

If you do not add `reboot` at the end of your C program, the kernel will go panic (for `init` being killed). See `logs/kernel.2_fail.log`.

## The BusyBox initramfs

Now we will build an initramfs that have a shell and some basic utilities inside. For such purposes, [BusyBox](https://www.busybox.net) will be a good choice. It contains simplified versions of various utilities with clean dependency (Linux headers and the C library).

```bash
# The default config do not contain network-related applications, rpm and dpkg.
make -j8 -C src/busybox-1.36.1 defconfig # This step is mandatory
cp busybox.ini src/busybox-1.36.1/.config

# Also: if you wish to make your own
# make -j8 -C src/busybox-1.36.1 menuconfig

# Build Bysybox against MUSL
env -i PATH="/usr/bin" \
    make -j8 -C src/busybox-1.36.1 busybox install \
    CONFIG_PREFIX="$(pwd)/opt/busybox-1.36.1-static" \
    CC="$(pwd)/opt/musl-1.2.5/bin/musl-gcc" \
    C_INCLUDE_PATH="$(pwd)/opt/linux_headers/include"

# Pack initramfs
printf '' | cpio -ov -H newc > opt/busybox_initramfs.cpio
for dir in opt/busybox-1.36.1-static busybox_initramfs; do
    find "${dir}" | \
        sed 's;'"${dir}"';.;' | \
        cpio -A -ov -D "$(pwd)/${dir}" -H newc \
        -O opt/busybox_initramfs.cpio
done
gzip -9f opt/busybox_initramfs.cpio
```

```bash
qemu-system-x86_64 \
    -m 2048 \
    -smp 1 \
    -machine pc \
    -kernel ./src/linux-4.19.317/arch/x86_64/boot/bzImage \
    -initrd opt/busybox_initramfs.cpio.gz \
    -append "${KERNEL_PARAMS}" \
    -nographic \
    -no-reboot
```

Now you may safely shut down the system through `reboot -f`. Have fun on your new virtualized system!

## Host Systems Tested

- Version 1.0 (this version):
  - Linux Mint 21.3 machine with `11.4.0-1ubuntu1~22.04` GCC and `6.5.0-41-generic` kernel of architecture `x86_64`.
  - Debian 13 Testing (`trixie`)  with `Debian 13.3.0-1` GCC and `Debian 6.5.6-1` kernel of architecture `x86_64`.
  - Ubuntu 20.04 LTS (`focal`) with `Ubuntu 9.4.0-1ubuntu1~20.04.2` GCC and `5.15.0-87-generic #97~20.04.1-Ubuntu` kernel of architecture `x86_64`.
