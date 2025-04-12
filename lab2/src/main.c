#include "stupid.h"

#include <stdio.h>

int main()
{
    int retv = stupid_add(1, -1);
    char* built_under;
#if defined(BUILT_UNDER_CMAKE)
    built_under = "CMake";
#elif defined(BUILT_UNDER_AUTOTOOLS)
    built_under = "GNU AutoTools";
#elif defined(BUILT_UNDER_MAKE_LIBTOOL)
    built_under = "GNU Make/LibTool";
#elif defined(BUILT_UNDER_SHELL)
    built_under = "shell scripts";
#else
    built_under = "Unknown";
#endif
    printf("Hello world from the stupid C program. Built under %s.\n", built_under);
    return retv;
}
