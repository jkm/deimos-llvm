/*===-- llvm-c/ExecutionEngine.h - ExecutionEngine Lib C Iface --*- C++ -*-===*\
|*                                                                            *|
|*                     The LLVM Compiler Infrastructure                       *|
|*                                                                            *|
|* This file is distributed under the University of Illinois Open Source      *|
|* License. See LICENSE.TXT for details.                                      *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* This header declares the C interface to libLLVMExecutionEngine.o, which    *|
|* implements various analyses of the LLVM IR.                                *|
|*                                                                            *|
|* Many exotic languages can interoperate with C code but have a harder time  *|
|* with C++ due to name mangling. So in addition to C, this interface enables *|
|* tools written in such languages.                                           *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/

module deimos.llvm.c.executionengine;

import deimos.llvm.c.core;
import deimos.llvm.c.target;
import deimos.llvm.c.targetmachine;

extern(C) nothrow:

/**
 * @defgroup LLVMCExecutionEngine Execution Engine
 * @ingroup LLVMC
 *
 * @{
 */

void LLVMLinkInJIT();
void LLVMLinkInMCJIT();
void LLVMLinkInInterpreter();

struct __LLVMOpaqueGenericValue {};
alias __LLVMOpaqueGenericValue *LLVMGenericValueRef;
struct __LLVMOpaqueExecutionEngine {};
alias __LLVMOpaqueExecutionEngine *LLVMExecutionEngineRef;

struct LLVMMCJITCompilerOptions {
  uint OptLevel;
  LLVMCodeModel CodeModel;
  LLVMBool NoFramePointerElim;
  LLVMBool EnableFastISel;
}

/*===-- Operations on generic values --------------------------------------===*/

LLVMGenericValueRef LLVMCreateGenericValueOfInt(LLVMTypeRef Ty,
                                                ulong N,
                                                LLVMBool IsSigned);

LLVMGenericValueRef LLVMCreateGenericValueOfPointer(void *P);

LLVMGenericValueRef LLVMCreateGenericValueOfFloat(LLVMTypeRef Ty, double N);

uint LLVMGenericValueIntWidth(LLVMGenericValueRef GenValRef);

ulong LLVMGenericValueToInt(LLVMGenericValueRef GenVal,
                                         LLVMBool IsSigned);

void *LLVMGenericValueToPointer(LLVMGenericValueRef GenVal);

double LLVMGenericValueToFloat(LLVMTypeRef TyRef, LLVMGenericValueRef GenVal);

void LLVMDisposeGenericValue(LLVMGenericValueRef GenVal);

/*===-- Operations on execution engines -----------------------------------===*/

LLVMBool LLVMCreateExecutionEngineForModule(LLVMExecutionEngineRef *OutEE,
                                            LLVMModuleRef M,
                                            char **OutError);

LLVMBool LLVMCreateInterpreterForModule(LLVMExecutionEngineRef *OutInterp,
                                        LLVMModuleRef M,
                                        char **OutError);

LLVMBool LLVMCreateJITCompilerForModule(LLVMExecutionEngineRef *OutJIT,
                                        LLVMModuleRef M,
                                        uint OptLevel,
                                        char **OutError);

void LLVMInitializeMCJITCompilerOptions(
  LLVMMCJITCompilerOptions *Options, size_t SizeOfOptions);

/**
 * Create an MCJIT execution engine for a module, with the given options. It is
 * the responsibility of the caller to ensure that all fields in Options up to
 * the given SizeOfOptions are initialized. It is correct to pass a smaller
 * value of SizeOfOptions that omits some fields. The canonical way of using
 * this is:
 *
 * LLVMMCJITCompilerOptions options;
 * LLVMInitializeMCJITCompilerOptions(&options, sizeof(options));
 * ... fill in those options you care about
 * LLVMCreateMCJITCompilerForModule(&jit, mod, &options, sizeof(options),
 *                                  &error);
 *
 * Note that this is also correct, though possibly suboptimal:
 *
 * LLVMCreateMCJITCompilerForModule(&jit, mod, 0, 0, &error);
 */
LLVMBool LLVMCreateMCJITCompilerForModule(
  LLVMExecutionEngineRef *OutJIT, LLVMModuleRef M,
  LLVMMCJITCompilerOptions *Options, size_t SizeOfOptions,
  char **OutError);

/** Deprecated: Use LLVMCreateExecutionEngineForModule instead. */
LLVMBool LLVMCreateExecutionEngine(LLVMExecutionEngineRef *OutEE,
                                   LLVMModuleProviderRef MP,
                                   char **OutError);

/** Deprecated: Use LLVMCreateInterpreterForModule instead. */
LLVMBool LLVMCreateInterpreter(LLVMExecutionEngineRef *OutInterp,
                               LLVMModuleProviderRef MP,
                               char **OutError);

/** Deprecated: Use LLVMCreateJITCompilerForModule instead. */
LLVMBool LLVMCreateJITCompiler(LLVMExecutionEngineRef *OutJIT,
                               LLVMModuleProviderRef MP,
                               uint OptLevel,
                               char **OutError);

void LLVMDisposeExecutionEngine(LLVMExecutionEngineRef EE);

void LLVMRunStaticConstructors(LLVMExecutionEngineRef EE);

void LLVMRunStaticDestructors(LLVMExecutionEngineRef EE);

int LLVMRunFunctionAsMain(LLVMExecutionEngineRef EE, LLVMValueRef F,
                          uint ArgC, const(char*) *ArgV,
                          const(char*) *EnvP);

LLVMGenericValueRef LLVMRunFunction(LLVMExecutionEngineRef EE, LLVMValueRef F,
                                    uint NumArgs,
                                    LLVMGenericValueRef *Args);

void LLVMFreeMachineCodeForFunction(LLVMExecutionEngineRef EE, LLVMValueRef F);

void LLVMAddModule(LLVMExecutionEngineRef EE, LLVMModuleRef M);

/** Deprecated: Use LLVMAddModule instead. */
void LLVMAddModuleProvider(LLVMExecutionEngineRef EE, LLVMModuleProviderRef MP);

LLVMBool LLVMRemoveModule(LLVMExecutionEngineRef EE, LLVMModuleRef M,
                          LLVMModuleRef *OutMod, char **OutError);

/** Deprecated: Use LLVMRemoveModule instead. */
LLVMBool LLVMRemoveModuleProvider(LLVMExecutionEngineRef EE,
                                  LLVMModuleProviderRef MP,
                                  LLVMModuleRef *OutMod, char **OutError);

LLVMBool LLVMFindFunction(LLVMExecutionEngineRef EE, const(char) *Name,
                          LLVMValueRef *OutFn);

void *LLVMRecompileAndRelinkFunction(LLVMExecutionEngineRef EE,
                                     LLVMValueRef Fn);

LLVMTargetDataRef LLVMGetExecutionEngineTargetData(LLVMExecutionEngineRef EE);

void LLVMAddGlobalMapping(LLVMExecutionEngineRef EE, LLVMValueRef Global,
                          void* Addr);

void *LLVMGetPointerToGlobal(LLVMExecutionEngineRef EE, LLVMValueRef Global);

/**
 * @}
 */
