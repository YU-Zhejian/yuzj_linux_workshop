# Source Code

You're presented with a common Linux program: A stupid C program that does almost nothing. The program should print:

```text
    Hello world from the stupid C program. Built under [XXXXX].
```

Where `[XXXXX]` is the build system used and exit with 0.

## Files in this Directory

- `main.c`: The main executable.
- `stupid.h`: The header file that contains function signature (API) for `libstupid`.
- `stupid.c`: The implementation of functions defined in `libstupid`.

The desired output will be:

- Shared logic from `stupid.c` and `stupid.h` should be built into a library named `libstupid`.
- The program from `main.c` should be built and link to the logic inside `libstupid`. Note that `main.c` requires function signature defined in `stupid.h`.

Now let's get into `01_shell_scp` and get started.

