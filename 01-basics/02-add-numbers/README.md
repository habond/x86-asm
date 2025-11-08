# Assignment 2: Add Numbers

Learn basic arithmetic and working with registers.

## Learning Objectives

- Use MOV to load immediate values
- Perform arithmetic with ADD
- Understand register operations
- Exit with a meaningful status code

## Background

In x86-64, you have 16 general-purpose 64-bit registers:
- `rax`, `rbx`, `rcx`, `rdx` - General purpose
- `rsi`, `rdi` - Often used for string/memory operations
- `rbp`, `rsp` - Stack operations
- `r8` through `r15` - Additional general purpose

For basic arithmetic, you'll mostly use `rax`, `rbx`, `rcx`, and `rdx`.

## The Task

Write a program that:
1. Loads the number 42 into register `rax`
2. Loads the number 27 into register `rbx`
3. Adds them together, storing the result in `rax`
4. Exits with the result as the exit code

## Instructions You'll Need

### MOV - Move data
```asm
mov dest, src       ; dest = src
```

Examples:
```asm
mov rax, 42         ; Load immediate value 42 into rax
mov rbx, rax        ; Copy rax to rbx
```

### ADD - Addition
```asm
add dest, src       ; dest = dest + src
```

Examples:
```asm
add rax, 10         ; rax = rax + 10
add rax, rbx        ; rax = rax + rbx
```

### XOR - Clear register (idiom)
```asm
xor reg, reg        ; reg = 0 (faster than mov reg, 0)
```

## Starter Code

```asm
section .text
global _start

_start:
    ; TODO: Load 42 into rax

    ; TODO: Load 27 into rbx

    ; TODO: Add rbx to rax (rax = rax + rbx)

    ; Exit with result in rax
    mov rdi, rax        ; Move result to rdi (exit code)
    mov rax, 60         ; sys_exit
    syscall
```

## Step by Step

### Step 1: Load values
```asm
mov rax, 42         ; rax = 42
mov rbx, 27         ; rbx = 27
```

### Step 2: Add them
```asm
add rax, rbx        ; rax = 42 + 27 = 69
```

### Step 3: Exit with result
```asm
mov rdi, rax        ; Exit code = 69
mov rax, 60         ; sys_exit
syscall
```

**Note**: We move the result to `rdi` because sys_exit expects the exit code in `rdi`, but we also need `rax` for the syscall number!

## Building and Running

```bash
nasm -f elf64 add.asm -o add.o
ld -o add add.o
./add
echo $?             # Should print 69
```

Or with Make:
```bash
make run
echo $?
```

## Expected Output

The program produces no output, but:
```bash
$ ./add
$ echo $?
69
```

The exit code should be 69 (42 + 27).

## Testing

Your program is correct if:
```bash
./add
echo $?
```
Prints `69`.

## Common Mistakes

### Mistake 1: Wrong register for exit code
```asm
; Wrong - exit code in rax
mov rax, 42
mov rax, 60         ; Oops! Just overwrote our result
syscall
```

**Fix**: Save result first
```asm
mov rax, 42
mov rdi, rax        ; Save result to rdi
mov rax, 60         ; Now load syscall number
syscall
```

### Mistake 2: Adding wrong operands
```asm
add rax, rax        ; This doubles rax, not what we want!
```

**Fix**:
```asm
add rax, rbx        ; Add rbx to rax
```

### Mistake 3: Not preserving result
```asm
add rax, rbx
xor rdi, rdi        ; Oops! Setting exit code to 0, losing our result
```

**Fix**:
```asm
add rax, rbx
mov rdi, rax        ; Use our result as exit code
```

## Experiments

Try modifying your program:

### 1. Different numbers
Change 42 and 27 to other values. Check the result with `echo $?`.

### 2. Subtraction
Use `sub` instead of `add`:
```asm
mov rax, 100
mov rbx, 31
sub rax, rbx        ; rax = 100 - 31 = 69
```

### 3. Multiple operations
```asm
mov rax, 10
mov rbx, 20
mov rcx, 39
add rax, rbx        ; rax = 30
add rax, rcx        ; rax = 69
```

### 4. Increment and decrement
```asm
mov rax, 68
inc rax             ; rax = 69
dec rax             ; rax = 68
inc rax             ; rax = 69
```

### 5. Multiplication (simple)
```asm
mov rax, 23
add rax, rax        ; rax = 46 (doubling)
add rax, 23         ; rax = 69
```

## Understanding Exit Codes

Exit codes are limited to 0-255:
- If your result is > 255, only the lower 8 bits are used
- Example: 256 becomes 0, 257 becomes 1, etc.
- This is because exit codes are a single byte

Try:
```asm
mov rax, 300
; 300 % 256 = 44, so exit code will be 44
```

## Debugging with GDB

```bash
nasm -f elf64 -g add.asm -o add.o
ld -o add add.o
gdb ./add

(gdb) break _start
(gdb) run
(gdb) stepi                 # Step one instruction
(gdb) info registers rax    # Check rax value
(gdb) stepi
(gdb) info registers rbx    # Check rbx value
(gdb) stepi
(gdb) info registers rax    # Check result
(gdb) continue
```

## Registers Visualization

After each instruction:

```asm
; Initial state: rax = ?, rbx = ?

mov rax, 42         ; rax = 42, rbx = ?
mov rbx, 27         ; rax = 42, rbx = 27
add rax, rbx        ; rax = 69, rbx = 27
mov rdi, rax        ; rax = 69, rbx = 27, rdi = 69
mov rax, 60         ; rax = 60, rbx = 27, rdi = 69
syscall             ; Exit with code 69
```

## Going Further

### Challenge 1: Three numbers
Add three numbers: 10 + 20 + 39
```asm
mov rax, 10
mov rbx, 20
mov rcx, 39
add rax, rbx
add rax, rcx
; rax = 69
```

### Challenge 2: Complex expression
Calculate: (10 + 20) + (30 + 9)
```asm
mov rax, 10
mov rbx, 20
add rax, rbx        ; rax = 30

mov rcx, 30
mov rdx, 9
add rcx, rdx        ; rcx = 39

add rax, rcx        ; rax = 69
```

### Challenge 3: Use different registers
Do the same calculation but use r8 and r9 instead:
```asm
mov r8, 42
mov r9, 27
add r8, r9
mov rdi, r8
mov rax, 60
syscall
```

## Next Steps

Once you complete this assignment, move on to:
- [03-conditionals](../03-conditionals/) - If statements and comparisons

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Register Reference](../../resources/instruction-reference.md#register-sizes)
