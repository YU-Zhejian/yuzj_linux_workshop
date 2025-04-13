---
geometry: margin=20mm
hyperrefoptions:
- linktoc=all
colorlinks: true
---
# Lab 1: Understanding Shell

## Why Learn This Course?

Shell allows us to interact with the operating system through a command line interface. With proper use of shell, we can automate repetitive tasks.

**NOTE** If you're interested in commands like `ls`, `mv`, `cp`, etc., go to the documentation of [GNU CoreUtils](https://www.gnu.org/software/coreutils/manual/html_node/index.html). Those commands ae neither part of the shell nor covered in this course.

## Learning Objectives

- Understand shell variable and environment variable.
- Understand different types of shell commands and how to tell one from another.
- Understand where a shell find its external commands.
- Understand redirections.

## Preparation

1. GNU Bash >= 4.4.
2. GNU CoreUtils, GNU Grep, GNU Sed, and GNU AWK.
3. `strace`.

In the following part, the term "shell" refers to GNU Bash only. Some commands may not be reproducible in other shells.

The following command creates a new shell with empty environment:

```bash
env -i bash --noprofile --norc
```

Note that `env` is an executable provided by GNU CoreUtils.

## Variables

### Shell Variable

Get all shell variables through `set` or `declare`. Sample output:

```bash
set
# BASH=/usr/bin/bash
# [...]
# _=-x
declare
#BASH=/usr/bin/bash
# [...]
# _='echo $A'
```

Set shell variable through `set` or `declare`. All following commands are equivalent:

```bash
A=a
set A=a
declare A=a
```

Note, no blanks before or after `=`. The following command will fail:

```bash
A = a
# A: command not found
```

A shell variable can be represented in multiple forms.

```bash
echo $A
# a
echo ${A}
# a
echo "${A}"
# a
# Single quote prevents expansion.
echo '${A}'
# ${A}
```

The curly braces and quotes are recommended. Look at the following example:

```bash
A=a
A_S=a_xxxxxx

echo "${A}_S" "$A_S"
# a_S a_xxxxxx
```

Using curly braces allows clear distinguishing between those 2 variables.

A shell variable works in the current shell and its subshell. The shell variable `BASH_SUBSHELL` shows the level of subshell. Note that the subshell is not a new process (as reflected by variable `$$`).

```bash
echo $A $BASH_SUBSHELL $$
# a 0 7022
eval 'echo $A $BASH_SUBSHELL $$' # Does not create subshells.
# a 7022
(echo $A $BASH_SUBSHELL $$) # Creates a subshell.
# a 1 7022
{ eval 'echo $A $BASH_SUBSHELL $$'; } # Does not create subshells.
# a 0 7022
true | eval 'echo $A $BASH_SUBSHELL $$' # Creates a subshell.
# a 1 7022

function f(){ echo $B $BASH_SUBSHELL $$; } # Does not create subshells.
B=b
f
# b 0 7022
```

However, modifications in subshell will not reflect on original shell variable.

```bash
A=1
((A++))
echo $A
# 2
(((A++)); echo $A $BASH_SUBSHELL); echo $A $BASH_SUBSHELL
# 3 1
# 2 0
```

It will also not work in child shell. A child shell is a new process, as the PID of the child shell (reflected by variable `$$`) differs from its parent. In the following example, the variable `A` is not recognized in child shell.

```bash
A=1
echo 'echo $A $$' | bash
# 30446
bash -c 'echo $A $$'
# 30622
```

### Basic Operations

Integer operations through `(())`:

```bash
A=1
echo $((A+1))
# 2
echo $((A+"1"))
# 2
B=$((A+"1"))
echo $B
# 2
C=$(("A"+"B"))
echo $C
# 3
C=$(("A+B"))
echo $C
# 3
((A++))
echo $A
# 2
```

Append through substitution.

```bash
A=a
A="${A} bbb"
echo $A
# a bbb
```

For other string manipulation, use GNU CoreUtils (Especially `tr`), Grep, Sed, AWK instead.

### Special shell variables

- `$0`, `$1`, ...: Commandline args.
- `$@`: Commandline args in an array.
- `$*`: Commandline args in a string.
- `$#`: Number of commandline args.
- `$?`: Exit value of previous command.
- `$$`: PID of shell.
- `$!`: PID of last background command.

### Environment Variables

Getting all environment variables:

```bash
export
# declare -x OLDPWD
# declare -x PWD="/mnt/f/home/Documents/yuzj_linux_workshop"
# declare -x SHLVL="1"
```

Or,

```bash
env
# PWD=/mnt/f/home/Documents/yuzj_linux_workshop
# SHLVL=1
# _=/usr/bin/env
```

Environment variables work in child shells.

```bash
declare -x A=a
bash -c 'echo $A'
# a
```

However, it cannot be modified in child shells.

