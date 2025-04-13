---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
colorlinks: true
---
# Stupid C Program using GNU LibTool and GNU Make

This directory contains a very simple using GNU LibTool and GNU Make. The former is used to create binary files and libraries for diverse platforms, while the latter is used for managing file dependencies. Compile the program and install it to `./opt` through:

```bash
make clean install
```

## GNU Make

GNU Make is, at essence, an executor of a direct acrylic graph of dependencies.

### Rules

GNU Make is formed by a set of rules that are defined in a Makefile. A rule consists of a target, a list of prerequisites, and commands that may build the target from the prerequisites. GNU Make will rebuild the target if any of its dependencies have changed (i.e., a newer modification time). For example:

```makefile
main.o: main.c
	$(CC) $(CFLAGS) -c $<
```

This instructs the GNU Make to create `main.o` from `main.c` by compiling it with the `$(CC)` compiler and the `$(CFLAGS)` flags.

Rules may also include wildcards, which are replaced by the GNU Make with the actual file names. For example, this rule with wildcard:

```makefile
%.lo: ../src/%.c
	libtool --tag=CC --mode=compile $(CC) $(CFLAGS) -c $<
```

Would build object files with the `.lo` suffix from a source file.

A rule may have multiple prerequisites, separated by spaces. For example:

```makefile
main: libstupid.la main.lo
	[...]
```

Would create `main` by linking `libstupid.la` and `main.lo`.

GNU Make also supports phony targets, which are non-file targets that will always be rebuilt. For example:

```makefile
.PHONY: clean
clean:
	[...]
```

### Invocation

GNU Make can be invoked with arguments specifying the targets to build. For example:

```bash
make all
```

Will build the target `all`. To see targets supported by the underlying Makefile, we may (From [here](https://unix.stackexchange.com/questions/230047/how-to-list-all-targets-in-make)):

```bash
make -npq : 2> /dev/null | \
    awk -v RS= -F: '$1 ~ /^[^#%.]+$/ { print $1 }'
# clean
# all
# main
# install
# main_static
```

Common phony targets involves:

- `all`: Build all targets without installing them.
- `clean`: Remove intermediate building files.
- `test`: Run tests.
- `doc` or `docs`: Generate documentation.
- `install`: Install the targets to the path specified by (usually) `PREFIX` GNU Make variable
- `distclean` Remove all built files and restore the repository to the stable state.
- `uninstall`: Remove the targets from the path specified by (usually) `PREFIX` GNU Make variable. Note that this target is usually **NOT** implemented.

Refer to the manual of the software you are building for more details.

Behavior of GNU Make can be affected by environment variables. For example, the following Makefile section:

```makefile
PREFIX ?= "$(PWD)/opt"
CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra -DBUILT_UNDER_MAKE_LIBTOOL
LDFLAGS ?=
```

Defines default values for `CC`, `CFLAGS`, and `LDFLAGS` if they are not set in the environment. Try to change some environment variables like `CC` or `PREFIX` and see what's happening. For example:

```bash
CC=clang make clean install
```

### What's Next?

Read the [_GNU Make Manual_](https://www.gnu.org/software/make/manual/) for more information about how to write Makefile.

Using GNU Make will also largely simplify daily maintenance \& bioinformatics work. This forms the basic ideas of [SnakeMake](https://snakemake.readthedocs.io/en/stable/), a commonly used bioinformatics workflow management system.

## GNU LibTool

GNU LibTool is a tool that allows generation of shared and static libraries on diverse platforms with minimal code modifications.

For example, the code:

```makefile
%.o: ../src/%.c
	$(CC) $(CFLAGS) -c $<
```

can be re-implemented as:

```makefile
%.lo: ../src/%.c
	libtool --tag=CC --mode=compile $(CC) $(CFLAGS) -c $<
```

Note that the `.lo` extension is used to denote a LibTool object. GNU LibTool will automatically build position-independent code (PIC)-version and non-PIC-version with proper flags.

GNU LibTool also have `link` and `install` modes. Note that the latter depends on `install`, a GNU CoreUtils binary which resembles `cp`.

### What's Next?

You may read the [_GNU LibTool Manual_](https://www.gnu.org/software/libtool/manual/) for more information. However, GNU LibTool is more commonly used together with GNU AutoConf and GNU AutoMake. So you're recommended to learn those tools first.
