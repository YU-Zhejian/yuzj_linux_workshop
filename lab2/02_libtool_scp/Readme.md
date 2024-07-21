# Stupid C Program using GNU LibTool and GNU Make

This directory contains a very simple using GNU LibTool and GNU Make. The former is used to create binary files and libraries for diverse platforms, while the latter is used for managing file dependencies. Compile the program and install it to `./opt` through:

```bash
make clean install
```

Try change some environment variables like `CC` or `PREFIX` and see what' happenning. For example:

```bash
CC=clang make clean install
```
