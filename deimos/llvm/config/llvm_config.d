/* include/llvm/Config/llvm-config.h. Generated from llvm-config.h.in by configure. */
/*===-- llvm/config/llvm-config.h - llvm configure variable -------*- C -*-===*/
/* */
/* The LLVM Compiler Infrastructure */
/* */
/* This file is distributed under the University of Illinois Open Source */
/* License. See LICENSE.TXT for details. */
/* */
/*===----------------------------------------------------------------------===*/

/* This file enumerates all of the llvm variables from configure so that
they can be in exported headers and won't override package specific
directives. This is a C file so we can include it in the llvm-c headers. */

module deimos.llvm.config.llvm_config;

version(llvmNoConfig) {}
else:

private
{
  import std.string : splitLines;
  import std.algorithm : startsWith, countUntil, filter;

  string llvmConfig()
  {
    enum defineStr = "#define";
    auto defines = import("llvm-config.h")
                   .splitLines()
                   .filter!(line => line.startsWith(defineStr))();

    auto code = "";
    foreach (d; defines)
    {
      d = d[defineStr.length+1 .. $];
      auto identifier = d[0 .. d.countUntil(" ")];
      d = d[identifier.length+1 .. $];
      switch (identifier)
      {
        default:
          if (d.startsWith("LLVMInitialize"))
             code ~= "alias " ~ identifier ~ " = " ~ d ~ ";\n";
          else
             code ~= "enum " ~ identifier ~ " = " ~ d ~ ";\n";
          break;
        case "LLVM_NATIVE_ARCH":
          code ~= "enum " ~ identifier ~ " = \"" ~ d ~ "\";\n";
          break;
        case "HAVE_MMAP_FILE":
          code ~= "enum " ~ identifier ~ " = true;\n";
          break;
        case "RETSIGTYPE":
          code ~= "enum " ~ identifier ~ " = typeid(" ~ d ~ ");\n";
          break;
      }
    }

    return code;
  }
}

import deimos.llvm.c.target;
extern(C) nothrow:
mixin(llvmConfig());
