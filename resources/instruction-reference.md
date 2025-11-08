# x86-64 Instruction Reference

A practical reference for the most commonly used x86-64 assembly instructions.

## Notation

- `reg`: Any general-purpose register (rax, rbx, etc.)
- `reg64`: 64-bit register (rax, rbx, rcx, etc.)
- `reg32`: 32-bit register (eax, ebx, ecx, etc.)
- `reg8`: 8-bit register (al, bl, cl, etc.)
- `mem`: Memory location
- `imm`: Immediate value (constant)
- `[]`: Memory access (e.g., `[rax]` means "value at address in rax")

## Data Movement

### MOV - Move data
```asm
mov dest, src       ; dest = src
```

Examples:
```asm
mov rax, 42         ; rax = 42
mov rbx, rax        ; rbx = rax
mov rax, [rbx]      ; rax = value at address in rbx
mov [rax], rbx      ; store rbx at address in rax
mov rdi, msg        ; rdi = address of msg
```

**Note**: Cannot move memory to memory directly. Use a register as intermediate.

### LEA - Load Effective Address
```asm
lea dest, [address]  ; dest = address (doesn't access memory)
```

Examples:
```asm
lea rsi, [msg]       ; rsi = address of msg
lea rax, [rbx + 8]   ; rax = rbx + 8 (address calculation)
lea rcx, [rax + rbx*4 + 10]  ; complex address calculation
```

**Note**: LEA is often used for arithmetic because it's fast.

### MOVZX/MOVSX - Move with zero/sign extension
```asm
movzx dest, src      ; Move and zero-extend
movsx dest, src      ; Move and sign-extend
```

Examples:
```asm
movzx rax, byte [rbx]   ; Load byte, zero-extend to 64-bit
movsx rax, byte [rbx]   ; Load byte, sign-extend to 64-bit
```

## Arithmetic

### ADD - Addition
```asm
add dest, src        ; dest = dest + src
```

Examples:
```asm
add rax, 10          ; rax = rax + 10
add rbx, rcx         ; rbx = rbx + rcx
add rax, [rbx]       ; rax = rax + value at [rbx]
```

### SUB - Subtraction
```asm
sub dest, src        ; dest = dest - src
```

Examples:
```asm
sub rax, 5           ; rax = rax - 5
sub rbx, rcx         ; rbx = rbx - rcx
```

### INC/DEC - Increment/Decrement
```asm
inc reg              ; reg = reg + 1
dec reg              ; reg = reg - 1
```

Examples:
```asm
inc rax              ; rax++
dec rcx              ; rcx--
```

### MUL - Unsigned multiplication
```asm
mul src              ; rdx:rax = rax * src (unsigned)
```

**Note**: Result is 128-bit (high part in rdx, low part in rax)

Examples:
```asm
mov rax, 5
mov rbx, 3
mul rbx              ; rax = 15 (rdx = 0)
```

### IMUL - Signed multiplication
```asm
imul src             ; rdx:rax = rax * src (signed)
imul dest, src       ; dest = dest * src (32/64-bit result)
imul dest, src, imm  ; dest = src * imm
```

Examples:
```asm
imul rbx             ; rax = rax * rbx (signed)
imul rax, rbx        ; rax = rax * rbx
imul rax, rbx, 10    ; rax = rbx * 10
```

### DIV - Unsigned division
```asm
div src              ; rax = rdx:rax / src (quotient)
                     ; rdx = rdx:rax % src (remainder)
```

**Important**: Set rdx to 0 before dividing!

Examples:
```asm
mov rax, 17
xor rdx, rdx         ; Clear rdx
mov rbx, 5
div rbx              ; rax = 3, rdx = 2
```

### IDIV - Signed division
```asm
idiv src             ; rax = rdx:rax / src (quotient)
                     ; rdx = rdx:rax % src (remainder)
```

## Logical Operations

### AND - Bitwise AND
```asm
and dest, src        ; dest = dest & src
```

### OR - Bitwise OR
```asm
or dest, src         ; dest = dest | src
```

### XOR - Bitwise XOR
```asm
xor dest, src        ; dest = dest ^ src
```

**Common idiom**: `xor rax, rax` clears rax to 0 (shorter than `mov rax, 0`)

### NOT - Bitwise NOT
```asm
not reg              ; reg = ~reg
```

### SHL/SHR - Shift left/right (logical)
```asm
shl dest, count      ; dest = dest << count
shr dest, count      ; dest = dest >> count (unsigned)
```

Examples:
```asm
shl rax, 1           ; rax = rax * 2
shr rax, 2           ; rax = rax / 4
```

### SAL/SAR - Shift arithmetic left/right
```asm
sal dest, count      ; dest = dest << count (same as shl)
sar dest, count      ; dest = dest >> count (signed, preserves sign bit)
```

## Comparison and Testing

### CMP - Compare
```asm
cmp op1, op2         ; Performs op1 - op2 and sets flags (doesn't store result)
```

Examples:
```asm
cmp rax, 10          ; Compare rax with 10
cmp rbx, rcx         ; Compare rbx with rcx
```

