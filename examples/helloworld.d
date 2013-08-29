import std.string;

void main()
{
	import deimos.llvm.c.core;

	// create a context
	auto globalContext = LLVMGetGlobalContext();

	// create a module
	auto myModule = LLVMModuleCreateWithNameInContext("myModule".toStringz(), globalContext);
	scope(exit) LLVMDisposeModule(myModule);

	// create a builder
	auto builder = LLVMCreateBuilderInContext(globalContext);


	// create main function
	auto functionType = LLVMFunctionType(LLVMVoidType(), null, 0, false);
	auto mainFunction = LLVMAddFunction(myModule, "main".toStringz(), functionType);

	// add it
	auto entry = LLVMAppendBasicBlockInContext(globalContext, mainFunction, "".toStringz());
	LLVMPositionBuilderAtEnd(builder, entry);

	// add global string
	auto helloWorldString = LLVMBuildGlobalStringPtr(builder, "hello world!\n".toStringz(), "name".toStringz());

	// printf
	auto array = [LLVMPointerType(LLVMInt8Type(), 0)];
	auto printfType = LLVMFunctionType(LLVMInt32Type(), array.ptr, 1, true);
	auto printfFunction = LLVMAddFunction(myModule, "printf".toStringz(), printfType);

	// call printf function with string
	auto args = [ helloWorldString ];
	LLVMBuildCall(builder, printfFunction, args.ptr, 1u, "".toStringz());
	LLVMBuildRetVoid(builder);

	import std.stdio;
	writeln("=== module ===");
	LLVMDumpModule(myModule);
	writeln("==============");

	import deimos.llvm.c.target;
	LLVMInitializeNativeTarget();

	import deimos.llvm.c.executionengine;
	LLVMLinkInInterpreter();
	LLVMExecutionEngineRef ee;
	LLVMCreateExecutionEngineForModule(&ee, myModule, null);
	scope(exit)
	{
		LLVMModuleRef OutMod;
		assert(LLVMRemoveModule(ee, myModule, &OutMod, null) == 0);
		LLVMDisposeExecutionEngine(ee);
	}

	// call main function
	writeln("Calling main");
	auto mainVal = LLVMRunFunction(ee, mainFunction, 0, null);
	scope(exit) LLVMDisposeGenericValue(mainVal);
	writefln("Return value for main is %s", LLVMGenericValueIntWidth(mainVal));

	// load and execute a function
	array = [LLVMFloatType()];
	auto sinType = LLVMFunctionType(LLVMFloatType(), array.ptr, 1, false);
	auto sinFunction = LLVMAddFunction(myModule, "sinf".toStringz(), sinType);
	auto sinArg = [LLVMCreateGenericValueOfFloat(LLVMFloatType(), 1.0)];
	auto sinVal = LLVMRunFunction(ee, sinFunction, 1, sinArg.ptr);
	writefln("Return value for sin(1.0) is %s", LLVMGenericValueToFloat(LLVMFloatType(), sinVal));
}
