#!/usr/bin/env bash
set -ue
cd "$(readlink -f "$(dirname "${0}")")"

wget https://salsa.debian.org/med-team/bwa/-/archive/debian/0.7.17-7/bwa-debian-0.7.17-7.tar.bz2
wget https://salsa.debian.org/med-team/kalign/-/archive/debian/1%253.4.0-1/kalign-debian-1%253.4.0-1.tar.bz2
wget https://sourceforge.net/projects/samtools/files/samtools/1.20/htslib-1.20.tar.bz2
wget https://sourceforge.net/projects/samtools/files/samtools/1.20/samtools-1.20.tar.bz2

for fn in ./*.tar.bz2; do
    tar xvjf "${fn}"
done
