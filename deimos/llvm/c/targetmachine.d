/*===-- llvm-c/TargetMachine.h - Target Machine Library C Interface - C++ -*-=*\
|*                                                                            *|
|*                     The LLVM Compiler Infrastructure                       *|
|*                                                                            *|
|* This file is distributed under the University of Illinois Open Source      *|
|* License. See LICENSE.TXT for details.                                      *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header declares the C interface to the Target and TargetMachine       *|
|* classes, which can be used to generate assembly or object files.           *|
|*                                                                            *|
|* Many exotic languages can interoperate with C code but have a harder time  *|
|* with C++ due to name mangling. So in addition to C, this interface enables *|
|* tools written in such languages.                                           *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/

module deimos.llvm.c.targetmachine;

import deimos.llvm.c.core;
import deimos.llvm.c.target : LLVMTargetDataRef;

extern(C) nothrow:

struct __LLVMTargetMachine {};
alias __LLVMTargetMachine *LLVMTargetMachineRef;
struct __LLVMTarget {};
alias __LLVMTarget *LLVMTargetRef;

alias int LLVMCodeGenOptLevel;
enum : LLVMCodeGenOptLevel {
    LLVMCodeGenLevelNone,
    LLVMCodeGenLevelLess,
    LLVMCodeGenLevelDefault,
    LLVMCodeGenLevelAggressive
}

alias int LLVMRelocMode;
enum : LLVMRelocMode {
    LLVMRelocDefault,
    LLVMRelocStatic,
    LLVMRelocPIC,
    LLVMRelocDynamicNoPic
}

alias int LLVMCodeModel;
enum : LLVMCodeModel {
    LLVMCodeModelDefault,
    LLVMCodeModelJITDefault,
    LLVMCodeModelSmall,
    LLVMCodeModelKernel,
    LLVMCodeModelMedium,
    LLVMCodeModelLarge
}

alias int LLVMCodeGenFileType;
enum : LLVMCodeGenFileType {
    LLVMAssemblyFile,
    LLVMObjectFile
}

/** Returns the first llvm::Target in the registered targets list. */
LLVMTargetRef LLVMGetFirstTarget();
/** Returns the next llvm::Target given a previous one (or null if there's none) */
LLVMTargetRef LLVMGetNextTarget(LLVMTargetRef T);

/*===-- Target ------------------------------------------------------------===*/
/** Returns the name of a target. See llvm::Target::getName */
const(char) *LLVMGetTargetName(LLVMTargetRef T);

/** Returns the description  of a target. See llvm::Target::getDescription */
const(char) *LLVMGetTargetDescription(LLVMTargetRef T);

/** Returns if the target has a JIT */
LLVMBool LLVMTargetHasJIT(LLVMTargetRef T);

/** Returns if the target has a TargetMachine associated */
LLVMBool LLVMTargetHasTargetMachine(LLVMTargetRef T);

/** Returns if the target as an ASM backend (required for emitting output) */
LLVMBool LLVMTargetHasAsmBackend(LLVMTargetRef T);

/*===-- Target Machine ----------------------------------------------------===*/
/** Creates a new llvm::TargetMachine. See llvm::Target::createTargetMachine */
LLVMTargetMachineRef LLVMCreateTargetMachine(LLVMTargetRef T, char *Triple,
  char *CPU, char *Features, LLVMCodeGenOptLevel Level, LLVMRelocMode Reloc,
  LLVMCodeModel CodeModel);

/** Dispose the LLVMTargetMachineRef instance generated by
  LLVMCreateTargetMachine. */
void LLVMDisposeTargetMachine(LLVMTargetMachineRef T);

/** Returns the Target used in a TargetMachine */
LLVMTargetRef LLVMGetTargetMachineTarget(LLVMTargetMachineRef T);

/** Returns the triple used creating this target machine. See
  llvm::TargetMachine::getTriple. The result needs to be disposed with
  LLVMDisposeMessage. */
char *LLVMGetTargetMachineTriple(LLVMTargetMachineRef T);

/** Returns the cpu used creating this target machine. See
  llvm::TargetMachine::getCPU. The result needs to be disposed with
  LLVMDisposeMessage. */
char *LLVMGetTargetMachineCPU(LLVMTargetMachineRef T);

/** Returns the feature string used creating this target machine. See
  llvm::TargetMachine::getFeatureString. The result needs to be disposed with
  LLVMDisposeMessage. */
char *LLVMGetTargetMachineFeatureString(LLVMTargetMachineRef T);

/** Returns the llvm::DataLayout used for this llvm:TargetMachine. */
LLVMTargetDataRef LLVMGetTargetMachineData(LLVMTargetMachineRef T);

/** Emits an asm or object file for the given module to the filename. This
  wraps several c++ only classes (among them a file stream). Returns any
  error in ErrorMessage. Use LLVMDisposeMessage to dispose the message. */
LLVMBool LLVMTargetMachineEmitToFile(LLVMTargetMachineRef T, LLVMModuleRef M,
  char *Filename, LLVMCodeGenFileType codegen, char **ErrorMessage);
