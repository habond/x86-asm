# Assignment 5: Functions

Learn how to organize code with functions, manage the stack, and follow calling conventions.

## Learning Objectives

- Define and call functions with CALL and RET
- Pass arguments using registers
- Understand the System V AMD64 ABI calling convention
- Manage the stack properly
- Preserve caller-saved and callee-saved registers

## Background

Functions in assembly work similarly to high-level languages:
```c
int add(int a, int b) {
    return a + b;
}

int main() {
    int result = add(5, 3);
    return result;
}
```

In assembly, you need to:
1. **Pass arguments** in registers
2. **Call** the function
3. **Save/restore** registers
4. **Return** the result

## The x86-64 Calling Convention

### Argument Passing (System V AMD64 ABI)

Arguments are passed in registers in this order:
1. `rdi` - First argument
2. `rsi` - Second argument
3. `rdx` - Third argument
4. `rcx` - Fourth argument
5. `r8` - Fifth argument
6. `r9` - Sixth argument
7. Stack - Additional arguments (if more than 6)

### Return Value

- `rax` - Return value (integers, pointers)
- `rdx:rax` - 128-bit return value (if needed)

### Register Preservation

**Caller-saved** (caller must save if needed):
- `rax`, `rcx`, `rdx`
- `rsi`, `rdi`
- `r8`, `r9`, `r10`, `r11`

**Callee-saved** (function must preserve):
- `rbx`, `rbp`
- `r12`, `r13`, `r14`, `r15`

**Special**:
- `rsp` - Stack pointer (must be preserved)

## The Task

Write a program that:
1. Defines a function `add_numbers` that adds two numbers
2. Calls this function with arguments 12 and 30
3. Returns the result (42)
4. Exits with the result as the exit code

## Instructions You'll Need

### CALL - Call a function
```asm
call function_name  ; Push return address and jump to function
```

**What it does**:
1. Pushes the address of the next instruction onto the stack
2. Jumps to the function

### RET - Return from function
```asm
ret                 ; Pop return address and jump to it
```

**What it does**:
1. Pops an address from the stack
2. Jumps to that address

### PUSH/POP - Stack operations
```asm
push reg            ; Push register onto stack (rsp -= 8)
pop reg             ; Pop from stack into register (rsp += 8)
```

## Starter Code

```asm
section .text
global _start

; Function: add_numbers
; Arguments: rdi = first number, rsi = second number
; Returns: rax = sum
add_numbers:
    ; TODO: Add rdi and rsi, store result in rax

    ; TODO: Return from function

_start:
    ; TODO: Load first argument (12) into rdi

    ; TODO: Load second argument (30) into rsi

    ; TODO: Call add_numbers function

    ; Exit with result
    mov rdi, rax        ; Exit code = result
    mov rax, 60         ; sys_exit
    syscall
```

## Step by Step

### Step 1: Define the function
```asm
add_numbers:
    mov rax, rdi        ; rax = first argument
    add rax, rsi        ; rax = rax + second argument
    ret                 ; Return to caller
```

### Step 2: Prepare arguments
```asm
_start:
    mov rdi, 12         ; First argument
    mov rsi, 30         ; Second argument
```

### Step 3: Call the function
```asm
    call add_numbers    ; Call function
    ; rax now contains the result (42)
```

### Step 4: Use the result
```asm
    mov rdi, rax        ; Exit code = result
    mov rax, 60
    syscall
```

## Building and Running

```bash
nasm -f elf64 function.asm -o function.o
ld -o function function.o
./function
echo $?             # Should print 42
```

Or with Make:
```bash
make run
echo $?
```

## Expected Output

```bash
$ ./function
$ echo $?
42
```

## Understanding the Stack

The stack grows downward (from high to low addresses):

```
Before CALL:
┌─────────┐ ← rsp
│         │
│  stack  │
│         │
└─────────┘

After CALL add_numbers:
┌─────────┐
│ return  │ ← rsp (pushed by CALL)
│ address │
├─────────┤
│         │
│  stack  │
│         │
└─────────┘

After RET:
┌─────────┐ ← rsp (popped by RET)
│         │
│  stack  │
│         │
└─────────┘
```

