#!/usr/bin/env bash
set -uex

make distclean || true
rm -fr \
    opt .deps ./*cache* ./*.m4 \
    ar-lib compile config.guess config.h.in config.sub configure \
    depcomp install-sh ltmain.sh main.c Makefile.in missing \
    stupid.c stupid.h stupid.info test-driver texinfo.tex ./*.log ./*.tar.*
cp ../src/*.c ../src/*.h .
autoreconf -f -v -i &>build.autoreconf.log

env -i PATH="/usr/bin" ./configure --prefix="$(pwd)/opt" &>build.configure.log

if which makeinfo &>/dev/null && which pdflatex &>/dev/null; then
    env -i PATH="/usr/bin" make -j8 doc &>build.make_doc.log
    env -i PATH="/usr/bin" make -j8 install install-doc &>build.make.log
fi
env -i PATH="/usr/bin" make -j8 dist &>build.make_dist.log
