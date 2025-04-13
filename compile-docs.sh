#!/usr/bin/env bash

set -ue
mkdir -p _build

pandoc -H header.tex Readme.md -o _build/index.pdf &
for i in {1..4}; do
    pandoc -H header.tex lab"${i}"/Readme.md -o "_build/lab${i}.pdf" &
done

for folder in src 01_shell_scp 02_libtool_scp 03_autotools_scp 04_cmake_scp; do
    pandoc -H header.tex lab2/"${folder}/Readme.md" -o "_build/lab2_${folder}.pdf" &
done
wait
qpdf --empty --pages \
    _build/index.pdf \
    _build/lab1.pdf \
    _build/lab2.pdf \
    _build/lab2_src.pdf \
    _build/lab2_01_shell_scp.pdf \
    _build/lab2_02_libtool_scp.pdf \
    _build/lab2_03_autotools_scp.pdf \
    _build/lab2_04_cmake_scp.pdf \
    _build/lab3.pdf \
    _build/lab4.pdf \
    -- out.pdf
