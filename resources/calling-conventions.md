# x86-64 Calling Conventions

Understanding how functions pass arguments and return values in x86-64 assembly.

## The System V AMD64 ABI

On Linux, x86-64 uses the **System V AMD64 ABI** calling convention. This is the standard for:
- Linux
- macOS
- BSD systems
- Most Unix-like systems

(Windows uses a different convention - not covered here)

## Register Usage

### Argument Passing

Arguments are passed in registers in this order:

| Argument | Register | Type |
|----------|----------|------|
| 1st | rdi | Integer/pointer |
| 2nd | rsi | Integer/pointer |
| 3rd | rdx | Integer/pointer |
| 4th | rcx | Integer/pointer |
| 5th | r8 | Integer/pointer |
| 6th | r9 | Integer/pointer |
| 7+ | stack | Push right to left |

**For floating-point**: Use xmm0-xmm7

### Return Values

| Size | Register |
|------|----------|
| Integer/pointer (64-bit) | rax |
| Integer (128-bit) | rdx:rax |
| Floating-point | xmm0 |

### Register Preservation

Registers are divided into two categories:

**Caller-saved** (volatile): Caller must save if needed
- rax, rcx, rdx
- rsi, rdi
- r8, r9, r10, r11
- xmm0-xmm15

**Callee-saved** (non-volatile): Callee must preserve
- rbx, rbp
- r12, r13, r14, r15

**Special registers**:
- rsp: Stack pointer (must be preserved)
- rbp: Base pointer (must be preserved if used)

## Stack Frame

The stack must be **16-byte aligned** before a `call` instruction.

```
Higher addresses
+------------------+
| arguments 7+     |  (if any)
+------------------+
| return address   |  <- pushed by 'call'
+------------------+
| saved rbp        |  (if used)
+------------------+
| local variables  |
+------------------+
| saved registers  |  (callee-saved registers)
+------------------+  <- rsp points here
Lower addresses
```

## Basic Function Template

### Simple Function (No Stack Frame)

For functions that don't need local variables or to save registers:

```asm
my_function:
    ; Arguments in rdi, rsi, rdx, rcx, r8, r9
    ; Do work...
    mov rax, result          ; Return value
    ret
```

### Function with Stack Frame

For functions needing local variables or preserving registers:

```asm
my_function:
    ; Prologue
    push rbp                 ; Save old base pointer
    mov rbp, rsp             ; Set up new base pointer
    sub rsp, 32              ; Allocate 32 bytes for locals (keep 16-byte aligned!)

    ; Save callee-saved registers if needed
    push rbx
    push r12

    ; Function body
    ; Access locals: [rbp-8], [rbp-16], etc.
    ; Do work...

    ; Epilogue
    pop r12                  ; Restore registers (reverse order!)
    pop rbx

    mov rsp, rbp             ; Restore stack pointer
    pop rbp                  ; Restore base pointer
    ret
```

**Important**: The `sub rsp, 32` must keep RSP 16-byte aligned!

## Examples

### Example 1: Function with 3 arguments

```asm
; Function: add_three(a, b, c) -> a + b + c
; Arguments: rdi=a, rsi=b, rdx=c
; Returns: rax

add_three:
    mov rax, rdi             ; rax = a
    add rax, rsi             ; rax = a + b
    add rax, rdx             ; rax = a + b + c
    ret                      ; return rax

; Calling it:
_start:
    mov rdi, 10              ; a = 10
    mov rsi, 20              ; b = 20
    mov rdx, 5               ; c = 5
    call add_three
    ; rax now contains 35
```

### Example 2: Function that preserves registers

