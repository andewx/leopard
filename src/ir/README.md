# Leopard

## Language Intermediate Representation


**Overview**

The leopard compiler intends to target LLVM IR while storing intermediate representation code into `.gen` files in the package versioning system directories. Additionally, package inspection symbol tables are exported into a general purpose `JSON` representation using `.sym` file extensions. While some compilers, "Swift", for example use their own intermediate languages for optimization and lowering, Leopard for it's initial release target intends to directly generate `llvm` representation for the time being although a subsequent intermediate language should not be ruled out for future major releases.


**Leopard Runtime Requirements**

For runtime requirements we have the following systems in play

- Configurable Garbage Collector
- Memory Allocation Arena System
- Safe pointer object lifetime handler
- Thread Routine Handling
- Multiprocessor Abstraction and Handling
- Input/Output and Blocking Handling
- GPU Device Targeting, GPU Device Setup and Handling, Kernel Invocations


**LLVM IR Packaging Structure**

LLVM ultimately must be able to properly link modules without any inlining. This requires that package and module specifications from high level leopard abstracts appropriately to the LLVM. Once achieved we can link LLVM modules together when compiling and properly call LLVM routines as required.

**Leopard Generation**

Prior to compiling to LLVM IR the Leo AST's must pass all semantic checking, the main requirement is that all type checking and generic type checking plus inferencing is properly handled. Once semantic verification is handled we can generate LLVM IR code.


**MLIR Integration**

Leopard optionally translates LLVM IR representation into MLIR which provides additional future extensions into other universal formats and compilation chains.

**OS Integration**

The Leopard install requires that all OS calls be properly mapped to the LLVM binding functions. This means that the system OS C libraries be properly identified and bound to LLVM routines.




