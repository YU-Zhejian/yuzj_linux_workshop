# Stupid C Program using GNU LibTool and GNU Make

This directory contains a very simple using GNU LibTool and GNU Make. The former is used to create binary files and libraries for diverse platforms, while the latter is used for managing file dependencies. Compile the program and install it to `./opt` through:

```bash
make clean install
```

Try to change some environment variables like `CC` or `PREFIX` and see what's happening. For example:

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

## GNU Make

GNU Make is, at essence, an executor of a direct acrylic graph of dependencies.

GNU Make is formed by a set of rules that are defined in a Makefile. For example, this rule with wildcard:

```make
%.lo: ../src/%.c
	libtool --tag=CC --mode=compile $(CC) $(CFLAGS) -c $<
```

Would build object files with the `.lo` suffix from a source file. And this rule:

```make
main: libstupid.la main.lo
	libtool --tag=CC --mode=link $(CC) $(LDFLAGS) -rpath $(PREFIX)/lib/ -o main $^
```

Would create `main` by linking `libstupid.la` and `main.lo`.

GNU Make will rebuild the target if any of its dependencies have changed (i.e., a newer modification time).

GNU Make also supports phony targets, which are non-file targets that will always be rebuilt. For example:

```make
.PHONY: clean
clean:
	[...]
```

Read its manual for more details. Using GNU Make will also largely simplify daily maintenance \& bioinformatics work.
