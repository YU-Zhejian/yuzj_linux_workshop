#!/usr/bin/env bash
set -uex

make distclean || true
rm -fr \
    opt .deps ./*cache* ./*.m4 \
    ar-lib compile config.guess config.h.in config.sub configure \
    depcomp install-sh ltmain.sh main.c Makefile.in missing \
    stupid.c stupid.h stupid.info test-driver texinfo.tex ./*.log ./*.tar.* \
    config.* configure libtool* ./*main* ./Makefile ./Makefile.in ./stamp* \
    ./*.lo ./*.o ./*.la .libs stupid.html
