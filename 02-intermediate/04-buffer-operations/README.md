# Assignment 4: Buffer Operations

Learn how to copy and manipulate blocks of memory using memcpy and memset.

## Learning Objectives

- Copy blocks of memory between buffers
- Implement memcpy function
- Understand pointer management
- Work with buffer boundaries
- Implement memset for buffer initialization
- Handle overlapping buffer cases

## Background

In C, `memcpy` and `memset` are fundamental functions for memory manipulation:

```c
// memcpy: Copy n bytes from source to destination
void *memcpy(void *dest, const void *src, size_t n) {
    char *d = dest;
    const char *s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

// memset: Fill n bytes with a value
void *memset(void *s, int c, size_t n) {
    unsigned char *p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}
```

## The Task

Write a program that:
1. Defines a source buffer with data
2. Implements a `memcpy` function that copies N bytes
3. Copies data from source to destination buffer
4. Verifies the copy by comparing a byte from the destination

The program should copy a string and return the first character of the copied string as the exit code.

## Memory Layout

When copying memory:

```
Before:
Source:      [H][e][l][l][o][0]
Dest:        [?][?][?][?][?][?]

After memcpy(dest, source, 6):
Source:      [H][e][l][l][o][0]  (unchanged)
Dest:        [H][e][l][l][o][0]  (copied)
```

## Function Calling Convention

For memcpy (System V AMD64 ABI):
- **rdi** = destination pointer
- **rsi** = source pointer
- **rdx** = number of bytes to copy
- **rax** = return value (destination pointer)

## Starter Code

```asm
section .data
    source db "Hello, Assembly!", 0

section .bss
    dest resb 20            ; Reserve 20 bytes for destination

section .text
global _start

; Function: memcpy
; Arguments: rdi = dest, rsi = source, rdx = count
; Returns: rax = dest pointer
memcpy:
    ; TODO: Save the original destination pointer for return value

    ; TODO: Initialize loop counter to 0

loop_start:
    ; TODO: Check if we've copied all bytes (counter >= count)

    ; TODO: Load byte from source[counter]

    ; TODO: Store byte to dest[counter]

    ; TODO: Increment counter

    ; TODO: Jump back to loop_start

done:
    ; TODO: Return original dest pointer in rax

_start:
    ; Set up arguments
    ; TODO: Load dest address into rdi

    ; TODO: Load source address into rsi

    ; TODO: Load byte count into rdx (17 bytes for "Hello, Assembly!")

    ; TODO: Call memcpy

    ; Verify copy - load first byte from dest
    mov rdi, dest
    movzx rax, byte [rdi]   ; Load first character ('H' = 72)

    ; Exit with first character as exit code
    mov rdi, rax
    mov rax, 60             ; sys_exit
    syscall
```

## Step by Step

### Step 1: Save destination pointer
```asm
memcpy:
    mov rax, rdi        ; Save dest pointer for return value
```

We need to return the original destination pointer, but we'll be modifying registers during the copy.

### Step 2: Set up loop counter
```asm
    xor rcx, rcx        ; rcx = 0 (byte counter)
```

### Step 3: Check loop condition
```asm
loop_start:
    cmp rcx, rdx        ; Have we copied rdx bytes?
    jge done            ; If yes, we're done
```

### Step 4: Copy one byte
```asm
    mov r8b, [rsi + rcx]    ; Load byte from source[rcx]
    mov [rdi + rcx], r8b    ; Store byte to dest[rcx]
```

**Note**: We use r8b (8-bit register) because we're copying one byte at a time.

### Step 5: Continue loop
```asm
    inc rcx             ; Increment counter
    jmp loop_start
```

### Step 6: Return
```asm
done:
    ret                 ; Return dest pointer in rax
```

## Alternative Implementation: Pointer Increment

Instead of using an index, you can increment pointers:

```asm
memcpy:
    mov rax, rdi        ; Save original dest
    xor rcx, rcx        ; Counter

loop_start:
    cmp rcx, rdx
    jge done

    mov r8b, [rsi]      ; Load from source
    mov [rdi], r8b      ; Store to dest

    inc rsi             ; Advance source pointer
    inc rdi             ; Advance dest pointer
    inc rcx             ; Increment counter
    jmp loop_start

done:
    ret
```

## Building and Running

```bash
nasm -f elf64 memcpy.asm -o memcpy.o
ld -o memcpy memcpy.o
./memcpy
echo $?             # Should print 72 (ASCII 'H')
```

Or with Make:
```bash
make run
echo $?
```

## Expected Output

```bash
$ ./memcpy
$ echo $?
72
```

This is the ASCII value of 'H', the first character of "Hello, Assembly!".

## Common Mistakes

### Mistake 1: Not saving destination pointer
```asm
memcpy:
    xor rcx, rcx        ; Forgot to save rdi!
    ; ... modify rdi ...
    ret                 ; Returns wrong value
```