```asm
; Function: multiply_and_add(a, b, c) -> (a * b) + c
; Uses rbx (callee-saved), so must preserve it

multiply_and_add:
    push rbx                 ; Save rbx

    mov rax, rdi             ; rax = a
    imul rax, rsi            ; rax = a * b
    mov rbx, rax             ; rbx = a * b
    add rbx, rdx             ; rbx = (a * b) + c
    mov rax, rbx             ; rax = result

    pop rbx                  ; Restore rbx
    ret

; Calling it:
_start:
    mov rdi, 6               ; a = 6
    mov rsi, 7               ; b = 7
    mov rdx, 3               ; c = 3
    call multiply_and_add
    ; rax now contains 45
```

### Example 3: Function with local variables

```asm
; Function: compute(x) -> (x * 2) + (x * 3)
; Uses local variable to store intermediate result

compute:
    push rbp
    mov rbp, rsp
    sub rsp, 16              ; Allocate 16 bytes (stay aligned!)

    ; Calculate x * 2
    mov rax, rdi
    shl rax, 1               ; rax = x * 2
    mov [rbp-8], rax         ; Store in local variable

    ; Calculate x * 3
    mov rax, rdi
    imul rax, 3              ; rax = x * 3

    ; Add them
    add rax, [rbp-8]         ; rax = (x*2) + (x*3)

    mov rsp, rbp             ; Clean up
    pop rbp
    ret

; Calling it:
_start:
    mov rdi, 10              ; x = 10
    call compute
    ; rax now contains 50 (20 + 30)
```

### Example 4: Calling with > 6 arguments

```asm
; Function: sum_many(a, b, c, d, e, f, g, h) -> sum of all
; First 6 in registers, last 2 on stack

sum_many:
    push rbp
    mov rbp, rsp

    ; Sum first 6 arguments (in registers)
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9

    ; Add 7th argument (first on stack)
    add rax, [rbp+16]        ; Skip return address (8) and rbp (8)

    ; Add 8th argument
    add rax, [rbp+24]

    pop rbp
    ret

; Calling it:
_start:
    ; Last arguments pushed first (right to left)
    push 80                  ; 8th argument
    push 70                  ; 7th argument

    ; First 6 in registers
    mov rdi, 10              ; 1st
    mov rsi, 20              ; 2nd
    mov rdx, 30              ; 3rd
    mov rcx, 40              ; 4th
    mov r8, 50               ; 5th
    mov r9, 60               ; 6th

    call sum_many
    add rsp, 16              ; Clean up stack (2 args * 8 bytes)
    ; rax now contains 360
```

### Example 5: Recursive function

```asm
; Factorial: factorial(n) -> n!
; Base case: n <= 1 returns 1
; Recursive: n * factorial(n-1)

factorial:
    push rbp
    mov rbp, rsp

    ; Check base case
    cmp rdi, 1
    jg recursive             ; If n > 1, recurse

    ; Base case: return 1
    mov rax, 1
    jmp done

recursive:
    push rdi                 ; Save n (caller-saved, but we need it)

    dec rdi                  ; n - 1
    call factorial           ; rax = factorial(n-1)

    pop rdi                  ; Restore n
    imul rax, rdi            ; rax = n * factorial(n-1)

done:
    pop rbp
    ret

; Calling it:
_start:
    mov rdi, 5               ; Calculate 5!
    call factorial
    ; rax now contains 120
```

## Stack Alignment Details

The stack must be 16-byte aligned **before** a `call` instruction.

When your function starts:
- `call` pushed 8-byte return address
- Stack is now misaligned (8-byte offset)

If you `push rbp` (8 bytes):
- Stack is aligned again (16-byte offset total)

When allocating space with `sub rsp, N`:
- N must maintain alignment
- Use multiples of 16
- If you need 12 bytes, allocate 16

**Example**:
```asm
function:
    push rbp                 ; rsp now 16-byte aligned
    mov rbp, rsp
    sub rsp, 32              ; Allocate space (keeps alignment)
    ; ... work ...
    mov rsp, rbp
    pop rbp
    ret
```

**Wrong**:
```asm
function:
    push rbp                 ; rsp now 16-byte aligned
    mov rbp, rsp
    sub rsp, 8               ; WRONG! Now misaligned
    ; Calling other functions may crash!
```

