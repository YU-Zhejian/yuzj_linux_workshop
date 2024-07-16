# Lab 4: Build Linux Kernel from Scratch

Version 1.0.

This lab allows you to build a Linux kernel from scratch and run it using PC emulators.

**WARNING**: This lab is tough for those who do not have experience in operating systems.

**NOTE**: The success construction of the Linux kernel largely depends on multiple factors like the version of compilers, the kernel version of the hosting system, and architecture of the host machine, etc.

**NOTE**: This version uses the earliest supporting LTS kernel, 4.19, whose End-Of-Life is at 2024/12. In case of errors, consult documentation [here](https://www.kernel.org/doc/html/v4.19/).

**Also see**: The [Linux from Scratch](https://www.linuxfromscratch.org/) (LFS) Project.

## Learning Objectives

- Understand the relationship between the filesystem, kernel, and shell.
- Knowing the basis of Linux booting process.
- Gain experience on compiling large C projects.

## Files in this Directory

- `linux.ini`: Configuration file for building the Linux kernel.
- `busybox.ini`: Configuration file for building static BusyBox.
- `hello.c`: A hello world program in C.
- `logs`: Kernel logs from QEMU.
- `busybox_initramfs`: File system tree for BusyBox initramfs.
- `src`: External source files.
- `opt`: Installation path of various packages.

## Dependencies

Get files using `src/reproduce.sh`. For building the kernel, see [this](https://www.kernel.org/doc/html/v4.19/process/changes.html#minimal-requirements-to-compile-the-kernel). For running the generated kernel and initramfs using virtual machine, install [QEMU](https://www.qemu.org) and [GNU cpio](https://www.gnu.org/software/cpio/).

## Configure the Linux Kernel

The Linux kernel is bundled with diverse drivers that are not needed for this small lab. A pre-configured version can be used via:

```shell
cp linux.ini src/linux-4.19.317/.config
```

This configuration is based on the configuration generated using `make -j8 -C src/linux-4.19.317 x86_64_defconfig` by removing network, graphics and sound related drivers, with the addition of [SquashFS](http://www.squashfs.org/) driver (although not used).

If you prefer to configure your own kernel, first generate a default configuration using:

```shell
make -j8 -C src/linux-4.19.317 x86_64_defconfig
```

Then customize in a terminal user interface with:

```shell
make -j8 -C src/linux-4.19.317 menuconfig
```

## Build Linux Kernel

Now we build the kernel and install Linux headers for developmental purposes. `env -i` was used to execute building process in a clean environment.

```shell
env -i PATH="/usr/bin" \
    make -j8 -C src/linux-4.19.317 bzImage
env -i PATH="/usr/bin"  \
    make -j8 -C src/linux-4.19.317 headers_install \
    ARCH=x86_64 \
    INSTALL_HDR_PATH="$(pwd)/opt/linux_headers"
```

Now the Linux kernel boot image will be available at `src/linux-4.19.317/arch/x86/boot/bzImage` and could be booted via QEMU. Try:

```shell
qemu-system-x86_64 \
    -m 2048 \
    -smp 1 \
    -machine pc \
    -kernel ./src/linux-4.19.317/arch/x86/boot/bzImage \
    -append "nokaslr console=tty0 console=ttyS0,115200" \
    -nographic
```

The kernel will boot and panic since no root filesystem was specified. See `logs/kernel.1.log` for the log on my system. Don't forget to terminate the QEMU emulator with `kill`.

## Building a Small C Library on the Kernel

Almost all applications would work a C library (`libc`), so building such is important. For simplicity and size, we choose [Musl](https://musl.libc.org/) as our C library. Enter `src/musl-1.2.5`, and run:

```shell
env -i PATH="/usr/bin" \
    ./configure  --prefix="$(pwd)/../../opt/musl-1.2.5"
env -i PATH="/usr/bin" make -j8 install
```

and a Musl C library together with its development tools and headers will be installed to `opt/musl-1.2.5`.

## The Hello World Initial RAM Filesystem (initramfs)

An initial RAM filesystem is a Linux filesystem that exists as a memory image and is supported by QEMU. We will use it as our root filesystem. Consult [here](https://www.kernel.org/doc/html/v4.19/admin-guide/initrd.html) for a more detailed introduction.

Now we will compile a static hello world program against the installed Musl C library.

```shell
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

```shell
echo -e "init" | \
    cpio -ov -D opt/hello_world_initramfs -H newc | \
    gzip -9 > opt/hello_world_initramfs.cpio.gz
```

Now run the kernel with our newly packed initramfs:

```shell
qemu-system-x86_64 \
    -m 2048 \
    -smp 1 \
    -machine pc \
    -kernel ./src/linux-4.19.317/arch/x86_64/boot/bzImage \
    -initrd opt/hello_world_initramfs.cpio.gz \
    -append "nokaslr console=tty0 console=ttyS0,115200 root=/dev/ram rdinit=/init rootfstype=ramfs" \
    -nographic
```

The init process successfully printed "Hello world!" and exit, which results in kernel panic. See `logs/kernel.2.log` for details.

## The BusyBox initramfs

Now we will build an initramfs that have a shell and some basic utilities inside. For such purposes, [BusyBox](https://www.busybox.net) will be a good choice. It contains simplified versions of various utilities with clean dependency (Linux headers and the C library).

```shell
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

```shell
qemu-system-x86_64 \
    -m 2048 \
    -smp 1 \
    -machine pc \
    -kernel ./src/linux-4.19.317/arch/x86_64/boot/bzImage \
    -initrd opt/busybox_initramfs.cpio.gz \
    -append "nokaslr console=tty0 console=ttyS0,115200 root=/dev/ram rdinit=/init rootfstype=ramfs" \
    -nographic \
    -no-reboot
```

Now you may safely shut down the system through `reboot -f`.

## Host Systems Tested

- Version 1.0 (this version):
   - Linux Mint 21.3 machine with `11.4.0-1ubuntu1~22.04` GCC and `6.5.0-41-generic` kernel of architecture `x86_64`.
   - Debian Testing with `Debian 13.3.0-1` GCC and `Debian 6.5.6-1` kernel of architecture `x86_64`.
   - Ubuntu 20.04 LTS (`focal`) with `Ubuntu 9.4.0-1ubuntu1~20.04.2` GCC and `5.15.0-87-generic #97~20.04.1-Ubuntu` kernel of architecture `x86_64`.