### TEST - Bitwise test
```asm
test op1, op2        ; Performs op1 & op2 and sets flags (doesn't store result)
```

Examples:
```asm
test rax, rax        ; Test if rax is zero
test al, 1           ; Test if lowest bit is set
```

## Control Flow

### JMP - Unconditional jump
```asm
jmp label            ; Jump to label
```

### Conditional Jumps

After `cmp a, b`:

| Instruction | Meaning | Condition |
|-------------|---------|-----------|
| `je` / `jz` | Jump if equal / zero | a == b |
| `jne` / `jnz` | Jump if not equal / not zero | a != b |
| `jg` / `jnle` | Jump if greater (signed) | a > b |
| `jge` / `jnl` | Jump if greater or equal (signed) | a >= b |
| `jl` / `jnge` | Jump if less (signed) | a < b |
| `jle` / `jng` | Jump if less or equal (signed) | a <= b |
| `ja` / `jnbe` | Jump if above (unsigned) | a > b |
| `jae` / `jnb` | Jump if above or equal (unsigned) | a >= b |
| `jb` / `jnae` | Jump if below (unsigned) | a < b |
| `jbe` / `jna` | Jump if below or equal (unsigned) | a <= b |

Examples:
```asm
cmp rax, 10
je equal             ; Jump if rax == 10
jl less_than         ; Jump if rax < 10
jg greater_than      ; Jump if rax > 10
```

### CALL - Call function
```asm
call label           ; Push return address and jump to label
```

### RET - Return from function
```asm
ret                  ; Pop return address and jump to it
```

## Stack Operations

### PUSH - Push onto stack
```asm
push reg             ; rsp = rsp - 8; [rsp] = reg
```

**Note**: Stack grows downward (toward lower addresses)

### POP - Pop from stack
```asm
pop reg              ; reg = [rsp]; rsp = rsp + 8
```

Examples:
```asm
push rax             ; Save rax
push rbx             ; Save rbx
; ... do work ...
pop rbx              ; Restore rbx
pop rax              ; Restore rax
```

**Important**: Pop in reverse order!

## Special Instructions

### SYSCALL - Invoke system call
```asm
syscall              ; Invoke Linux system call
```

**Usage**:
1. Put syscall number in rax
2. Put arguments in rdi, rsi, rdx, r10, r8, r9
3. Execute syscall
4. Result returned in rax

Example:
```asm
mov rax, 1           ; sys_write
mov rdi, 1           ; stdout
mov rsi, msg         ; buffer
mov rdx, len         ; length
syscall
```

### NOP - No operation
```asm
nop                  ; Do nothing (1 byte, useful for alignment/debugging)
```

## Register Sizes

x86-64 registers can be accessed at different sizes. Each general-purpose register has multiple names depending on which part you want to access:

| 64-bit | 32-bit | 16-bit | 8-bit high | 8-bit low |
|--------|--------|--------|------------|-----------|
| rax | eax | ax | ah | al |
| rbx | ebx | bx | bh | bl |
| rcx | ecx | cx | ch | cl |
| rdx | edx | dx | dh | dl |
| rsi | esi | si | - | sil |
| rdi | edi | di | - | dil |
| rbp | ebp | bp | - | bpl |
| rsp | esp | sp | - | spl |
| r8 | r8d | r8w | - | r8b |
| r9 | r9d | r9w | - | r9b |
| r10-r15 | r10d-r15d | r10w-r15w | - | r10b-r15b |

### Understanding Register Parts

**Visual representation of RAX:**
```
┌────────────────────────────────────────────────────────────────┐
│                              RAX (64-bit)                       │
├────────────────────────────────────┬───────────────────────────┤
│                                    │      EAX (32-bit)          │
│                                    ├───────────────┬────────────┤
│                                    │               │  AX (16-bit)
│                                    │               ├──────┬─────┤
│                                    │               │  AH  │  AL │
└────────────────────────────────────┴───────────────┴──────┴─────┘
 Bit:  63                          32              16   8    0
```

### When to Use Each Size

**8-bit registers (al, bl, cl, etc.):**
- Loading/storing single bytes (characters)
- Working with byte arrays
- String operations

```asm
mov al, [rsi]        ; Load one byte from memory
mov byte [rdi], al   ; Store one byte to memory
cmp al, 0            ; Compare byte with 0 (null terminator)
```

**16-bit registers (ax, bx, cx, etc.):**
- Rarely used in modern 64-bit code
- Working with 16-bit values (words)

```asm
mov ax, [rsi]        ; Load 16-bit value
```

**32-bit registers (eax, ebx, ecx, etc.):**
- 32-bit integers
- Often used for counters and indices

```asm
mov eax, 100         ; Load 32-bit value
add ecx, 1           ; Increment 32-bit counter
```

**64-bit registers (rax, rbx, rcx, etc.):**
- Pointers and addresses (always 64-bit)
- Large integers
- System call numbers and arguments

```asm
mov rax, 60          ; System call number
mov rdi, msg         ; Pointer to string
lea rsi, [rax + rbx] ; Address calculation
```

