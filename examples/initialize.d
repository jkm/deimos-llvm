void main()
{
	import deimos.llvm.c.target;
	LLVMInitializeAllTargetInfos();
	LLVMInitializeAllTargets();
	LLVMInitializeAllTargetMCs();
	LLVMInitializeAllAsmPrinters();
	LLVMInitializeAllAsmParsers();
	LLVMInitializeAllDisassemblers();
}
