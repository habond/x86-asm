# Assignment 1: Bit Manipulation

Master low-level bit operations and learn to work with individual bits.

## Learning Objectives

- Use bitwise AND, OR, XOR, NOT operations
- Set, clear, and test individual bits
- Work with bit masks and flags
- Count set bits (population count)
- Understand bit shifts and rotations

## Background

Bit manipulation is fundamental to low-level programming. It's used for:
- **Flags and permissions** (file permissions, CPU flags)
- **Compression** (packing multiple values)
- **Cryptography** (XOR operations)
- **Graphics** (color manipulation)
- **Networking** (IP addresses, protocols)

## The Task

Implement a function that counts the number of set bits (1s) in a 64-bit integer.

For example:
- `count_bits(0b1010)` → 2 (two 1s)
- `count_bits(0b1111)` → 4 (four 1s)
- `count_bits(0xFF)` → 8 (eight 1s)

## Bitwise Operations

### AND - Masking

```asm
mov rax, 0b1101
and rax, 0b1001      ; Result: 0b1001
```

Use AND to:
- Test if bits are set
- Clear specific bits (with inverted mask)
- Extract bit fields

### OR - Setting Bits

```asm
mov rax, 0b1001
or  rax, 0b0100      ; Result: 0b1101
```

Use OR to:
- Set specific bits
- Combine bit flags

### XOR - Toggling Bits

```asm
mov rax, 0b1001
xor rax, 0b1111      ; Result: 0b0110
```

Use XOR to:
- Toggle bits
- Compare for equality (xor rax, rbx; test rax, rax; jz equal)
- Simple encryption

### NOT - Inverting Bits

```asm
mov rax, 0b1001
not rax              ; Result: 0xFFFFFFFFFFFFFFF6 (all bits flipped)
```

### Shifts

```asm
mov rax, 0b0001
shl rax, 2           ; Shift left by 2: 0b0100 (multiply by 4)
shr rax, 1           ; Shift right by 1: 0b0010 (divide by 2)

; Arithmetic shift (preserves sign)
mov rax, -8
sar rax, 1           ; Arithmetic right shift: -4
```

### Bit Test Instructions

```asm
bt  rax, 5           ; Test bit 5, sets CF flag
jc  bit_is_set

bts rax, 3           ; Test bit 3 and set it
btr rax, 7           ; Test bit 7 and clear it
btc rax, 2           ; Test bit 2 and toggle it
```

## Starter Code

```asm
section .text
global _start

; Function: count_bits
; Arguments: rdi = 64-bit number
; Returns: rax = count of set bits
count_bits:
    ; TODO: Count number of 1 bits in rdi
    ; Hint: Loop through each bit, test it, increment counter if set

    xor rax, rax        ; counter = 0
    mov rcx, 64         ; 64 bits to check

loop:
    ; TODO: Test the lowest bit of rdi
    ; Hint: Use 'test' or 'and' with 1

    ; TODO: If bit is set, increment rax

    ; TODO: Shift rdi right by 1 to check next bit

    ; TODO: Decrement rcx and loop if not zero

    ret

_start:
    ; Test with value 0x0F (binary: 00001111, should have 4 set bits)
    mov rdi, 0x0F
    call count_bits

    ; Exit with the count as exit code (should be 4)
    mov rdi, rax
    mov rax, 60
    syscall
```

## Step by Step

### Step 1: Initialize

```asm
count_bits:
    xor rax, rax        ; counter = 0
    mov rcx, 64         ; bits remaining
```

### Step 2: Test the lowest bit

```asm
loop_start:
    test rdi, 1         ; Test bit 0 (lowest bit)
    jz skip             ; If zero, skip increment
    inc rax             ; Increment counter
skip:
```

### Step 3: Shift and continue

```asm
    shr rdi, 1          ; Shift right by 1 (next bit becomes lowest)
    dec rcx             ; Decrement bit counter
    jnz loop_start      ; Continue if bits remaining
```

### Step 4: Return

```asm
    ret                 ; count in rax
```

## Building and Running

```bash
nasm -f elf64 bitcount.asm -o bitcount.o
ld -o bitcount bitcount.o
./bitcount
echo $?                 # Should print 4 for input 0x0F
```

## Testing

Test with different values:

```asm
mov rdi, 0x00           ; 0 bits set → exit code 0
mov rdi, 0x01           ; 1 bit set → exit code 1
mov rdi, 0xFF           ; 8 bits set → exit code 8
mov rdi, 0xFFFFFFFFFFFFFFFF  ; 64 bits set → exit code 64
mov rdi, 0xAAAAAAAAAAAAAAAA  ; Every other bit: 32 bits set
```

## Common Bit Manipulation Tasks

### Set a specific bit

```asm
; Set bit N in register rax
mov rcx, 5              ; Bit number
mov rbx, 1
shl rbx, cl             ; Create mask: 1 << 5 = 0b100000
or  rax, rbx            ; Set the bit
```

