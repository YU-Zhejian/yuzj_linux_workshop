#!/usr/bin/env bash
set -ue
wget -c -4  https://gcc.gnu.org/onlinedocs/gcc-14.2.0/gcc.pdf

for software in ld binutils as; do
    wget -c -4 https://sourceware.org/binutils/docs/"${software}".pdf
done

for software in automake libtool make autoconf bash grep sed gawk; do
    wget -c -4  https://www.gnu.org/software/"${software}"/manual/"${software}".pdf
done