### Important Behavior

**Writing to 32-bit register zeroes upper 32 bits:**
```asm
mov rax, 0xFFFFFFFFFFFFFFFF  ; rax = all 1s
mov eax, 1                    ; rax = 0x0000000000000001 (upper 32 bits cleared!)
```

**Writing to 8-bit or 16-bit registers preserves upper bits:**
```asm
mov rax, 0xFFFFFFFFFFFFFFFF  ; rax = all 1s
mov ax, 0                     ; rax = 0xFFFFFFFFFFFF0000 (upper 48 bits unchanged)
mov al, 0                     ; rax = 0xFFFFFFFFFFFFFF00 (only lowest byte changed)
```

### Common Use Cases

**Loading a byte (character from string):**
```asm
mov al, [rsi]        ; Load byte into al
cmp al, 0            ; Check if null terminator
```

**Clearing a register:**
```asm
xor rax, rax         ; Fast way to zero rax (all 64 bits)
xor eax, eax         ; Also zeros rax (32-bit write clears upper bits)
```

**Using different sizes in same code:**
```asm
mov rax, 0x1234567890ABCDEF  ; Full 64-bit value
mov al, [rsi]                ; Load byte into low 8 bits
; rax now = 0x1234567890ABCD?? (last byte from [rsi])
```

## Addressing Modes

### Immediate
```asm
mov rax, 42          ; Load constant
```

### Register
```asm
mov rax, rbx         ; Copy register
```

### Direct
```asm
mov rax, [0x1000]    ; Load from fixed address
```

### Register Indirect
```asm
mov rax, [rbx]       ; Load from address in rbx
```

### Base + Displacement
```asm
mov rax, [rbx + 8]   ; Load from rbx + 8
```

### Base + Index
```asm
mov rax, [rbx + rcx]  ; Load from rbx + rcx
```

### Base + Index * Scale + Displacement
```asm
mov rax, [rbx + rcx*4 + 8]   ; rbx + (rcx * 4) + 8
```

Scale can be 1, 2, 4, or 8 (for byte, word, dword, qword arrays)

## Common Patterns

### Zero a register
```asm
xor rax, rax         ; Faster than mov rax, 0
```

### Clear a memory location
```asm
mov qword [addr], 0
```

### Swap two registers (without temp)
```asm
xor rax, rbx
xor rbx, rax
xor rax, rbx
```

### Multiply by power of 2
```asm
shl rax, 3           ; rax = rax * 8 (faster than mul)
```

### Divide by power of 2
```asm
shr rax, 2           ; rax = rax / 4 (unsigned)
sar rax, 2           ; rax = rax / 4 (signed)
```

### Save and restore registers
```asm
push rax
push rbx
; ... use rax and rbx ...
pop rbx
pop rax
```

## Flags Register

These flags are set by arithmetic and comparison operations:

| Flag | Name | Meaning |
|------|------|---------|
| CF | Carry Flag | Unsigned overflow |
| ZF | Zero Flag | Result was zero |
| SF | Sign Flag | Result was negative |
| OF | Overflow Flag | Signed overflow |
| PF | Parity Flag | Even number of 1 bits |

Conditional jumps test these flags.

## Size Directives

Specify operand size when ambiguous:

```asm
mov byte [rax], 1    ; Store 1 byte
mov word [rax], 1    ; Store 2 bytes
mov dword [rax], 1   ; Store 4 bytes
mov qword [rax], 1   ; Store 8 bytes
```

## Useful Pseudo-Instructions

These aren't real CPU instructions, but NASM provides them:

```asm
db 10                ; Define byte
dw 1000              ; Define word (2 bytes)
dd 100000            ; Define double word (4 bytes)
dq 10000000000       ; Define quad word (8 bytes)

resb 100             ; Reserve 100 bytes
resw 50              ; Reserve 50 words (100 bytes)
```

## Quick Reference Card

**Most common instructions for beginners**:

```asm
; Data movement
mov rax, 42          ; Load constant
mov rax, rbx         ; Copy register
mov rax, [rbx]       ; Load from memory
mov [rax], rbx       ; Store to memory

; Arithmetic
add rax, rbx         ; rax += rbx
sub rax, rbx         ; rax -= rbx
inc rax              ; rax++
dec rax              ; rax--
imul rax, rbx        ; rax *= rbx

; Comparison and branching
cmp rax, rbx         ; Compare
je label             ; Jump if equal
jne label            ; Jump if not equal
jl label             ; Jump if less
jg label             ; Jump if greater
jmp label            ; Unconditional jump

; Functions
call function        ; Call function
ret                  ; Return

; Stack
push rax             ; Save rax
pop rax              ; Restore rax

; System calls
mov rax, 60          ; exit syscall
xor rdi, rdi         ; status 0
syscall              ; invoke
```

## Next Steps

- Practice with [01-basics](../01-basics/) exercises
- Refer to [calling-conventions.md](calling-conventions.md) for function calling rules
- See [syscalls-linux.md](syscalls-linux.md) for system call details
