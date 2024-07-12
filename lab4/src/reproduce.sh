#!/usr/bin/env bash
set -ue
cd "$(readlink -f "$(dirname "${0}")")"

wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.317.tar.xz
wget https://musl.libc.org/releases/musl-1.2.5.tar.gz
wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2

for fn in ./*.tar.bz2; do
    tar xvjf "${fn}"
done

for fn in ./*.tar.xz; do
    tar xvJf "${fn}"
done

for fn in ./*.tar.gz; do
    tar xvzf "${fn}"
done
