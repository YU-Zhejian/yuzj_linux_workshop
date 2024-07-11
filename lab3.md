# Lab 3: Install C Programs from Source

## Example of Pure Makefile: BWA

Change working directory into `src/bwa-debian-0.7.17-7`.

For GCC later than or equal to 10, apply required patch by:

```shell
patch  < debian/patches/gcc10.patch
```

And build BWA by:

```shell
make -j8
```

Test whether BWA is working.

```shell
./bwa index ./debian/examples/ref.fa
./bwa mem ./debian/examples/ref.fa \
    ./debian/examples/read1.fq \
    ./debian/examples/read2.fq \
    > ./debian/examples/pe.sam
```

Observe runpaths bundled with BWA binary.

```shell
readelf -d ./bwa
```

## Example of GNU AutoTools: SAMtools

Firstly, we create a target directory to where SAMtools and HTSLib will be installed.

```shell
mkdir -p opt/samtools-1.20
```

Now we build HTSLib. Entering `src/htslib-1.20`, we run:

```shell
./configure --prefix="$(pwd)/../../opt/samtools-1.20"
make -j8 install
```

Now HTSLib is installed to `opt/samtools-1.20`. Let's build SAMtools. Entering `src/samtools-1.20`, we run:

```shell
./configure \
    --prefix="$(pwd)/../../opt/samtools-1.20" \
    --with-htslib="$(pwd)/../../opt/samtools-1.20" \
    --without-curses
make -j8 install
```

Now SAMtools should be installed. Let's see whether it works.

```shell
opt/samtools-1.20/bin/samtools version
```

If you see the following error:

```text
opt/samtools-1.20/bin/samtools: /lib/x86_64-linux-gnu/libhts.so.3: no version information available (required by opt/samtools-1.20/bin/samtools)
```

Try the following:

```shell
LD_LIBRARY_PATH="opt/samtools-1.20/lib:${LD_LIBRARY_PATH:-}" \
    opt/samtools-1.20/bin/samtools version
```

Reflect why this works.

## Example of CMake: kAlign

Make installation folder:

```shell
mkdir -p opt/kalign-debian-1_3.4.0
```

Enter `src/kalign-debian-1%3.4.0-1/`, and run:

```shell
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="$(pwd)/../../../opt/kalign-debian-1_3.4.0"
make -j8 install
```

Test whether kAlign is working using:

```shell
opt/kalign-debian-1_3.4.0/bin/kalign --version
```
