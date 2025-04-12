#!/usr/bin/env bash

wget https://gcc.gnu.org/onlinedocs/gcc-14.2.0/gcc.pdf

for software in ld binutils as; do
    wget https://sourceware.org/binutils/docs/"${software}".pdf
done

for software in automake libtool make autoconf bash grep sed gawk; do
    wget https://www.gnu.org/software/"${software}"/manual/"${software}".pdf
done