### Clear a specific bit

```asm
; Clear bit N in register rax
mov rcx, 5
mov rbx, 1
shl rbx, cl             ; Create mask
not rbx                 ; Invert mask
and rax, rbx            ; Clear the bit
```

### Toggle a specific bit

```asm
; Toggle bit N in register rax
mov rcx, 5
mov rbx, 1
shl rbx, cl
xor rax, rbx            ; Toggle the bit
```

### Check if bit is set

```asm
; Check if bit N is set
mov rcx, 5
bt rax, rcx             ; Bit test
jc bit_is_set           ; Jump if carry (bit is 1)
```

### Extract a bit field

```asm
; Extract bits 4-7 from rax
mov rbx, rax
shr rbx, 4              ; Shift right to position
and rbx, 0xF            ; Mask to get 4 bits
```

## Going Further

### Challenge 1: Bit Parity

Write a function that returns 1 if the number has odd parity (odd number of 1 bits), 0 otherwise.

```asm
; parity(0b101) → 0 (even: 2 bits)
; parity(0b111) → 1 (odd: 3 bits)
```

### Challenge 2: Reverse Bits

Reverse all bits in a 64-bit number.

```asm
; reverse(0b00000001) → 0b10000000...
; reverse(0b10110000) → 0b00001101...
```

Hint: Build result bit by bit, shifting in opposite directions.

### Challenge 3: Lowest Set Bit

Find the position of the lowest set bit (rightmost 1).

```asm
; lowest_bit(0b101000) → 3
; lowest_bit(0b000100) → 2
```

Hint: Use bit isolation: `x & -x` isolates the lowest set bit.

### Challenge 4: Clear Lowest Bit

Clear the lowest set bit.

```asm
; clear_lowest(0b101100) → 0b101000
; clear_lowest(0b000110) → 0b000100
```

Hint: `x & (x - 1)` clears the lowest set bit.

### Challenge 5: Power of Two Check

Check if a number is a power of two.

```asm
; is_pow2(8) → 1 (true)
; is_pow2(7) → 0 (false)
```

Hint: Powers of two have exactly one bit set.

## Real-World Example: Unix File Permissions

```asm
section .data
    ; File permission bits (like chmod)
    O_READ  equ 4       ; 0b100
    O_WRITE equ 2       ; 0b010
    O_EXEC  equ 1       ; 0b001

section .text
check_permissions:
    ; rdi = permission bits
    ; Check for read permission
    test rdi, O_READ
    jz no_read

    ; Check for write permission
    test rdi, O_WRITE
    jz no_write

    ; Check for execute permission
    test rdi, O_EXEC
    jz no_exec

has_all:
    mov rax, 1
    ret

no_read:
no_write:
no_exec:
    xor rax, rax
    ret
```

## Optimization: Brian Kernighan's Algorithm

A faster way to count bits (only loops for each set bit):

```asm
count_bits_fast:
    xor rax, rax            ; counter = 0

loop:
    test rdi, rdi           ; Check if rdi is 0
    jz done

    inc rax                 ; Increment counter
    mov rbx, rdi
    dec rbx                 ; rdi - 1
    and rdi, rbx            ; Clear lowest set bit: rdi &= (rdi - 1)
    jmp loop

done:
    ret
```

This algorithm runs in O(number of set bits) instead of O(64).

## Debugging Tips

```bash
# In GDB, examine bits
(gdb) print/t $rax          # Print in binary
(gdb) print/x $rax          # Print in hexadecimal
(gdb) x/8tb &variable       # Examine 8 bytes as binary

# Watch a specific bit
(gdb) watch (rax & (1 << 5))  # Break when bit 5 changes
```

## Common Mistakes

### Mistake 1: Not preserving the value

```asm
; Wrong - destroys input
count_bits:
    shr rdi, 1          ; Modifies input!

; Right - work with a copy
count_bits:
    mov rbx, rdi        ; Copy to rbx
    shr rbx, 1          ; Modify copy
```

### Mistake 2: Wrong loop condition

```asm
; Wrong - infinite loop if rdi is 0
loop:
    test rdi, 1
    shr rdi, 1
    jmp loop            ; Never stops!

; Right - use a counter
    mov rcx, 64
loop:
    ; ...
    dec rcx
    jnz loop
```

### Mistake 3: Signed vs unsigned shifts

```asm
; Wrong for unsigned - sign extends
mov rax, 0x8000000000000000
sar rax, 1              ; Arithmetic shift: 0xC000000000000000

; Right for unsigned
shr rax, 1              ; Logical shift: 0x4000000000000000
```

## Next Steps

Once you complete this assignment, move on to:
- [02-stack-frames](../02-stack-frames/) - Complex stack management

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Bit Twiddling Hacks](https://graphics.stanford.edu/~seander/bithacks.html)
