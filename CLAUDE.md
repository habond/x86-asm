# Claude Guide for x86-64 Assembly Repository

This document provides context and guidelines for Claude Code when assisting with this x86-64 assembly learning repository.

## Repository Overview

This is an educational repository for learning x86-64 assembly programming on Linux. It contains:
- **01-basics/**: Foundational concepts (hello world, arithmetic, conditionals, loops, functions, factorial)
- **02-intermediate/**: Data manipulation (strings, arrays, buffers, command-line args)
- **03-advanced/**: Advanced topics (bit manipulation, stack frames, multi-file projects, file I/O, structures, hash tables, heap allocation)
- **resources/**: Reference documentation for instructions, syscalls, calling conventions, and testing

## Key Technical Details

### Platform & Toolchain
- **Target**: Linux x86-64 (64-bit)
- **Assembler**: NASM (Intel syntax)
- **Format**: ELF64
- **Linker**: GNU ld
- **Development Environment**: Docker container (Ubuntu 22.04) or Linux VM

### Linux x86-64 System Call Convention
- **syscall instruction** (not int 0x80)
- **Arguments**: rax (syscall number), rdi, rsi, rdx, r10, r8, r9
- **Common syscalls**:
  - `sys_read` = 0
  - `sys_write` = 1
  - `sys_open` = 2
  - `sys_close` = 3
  - `sys_mmap` = 9
  - `sys_munmap` = 11
  - `sys_brk` = 12
  - `sys_exit` = 60
- **Return value**: rax (negative values indicate errors)

### Linux x86-64 Calling Convention (System V AMD64 ABI)
- **Arguments** (in order): rdi, rsi, rdx, rcx, r8, r9, then stack
- **Return value**: rax (rdx for 128-bit returns)
- **Caller-saved**: rax, rcx, rdx, rsi, rdi, r8-r11
- **Callee-saved**: rbx, rsp, rbp, r12-r15
- **Stack alignment**: 16-byte aligned before CALL
- **Red Zone**: 128 bytes below rsp (leaf functions can use without adjusting rsp)

### NASM Syntax Essentials
```nasm
section .data           ; Initialized data
    msg db "Hello", 0   ; Define byte(s)
    num dq 42           ; Define quadword (8 bytes)

section .bss            ; Uninitialized data
    buffer resb 64      ; Reserve 64 bytes

section .text           ; Code
    global _start       ; Entry point for ld

_start:
    ; Intel syntax: instruction destination, source
    mov rax, 1          ; Move 1 into rax
    mov rdi, rax        ; Move rax into rdi
    syscall             ; Make system call
```

## Guidelines for Claude

### When Writing Assembly Code

1. **Always use Linux x86-64 conventions**:
   - Use `syscall` instruction (never `int 0x80`)
   - Use correct syscall numbers (write=1, exit=60, not 32-bit numbers)
   - Follow System V AMD64 ABI for function calls

2. **Structure programs correctly**:
   ```nasm
   section .data
       ; Data here

   section .text
       global _start

   _start:
       ; Your code

       ; ALWAYS exit properly
       mov rax, 60         ; sys_exit
       xor rdi, rdi        ; exit code 0
       syscall
   ```

3. **Use proper NASM syntax**:
   - Intel syntax: `mov destination, source`
   - Size specifiers when needed: `byte [addr]`, `qword [addr]`
   - Labels end with colon: `loop_start:`

4. **Preserve registers in functions**:
   - Save callee-saved registers (rbx, rbp, r12-r15) if used
   - Maintain 16-byte stack alignment
   - Use standard calling convention

5. **Include helpful comments**:
   - Explain what each section does
   - Document register usage
   - Note calling convention adherence

### When Debugging/Explaining

1. **Use GDB commands**:
   ```bash
   gdb ./program
   (gdb) break _start
   (gdb) run
   (gdb) stepi              # Step one instruction
   (gdb) info registers     # Show all registers
   (gdb) x/s $rsi          # Examine string
   ```

2. **Suggest useful debugging tools**:
   - `strace ./program` - trace syscalls
   - `objdump -d program` - disassemble
   - `readelf -a program` - examine ELF structure
   - NASM listing files: `nasm -f elf64 -l output.lst program.asm`

3. **Explain at appropriate level**:
   - For basics: explain what registers and syscalls are
   - For intermediate: focus on data flow and memory layout
   - For advanced: discuss optimization and architecture details

### Common Pitfalls to Avoid

1. **Wrong syscall numbers**: Don't use macOS, Windows, or x86-32 syscalls
2. **Forgetting to exit**: Always end with sys_exit (60) to avoid segfault
3. **Stack misalignment**: Ensure 16-byte alignment before CALL
4. **Register clobbering**: Preserve callee-saved registers
5. **Wrong instruction sizes**: Be explicit with sizes when ambiguous

### Project Structure Patterns

Each assignment typically has:
- `README.md` - Instructions and explanation
- `main.asm` - Starter code or student solution
- `solution.asm` - Reference solution
- `Makefile` - Build automation
- Sometimes: `test.sh` or additional files

### Makefile Targets
Standard targets across assignments:
- `make` or `make all` - Build main.asm
- `make run` - Build and run main.asm
- `make solution` - Build and run solution.asm
- `make test` - Run test script on implementation
- `make reset` - Reset main.asm to template (clean slate for students)
- `make clean` - Remove build artifacts
- `make debug` - Build with debug symbols

### When Suggesting Code Changes

1. **Prefer editing existing files** over creating new ones
2. **Maintain the educational structure** - don't over-engineer
3. **Keep code simple and readable** - this is for learning
4. **Follow the existing style** in the repository
5. **Test suggestions** - verify code assembles and runs correctly

### Docker Environment

The project uses Docker for a consistent Linux environment:
```bash
# Recommended method
docker-compose run --rm asm-dev

# Alternative
docker run -it --rm --platform linux/amd64 \
  -v $(pwd):/code -w /code ubuntu:22.04 bash
```

All assembly must be compiled and run inside the Linux container.

### File References

When referencing files, use clickable markdown links:
- Files: `[main.asm](01-basics/01-hello-world/main.asm)`
- Specific lines: `[main.asm:15](01-basics/01-hello-world/main.asm#L15)`
- Line ranges: `[main.asm:15-20](01-basics/01-hello-world/main.asm#L15-L20)`

## Quick Reference

### Registers
- **General purpose (64-bit)**: rax, rbx, rcx, rdx, rsi, rdi, rbp, rsp, r8-r15
- **Lower 32-bit**: eax, ebx, ecx, etc.
- **Lower 16-bit**: ax, bx, cx, etc.
- **Lower 8-bit**: al, bl, cl, etc.

### Common Instructions
- **Data movement**: mov, lea, push, pop
- **Arithmetic**: add, sub, imul, idiv, inc, dec
- **Logical**: and, or, xor, not, shl, shr, sal, sar
- **Comparison**: cmp, test
- **Control flow**: jmp, je, jne, jg, jl, jge, jle, ja, jb, call, ret
- **String ops**: rep movsb, rep stosb

### Flags (RFLAGS)
- **ZF**: Zero flag (result was zero)
- **SF**: Sign flag (result was negative)
- **CF**: Carry flag (unsigned overflow)
- **OF**: Overflow flag (signed overflow)

## Educational Philosophy

When helping with this repository:
- **Encourage experimentation** - Breaking things is part of learning
- **Explain the "why"** - Don't just provide solutions
- **Build intuition** - Help users understand what the CPU is doing
- **Progressive complexity** - Don't jump ahead too fast
- **Hands-on practice** - Typing code builds understanding

## Resources in Repository

Point users to these resources when relevant:
- [resources/getting-started.md](resources/getting-started.md) - Setup
- [resources/instruction-reference.md](resources/instruction-reference.md) - Instruction details
- [resources/syscalls-linux.md](resources/syscalls-linux.md) - System calls
- [resources/calling-conventions.md](resources/calling-conventions.md) - ABI details
- [resources/testing-guide.md](resources/testing-guide.md) - Testing and debugging strategies

## Security Note

This is an educational repository for defensive security understanding. When helping:
- ✅ Explain vulnerabilities (buffer overflows, stack smashing, etc.)
- ✅ Write defensive code and detection tools
- ✅ Analyze how exploits work (educational)
- ❌ Don't write actual exploit code
- ❌ Don't help with malicious use cases
