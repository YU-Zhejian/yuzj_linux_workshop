#!/usr/bin/env bash
set -uex
rm -fr build_make build_ninja opt
mkdir -p build_make build_ninja
env -i -C build_make PATH="/usr/bin" cmake .. \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/opt" \
    &>build_make.configure.log
env -i -C build_make PATH="/usr/bin" make -j8 \
    &>build_make.make.log
env -i -C build_make PATH="/usr/bin" make install -j8 \
    &>build_make.make_install.log
env -i -C build_make PATH="/usr/bin" ctest \
    &>build_make.ctest.log

env -i -C build_ninja PATH="/usr/bin" cmake \
    -DCMAKE_C_COMPILER=clang \
    -G Ninja \
    .. &>build_ninja.configure.log
env -i -C build_ninja PATH="/usr/bin" ninja -j8 \
    &>build_ninja.make.log
env -i -C build_ninja PATH="/usr/bin" ninja -t graph |
    dot -Tpdf -ocmake_ninja.pdf