```bash
declare -x A=a
bash -c 'declare -x A=b'
echo $A
# a
```

Neither can it be modified in subshells.

```bash
declare -x A=a
(echo $A; declare -x | grep A)
#a
#declare -x A="a"
(A=b; echo $A; declare -x | grep A); declare -x | grep A
# b
# declare -x A="b"
# declare -x A="a"
echo $A
# a
```

Elevation of shell variables to environment variables can be done using `export` or `declare -x`.

```bash
A=a
echo $A
# a
bash -c 'echo $A'
# [EMPTY]

export A # or: declare -x A
echo $A
# a
bash -c 'echo $A'
# a

export -n A
echo $A
# a
bash -c 'echo $A'
```

Set environment variables to sub-processes through pre-pend or `env` executable.

```bash
A=a bash -c 'env' | grep '^A'
# A=a
A=a bash -c 'echo $A'
# a
env A=a bash -c 'echo $A'
# a
```

Environment variables can be passed to all sub-processes started (forked) from the shell. It can change the behavior of sub-processes.

### Special Environment Variables

- `SHELL`: Current shell executable. Good to tell bash from zsh.
- `PWD`: Current working directory.
- `OLDPWD`: Prebious working directory; where `cd -` goes.
- `TERM`: Current terminal type.
- `PATH`: Where shell searches for executables. Separated by `:`.
- `HOME`: Home directory.
- `USER`: User name.
- `TMP`/`TEMP`: Where to place temporary files. Useful if root partition is about to full.
- `LANG`/`LANGUAGE`/`LC_*`: Language specifications.

Other environment variables used in compilers were introduced in the labs below.

Warning: Depending on environment variables instead of system calls are not wise. For example, use `$(pwd)` instead of `${PWD}`.

## Commands

A command can be builtin, alias, function, or external executables. Tell them using `type` builtin.

```bash
type if
# if is a shell keyword
type cd
# cd is a shell builtin
type ls
# ls is /usr/bin/ls
alias ls="ls -lFh"
type ls
# ls is aliased to `ls -lFh'
function fn() { return 0; }
type fn
# fn is a function
# fn ()
# {
#     return 0
# }
```

Use `type -a` to see resolution order. For example,

```bash
function echo() { return 0; }
alias echo="echo -E"
type -a echo
# echo is aliased to `echo -E'
# echo is a function
# echo ()
# {
#     return 0
# }
# echo is a shell builtin
# echo is /usr/bin/echo
# echo is /bin/echo
```

If some name is either builtin or external (e.g., `kill`), we can force shell to use its external version through:

```bash
# An example of builtin kill
kill --version
# bash: kill: -version: invalid signal specification

"$(type -P kill)" --version
# kill from procps-ng 4.0.4
"$(which kill)" --version
# kill from procps-ng 4.0.4
env kill --version
# kill from procps-ng 4.0.4
```

Note that `which` and `env` are provided by GNU CoreUtils.

## Shell Invocation

Observe files read for login interactive shell (For Alpine Linux, change `openat` to `open`.):

```bash
echo exit | \
    strace -e trace='openat' -e signal=none env -i bash -li 2>&1 1>/dev/null | \
    cut -d '"' -f 2 | \
    grep '^/' | \
    grep -Ev "locale/|langpack|^/dev|/$|/etc/ld-.*|.*so.*"
# /etc/passwd
# /etc/terminfo/d/dumb
# /etc/profile
# /etc/profile.d/locale.sh
# /home/yuzj/.bash_profile
# /home/yuzj/.bash_login
# /home/yuzj/.profile
# /home/yuzj/.bash_history
# /home/yuzj/.bash_history
# /home/yuzj/.inputrc
# /etc/inputrc
# /home/yuzj/.bash_logout
# /home/yuzj/.bash_history
# /home/yuzj/.bash_history
```

Observe files read for non-login interactive shell:

```bash
echo exit | \
    strace -e trace='openat' -e signal=none env -i bash -i 2>&1 1>/dev/null | \
    cut -d '"' -f 2 | \
    grep '^/' | \
    grep -Ev "locale/|langpack|^/dev|/$|/etc/ld-.*|.*so.*"
# /etc/passwd
# /etc/terminfo/d/dumb
# /etc/bash/bashrc
# /etc/profile.d/locale.sh
# /home/yuzj/.bashrc
# /home/yuzj/.bash_history
# /home/yuzj/.bash_history
# /home/yuzj/.inputrc
# /etc/inputrc
# /home/yuzj/.bash_history
# /home/yuzj/.bash_history
```

Observe files read for non-login interactive shell:

```bash
echo exit | \
    strace -e trace='openat' -e signal=none env -i bash 2>&1 1>/dev/null | \
    cut -d '"' -f 2 | \
    grep '^/' | \
    grep -Ev "locale/|langpack|^/dev|/$|/etc/ld-.*|.*so.*"
