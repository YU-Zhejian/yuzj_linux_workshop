bin_PROGRAMS = main
main_SOURCES = main.c

lib_LTLIBRARIES = libstupid.la
libstupid_la_SOURCES = stupid.c
include_HEADERS = stupid.h

main_LDADD = libstupid.la

TESTS = main
check_PROGRAMS = main

info_TEXINFOS = stupid.texi

# Add alias for check
test: check
# Add alias for doc
doc: dvi ps pdf html info
install-doc: install-dvi install-ps install-pdf install-html install-info
