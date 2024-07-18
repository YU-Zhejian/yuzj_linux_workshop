#!/usr/bin/env bash
set -ue

PWD="$(pwd)"
[ -n "${CC:-}" ] || CC="$(which gcc)"
[ -n "${AR:-}" ] || AR="$(which ar)"
[ -n "${RANLIB:-}" ] || RANLIB="$(which ranlib)"
[ -n "${CFLAFS:-}" ] || CFLAFS=("-O2" "-Wall" "-Wextra" "-DBUILT_UNDER_SHELL" "-fPIC" "-fPIE")
[ -n "${LDFLAGS:-}" ] || LDFLAGS=("-L${PWD}")
set -x

# Build
"${CC}" "${CFLAFS[@]}" --verbose -E -o main.i ../src/main.c &>main.i.log
"${CC}" "${CFLAFS[@]}" --verbose -S -o main.s main.i &>main.s.log
"${CC}" "${CFLAFS[@]}" --verbose -c -o main.o main.s &>main.o.log

"${CC}" "${CFLAFS[@]}" --verbose -c -o stupid.o ../src/stupid.c &>stupid.o.log

# Link
"${AR}" rvcs libstupid.a stupid.o &>libstupid.a.log
"${RANLIB}" libstupid.a &>>libstupid.a.log
"${CC}" "${LDFLAGS[@]}" --verbose \
    -shared \
    -Wl,-rpath="${PWD}" \
    -o libstupid.so stupid.o \
    &>libstupid.so.log

"${CC}" "${LDFLAGS[@]}" --verbose -o main main.o -lstupid &>main.log
"${CC}" "${LDFLAGS[@]}" --verbose -static -static-libgcc -o main_static main.o -lstupid &>main_static.log
