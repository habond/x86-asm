# 03-advanced - Advanced Topics

Take your assembly skills to the next level with advanced algorithms and system programming.

## What You'll Learn

By the end of this section, you'll be able to:
- Manipulate individual bits and use bitwise operations
- Work with complex stack frames and local variables
- Perform file I/O operations
- Implement complex data structures
- Build real-world command-line tools

## Prerequisites

Before starting:
1. ✅ Complete [01-basics](../01-basics/)
2. ✅ Complete [02-intermediate](../02-intermediate/)
3. ✅ Comfortable with functions, stack, and memory operations
4. ✅ Proficient with GDB debugging

Not done yet? Go back and complete the intermediate section first!

## Assignments

Complete these in order:

### 1. [Bit Manipulation](01-bit-manipulation/)
**Topics**: Bitwise operations, masks, flags, bit fields

Learn how to:
- Use AND, OR, XOR, NOT operations
- Set, clear, and test individual bits
- Work with bit masks and flags
- Implement bit counting algorithms
- Use shifts for multiplication/division

**Time**: 2-3 hours

---

### 2. [Stack Frames](02-stack-frames/)
**Topics**: Complex stack usage, local variables, nested function calls

Learn how to:
- Create proper stack frames with RBP
- Allocate local variables on the stack
- Handle nested function calls
- Preserve and restore registers properly
- Debug stack-related issues

**Time**: 2-3 hours

---

### 3. [Multi-File Projects](03-multi-file/)
**Topics**: External symbols, linking multiple files, code organization

Learn how to:
- Use `global` and `extern` directives
- Link multiple object files
- Create reusable library functions
- Organize code across files
- Build modular programs

**Time**: 2-3 hours

---

### 4. [File I/O](04-file-io/)
**Topics**: File operations, open, read, write, close

Learn how to:
- Open and create files
- Read from files
- Write to files
- Close file descriptors
- Handle I/O errors
- Build a simple file copy tool

**Time**: 3-4 hours

---

### 5. [Structures](05-structures/)
**Topics**: Struct-like data, memory layouts, complex types

Learn how to:
- Define C-like structures in assembly
- Access struct fields
- Allocate structures on stack and heap
- Pass structures to functions
- Work with arrays of structures

**Time**: 3-4 hours

---

### 6. [Hash Table](06-hash-table/)
**Topics**: Hash functions, collision handling, data structures

Learn how to:
- Implement a hash function
- Create a simple hash table
- Handle collisions (linear probing)
- Insert, lookup, and delete entries
- Build a practical key-value store

**Time**: 4-5 hours

---

### 7. [Heap Allocation](07-heap-allocation/)
**Topics**: Dynamic memory allocation, brk syscall, malloc/free implementation

Learn how to:
- Understand heap vs stack memory
- Use the brk system call to grow the heap
- Implement a simple memory allocator (malloc)
- Manage dynamically allocated memory
- Understand how real malloc() works

**Time**: 4-5 hours

---

## Learning Path

```
From 02-intermediate
    ↓
01-bit-manipulation (Low-level operations)
    ↓
02-stack-frames (Advanced function management)
    ↓
03-multi-file (Code organization)
    ↓
04-file-io (System programming)
    ↓
05-structures (Complex data organization)
    ↓
06-hash-table (Real data structure)
    ↓
07-heap-allocation (Memory management)
    ↓
Ready for expert topics!
```

## Key Concepts

### Bitwise Operations

x86-64 provides powerful bit manipulation instructions:

```asm
and rax, rbx        ; Bitwise AND
or  rax, rbx        ; Bitwise OR
xor rax, rbx        ; Bitwise XOR
not rax             ; Bitwise NOT

shl rax, 3          ; Shift left (multiply by 8)
shr rax, 2          ; Shift right (divide by 4)
rol rax, 4          ; Rotate left
ror rax, 4          ; Rotate right

bt  rax, 5          ; Bit test (sets CF to bit 5)
bts rax, 3          ; Bit test and set
btr rax, 7          ; Bit test and reset
btc rax, 2          ; Bit test and complement
```

### Stack Frames

Proper stack frame management for complex functions:

```asm
function:
    push rbp            ; Save old base pointer
    mov rbp, rsp        ; Set new base pointer
    sub rsp, 32         ; Allocate 32 bytes for locals

    ; Local variables accessed via rbp:
    ; [rbp-8]  = local1
    ; [rbp-16] = local2
    ; [rbp-24] = local3
    ; [rbp-32] = local4

    ; Function parameters:
    ; rdi, rsi, rdx, rcx, r8, r9 (first 6)
    ; [rbp+16], [rbp+24], ... (rest on stack)

    ; Function body here

    mov rsp, rbp        ; Restore stack pointer
    pop rbp             ; Restore base pointer
    ret
```

### File I/O System Calls