**Fix**: Save it first
```asm
memcpy:
    mov rax, rdi        ; Save for return
```

### Mistake 2: Wrong register size
```asm
mov r8, [rsi + rcx]     ; Wrong! Loads 8 bytes
```

**Fix**: Use byte register
```asm
mov r8b, [rsi + rcx]    ; Correct! Loads 1 byte
```

### Mistake 3: Forgetting to increment counter
```asm
loop_start:
    mov r8b, [rsi + rcx]
    mov [rdi + rcx], r8b
    jmp loop_start      ; Infinite loop! rcx never changes
```

**Fix**: Increment the counter
```asm
    inc rcx
    jmp loop_start
```

### Mistake 4: Off-by-one error
```asm
cmp rcx, rdx
jg done                 ; Wrong! Copies rdx+1 bytes
```

**Fix**: Use >= comparison
```asm
cmp rcx, rdx
jge done                ; Correct! Stops when rcx == rdx
```

### Mistake 5: Overlapping buffers (forward copy)
```asm
; If source and dest overlap and dest > source:
; Source: [1][2][3][4][5]
; Dest:       [?][?][?][?][?]
; Forward copy will overwrite source data before reading it!
```

For overlapping buffers, you need to copy backwards (covered in Going Further).

### Mistake 6: Not handling zero count
```asm
; What if rdx = 0?
; The loop should handle this naturally:
cmp rcx, rdx        ; 0 >= 0 is true
jge done            ; Exits immediately - correct behavior
```

## Memory Regions

### .data Section
Contains initialized data:
```asm
section .data
    message db "Hello", 0
    numbers dq 1, 2, 3, 4, 5
```

### .bss Section
Contains uninitialized data (more efficient):
```asm
section .bss
    buffer resb 100     ; Reserve 100 bytes
    array resq 50       ; Reserve 50 qwords (400 bytes)
```

## Experiments

### 1. Implement memset
Fill a buffer with a specific byte value:

```asm
; Function: memset
; Arguments: rdi = buffer, rsi = byte value, rdx = count
; Returns: rax = buffer pointer
memset:
    mov rax, rdi        ; Save buffer pointer
    xor rcx, rcx

loop_start:
    cmp rcx, rdx
    jge done
    mov [rdi + rcx], sil    ; sil is low byte of rsi
    inc rcx
    jmp loop_start

done:
    ret

; Usage:
section .bss
    buffer resb 10

section .text
_start:
    mov rdi, buffer
    mov rsi, 'X'        ; Fill with 'X'
    mov rdx, 10         ; 10 bytes
    call memset
    ; buffer now contains "XXXXXXXXXX"
```

### 2. Copy in reverse order
Useful for overlapping buffers where dest > source:

```asm
; Copy from end to beginning
memcpy_reverse:
    mov rax, rdi            ; Save dest

    ; Start from last byte
    mov rcx, rdx
    dec rcx                 ; rcx = count - 1

loop_start:
    cmp rcx, 0
    jl done

    mov r8b, [rsi + rcx]
    mov [rdi + rcx], r8b

    dec rcx
    jmp loop_start

done:
    ret
```

### 3. Copy only non-zero bytes
```asm
memcpy_nonzero:
    mov rax, rdi
    xor rcx, rcx

loop_start:
    cmp rcx, rdx
    jge done

    mov r8b, [rsi + rcx]
    cmp r8b, 0              ; Skip zeros
    je skip
    mov [rdi + rcx], r8b

skip:
    inc rcx
    jmp loop_start

done:
    ret
```

### 4. Count differences between buffers
Compare two buffers:

```asm
; rdi = buffer1, rsi = buffer2, rdx = count
; Returns: rax = number of different bytes
memcmp_count:
    xor rax, rax        ; difference count = 0
    xor rcx, rcx

loop:
    cmp rcx, rdx
    jge done

    mov r8b, [rdi + rcx]
    mov r9b, [rsi + rcx]
    cmp r8b, r9b
    je same
    inc rax             ; Different, increment count

same:
    inc rcx
    jmp loop

done:
    ret
```

## Going Further

### Challenge 1: Optimized memcpy using movsb
The x86-64 architecture has a special instruction for memory copying:

```asm
memcpy_optimized:
    mov rax, rdi        ; Save dest
    mov rcx, rdx        ; Count in rcx for rep prefix

    ; rep movsb: Repeat movsb (move string byte) rcx times
    ; Automatically increments rsi and rdi
    ; Automatically decrements rcx
    rep movsb

    ret
```

**Note**: `movsb` copies from [rsi] to [rdi], then increments both. The `rep` prefix repeats this rcx times.

### Challenge 2: Word-aligned copy
Copy by qwords (8 bytes) when possible, then copy remaining bytes:

```asm
memcpy_fast:
    mov rax, rdi        ; Save dest
    mov rcx, rdx        ; Total bytes

    ; Copy 8 bytes at a time
    shr rdx, 3          ; rdx = count / 8 (number of qwords)
    xor r8, r8

qword_loop:
    cmp r8, rdx
    jge remaining_bytes

    mov r9, [rsi + r8*8]
    mov [rdi + r8*8], r9

    inc r8
    jmp qword_loop

remaining_bytes:
    ; Calculate remaining bytes
    mov r8, rdx
    shl r8, 3           ; r8 = (count / 8) * 8
    mov r9, r8          ; Start index for byte copy

byte_loop:
    cmp r9, rcx         ; rcx still has total count
    jge done

    mov r10b, [rsi + r9]
    mov [rdi + r9], r10b

    inc r9
    jmp byte_loop

done:
    ret
```

### Challenge 3: Detect overlapping buffers
Determine if buffers overlap and choose copy direction:

```asm
memcpy_safe:
    mov rax, rdi        ; Save dest

    ; Check if dest > source AND dest < source + count
    cmp rdi, rsi
    jle forward_copy    ; dest <= source, safe to copy forward

    ; Check if dest >= source + count
    lea r8, [rsi + rdx]
    cmp rdi, r8
    jge forward_copy    ; dest >= source + count, safe to copy forward

    ; Overlapping! Copy backwards
    jmp copy_backward

forward_copy:
    ; Normal forward copy
    xor rcx, rcx
loop1:
    cmp rcx, rdx
    jge done
    mov r9b, [rsi + rcx]
    mov [rdi + rcx], r9b
    inc rcx
    jmp loop1

copy_backward:
    ; Copy from end to beginning
    mov rcx, rdx
    dec rcx
loop2:
    cmp rcx, 0
    jl done
    mov r9b, [rsi + rcx]
    mov [rdi + rcx], r9b
    dec rcx
    jmp loop2

done:
    ret
```

### Challenge 4: memcpy with bounds checking
Add safety checks:

```asm
; rdi = dest, rsi = source, rdx = count
; r8 = dest_size, r9 = source_size
; Returns: rax = dest on success, 0 on error
memcpy_checked:
    ; Check if count > dest_size
    cmp rdx, r8
    jg error

    ; Check if count > source_size
    cmp rdx, r9
    jg error

    ; Proceed with copy
    mov rax, rdi
    xor rcx, rcx

loop:
    cmp rcx, rdx
    jge done
    mov r10b, [rsi + rcx]
    mov [rdi + rcx], r10b
    inc rcx
    jmp loop

done:
    ret

error:
    xor rax, rax        ; Return NULL on error
    ret
```

### Challenge 5: Case-converting copy
Copy while converting to uppercase:

```asm
memcpy_uppercase:
    mov rax, rdi
    xor rcx, rcx

loop:
    cmp rcx, rdx
    jge done

    mov r8b, [rsi + rcx]

    ; Check if lowercase letter (a-z)
    cmp r8b, 'a'
    jl store
    cmp r8b, 'z'
    jg store

    ; Convert to uppercase (subtract 32)
    sub r8b, 32

store:
    mov [rdi + rcx], r8b
    inc rcx
    jmp loop

done:
    ret
```

## Real-World Applications

Buffer operations are fundamental to:

- **String manipulation**: Copying, concatenating, transforming strings
- **Memory management**: Moving data between buffers
- **I/O operations**: Reading/writing files and network data
- **Data structures**: Implementing arrays, queues, rings buffers
- **Image processing**: Copying pixel data, transforming images
- **Networking**: Packet processing, protocol implementation
- **Compression**: Moving data during compression/decompression

## Performance Considerations

### 1. Alignment
Aligned memory accesses are faster:
```
Aligned (fast):    Address 0x1000, 0x1008, 0x1010
Unaligned (slow):  Address 0x1001, 0x1009, 0x1011
```

### 2. Cache Lines
Modern CPUs load 64-byte cache lines. Copying in cache-line-sized chunks can be faster.

### 3. SIMD Instructions
For large buffers, SSE/AVX instructions can copy 16/32 bytes at once (advanced topic).

### 4. rep movsb
Modern CPUs optimize `rep movsb` to use wide loads/stores automatically.

## Debugging Tips

```bash
# Compile with debug symbols
nasm -f elf64 -g memcpy.asm -o memcpy.o
ld -o memcpy memcpy.o

# Debug with GDB
gdb ./memcpy

# Useful GDB commands:
(gdb) break memcpy
(gdb) run
(gdb) x/s $rsi          # View source string
(gdb) x/20bx $rdi       # View dest as hex bytes
(gdb) stepi             # Step one instruction
(gdb) info registers    # Show all registers
(gdb) x/s $rdi          # View dest after copy
```

## Next Steps

Once you complete this assignment, explore:
- Memory alignment and performance
- SIMD instructions for bulk operations
- Advanced string manipulation
- Custom memory allocators

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Memory Addressing](../../resources/instruction-reference.md#memory-addressing)
- [String Instructions](../../resources/instruction-reference.md#string-instructions)
