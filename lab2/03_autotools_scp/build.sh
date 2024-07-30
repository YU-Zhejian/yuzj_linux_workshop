#!/usr/bin/env bash
set -uex

cp ../src/*.c ../src/*.h .
autoreconf -f -v -i &>build.autoreconf.log

env -i PATH="/usr/bin" ./configure --prefix="$(pwd)/opt" &>build.configure.log
env -i PATH="/usr/bin" make -j8 &>build.make.log
env -i PATH="/usr/bin" make -j8 install &>build.make_install.log

if which makeinfo &>/dev/null && which pdflatex &>/dev/null; then
    env -i PATH="/usr/bin" make -j8 doc &>build.make_doc.log
    env -i PATH="/usr/bin" make -j8 install-doc &>build.make_install_doc.log
fi
env -i PATH="/usr/bin" make -j8 dist &>build.make_dist.log
