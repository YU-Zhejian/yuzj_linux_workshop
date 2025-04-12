#!/usr/bin/env bash
set -ue

PWD="$(pwd)"
[ -n "${CC:-}" ] || CC="$(which gcc)"
[ -n "${AR:-}" ] || AR="$(which ar)"
[ -n "${RANLIB:-}" ] || RANLIB="$(which ranlib)"
# shellcheck disable=SC2206
[ -n "${CFLAGS:-}" ] && CFLAGS=(${CFLAGS}) || CFLAGS=("-O2" "-Wall" "-Wextra" "-DBUILT_UNDER_SHELL" "-fPIC" "-fPIE")
# shellcheck disable=SC2206
[ -n "${LDFLAGS:-}" ] && LDFLAGS=(${LDFLAGS}) || LDFLAGS=("-L${PWD}")
set -x

# Build
"${CC}" "${CFLAGS[@]}" --verbose -E -o main.i ../src/main.c &>main.i.log
"${CC}" "${CFLAGS[@]}" --verbose -S -o main.s main.i &>main.s.log
"${CC}" "${CFLAGS[@]}" --verbose -c -o main.o main.s &>main.o.log
"${CC}" "${CFLAGS[@]}" --verbose -c -o stupid.o ../src/stupid.c &>stupid.o.log

# Link
"${AR}" rvcs libstupid.a stupid.o &>libstupid.a.log
"${RANLIB}" libstupid.a &>>libstupid.a.log
"${CC}" "${LDFLAGS[@]}" --verbose -shared -o libstupid.so stupid.o &>libstupid.so.log

"${CC}" "${LDFLAGS[@]}" --verbose -Wl,-rpath="${PWD}" -o main main.o -lstupid &>main.log
"${CC}" "${LDFLAGS[@]}" --verbose -static -static-libgcc -o main_static main.o -lstupid &>main_static.log
