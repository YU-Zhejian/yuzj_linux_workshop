#!/usr/bin/env bash
set -ue
cd "$(readlink -f "$(dirname "${0}")")"

wget -4 https://cmake.org/files/v3.30/cmake-3.30.0-linux-x86_64.tar.gz
tar xzvf cmake-3.30.0-linux-x86_64.tar.gz
