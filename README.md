LLVM D(eimos) interface
=======================

This project provides a [Deimos](https://github.com/D-Programming-Deimos) interface for
[LLVM](http://www.llvm.org).

By default it uses the config files provided by LLVM. Specify
`-J/path/to/include/llvm/Config` when building or use `-version=llvmNoConfig`
to disable it. But then you have to manually initialize the targets, etc. (see
module `deimos.llvm.c.target`).

E.g. on a Linux system run
```
$ dmd $(llvm-config-3.3 --ldflags --libs | sed -e 's/-L/-L-L/g' | sed -e 's/-l/-L-l/g') -L-lstdc++ -version=llvmNoConfig -run examples/helloworld.d
```
