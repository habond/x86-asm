# 01-basics - Foundation

Welcome to the basics section! This is where your assembly journey begins.

## What You'll Learn

By the end of this section, you'll be able to:
- Write simple assembly programs
- Use registers and perform arithmetic
- Make decisions with conditionals
- Create loops
- Write and call functions
- Understand the stack

## Prerequisites

Before starting:
1. ✅ Complete the [Getting Started Guide](../resources/getting-started.md)
2. ✅ Set up your Linux environment (Docker/VM/Multipass)
3. ✅ Install NASM, ld, and make
4. ✅ Test that you can assemble and run programs

Not done yet? Go back to the [main README](../README.md) and set up first!

## Assignments

Complete these in order:

### 1. [Hello World](01-hello-world/)
**Topics**: Program structure, syscalls, data sections

Your first program! Learn how to:
- Structure an assembly program
- Define data in the `.data` section
- Use the `write` system call
- Exit properly

**Time**: 30-60 minutes

---

### 2. [Add Numbers](02-add-numbers/)
**Topics**: Registers, MOV, ADD, arithmetic

Basic arithmetic! Learn how to:
- Use general-purpose registers
- Load immediate values
- Perform addition
- Exit with a meaningful status code

**Time**: 30-45 minutes

---

### 3. [Conditionals](03-conditionals/)
**Topics**: CMP, TEST, conditional jumps, branching

Make decisions! Learn how to:
- Compare values
- Jump based on conditions
- Implement if/else logic
- Use JE, JNE, JG, JL, etc.

**Time**: 1-2 hours

---

### 4. [Loops](04-loops/)
**Topics**: Counters, jumps, loop patterns

Repeat operations! Learn how to:
- Implement while loops
- Create for loops
- Use loop counters
- Combine conditionals and jumps

**Time**: 1-2 hours

---

### 5. [Functions](05-functions/)
**Topics**: CALL, RET, calling conventions, stack

Organize code! Learn how to:
- Define functions
- Call functions with CALL
- Return with RET
- Pass arguments correctly
- Understand the calling convention

**Time**: 2-3 hours

---

### 6. [Factorial](06-factorial/)
**Topics**: Recursion, stack operations, real problem

Put it all together! Learn how to:
- Write recursive functions
- Manage the stack properly
- Preserve registers
- Solve a real problem

**Time**: 2-3 hours

---

## Learning Path

```
Start Here
    ↓
01-hello-world (Essential fundamentals)
    ↓
02-add-numbers (Working with registers)
    ↓
03-conditionals (Decision making)
    ↓
04-loops (Repetition)
    ↓
05-functions (Code organization)
    ↓
06-factorial (Real problem solving)
    ↓
Ready for intermediate!
```

## How to Approach Each Assignment

### 1. Read the README
Each assignment has a detailed README with:
- Learning objectives
- Background information
- Step-by-step guide
- Common mistakes
- Debugging tips

**Don't skip the README!** It has everything you need.

### 2. Try It Yourself
Open the starter file (e.g., `hello.asm`) and try to complete the TODOs.

**Don't look at the solution immediately!** Struggling is part of learning.

### 3. Test Your Code
Build and run:
```bash
make
./program
```

Does it work? Great! Does it crash? Time to debug!

### 4. Debug If Needed
Use GDB:
```bash
nasm -f elf64 -g program.asm -o program.o
ld -o program program.o
gdb ./program
```

### 5. Experiment
Once it works, try the "Going Further" challenges. Modify the code and see what happens!

### 6. Check the Solution
Compare your solution with `solution.asm`:
```bash
make solution
```

Is yours different? That's okay! There are many ways to solve problems.

## Tips for Success

### 1. Go Slow
Don't rush! Assembly is detailed work. One mistake = crash.

### 2. Read Error Messages
The assembler and linker tell you exactly what's wrong:
```
error: symbol `msg` undefined
```
This means you forgot to define `msg`!

