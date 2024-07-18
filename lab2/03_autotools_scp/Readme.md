# Stupid C Program using GNU AutoTools

```bash
cp ../src/* .
autoreconf -f -v -i
autoheader
env -i PATH="/usr/bin" ./configure --prefix="$(pwd)/opt"
env -i PATH="/usr/bin" make -j8 install
```
