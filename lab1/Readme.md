# Lab 1: Shell Commands and Redirection

## Learning Objectives

- Understand different types of shell commands and how to tell one from another.
- Understand where shell find its external commands.

## Preparation

[GNU Bourne-Again Shell (Bash)](https://www.gnu.org/software/bash/), version 5

Create a new shell with empty environment:

```shell
env -i bash --noprofile --norc
```

## Shell Variables

Get all shell variables through `set` or `declare`. Sample output:

```shell
set
# BASH=/usr/bin/bash
# [...]
# _=-x
declare
#BASH=/usr/bin/bash
# [...]
# _='echo $A'
```

Set shell variable

```shell
A=a
set A=a 
declare A=a
```

A Shell variable works in current shell and its subshell.

```shell
echo $A $BASH_SUBSHELL
# a 0
(echo $A $BASH_SUBSHELL)
# a 1
(eval 'echo $A $BASH_SUBSHELL')
# a 1
{ eval 'echo $A $BASH_SUBSHELL'; }
# a 0
true | eval 'echo $A $BASH_SUBSHELL'
# a 1

function f(){ echo $B $BASH_SUBSHELL; }
B=b
f
# b 0
```

However, modifications in subshell will not reflect on original shell variable.

```shell
A=1
((A++))
echo $A
# 2
(((A++)); echo $A $SHLVL); echo $A $SHLVL
# 3 1
# 2 0
```

It will also **NOT** work in child shell.

```shell
A=1
echo 'echo $A' | bash
# [EMPTY]
bash -c 'echo $A'
# [EMPTY]
```

## Environment Variables

Getting all environment variables:

```shell
export
# declare -x OLDPWD
# declare -x PWD="/mnt/f/home/Documents/yuzj_linux_workshop"
# declare -x SHLVL="1"
```

Or,

```shell
env
# PWD=/mnt/f/home/Documents/yuzj_linux_workshop
# SHLVL=1
# _=/usr/bin/env
```

Elevation of shell variables.

```shell
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

## Commands


