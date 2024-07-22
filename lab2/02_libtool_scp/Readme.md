# Stupid C Program using GNU LibTool and GNU Make

This directory contains a very simple using GNU LibTool and GNU Make. The former is used to create binary files and libraries for diverse platforms, while the latter is used for managing file dependencies. Compile the program and install it to `./opt` through:

```bash
make clean install
```

Try change some environment variables like `CC` or `PREFIX` and see what's happening. For example:

```bash
CC=clang make clean install
```

To see targets supported by the underlying Makefile, we may (From [here](https://unix.stackexchange.com/questions/230047/how-to-list-all-targets-in-make)):

```bash
make -qp | \
    awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | \
    sort -u
# all
# clean
# install
# lib%.la
# libstupid.la
# main
# main.lo
# main_static
# Makefile
# stupid.lo
```
