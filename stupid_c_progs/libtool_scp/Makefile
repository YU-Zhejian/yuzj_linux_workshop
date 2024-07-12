.SUFFIXES:            # Delete the default suffixes

# Install prefix that SHOULD NOT CONTAIN BLANKS
PREFIX := "$(PWD)/opt"
CC := gcc
CFLAGS := -O2 -Wall -Wextra
LDFLAGS :=

.PHONY: all
all: main

%.lo: ../src/%.c
	libtool --tag=CC --mode=compile $(CC) $(CFLAGS) -c $<

lib%.la: %.lo
	libtool --tag=CC --mode=link $(CC) $(LDFLAGS) -o $@ $< -rpath $(PREFIX)/lib/

main: libstupid.la main.lo
	libtool --tag=CC --mode=link $(CC) $(LDFLAGS) -o main $^

.PHONY: clean
clean:
	rm -fr *.o *.lo .libs *.la main

.PHONY: install
install: all
	libtool --mode=install install -D libstupid.la $(PREFIX)/lib/libstupid.la
	libtool --mode=install install -D main $(PREFIX)/bin/main
	install -D ../src/stupid.h $(PREFIX)/include/stupid.h
	libtool --finish $(PREFIX)/lib/
