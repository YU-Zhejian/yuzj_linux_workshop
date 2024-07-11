# Lab 4: Build Linux Kernel from Scratch

**WARNING**: This lab is very hard for those who do not have experience in operating systems.

This lab was finished on a Linux Mint 21.3 machine with `11.4.0-1ubuntu1~22.04` GCC and `6.5.0-41-generic` kernel.

## Configure the Building Process

Linux kernel bundles itself with dependencies we may not want.

Generate a default configuration using:

```shell
make -j8 -C src/linux-4.19.317 x86_64_defconfig
```

And then customize in a terminal user interface with:

```shell
make -j8 -C src/linux-4.19.317 menuconfig
```

A pre-configured version can be used via

```shell
cp lfs/linux.conf src/linux-4.19.317/.config
```

## Build Linux Kernel

Now we build the kernel and install Linux headers for developmental purposes.

```shell
make -j8 -C src/linux-4.19.317 bzImage \
    C_INCLUDE_PATH="/usr/include"
make -j8 -C src/linux-4.19.317 headers_install \
    ARCH=x86_64 \
    INSTALL_HDR_PATH="$(pwd)/opt/linux_headers"
```

Now the Linux kernel boot image will be available at `src/linux-4.19.317/arch/x86/boot/bzImage` and could be boot via QEMU. Let's try this:

```shell
qemu-system-x86_64 \
    -m 2048 \
    -smp 1 \
    -machine pc \
    -kernel ./src/linux-4.19.317/arch/x86/boot/bzImage \
    -append "nokaslr console=tty0 console=ttyS0,115200" \
    -nographic
```

The kernel will go into panic since no root filesystem was specified. See `lfs/logs/kernel.1.log` for the log on my system.

## Building C Library on the Kernel

As we all know, almost all applications would work on the system C library (`libc`), so building such is important.

Enter `src/musl-1.2.5`, ans run:

```shell
./configure  --prefix="$(pwd)/../../opt/musl-1.2.5"
make -j8 install
```

and Musl C library will be installed to `opt/musl-1.2.5`.

## The Hello World Init RAM Filesystem (initramfs)

Now we would compile a static hello world program against musl C library.

```shell
mkdir -p opt/hello_world_initramfs
opt/musl-1.2.5/bin/musl-gcc \
    -static -static-libgcc \
    lfs/hello.c \
    -o opt/hello_world_initramfs/init
strip opt/hello_world_initramfs/init
```

And pack it into the initramfs:

```shell
echo -e "init" | \
    cpio -ov -D opt/hello_world_initramfs -H newc | \
    gzip -9 > opt/hello_world_initramfs.cpio.gz
```

Now run the program:

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

The init process successfully printed "Hello world!" and exit, which results in kernel panic. See `lfs/logs/kernel.2.log` for details.

## The BusyBox initramfs

```shell
make -j8 -C src/busybox-1.36.1 defconfig
make -j8 -C src/busybox-1.36.1 menuconfig
cp lfs/busybox.conf src/busybox-1.36.1/.config
make -j8 -C src/busybox-1.36.1 busybox install \
    CONFIG_PREFIX="$(pwd)/opt/busybox-1.36.1-static" \
    CC="$(pwd)/opt/musl-1.2.5/bin/musl-gcc" \
    C_INCLUDE_PATH="$(pwd)/opt/linux_headers/include"

printf '' | cpio -ov -H newc > opt/busybox_initramfs.cpio
for dir in opt/busybox-1.36.1-static lfs/busybox_initramfs; do
    find "${dir}" | \
        sed 's;'"${dir}"';.;' | \
        cpio -A -ov -D "$(pwd)/${dir}" -H newc \
        -O opt/busybox_initramfs.cpio
done
gzip -9f opt/busybox_initramfs.cpio
```

Remember, shutdown the system through `reboot -f`.

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