```asm
; open(filename, flags, mode)
mov rax, 2              ; sys_open
mov rdi, filename       ; const char *filename
mov rsi, 0              ; O_RDONLY (0), O_WRONLY (1), O_RDWR (2)
mov rdx, 0644o          ; mode (for create)
syscall                 ; returns fd in rax

; read(fd, buffer, count)
mov rax, 0              ; sys_read
mov rdi, fd             ; file descriptor
mov rsi, buffer         ; char *buffer
mov rdx, 1024           ; size_t count
syscall                 ; returns bytes read in rax

; write(fd, buffer, count)
mov rax, 1              ; sys_write
mov rdi, fd             ; file descriptor
mov rsi, buffer         ; const char *buffer
mov rdx, count          ; size_t count
syscall                 ; returns bytes written in rax

; close(fd)
mov rax, 3              ; sys_close
mov rdi, fd             ; file descriptor
syscall
```

### Structure Access

```asm
; Define a structure layout (in comments)
; struct Person {
;     uint64_t id;        // offset 0
;     uint32_t age;       // offset 8
;     uint32_t height;    // offset 12
;     char name[16];      // offset 16
; }                       // total size: 32 bytes

section .data
    person:
        dq 12345            ; id
        dd 30               ; age
        dd 175              ; height
        db "John Doe", 0    ; name (padded to 16 bytes)
        times 7 db 0        ; padding

section .text
    ; Access fields
    mov rax, [person]       ; Get id (offset 0)
    mov eax, [person+8]     ; Get age (offset 8)
    mov eax, [person+12]    ; Get height (offset 12)
    lea rsi, [person+16]    ; Get pointer to name (offset 16)
```

### Heap Allocation

```asm
; brk(addr) - set program break (grow/shrink heap)
; Get current break
mov rax, 12             ; sys_brk
xor rdi, rdi            ; 0 = query current
syscall                 ; returns current break in rax

; Allocate 1024 bytes
mov rdi, rax            ; Current break
add rdi, 1024           ; New break = current + 1024
mov rax, 12             ; sys_brk
syscall                 ; returns new break in rax

; Simple malloc implementation
my_malloc:
    ; Add header size and align to 16 bytes
    add rdi, 16         ; Space for metadata
    add rdi, 15
    and rdi, -16        ; Round up to 16-byte boundary

    ; Grow heap
    call grow_heap

    ; Return pointer (skip header)
    add rax, 16
    ret
```

## Common Patterns

### Pattern 1: Bit Flags

```asm
; Define flags
READ_FLAG  equ 1    ; Bit 0
WRITE_FLAG equ 2    ; Bit 1
EXEC_FLAG  equ 4    ; Bit 2

; Set a flag
or byte [permissions], WRITE_FLAG

; Clear a flag
and byte [permissions], ~READ_FLAG

; Toggle a flag
xor byte [permissions], EXEC_FLAG

; Test a flag
test byte [permissions], READ_FLAG
jnz has_read_permission
```

### Pattern 2: Error Handling

```asm
; System calls return -1 to -4095 for errors
open_file:
    mov rax, 2              ; sys_open
    mov rdi, filename
    mov rsi, 0              ; O_RDONLY
    syscall

    cmp rax, 0
    jl error                ; Negative = error

    ; rax contains valid fd
    ret

error:
    ; Handle error (rax contains -errno)
    neg rax                 ; Convert to positive errno
    ret
```

### Pattern 3: Buffer Management

```asm
section .bss
    buffer resb 4096        ; Reserve 4KB buffer

section .text
read_file:
    mov rax, 0              ; sys_read
    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 4096
    syscall

    cmp rax, 0
    jl error                ; Error
    je eof                  ; End of file
    ; rax contains bytes read
    ret

eof:
    xor rax, rax            ; Return 0
    ret

error:
    mov rax, -1             ; Return -1
    ret
```

### Pattern 4: Structure Iteration

```asm
; Array of structures
section .data
    STRUCT_SIZE equ 32
    people:
        ; person 0
        dq 1                ; id
        dd 25               ; age
        dd 180              ; height
        db "Alice", 0
        times 11 db 0       ; padding

        ; person 1
        dq 2
        dd 30
        dd 175
        db "Bob", 0
        times 13 db 0

    people_count equ 2

section .text
iterate_people:
    xor rcx, rcx            ; index = 0

loop:
    cmp rcx, people_count
    jge done

    ; Calculate structure address
    mov rax, rcx
    imul rax, STRUCT_SIZE
    lea rsi, [people + rax]

    ; Access fields
    mov rdi, [rsi]          ; id at offset 0
    mov r8d, [rsi+8]        ; age at offset 8

    ; Process structure...

    inc rcx
    jmp loop

done:
    ret
```

## Advanced Debugging

### GDB for Complex Code

