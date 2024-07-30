.SUFFIXES:            # Delete the default suffixes

# Install prefix that SHOULD NOT CONTAIN BLANKS
PREFIX ?= "$(PWD)/opt"
CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra -DBUILT_UNDER_MAKE_LIBTOOL
LDFLAGS ?=

.PHONY: all
all: main main_static

%.lo: ../src/%.c
	libtool --tag=CC --mode=compile $(CC) $(CFLAGS) -c $<

lib%.la: %.lo
	# Here, -rpath is a must. Otherwise libtool will not create shared libraries.
	libtool --tag=CC --mode=link $(CC) $(LDFLAGS) -rpath $(PREFIX)/lib/ -o $@ $<

main: libstupid.la main.lo
	libtool --tag=CC --mode=link $(CC) $(LDFLAGS) -rpath $(PREFIX)/lib/ -o main $^

main_static: libstupid.la main.lo
	libtool --tag=CC --mode=link $(CC) $(LDFLAGS) -static -Wl,-static -static-libgcc -o main_static $^

.PHONY: clean
clean:
	rm -fr ./*.o ./*.lo .libs ./*.la main ./*.exe ./*.dll

.PHONY: install
install: all
	libtool --mode=install install -D libstupid.la $(PREFIX)/lib/libstupid.la
	libtool --mode=install install -D main $(PREFIX)/bin/main
	libtool --mode=install install -D main_static $(PREFIX)/bin/main_static
	install -D ../src/stupid.h $(PREFIX)/include/stupid.h
	libtool --finish $(PREFIX)/lib/