## Stack Alignment

The System V ABI requires the stack to be 16-byte aligned before a CALL.

When `_start` begins, `rsp % 16 = 8` (because the kernel pushed 8 bytes).

Before calling a function:
```asm
; _start begins with rsp % 16 = 8
; CALL pushes 8 bytes, making rsp % 16 = 0 ✓
call add_numbers    ; Stack is properly aligned
```

For multiple calls or complex functions, you may need to adjust:
```asm
_start:
    sub rsp, 8          ; Align stack (rsp % 16 = 0)
    call function
    add rsp, 8          ; Restore stack
```

## Common Mistakes

### Mistake 1: Wrong argument registers
```asm
mov rax, 12         ; Wrong! Arguments go in rdi, rsi, etc.
mov rbx, 30
call add_numbers
```

**Fix**: Use the correct registers
```asm
mov rdi, 12         ; First argument
mov rsi, 30         ; Second argument
call add_numbers
```

### Mistake 2: Forgetting to return
```asm
add_numbers:
    mov rax, rdi
    add rax, rsi
    ; Forgot ret! Will execute whatever comes next
```

**Fix**: Always return
```asm
add_numbers:
    mov rax, rdi
    add rax, rsi
    ret                 ; Return to caller
```

### Mistake 3: Not preserving callee-saved registers
```asm
my_function:
    mov rbx, 100        ; Oops! rbx is callee-saved
    ; ... do work ...
    ret                 ; rbx not restored!
```

**Fix**: Save and restore
```asm
my_function:
    push rbx            ; Save rbx
    mov rbx, 100
    ; ... do work ...
    pop rbx             ; Restore rbx
    ret
```

### Mistake 4: Stack misalignment
```asm
_start:
    ; rsp % 16 = 8 initially
    push rax            ; rsp % 16 = 0
    call function       ; rsp % 16 = 8 (CALL pushes 8 bytes)
    ; Stack misaligned! May crash in complex functions
```

**Fix**: Keep stack aligned
```asm
_start:
    ; Don't push odd number of times before call
    call function       ; Aligned
```

## Debugging with GDB

```bash
nasm -f elf64 -g function.asm -o function.o
ld -o function function.o
gdb ./function

(gdb) break _start
(gdb) break add_numbers
(gdb) run
(gdb) info registers rdi rsi    # Check arguments
(gdb) stepi
(gdb) info registers rax        # Check return value
(gdb) bt                        # Backtrace (call stack)
(gdb) continue
```

## Experiments

### 1. Multiple arguments
Function with three arguments:
```asm
add_three:
    mov rax, rdi        ; First argument
    add rax, rsi        ; Second argument
    add rax, rdx        ; Third argument
    ret

_start:
    mov rdi, 10
    mov rsi, 20
    mov rdx, 12
    call add_three      ; rax = 42
```

### 2. Multiple function calls
```asm
add_numbers:
    mov rax, rdi
    add rax, rsi
    ret

multiply_by_two:
    mov rax, rdi
    add rax, rdi        ; Double it
    ret

_start:
    ; result = (10 + 11) * 2
    mov rdi, 10
    mov rsi, 11
    call add_numbers    ; rax = 21

    mov rdi, rax        ; Pass result to next function
    call multiply_by_two ; rax = 42

    mov rdi, rax
    mov rax, 60
    syscall
```

### 3. Nested function calls
```asm
add_numbers:
    mov rax, rdi
    add rax, rsi
    ret

compute:
    ; Save arguments (caller-saved)
    push rdi
    push rsi

    ; Call add_numbers(5, 7)
    mov rdi, 5
    mov rsi, 7
    call add_numbers    ; rax = 12

    ; Restore arguments
    pop rsi
    pop rdi

    ; Add to original arguments
    add rax, rdi
    add rax, rsi
    ret

_start:
    mov rdi, 10
    mov rsi, 20
    call compute        ; rax = (5+7) + 10 + 20 = 42

    mov rdi, rax
    mov rax, 60
    syscall
```

