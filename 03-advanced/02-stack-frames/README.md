# Assignment 2: Stack Frames

Master complex stack management with proper stack frames and local variables.

## Learning Objectives

- Create proper stack frames with RBP
- Allocate and access local variables on the stack
- Handle nested function calls correctly
- Preserve callee-saved registers
- Debug stack-related issues

## Background

So far, you've used simple functions without local variables. Real-world functions often need:
- **Local variables** that live on the stack
- **Preserved registers** (callee-saved)
- **Nested calls** to other functions
- **Proper stack alignment** (16-byte boundary)

## The Task

Implement a function that calculates Fibonacci numbers using **recursion with memoization**.

The function should:
1. Use a local array to cache previously computed values
2. Make recursive calls properly
3. Maintain correct stack frames

## Stack Frame Anatomy

```
High addresses
+------------------+
| Return address   | ← Pushed by CALL
+------------------+
| Saved RBP        | ← push rbp
+------------------+ ← RBP points here
| Local var 1      | [rbp-8]
+------------------+
| Local var 2      | [rbp-16]
+------------------+
| Local var 3      | [rbp-24]
+------------------+
| Saved registers  | push rbx, r12, etc.
+------------------+ ← RSP points here
Low addresses
```

## Function Prologue and Epilogue

### Prologue (function entry)

```asm
function_name:
    push rbp            ; Save old base pointer
    mov rbp, rsp        ; Set up new base pointer
    sub rsp, 32         ; Allocate space for local variables

    ; Save callee-saved registers if using them
    push rbx
    push r12
    push r13
```

### Epilogue (function exit)

```asm
    ; Restore callee-saved registers (in reverse order)
    pop r13
    pop r12
    pop rbx

    mov rsp, rbp        ; Restore stack pointer (deallocate locals)
    pop rbp             ; Restore old base pointer
    ret
```

## Starter Code

```asm
section .text
global _start

; Function: fibonacci
; Arguments: rdi = n (which Fibonacci number to compute)
; Returns: rax = fibonacci(n)
; Uses stack frame with local variables for memoization
fibonacci:
    ; TODO: Set up stack frame
    ; push rbp
    ; mov rbp, rsp
    ; sub rsp, ??? (allocate space for locals)

    ; TODO: Base cases
    ; if n <= 1, return n

    ; TODO: Recursive case
    ; return fibonacci(n-1) + fibonacci(n-2)

    ; TODO: Clean up stack frame
    ; mov rsp, rbp
    ; pop rbp
    ret

_start:
    ; Calculate fibonacci(10)
    mov rdi, 10
    call fibonacci

    ; Exit with result (should be 55)
    mov rdi, rax
    mov rax, 60
    syscall
```

## Step by Step

### Step 1: Set up stack frame

```asm
fibonacci:
    push rbp            ; Save caller's base pointer
    mov rbp, rsp        ; Our base pointer = current stack top
    sub rsp, 16         ; Allocate 16 bytes for locals
                        ; [rbp-8] will store n-1 result
                        ; [rbp-16] will store n-2 result
```

### Step 2: Base cases

```asm
    ; if (n <= 1) return n
    cmp rdi, 1
    jg recursive_case   ; if n > 1, go to recursive case

    mov rax, rdi        ; return n
    jmp epilogue        ; Clean up and return
```

### Step 3: Recursive case - fibonacci(n-1)

```asm
recursive_case:
    ; Save n (we'll need it)
    push rdi

    ; Calculate fibonacci(n-1)
    dec rdi             ; n-1
    call fibonacci      ; Result in rax

    ; Save result of fibonacci(n-1)
    mov [rbp-8], rax

    ; Restore n
    pop rdi
```

### Step 4: Calculate fibonacci(n-2)

```asm
    ; Calculate fibonacci(n-2)
    sub rdi, 2          ; n-2
    call fibonacci      ; Result in rax

    ; Save result of fibonacci(n-2)
    mov [rbp-16], rax
```

### Step 5: Sum and return

```asm
    ; Return fibonacci(n-1) + fibonacci(n-2)
    mov rax, [rbp-8]    ; Get fibonacci(n-1)
    add rax, [rbp-16]   ; Add fibonacci(n-2)
```

### Step 6: Epilogue

```asm
epilogue:
    mov rsp, rbp        ; Deallocate locals
    pop rbp             ; Restore caller's base pointer
    ret
```

## Stack Alignment

The x86-64 ABI requires the stack to be 16-byte aligned before `call`:

```asm
; Before any 'call', (rsp % 16) must equal 0

; If rsp is misaligned, you'll get subtle bugs or crashes
; Ensure alignment by:
function:
    push rbp            ; rsp -= 8 (now misaligned)
    mov rbp, rsp
    sub rsp, 8          ; Align: rsp -= 8 (now aligned)

    call other_func     ; Stack is aligned ✓

    add rsp, 8
    pop rbp
    ret
```

## Local Variables Example

```asm
compute_average:
    push rbp
    mov rbp, rsp
    sub rsp, 32         ; 4 local variables (8 bytes each)

    ; Local variables:
    ; [rbp-8]  = sum
    ; [rbp-16] = count
    ; [rbp-24] = average
    ; [rbp-32] = temp

    ; Initialize sum = 0
    mov qword [rbp-8], 0

    ; sum += value
    mov rax, [rbp-8]
    add rax, rdi
    mov [rbp-8], rax

    ; ... more computation ...

    ; Return average
    mov rax, [rbp-24]

    mov rsp, rbp
    pop rbp
    ret
```

## Preserving Callee-Saved Registers