### 3. Use Comments
Assembly is hard to read. Comment everything:
```asm
mov rax, 1          ; sys_write
mov rdi, 1          ; stdout
mov rsi, msg        ; pointer to message
```

### 4. Test Incrementally
Don't write 50 lines and then test. Write 5 lines, assemble, test, repeat.

### 5. Use the Debugger
GDB is your friend! When something doesn't work, step through:
```bash
(gdb) break _start
(gdb) run
(gdb) stepi
(gdb) info registers
```

### 6. Refer to Resources
Keep these open:
- [Instruction Reference](../resources/instruction-reference.md)
- [Syscall Reference](../resources/syscalls-linux.md)
- [Calling Conventions](../resources/calling-conventions.md)

## Common Pitfalls

### Not Exiting Properly
**Problem**: Segfault at the end
**Solution**: Always exit with syscall 60

```asm
mov rax, 60
xor rdi, rdi
syscall
```

### Wrong Syscall Numbers
**Problem**: Using macOS or 32-bit syscalls
**Solution**: Use Linux x86-64 numbers (write=1, exit=60)

### Typos in Labels
**Problem**: `undefined symbol` errors
**Solution**: Double-check spelling

```asm
section .data
    msg db "Hello", 10

section .text
    mov rsi, msg        ; Correct
    mov rsi, message    ; Wrong! Undefined symbol
```

### Forgetting Global Directive
**Problem**: `undefined reference to '_start'`
**Solution**: Add `global _start`

```asm
section .text
global _start       ; Don't forget this!

_start:
    ; ...
```

## Practice Suggestions

### Daily Practice (Recommended)
- **Day 1**: Hello World
- **Day 2**: Add Numbers + experiments
- **Day 3**: Start Conditionals
- **Day 4**: Finish Conditionals
- **Day 5**: Start Loops
- **Day 6**: Finish Loops + experiments
- **Day 7**: Rest or review
- **Day 8**: Start Functions
- **Day 9**: Finish Functions
- **Day 10**: Start Factorial
- **Day 11**: Finish Factorial
- **Day 12-14**: Review, experiments, challenges

### Intensive Learning (Fast Track)
If you have a weekend or a few dedicated days:
- **Session 1 (2h)**: Hello World + Add Numbers
- **Session 2 (2h)**: Conditionals
- **Session 3 (2h)**: Loops
- **Session 4 (3h)**: Functions
- **Session 5 (3h)**: Factorial
- **Total**: ~12 hours over 3-4 days

## What You'll Know After Basics

After completing this section, you'll understand:
- ✅ How assembly programs are structured
- ✅ How to use registers for computation
- ✅ How to make decisions (if/else)
- ✅ How to create loops (while/for)
- ✅ How to write and call functions
- ✅ How the stack works
- ✅ How to debug with GDB
- ✅ How to read x86-64 assembly code

You'll be ready to:
- Write simple programs from scratch
- Understand compiler output
- Debug low-level code
- Move on to intermediate topics

## Troubleshooting

### Can't Assemble
```bash
command not found: nasm
```
**Fix**: Install NASM
```bash
apt install nasm    # In Docker/VM
```

### Can't Link
```bash
command not found: ld
```
**Fix**: Install binutils
```bash
apt install binutils
```

### Segmentation Fault
**Common causes**:
1. Didn't exit with syscall 60
2. Accessing invalid memory
3. Stack misalignment (in function calls)

**Debug**:
```bash
gdb ./program
(gdb) run
# GDB will show where it crashed
```

### Wrong Output
Use strace to see what syscalls are happening:
```bash
strace ./program
```

## Getting Help

Stuck on an assignment?

1. **Re-read the README** - The answer is usually there
2. **Check the instruction reference** - Make sure you're using instructions correctly
3. **Use GDB** - Step through and see what's actually happening
4. **Look at the solution** - But only after trying!
5. **Experiment** - Change things and see what happens

## Ready?

Great! Let's start with the first assignment:

### → [01-hello-world](01-hello-world/)

You've got this! 🚀
