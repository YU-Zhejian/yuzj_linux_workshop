# Quiz on Shell

Ver 0.3; Based on 0.2 in 2022 summer program.

[TOC]

## Assumptions

1. GNU Bash >= 4.4.
2. GNU CoreUtils, GNU Grep, GNU Sed, and GNU AWK.
3. Except _GNU Bash Reference_, _POSIX Reference_ and the manual/info pages of all above software, no external documentation or internet access is allowed.

## Short Answer Questions

1. Explain the differences between `#!/usr/bin/env bash`, `#!/usr/bin/bash` and `#!bash`.
2. Explain the differences between `$(which ls) -1 .` and `find . -maxdepth 1`.
3. If variable `A` is array, explain the differences between `${A}`, `${A[*]}`, `${A[@]}`.
4. Explain difference between `'` and `"`.
5. Commands like `echo`, `kill` and `time` can be provided by both shell builtin and external binary. Explain the difference between shell builtin and external binary. How can we ensure the command we get is the desired one?
6. Given the following shell script:

   ```bash
   #!/usr/bin/env bash
   set -ue
   RESULT=0
   yes | head -n 10 | while read -r line; do
   	RESULT=$((${RESULT}+1))
   done
   echo "${RESULT}"
   ```

   Why variable `RESULT` is `0` after the script finishes? Modify the program to make it `10`.

7. The following script for getting 10 `y`s would terminate with exit value 1. Why?

   ```bash
   #!/usr/bin/env bash
   set -ueo pipefail
   yes | head -n 10
   ```

8. Given the following shell script:

   ```bash
   #!/usr/bin/env bash
   set -ueo pipefail
   some_complex_command || true
   ```

   Explain why `|| true` statement is placed here.

9. Given the following shell statement:

   ```bash
   command_1 && command_2 || command_3
   ```

   Explain how it differs with the following:

   ```bash
   if command_1; then command_2; else command_3; fi
   ```

10. The following shell scripts are designed to create `1.sh` if it does not exist, and do nothing otherwise. Explain the difference between those scripts.

   ```bash
   #!/usr/bin/env bash
   set -ueo pipefail
   [ ! -f 1.sh ] && touch 1.sh
   ```

   ```bash
   #!/usr/bin/env bash
   set -ueo pipefail
   [ -f 1.sh ] || touch 1.sh
   ```

## Bonus: Small Programs using Bash

You're not required to do this.

### Auto Extractor for Diverse Formats

A bioinformatician may extract compressed files or archives of diverse formats. Following is a list of common programs (in an order of most favorable to least favorable) and the format they may handle:

| Program                      | Extensions |
|------------------------------|------------|
| `tar`                        | `tar`      |
| `pigz`, `gzip`, `7z`, `7za`  | `gz`       |
| `pbz2`, `bzip2`, `7z`, `7za` | `bz2`      |
| `xz`, `7za`, `7z`            | `xz`       |
| `xz`, `lzma`                 | `lzma`     |
| `lz4`                        | `lz4`      |
| `zstd`                       | `zstd`     |
| `lzop`                       | `lzo`      |
| `lzip`                       | `lz`       |
| `7za`, `7z`                  | `7z`       |
| `brotli`                     | `br`       |
| `unrar`                      | `rar`      |
| `unzip`                      | `zip`      |

Write a program in shell to automatically extract files based on extensions. If multiple extractors are available for recognized format, the program should try from most favourable program to least, and throw error if no suitable program is found or if the format is not recognized. The program should be able to recognize and extract combo formats listed as well:

- `tar.gz` (`tgz`)
- `tar.bz2` (`tbz`)
- `tar.xz` (`txz`)
- `tar.lzma`
- `tar.zst`
- `tar.lzo`
- `tar.br`
- `tar.7z`
- `tar.zip`

### Table Formatter

Following is a CSV table of some commands, their exit values and durations.

```csv
NO.,COMMAND,EXIT,TIME
1,bwa mem -M -R @RG"tID:case4_techrep_2tSM:case4_techrep_2tLB:WXStPL:Illumina" /gpfsdata/hg38.fa 1.fq 2.fq,0,3:47:51
2,bwa mem --help,1,0:0:1
3,man bwa | cat,0,0:0:1
```

Write a program (`table_formatter`) to format the table. It should accept some whatever-delimited-values from standard input and return formatted table to standard output, with `--shrink` and `-d` parameter deciding max string length in a cell and the delimiter of the input.

Input:

```shell
cat <<EOF | table_formatter --shrink 60 -d ';'
NO.;COMMAND;EXIT;TIME
1;bwa mem -M -R @RG"tID:case4_techrep_2tSM:case4_techrep_2tLB:WXStPL:Illumina" /gpfsdata/hg38.fa 1.fq 2.fq;0;3:47:51
2;bwa mem --help;1;0:0:1
3;man bwa | cat;0;0:0:1
EOF
```

Output:

```text
|=============================================================================|
|NO.|COMMAND                                                     |EXIT|TIME   |
|=============================================================================|
|1  |bwa mem -M -R @RG"tID:case4_techrep_2tSM:case4_techrep_2t...|0   |3:47:51|
|-----------------------------------------------------------------------------|
|2  |bwa mem --help                                              |1   |0:0:1  |
|-----------------------------------------------------------------------------|
|3  |man bwa | cat                                               |0   |0:0:1  |
|=============================================================================|
```
