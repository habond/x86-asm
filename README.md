# x86-64 Assembly Learning Path

A practical, beginner-friendly curriculum for learning x86-64 assembly programming on Linux.

## Why This Curriculum?

- **Simple toolchain**: No platform quirks or complex address loading
- **Clear examples**: Every concept explained step-by-step
- **Hands-on learning**: Write real code, not just read about it
- **Progressive difficulty**: Start simple, build up gradually

## Prerequisites

- A computer (macOS, Windows, or Linux)
- Basic programming knowledge (any language)
- Willingness to learn low-level concepts
- Terminal/command line familiarity

**You don't need**:
- A Linux machine (we'll set up an environment for you)
- Prior assembly experience
- Computer architecture knowledge (we'll teach you)

## Quick Start

### 1. Set Up Your Environment

Follow the [Getting Started Guide](resources/getting-started.md) to set up:
- **Docker** (recommended - fast and easy)
- **Virtual Machine** (full Linux experience)
- **Multipass** (clean and simple)

Choose whichever you prefer - all work great!

### 2. Test Your Setup

#### Easiest Method: Docker Compose (Recommended)

```bash
# Navigate to the repository
cd /path/to/x86-asm

# Start the development environment (all tools pre-installed!)
docker-compose run --rm asm-dev

# Test with hello world
cd 01-basics/01-hello-world
make solution
# Should print "Hello, World!"
```

#### Alternative: Build with Dockerfile

```bash
# Build the image once
docker build -t asm-dev .

# Run the container
docker run -it --rm --platform linux/amd64 \
  -v $(pwd):/code -w /code asm-dev

# Test with hello world
cd 01-basics/01-hello-world
make solution
```

#### Plain Docker (No build required)

```bash
# Enter Linux environment
docker run -it --rm --platform linux/amd64 \
  -v $(pwd):/code -w /code ubuntu:22.04 bash

# Install tools (once per session)
apt update && apt install -y nasm make gdb binutils

# Test with hello world
cd 01-basics/01-hello-world
make solution
```

See [.quickstart.md](.quickstart.md) for more Docker setup options.

### 3. Start Learning

Begin with [01-basics/01-hello-world](01-basics/01-hello-world/)

## Curriculum Structure

### [01-basics/](01-basics/) - Foundation (Start Here!)

Learn the fundamentals:

1. **[01-hello-world](01-basics/01-hello-world/)** - Your first program
   - Program structure
   - System calls
   - Writing to stdout

2. **[02-add-numbers](01-basics/02-add-numbers/)** - Basic arithmetic
   - Registers
   - MOV and ADD instructions
   - Exit codes

3. **[03-conditionals](01-basics/03-conditionals/)** - Decision making
   - CMP and TEST instructions
   - Conditional jumps (JE, JNE, JG, JL, etc.)
   - If/else logic

4. **[04-loops](01-basics/04-loops/)** - Repetition
   - Loop counters
   - Jump instructions
   - While and for loop patterns

5. **[05-functions](01-basics/05-functions/)** - Code organization
   - CALL and RET
   - Calling conventions
   - Argument passing

6. **[06-factorial](01-basics/06-factorial/)** - Putting it together
   - Recursive functions
   - Stack operations
   - Real problem solving

### [02-intermediate/](02-intermediate/) - Working with Data

Build practical skills with memory and data manipulation:

1. **[01-string-length](02-intermediate/01-string-length/)** - String traversal
   - Memory addressing
   - Byte operations
   - Null terminators
   - Pointer arithmetic

2. **[02-arrays](02-intermediate/02-arrays/)** - Array manipulation
   - Array indexing
   - Element access
   - Finding min/max
   - Array iteration

3. **[03-string-compare](02-intermediate/03-string-compare/)** - String comparison
   - Lexicographic ordering
   - strcmp implementation
   - Character-by-character comparison
   - Signed comparisons

4. **[04-buffer-operations](02-intermediate/04-buffer-operations/)** - Memory operations
   - memcpy implementation
   - memset and buffer filling
   - Memory regions
   - Pointer management

5. **[05-command-line-args](02-intermediate/05-command-line-args/)** - Program arguments
   - argc/argv access
   - Stack layout at startup
   - Argument iteration
   - String printing

### [03-advanced/](03-advanced/) - Advanced Topics

Master advanced assembly programming techniques:

1. **[01-bit-manipulation](03-advanced/01-bit-manipulation/)** - Bitwise operations
   - AND, OR, XOR, NOT operations
   - Bit masks and flags
   - Bit counting algorithms
   - Shifts and rotations

2. **[02-stack-frames](03-advanced/02-stack-frames/)** - Complex stack management
   - Proper stack frames with RBP
   - Local variables on the stack
   - Nested function calls
   - Register preservation

3. **[03-multi-file](03-advanced/03-multi-file/)** - Multi-file projects
   - External symbol references
   - Global and extern directives
   - Linking multiple object files
   - Code organization

4. **[04-file-io](03-advanced/04-file-io/)** - File operations
   - Open, read, write, close syscalls
   - File descriptors
   - Error handling
   - Building a file copy utility

5. **[05-structures](03-advanced/05-structures/)** - Complex data structures
   - C-like struct definitions
   - Field offsets and access
   - Arrays of structures
   - Passing structures to functions

6. **[06-hash-table](03-advanced/06-hash-table/)** - Data structure implementation
   - Hash function design
   - Collision resolution (linear probing)
   - Insert and lookup operations
   - Building a key-value store

7. **[07-heap-allocation](03-advanced/07-heap-allocation/)** - Dynamic memory allocation
   - Understanding the heap vs stack
   - Using the brk system call
   - Implementing malloc/free
   - Memory management fundamentals

## How to Use This Curriculum

### For Complete Beginners

1. **Follow in order** - Don't skip ahead!
2. **Read the README** - Each assignment has detailed explanations
3. **Try it yourself first** - Don't look at solutions immediately
4. **Experiment** - Change things and see what happens
5. **Use the debugger** - GDB is your friend
6. **Take breaks** - Assembly can be mentally taxing

### For Experienced Programmers

You can move faster, but still:
1. **Skim the basics** - Even if you know programming, x86-64 has specifics
2. **Focus on calling conventions** - This is crucial for real-world use
3. **Practice the exercises** - Muscle memory matters in assembly
4. **Challenge yourself** - Try the "Going Further" sections

### Daily Practice

**Recommended schedule**:

*Basics (Foundation):*
- **Days 1-2**: Setup + Hello World + Add Numbers
- **Days 3-4**: Conditionals
- **Days 5-7**: Loops
- **Days 8-10**: Functions
- **Days 11-14**: Factorial + Review

*Intermediate (Data Manipulation):*
- **Days 15-16**: String Length + Arrays
- **Days 17-18**: String Compare
- **Days 19-21**: Buffer Operations
- **Days 22-24**: Command-Line Args + Review

*Advanced (Systems Programming):*
- **Days 25-26**: Bit Manipulation
- **Days 27-28**: Stack Frames
- **Days 29-31**: Multi-File Projects
- **Days 32-34**: File I/O
- **Days 35-37**: Structures
- **Days 38-42**: Hash Table
- **Days 43-47**: Heap Allocation + Review

**Total time**: ~7-8 weeks of casual practice (1-2 hours/day)

## Building Programs

### Method 1: Using Make (Easiest)

Every assignment has a Makefile:

```bash
make            # Build your code
make run        # Build and run
make solution   # See the solution
make clean      # Clean up
```

### Method 2: Manual (Learn the tools)

```bash
# Assemble
nasm -f elf64 program.asm -o program.o

# Link
ld -o program program.o

# Run
./program

# Check exit code
echo $?
```

### Method 3: With Debug Info

```bash
# Assemble with debug symbols
nasm -f elf64 -g program.asm -o program.o

# Link
ld -o program program.o

# Debug with GDB
gdb ./program
```

## Resources

The [resources/](resources/) directory contains:

- **[getting-started.md](resources/getting-started.md)** - Environment setup (Docker, VM, etc.)
- **[instruction-reference.md](resources/instruction-reference.md)** - x86-64 instruction guide
- **[syscalls-linux.md](resources/syscalls-linux.md)** - Linux system calls reference
- **[calling-conventions.md](resources/calling-conventions.md)** - Function calling rules
- **[testing-guide.md](resources/testing-guide.md)** - Testing and debugging strategies

## Essential Tools

### NASM (Assembler)

Converts assembly code to machine code:
```bash
nasm -f elf64 program.asm -o program.o
```

Options:
- `-f elf64`: 64-bit Linux format
- `-g`: Include debug info
- `-l program.lst`: Generate listing file

### LD (Linker)

Creates executable from object files:
```bash
ld -o program program.o
```

### GDB (Debugger)

Debug your programs:
```bash
gdb ./program
(gdb) break _start      # Set breakpoint
(gdb) run               # Start program
(gdb) stepi             # Step one instruction
(gdb) info registers    # View registers
(gdb) continue          # Continue execution
```

### strace (System Call Tracer)

See what syscalls your program makes:
```bash
strace ./program
```

## Common Mistakes (and How to Avoid Them)

### 1. Wrong Syscall Numbers
**Wrong**: Using macOS or x86-32 syscall numbers
**Right**: Use Linux x86-64 numbers (write=1, exit=60)

### 2. Forgetting to Exit
**Wrong**: Program ends without exit syscall → segfault
**Right**: Always end with `mov rax, 60; syscall`

### 3. Stack Misalignment
**Wrong**: Calling functions with unaligned stack
**Right**: Keep stack 16-byte aligned

### 4. Not Preserving Registers
**Wrong**: Using callee-saved registers without saving
**Right**: Push/pop rbx, rbp, r12-r15 if you use them

### 5. Wrong Argument Registers
**Wrong**: Putting arguments in wrong registers
**Right**: rdi, rsi, rdx, rcx, r8, r9 (in that order)

## Debugging Tips

### 1. Use GDB Liberally
Don't guess - step through and see what's actually happening!

### 2. Check Register Values
```bash
(gdb) info registers
(gdb) print $rax
```

### 3. Examine Memory
```bash
(gdb) x/s $rsi          # View string at rsi
(gdb) x/10x $rsp        # View 10 words at stack pointer
```

### 4. Use strace
See exactly what syscalls are happening:
```bash
strace ./program
```

### 5. Generate Listing Files
See how your code is assembled:
```bash
nasm -f elf64 -l program.lst program.asm
cat program.lst
```

## Learning Strategies

### Active Learning
- **Type, don't copy-paste** - Build muscle memory
- **Break things intentionally** - See what errors look like
- **Modify examples** - Change numbers, add instructions
- **Explain to yourself** - Talk through what each instruction does

### When You're Stuck
1. **Read the error message carefully**
2. **Check the instruction reference**
3. **Use GDB to step through**
4. **Compare with the solution** (but try first!)
5. **Take a break** - Sometimes you need fresh eyes

### Mastery Indicators
You've mastered a concept when you can:
- Write code without referring to examples
- Explain it to someone else
- Debug it when something goes wrong
- Modify it for different requirements

## Estimated Timeline

**Beginner pace** (never programmed before):
- Setup: 1-2 hours
- 01-basics: 2-3 weeks (1 hour/day)
- 02-intermediate: 2-3 weeks (1 hour/day)
- 03-advanced: 3-5 weeks (1 hour/day)
- Total: ~8-11 weeks

**Intermediate pace** (know some programming):
- Setup: 30 minutes
- 01-basics: 1-2 weeks (1-2 hours/day)
- 02-intermediate: 1-2 weeks (1-2 hours/day)
- 03-advanced: 2-4 weeks (1-2 hours/day)
- Total: ~5-8 weeks

**Fast pace** (experienced programmer):
- Setup: 15 minutes
- 01-basics: 3-5 days (2-3 hours/day)
- 02-intermediate: 4-6 days (2-3 hours/day)
- 03-advanced: 8-12 days (2-3 hours/day)
- Total: ~2-3 weeks

## What's Next?

After completing the curriculum (including 03-advanced), you can:

1. **Learn even more advanced topics**:
   - SIMD/SSE instructions for parallel processing
   - Floating-point operations (x87 FPU, SSE)
   - Multi-threading and synchronization primitives
   - Inline assembly in C/C++
   - Operating system interfaces

2. **Build real projects**:
   - Command-line tools
   - Performance-critical code
   - System utilities
   - Exploit development (ethical only!)

3. **Optimize existing code**:
   - Profile and improve C/C++ programs
   - Write assembly hot-paths
   - Understand compiler output

4. **Understand systems better**:
   - Operating system internals
   - Compiler design
   - Reverse engineering (ethical)
   - Security analysis

## Getting Help

### Documentation
- Read the [resources](resources/) thoroughly
- Check instruction reference for syntax
- Review syscall reference for system calls

### Debugging
- Use GDB to step through code
- Use strace to see syscalls
- Add debug output with extra writes

### Community Resources
- [NASM Documentation](https://www.nasm.us/xdoc/2.16.01/html/nasmdoc0.html)
- [Intel Software Developer Manuals](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [x86-64 ABI Documentation](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf)
- [Linux Syscall Table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)

## Philosophy

This curriculum follows these principles:

1. **Simplicity First** - Start with the easiest concepts
2. **Hands-On Learning** - Type code, don't just read
3. **Build Intuition** - Understand *why*, not just *how*
4. **Immediate Feedback** - See results right away
5. **Progressive Complexity** - Each lesson builds on previous ones

## Contributing

Found a bug? Have a suggestion? This curriculum can be improved!

Common contributions:
- Typo fixes
- Clearer explanations
- Additional exercises
- Better examples
- New assignments

## Success Stories

You'll know you're making progress when:
- ✅ You can write a Hello World from memory
- ✅ You understand what each register does
- ✅ You can read and understand assembly code
- ✅ You can debug with GDB confidently
- ✅ You understand function calling conventions
- ✅ You can solve problems in assembly

## Start Learning!

Ready to begin? Head to:

### → [Getting Started Guide](resources/getting-started.md)

Then:

### → [Assignment 1: Hello World](01-basics/01-hello-world/)

Good luck, and enjoy your assembly journey! 🚀