```bash
# Set breakpoints on functions
(gdb) break my_function
(gdb) break *0x401234            # Break at address

# Examine the stack
(gdb) info frame                 # Current frame info
(gdb) backtrace                  # Call stack
(gdb) frame 2                    # Switch to frame 2

# Examine local variables
(gdb) x/8gx $rbp-32             # View locals on stack
(gdb) x/s $rbp-16               # View string local

# Watch memory
(gdb) watch *(long*)0x404000    # Break when memory changes
(gdb) watch $rax                # Break when register changes

# Examine file descriptors
(gdb) shell ls -l /proc/PID/fd  # View open files
```

### Performance Analysis

```bash
# Use perf to analyze performance
perf stat ./program             # Get statistics
perf record ./program           # Record performance data
perf report                     # View report

# Use strace to see syscalls and timing
strace -c ./program             # Count syscalls
strace -T ./program             # Show time per syscall
```

## Common Mistakes

### 1. Not Checking System Call Errors

```asm
; Wrong - doesn't check for errors
mov rax, 2
mov rdi, filename
syscall
mov [fd], rax               ; Could be -1!

; Right - check for errors
mov rax, 2
mov rdi, filename
syscall
cmp rax, 0
jl open_error               ; Handle error
mov [fd], rax               ; Store valid fd
```

### 2. Stack Misalignment

```asm
; Wrong - stack not 16-byte aligned before call
function:
    push rbx                ; rsp now 8-byte aligned (not 16!)
    call external           ; Segfault or subtle bugs

; Right - maintain alignment
function:
    push rbx
    sub rsp, 8              ; Align to 16 bytes
    call external
    add rsp, 8
    pop rbx
    ret
```

### 3. Not Closing File Descriptors

```asm
; Wrong - leaks file descriptor
read_config:
    ; Open file
    ; Read data
    ret                     ; File still open!

; Right - always close
read_config:
    push rbx
    ; Open file -> rbx
    ; Read data
    mov rdi, rbx
    mov rax, 3              ; sys_close
    syscall
    pop rbx
    ret
```

### 4. Incorrect Structure Padding

```asm
; Wrong - no padding, fields misaligned
section .data
    person:
        db 1                ; char id
        dq 1000             ; Misaligned qword!

; Right - proper alignment
section .data
    person:
        db 1                ; char id
        times 7 db 0        ; padding
        dq 1000             ; Aligned qword
```

## Performance Tips

### Use Bit Operations for Math

```asm
; Slow
mov rax, 8
imul rbx, rax               ; Multiply by 8

; Fast
shl rbx, 3                  ; Shift left by 3 (multiply by 8)

; Slow
mov rax, 16
xor rdx, rdx
div rax                     ; Divide by 16

; Fast
shr rax, 4                  ; Shift right by 4 (divide by 16)
```

### Minimize System Calls

```asm
; Slow - many small writes
loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, char
    mov rdx, 1
    syscall
    ; ... loop ...

; Fast - buffer and write once
; Fill buffer in loop, then single write
```

### Use Registers for Locals When Possible

```asm
; Slower - stack access
mov [rbp-8], rax
add rax, [rbp-8]

; Faster - register access
mov rbx, rax
add rax, rbx
```

## What You'll Know After Advanced

After completing this section, you'll understand:
- ✅ How to manipulate bits and use bitwise operations
- ✅ How to create complex stack frames
- ✅ How to work with files and I/O
- ✅ How to implement data structures
- ✅ How to build real command-line tools
- ✅ How to debug complex assembly programs

You'll be ready to:
- Write systems-level programs
- Implement algorithms in assembly
- Optimize performance-critical code
- Understand compiler output deeply
- Build practical tools and utilities

## Practice Suggestions

### Daily Practice (Recommended)
- **Days 1-2**: Bit manipulation + experiments
- **Days 3-4**: Stack frames
- **Days 5-7**: Multi-file projects
- **Days 8-10**: File I/O
- **Days 11-13**: Structures
- **Days 14-17**: Hash table
- **Days 18-21**: Heap allocation
- **Days 22-23**: Review and projects

### Challenge Projects

1. **Simple grep**: Search for text in files
2. **Word frequency counter**: Count word occurrences in text
3. **CSV parser**: Parse and process CSV files
4. **Base64 encoder/decoder**: Implement Base64 encoding
5. **Simple calculator**: RPN calculator with file I/O
6. **Log analyzer**: Parse and analyze log files
7. **Mini database**: Simple file-based key-value store

## Getting Help

Stuck on an assignment?

1. **Re-read the README** - Advanced topics are complex, review carefully
2. **Check syscall return values** - Many bugs come from ignored errors
3. **Use GDB extensively** - Step through and examine state
4. **Check file descriptors** - Use `ls -l /proc/PID/fd`
5. **Examine the stack** - Use `x/20gx $rsp` in GDB
6. **Look at the solution** - But only after serious attempts!

## Ready?

Great! Let's start with the first assignment:

### → [01-bit-manipulation](01-bit-manipulation/)

You've got this! 🚀