According to the x86-64 calling convention, these registers must be preserved:
- **rbx**, **rbp**, **r12**, **r13**, **r14**, **r15**

```asm
my_function:
    push rbp
    mov rbp, rsp

    ; Save registers we'll use
    push rbx
    push r12
    push r13

    ; Use rbx, r12, r13 freely
    mov rbx, 100
    mov r12, 200

    ; Restore in reverse order
    pop r13
    pop r12
    pop rbx

    pop rbp
    ret
```

## Nested Function Calls

When calling functions from within functions:

```asm
outer:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Save arguments we need after call
    push rdi

    ; Call inner function
    mov rdi, 42
    call inner          ; This will modify rax, rcx, rdx, etc.

    ; Save result
    mov [rbp-8], rax

    ; Restore original argument
    pop rdi

    ; Use saved result
    mov rax, [rbp-8]

    mov rsp, rbp
    pop rbp
    ret

inner:
    ; Simple function
    mov rax, rdi
    add rax, 10
    ret
```

## Building and Running

```bash
nasm -f elf64 fibonacci.asm -o fibonacci.o
ld -o fibonacci fibonacci.o
./fibonacci
echo $?                 # Should print 55 (fibonacci(10))
```

## Testing

Test with different values:

```asm
mov rdi, 0              ; fib(0) = 0
mov rdi, 1              ; fib(1) = 1
mov rdi, 5              ; fib(5) = 5
mov rdi, 10             ; fib(10) = 55
mov rdi, 15             ; fib(15) = 610
```

## Debugging Stack Frames

```bash
# In GDB, examine the stack
(gdb) break fibonacci
(gdb) run
(gdb) info frame            # Show frame info
(gdb) backtrace             # Show call stack
(gdb) info locals           # Show local variables

# Examine stack memory
(gdb) x/20gx $rsp           # View stack from rsp
(gdb) x/10gx $rbp-32        # View local variables

# Step through frame setup
(gdb) disassemble fibonacci
(gdb) si                    # Step one instruction
```

## Common Mistakes

### Mistake 1: Not aligning stack

```asm
; Wrong - stack misaligned
function:
    push rbp            ; rsp -= 8
    mov rbp, rsp
    call other          ; Misaligned! May crash

; Right - maintain alignment
function:
    push rbp
    mov rbp, rsp
    sub rsp, 8          ; Align to 16 bytes
    call other          ; Aligned ✓
    add rsp, 8
    pop rbp
    ret
```

### Mistake 2: Accessing locals after deallocation

```asm
; Wrong - accessing after rsp restored
    mov rax, [rbp-8]
    mov rsp, rbp        ; Locals gone!
    add rax, [rbp-8]    ; Undefined behavior!
    pop rbp
    ret

; Right - use locals before deallocation
    mov rax, [rbp-8]
    add rax, [rbp-16]
    mov rsp, rbp        ; Now deallocate
    pop rbp
    ret
```

### Mistake 3: Not preserving registers

```asm
; Wrong - corrupts caller's rbx
function:
    mov rbx, 100        ; Caller's rbx destroyed!
    ret

; Right - save and restore
function:
    push rbx
    mov rbx, 100
    pop rbx
    ret
```

### Mistake 4: Wrong prologue/epilogue order

```asm
; Wrong - epilogue in wrong order
    pop rbp
    mov rsp, rbp        ; Too late! rbp already restored
    ret

; Right
    mov rsp, rbp
    pop rbp
    ret
```

## Going Further

### Challenge 1: Factorial with locals

Write a factorial function that uses local variables to store intermediate results.

### Challenge 2: Calculate power

Implement `power(base, exp)` using recursion with proper stack frames.

```asm
; power(2, 8) = 256
; power(3, 4) = 81
```

### Challenge 3: Greatest Common Divisor

Implement Euclid's GCD algorithm recursively.

```asm
; gcd(48, 18) = 6
; gcd(100, 35) = 5
```

### Challenge 4: Array Sum with Nested Calls

Create a function that sums an array by recursively calling itself on halves of the array.

## Real-World Example: Complex Function

```asm
section .data
    array dq 1, 2, 3, 4, 5
    array_len equ 5

section .text

; Function: process_array
; Arguments: rdi = pointer to array, rsi = length
; Returns: rax = result
; Local variables: min, max, sum, average
process_array:
    push rbp
    mov rbp, rsp
    sub rsp, 32         ; 4 local variables

    ; Save callee-saved registers
    push rbx
    push r12
    push r13

    ; r12 = array pointer
    ; r13 = length
    mov r12, rdi
    mov r13, rsi

    ; Call find_min
    mov rdi, r12
    mov rsi, r13
    call find_min
    mov [rbp-8], rax    ; Save min

    ; Call find_max
    mov rdi, r12
    mov rsi, r13
    call find_max
    mov [rbp-16], rax   ; Save max

    ; Call sum_array
    mov rdi, r12
    mov rsi, r13
    call sum_array
    mov [rbp-24], rax   ; Save sum

    ; Calculate average
    mov rax, [rbp-24]
    xor rdx, rdx
    div r13
    mov [rbp-32], rax   ; Save average

    ; Return average
    mov rax, [rbp-32]

    ; Restore registers
    pop r13
    pop r12
    pop rbx

    mov rsp, rbp
    pop rbp
    ret
```

## Next Steps

Once you complete this assignment, move on to:
- [03-multi-file](../03-multi-file/) - Multi-file projects with external symbols

## Resources

- [Calling Conventions](../../resources/calling-conventions.md)
- [Instruction Reference](../../resources/instruction-reference.md)