### 4. Function with local variables (using stack)
```asm
calculate:
    ; Allocate stack space for locals
    sub rsp, 16         ; 2 local variables (8 bytes each)

    ; local1 = rdi + rsi
    mov rax, rdi
    add rax, rsi
    mov [rsp], rax      ; Store local1 at [rsp]

    ; local2 = rdi - rsi
    mov rax, rdi
    sub rax, rsi
    mov [rsp+8], rax    ; Store local2 at [rsp+8]

    ; Return local1 + local2
    mov rax, [rsp]
    add rax, [rsp+8]

    ; Deallocate stack space
    add rsp, 16
    ret

_start:
    mov rdi, 30
    mov rsi, 12
    call calculate      ; (30+12) + (30-12) = 42 + 18 = 60

    mov rdi, rax
    mov rax, 60
    syscall
```

## Preserving Registers Example

When using callee-saved registers:
```asm
my_function:
    ; Save callee-saved registers
    push rbx
    push r12

    ; Use them
    mov rbx, rdi
    mov r12, rsi
    ; ... do work ...
    mov rax, rbx
    add rax, r12

    ; Restore callee-saved registers
    pop r12
    pop rbx
    ret

_start:
    mov rbx, 999        ; Caller's rbx value
    mov rdi, 30
    mov rsi, 12
    call my_function
    ; rbx still = 999 (preserved by function)
```

## Function Call Visualization

```
1. _start:
   rdi = 12, rsi = 30

2. call add_numbers
   - Push return address to stack
   - Jump to add_numbers

3. add_numbers:
   rax = rdi (12)
   rax = rax + rsi (12 + 30 = 42)

4. ret
   - Pop return address from stack
   - Jump back to _start

5. _start (continued):
   rax = 42
   Exit with code 42
```

## Going Further

### Challenge 1: Maximum function
Find max of two numbers:
```asm
max:
    mov rax, rdi        ; Assume rdi is max
    cmp rdi, rsi        ; Compare rdi with rsi
    jge done            ; If rdi >= rsi, we're done
    mov rax, rsi        ; Otherwise rsi is max
done:
    ret

_start:
    mov rdi, 25
    mov rsi, 42
    call max            ; rax = 42
```

### Challenge 2: String length function
Calculate length of a null-terminated string:
```asm
section .data
    msg db "Hello", 0

section .text
global _start

strlen:
    ; rdi = pointer to string
    ; returns length in rax
    xor rax, rax        ; length = 0
loop:
    cmp byte [rdi+rax], 0  ; Check if null terminator
    je done
    inc rax             ; length++
    jmp loop
done:
    ret

_start:
    mov rdi, msg
    call strlen         ; rax = 5

    mov rdi, rax
    mov rax, 60
    syscall
```

### Challenge 3: Recursive countdown
Count down from N to 0:
```asm
countdown:
    ; rdi = number to count from
    ; Returns rdi in rax when done
    push rdi            ; Save rdi (callee-saved practice)

    cmp rdi, 0          ; if (n <= 0)
    jle base_case       ; return 0

    dec rdi             ; n - 1
    call countdown      ; countdown(n-1)

    pop rdi             ; Restore original rdi
    mov rax, rdi        ; Return original value
    ret

base_case:
    pop rdi             ; Clean up stack
    xor rax, rax        ; Return 0
    ret

_start:
    mov rdi, 5
    call countdown
    ; Would actually need to accumulate values for useful result
```

## Next Steps

Once you complete this assignment, move on to:
- [06-factorial](../06-factorial/) - Recursive factorial calculation

## Resources

- [Calling Conventions](../../resources/calling-conventions.md)
- [Instruction Reference](../../resources/instruction-reference.md)
- [System V AMD64 ABI](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf)