## Calling C Functions from Assembly

Since we use the same ABI, calling C functions is straightforward:

```asm
section .data
    format db "Value: %d", 10, 0

section .text
extern printf                ; Declare external C function

global main                  ; C expects 'main', not '_start'

main:
    push rbp
    mov rbp, rsp

    ; printf("Value: %d\n", 42)
    mov rdi, format          ; 1st arg: format string
    mov rsi, 42              ; 2nd arg: value
    xor rax, rax             ; AL=0 means no vector registers used
    call printf

    ; Return 0 from main
    xor rax, rax

    pop rbp
    ret
```

**Compile and link with C**:
```bash
nasm -f elf64 program.asm
gcc program.o -o program
./program
```

## Leaf Functions Optimization

A "leaf function" doesn't call other functions. It can skip the prologue/epilogue:

```asm
; Simple leaf function
add_two:
    mov rax, rdi
    add rax, rsi
    ret                      ; No need for stack frame!
```

Only use stack frame if you:
1. Call other functions
2. Need local variables beyond registers
3. Need to preserve callee-saved registers

## Common Patterns

### Save all callee-saved registers

```asm
function:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; ... function body ...

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
```

### Quick function return

```asm
function:
    ; ... compute result in rax ...
    ret                      ; That's it!
```

### Preserve caller-saved register across call

```asm
    mov r10, rdi             ; Save rdi (we'll need it after call)
    call other_function      ; Might destroy rdi
    mov rdi, r10             ; Restore rdi
```

## Common Mistakes

### ❌ Wrong: Not preserving callee-saved registers
```asm
my_function:
    mov rbx, rdi             ; Using rbx...
    ; ... work with rbx ...
    ret                      ; Forgot to restore rbx!
```

### ✅ Correct:
```asm
my_function:
    push rbx                 ; Save it!
    mov rbx, rdi
    ; ... work with rbx ...
    pop rbx                  ; Restore it!
    ret
```

### ❌ Wrong: Stack misalignment
```asm
my_function:
    push rbp
    mov rbp, rsp
    sub rsp, 8               ; Now misaligned!
    call other_func          ; May crash!
```

### ✅ Correct:
```asm
my_function:
    push rbp
    mov rbp, rsp
    sub rsp, 16              ; Keep 16-byte aligned
    call other_func          ; Safe!
```

### ❌ Wrong: Not cleaning up stack after call
```asm
    push 42                  ; 7th argument
    call function
    ; Forgot to clean up!
```

### ✅ Correct:
```asm
    push 42
    call function
    add rsp, 8               ; Clean up
```

## Quick Reference

**Function prologue** (if needed):
```asm
push rbp
mov rbp, rsp
sub rsp, 32                  ; Allocate locals (multiple of 16)
```

**Function epilogue**:
```asm
mov rsp, rbp                 ; Or: leave
pop rbp
ret
```

**Call function**:
```asm
mov rdi, arg1                ; Set up arguments
mov rsi, arg2
call function
; Result in rax
```

**Preserve registers**:
```asm
push rbx                     ; Before using
; ... use rbx ...
pop rbx                      ; Before returning
```

## Summary Table

| Aspect | Rule |
|--------|------|
| Arguments | rdi, rsi, rdx, rcx, r8, r9, then stack |
| Return value | rax |
| Caller-saved | rax, rcx, rdx, rsi, rdi, r8-r11 |
| Callee-saved | rbx, rbp, r12-r15 |
| Stack pointer | rsp (must preserve) |
| Stack alignment | 16-byte before `call` |
| Frame pointer | rbp (optional, but must preserve if used) |

## Practice

Try implementing these functions:
1. `max(a, b)` - return larger of two numbers
2. `strlen(str)` - count characters until null byte
3. `sum_array(array, length)` - sum array elements
4. `fibonacci(n)` - nth Fibonacci number (recursive)

See the [01-basics](../01-basics/) exercises for practice!