# /etc/passwd
```

Alias expansion is turned off for non-interactive shell.

```bash
env -i bash << EOF
shopt expand_aliases
alias ls='ls -lFh'
type -a ls
exit
EOF
# expand_aliases  off
# ls is /usr/bin/ls
# ls is /bin/ls

env -i bash -i << EOF
shopt expand_aliases
alias ls='ls -lFh'
type -a ls
exit
EOF
# yuzj@DESKTOP-FHVJD55:[...]/yuzj_linux_workshop$ shopt expand_aliases
# expand_aliases  on
# yuzj@DESKTOP-FHVJD55:[...]/yuzj_linux_workshop$ alias ls='ls -lFh'
# yuzj@DESKTOP-FHVJD55:[...]/yuzj_linux_workshop$ type -a ls
# ls is aliased to `ls -lFh'
# ls is /usr/bin/ls
# ls is /bin/ls
# yuzj@DESKTOP-FHVJD55:/mnt/f/home/Documents/yuzj_linux_workshop$ exit
# exit
```

## Redirections

- Once a process is started, three "pipes" will be connected to it. Namely:
  - Standard input (`stdin`) for file descriptor `0` and device `/dev/stdin`.
  - Standard output (`stdout`) for file descriptor `1` and device `/dev/stdout`.
  - Standard error (`stderr`) for file descriptor `2` and device `/dev/stderr`.
- If there are no redirections, all three "pipes" are connected to your current **terminal**. That is, keyboard as `stdin`, screen as `stdout` and `stderr`.
- Some special files:
  - `/dev/null` is a "black hole" file. Anything appended will disappear.
  - `/dev/random` generates pseudo-random numbers.
  - `/dev/zero` generates `\0`s.
  - `/dev/tty` is the controlling terminal of the current process. I.e, the terminal that connects to your interactive shell.

### Pipes (`|`)

Syntax: `prog1 | prog2`

Use `stdout` of `prog1` as `stdin` of `prog2`.

Example:

```bash
cat /etc/passwd | wc -l
# 55
```

### Less than (`<`)

Syntax: `prog1 < file1`

Use `file1` as `stdin` of `prog1`.

Example:

```bash
wc -l < /etc/passwd
# 55
```

Syntax:

```bash
prog1 << EOF
Contents
EOF
```

Read from next line to `EOF` as `stdin` of `prog1`.

Example:

```bash
base64 -d << EOF
SW4gdGhlIGJlZ2lubmluZyBHb2QgY
3JlYXRlZCB0aGUgaGVhdmVuIGFuZC
B0aGUgZWFydGguCg==
EOF
# In the beginning God created the heaven and the earth.
```

The above command is how we store binary files inside a shell script file.

### Greater than (`>`)

Syntax: `prog1 n> file1`

Write file descriptor `n` of `prog1` to `file1`.

`n` can be omitted if `n=1`.

Syntax: `prog1 n>> file1`

Append (Add to bottom) file descriptor `n` of `prog1` to `file1`.

Example:

```bash
env ls -1 /etc > etc.txt
wc -l etc.txt
# 243 etc.txt

env ls -1 /etc > etc.txt
wc -l etc.txt
# 243 etc.txt

env ls -1 /etc >> etc.txt
wc -l etc.txt
# 486 etc.txt

strace ls 2> /dev/null
# Readme.md  etc.txt
strace ls > /dev/null
# execve("/usr/bin/ls", ["ls"], 0x7ffec82578c0 /* 31 vars */) = 0
# brk(NULL)                               = 0x5619714e3000
# exit_group(0)                           = ?
# [...]
# +++ exited with 0 +++
```

### Process Substitution (`<()` `>()`)

Syntax: `prog1 <(prog2)` to use `stdout` for `prog2` as a **file** in commandline that invokes `prog1`.

Syntax: `prog1 >(prog2)` to use `stdin` for `prog2` as a **file** in commandline that invokes `prog1`.

Example:

```bash
wc -l <(ls /etc)
# 243 /dev/fd/63

