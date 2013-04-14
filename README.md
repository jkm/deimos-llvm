LLVM D(eimos) interface
=======================

This project provides a [Deimos](http://dlang.org/) interface for
[LLVM](http://www.llvm.org).

By default it uses the config files provided by LLVM. Specify
`-J/path/to/include/llvm/Config` when building or use `-version=llvmNoConfig`
to disable it. But then you have to manually initialize the targets, etc. (see
module `deimos.llvm.c.target`).
