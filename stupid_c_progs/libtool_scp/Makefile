.SUFFIXES:            # Delete the default suffixes

# Install prefix that SHOULD NOT CONTAIN BLANKS
PREFIX := "$(PWD)/opt"

.PHONY: all
all: $(CURDIR)/main

$(CURDIR)/%.lo: $(CURDIR)/../src/%.c $(CURDIR)/../src/stupid.h
	libtool --mode=compile gcc -c $<

$(CURDIR)/lib%.la: $(CURDIR)/%.lo
	libtool --mode=link gcc -o $@ $< -rpath $(PREFIX)/lib/

$(CURDIR)/main: $(CURDIR)/libstupid.la $(CURDIR)/main.lo
	libtool --mode=link gcc -o main $^

.PHONY: clean
clean:
	rm -fr $(CURDIR)/*.o $(CURDIR)/*.lo $(CURDIR)/.libs $(CURDIR)/*.la $(CURDIR)/main

.PHONY: install
install: all
	libtool --mode=install install -D $(CURDIR)/libstupid.la $(PREFIX)/lib/libstupid.la
	libtool --mode=install install -D $(CURDIR)/main $(PREFIX)/bin/main
	libtool --finish $(PREFIX)/lib/