tar cf >(wc -c) .
# 819200
```

### First-In-First-Out (FIFO) Files

FIFOs are special files that can be used as a pipe. It can be created by command `mkfifo`.

Usage: `prog1 > fifo1` with `prog2 < fifo1` equals `prog1 | prog2`.

Example:

```bash
mkfifo fifo1 # May not work on certain file systems
find 2> /dev/null | tee fifo1 &
cat fifo1 | xz –c - > find.xz
rm -f fifo1
```

### Tips

- Redirect both to a file: `prog1 &> file1`
- Redirect both to different files: `prog1 > file1 2> file2`
- `cat`: To redirect `stdin` as `stdout`.
- `cat files`: To redirect contents of all file in `files` to `stdout`.
- `tee files`: To redirect `stdin` to all file in `files` and `stdout`.
- `more`, `less` and `most`: Veiw long contents in `stdin` with paging.

Example:

```bash
find /root 2>&1 | wc -l
# 2
find /root | wc -l
# find: ‘/root’: Permission denied
# 1
```

Some programs use `–` to represent `stdin`.

```bash
echo "In the beginning..." | sha1sum -
# 399203358dee31c80a1769a3c501901321bc08ed  -
echo "In the beginning..." | sha1sum /dev/stdin
# 399203358dee31c80a1769a3c501901321bc08ed  /dev/stdin
echo "In the beginning..." | sha1sum
399203358dee31c80a1769a3c501901321bc08ed  -
```

Some redirections create subshells. For example, process substitution creates subshells. However, they do not create child shell.

```bash
echo $BASH_SUBSHELL
# 0
eval 'echo OUTER $BASH_SUBSHELL $$' <(eval 'echo INNER $BASH_SUBSHELL $$ >&2')
# OUTER 0 7022 /dev/fd/63
# INNER 1 7022
```

Pipe creates subshells.

```bash
true | eval 'echo $BASH_SUBSHELL'
# 1
true | false; echo $?
# 1
false | true; echo $?
# 0

env -i bash --norc --noprofile << EOF
set -ue
find /root 2>/dev/null | wc -l > /dev/null
echo "I am still alive!"
EOF
# I am still alive!
```

Shell option `pipefail` allows failure of the entire command if one of the components failed.

```bash
env -i bash --norc --noprofile << EOF
set -ueo pipefail
find /root 2>/dev/null | wc -l > /dev/null
EOF
# [EMPTY]
```

However, beware of commands thay may raise broken pipe exception:

```bash
env -i bash --norc --noprofile << EOF
set -ueo pipefail
head -n 1 /etc/passwd | wc -l > /dev/null
echo "I am still alive!"
EOF
# I am still alive!

env -i bash --norc --noprofile << EOF
set -ueo pipefail
head -n 1 < /etc/passwd | wc -l > /dev/null
echo "I am still alive!"
EOF
# I am still alive!

env -i bash --norc --noprofile << EOF
set -ueo pipefail
yes | head -n 1 | wc -l > /dev/null
echo "I am still alive!"
EOF
# [EMPTY]
```

## Miscellaneous

### Expand to stdout of sub-process: `$()`

Syntax: `$(prog)`

Example:

```bash
echo $(pwd)
# /home/yuzj/Documents/yuzj_linux_workshop/lab2/01_shell_scp
echo `pwd` # Obsolete form, not recommended.
# /home/yuzj/Documents/yuzj_linux_workshop/lab2/01_shell_scp
```

### Expand to Numbers: `{start..end}`

Example:

```bash
echo {1..5}
# 1 2 3 4 5
echo {001..005}
# 001 002 003 004 005
```

### Wildcard matching: Glob

Example:

```bash
# ? match one character
echo /bin/?z
# /bin/7z /bin/lz /bin/uz /bin/xz

# * match any character
echo /bin/*z
# /bin/7z /bin/compiz /bin/gts2xyz /bin/lz /bin/pigz
# /bin/ppmtopuzz /bin/tgz /bin/unpigz /bin/unxz /bin/uz /bin/xz

# However, they will not work if no files matching the pattern.
echo *xxxxx
# *xxxxx
```

Other patterns may cause confusion, so not introduced.

### `test` keyword

`test expr` and `[ expr ]` are equivalent. Note that the blank space inside the square brackets are required.

```bash
test 1 -lt 2; echo $?
# 0

[ 1 -lt 2 ]; echo $?
# 0
```

`[[ expr ]]` provides more powerful features.

## Shell Software Engineering

Secure shell script:

- Add `set -ue` before execution of commands allows shell to fail on undefined variables and errors.
- However, be cautious with `set -o pipefail` since broken pipe is really common.
- Also, there are scripts that depend on default values of undefined shell variables (e.g., Conda initialization script). Remember to turn `set -ue` off before evaluating those scripts.
- Do not use `eval`.
- Read from `tty` instead of `stdin` for passwords. For example, `read -s PASSWD < /dev/tty; echo $PASSWD`.
- Add shebang line (e.g., `#!/usr/bin/env bash` or `#!/bin/bash`) for the correct shell.
- Use LF instead of CRLF for shell scripts.
- While reading a file, instead of:

  ```bash
  cat /etc/passwd | while read -r line; do
      echo $line
  done
  ```

  Use:

  ```bash
  while read -r line; do
      echo $line
  done < /etc/passwd
  ```

  Or:

  ```bash
  while read -r line; do
      echo $line
  done < <(cat /etc/passwd)
  ```

  To prevent opening of subshells.
