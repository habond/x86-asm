# Assignment 2: Arrays

Learn how to work with arrays, access elements by index, and find values.

## Learning Objectives

- Define arrays in memory
- Access elements by index
- Iterate through arrays
- Find minimum and maximum values
- Understand array bounds and scaling

## Background

Arrays are contiguous blocks of memory containing elements of the same type:

```c
int numbers[] = {10, 25, 3, 42, 17};
// Access: numbers[0] = 10, numbers[1] = 25, etc.

// Find max
int max = numbers[0];
for (int i = 1; i < 5; i++) {
    if (numbers[i] > max) {
        max = numbers[i];
    }
}
```

## The Task

Write a program that:
1. Defines an array of integers
2. Implements a function to find the maximum value
3. Returns the maximum as the exit code

For the array `[10, 25, 3, 42, 17]`, the program should exit with code 42.

## Array Memory Layout

Arrays are stored sequentially:

```
For byte array [10, 20, 30]:
Address:    0x00  0x01  0x02
Value:      10    20    30

For dword array [10, 20, 30]:
Address:    0x00  0x04  0x08
Value:      10    20    30
```

## Array Indexing

### Formula
```
address = base_address + (index × element_size)
```

### Examples
```asm
; Byte array (1 byte per element)
mov al, [rsi + rcx]         ; array[rcx]

; Word array (2 bytes per element)
mov ax, [rsi + rcx*2]       ; array[rcx]

; Dword array (4 bytes per element)
mov eax, [rsi + rcx*4]      ; array[rcx]

; Qword array (8 bytes per element)
mov rax, [rsi + rcx*8]      ; array[rcx]
```

## Starter Code

```asm
section .data
    ; Array of 5 quad-words (8 bytes each)
    array dq 10, 25, 3, 42, 17
    array_len equ 5

section .text
global _start

; Function: find_max
; Arguments: rdi = pointer to array, rsi = array length
; Returns: rax = maximum value
find_max:
    ; TODO: Load first element as initial max

    ; TODO: Initialize loop counter to 1 (we already have first element)

loop_start:
    ; TODO: Check if counter >= array length

    ; TODO: Load current element (array[counter])
    ; Hint: Use [rdi + rcx*8] for qword array

    ; TODO: Compare with current max

    ; TODO: If current element > max, update max

    ; TODO: Increment counter

    ; TODO: Jump back to loop_start

done:
    ; TODO: Return max in rax

_start:
    ; TODO: Load array address into rdi

    ; TODO: Load array length into rsi

    ; TODO: Call find_max

    ; Exit with max value
    mov rdi, rax        ; Exit code = max value
    mov rax, 60         ; sys_exit
    syscall
```

## Step by Step

### Step 1: Initialize with first element
```asm
find_max:
    mov rax, [rdi]      ; rax = array[0] (initial max)
    mov rcx, 1          ; rcx = 1 (start from second element)
```

### Step 2: Loop through remaining elements
```asm
loop_start:
    cmp rcx, rsi        ; Is counter >= length?
    jge done            ; If yes, we're done
```

### Step 3: Load current element
```asm
    mov rbx, [rdi + rcx*8]  ; rbx = array[rcx]
```

**Note**: We multiply by 8 because each qword is 8 bytes.

### Step 4: Compare and update max
```asm
    cmp rbx, rax        ; Is array[rcx] > max?
    jle skip            ; If not, skip update
    mov rax, rbx        ; Update max

skip:
```

### Step 5: Continue loop
```asm
    inc rcx             ; counter++
    jmp loop_start

done:
    ret                 ; Return max in rax
```

## Building and Running

```bash
nasm -f elf64 array.asm -o array.o
ld -o array array.o
./array
echo $?             # Should print 42
```

## Common Mistakes

### Mistake 1: Wrong scaling factor
```asm
mov rax, [rdi + rcx]    ; Wrong! Treats as byte array
```

**Fix**: Scale by element size
```asm
mov rax, [rdi + rcx*8]  ; Correct for qword array
```

### Mistake 2: Starting at wrong index
```asm
mov rcx, 0              ; Starting at 0
mov rax, 0              ; Max initialized to 0, not array[0]
```

**Fix**: Initialize max from first element
```asm
mov rax, [rdi]          ; Max = array[0]
mov rcx, 1              ; Start from index 1
```

### Mistake 3: Off-by-one in bounds check
```asm
cmp rcx, rsi
jg done                 ; Wrong! Skips last element
```

**Fix**: Use correct comparison
```asm
cmp rcx, rsi
jge done                ; Correct! Stops when rcx >= length
```

## Data Type Sizes

```asm
section .data
    byte_array   db 10, 20, 30        ; 1 byte each
    word_array   dw 100, 200, 300     ; 2 bytes each
    dword_array  dd 1000, 2000, 3000  ; 4 bytes each
    qword_array  dq 10000, 20000      ; 8 bytes each

; Access patterns:
mov al,  [byte_array + rcx]       ; No scaling (×1)
mov ax,  [word_array + rcx*2]     ; ×2
mov eax, [dword_array + rcx*4]    ; ×4
mov rax, [qword_array + rcx*8]    ; ×8
```

## Experiments

### 1. Find Minimum
```asm
find_min:
    mov rax, [rdi]      ; min = array[0]
    mov rcx, 1

loop:
    cmp rcx, rsi
    jge done
    mov rbx, [rdi + rcx*8]
    cmp rbx, rax        ; Is array[rcx] < min?
    jge skip
    mov rax, rbx        ; Update min

skip:
    inc rcx
    jmp loop

done:
    ret
```

### 2. Sum Array
```asm
array_sum:
    xor rax, rax        ; sum = 0
    xor rcx, rcx        ; index = 0

loop:
    cmp rcx, rsi
    jge done
    add rax, [rdi + rcx*8]  ; sum += array[rcx]
    inc rcx
    jmp loop

done:
    ret
```

### 3. Count Elements Greater Than Value
```asm
; rdi = array, rsi = length, rdx = threshold
count_greater:
    xor rax, rax        ; count = 0
    xor rcx, rcx

loop:
    cmp rcx, rsi
    jge done
    mov rbx, [rdi + rcx*8]
    cmp rbx, rdx        ; Is element > threshold?
    jle skip
    inc rax             ; count++

skip:
    inc rcx
    jmp loop

done:
    ret
```

### 4. Find Element Index
```asm
; rdi = array, rsi = length, rdx = value to find
; Returns: rax = index or -1 if not found
find_index:
    xor rcx, rcx

loop:
    cmp rcx, rsi
    jge not_found
    cmp [rdi + rcx*8], rdx
    je found
    inc rcx
    jmp loop

found:
    mov rax, rcx        ; Return index
    ret

not_found:
    mov rax, -1         ; Return -1
    ret
```

## Going Further

### Challenge 1: Bubble Sort
```asm
bubble_sort:
    ; rdi = array, rsi = length
    push rbx
    push r12
    push r13

    mov r12, rsi        ; r12 = n

outer_loop:
    dec r12             ; n--
    cmp r12, 0
    jle done

    xor rcx, rcx        ; i = 0

inner_loop:
    cmp rcx, r12
    jge outer_loop

    ; Compare array[i] and array[i+1]
    mov rax, [rdi + rcx*8]
    mov rbx, [rdi + rcx*8 + 8]
    cmp rax, rbx
    jle no_swap

    ; Swap
    mov [rdi + rcx*8], rbx
    mov [rdi + rcx*8 + 8], rax

no_swap:
    inc rcx
    jmp inner_loop

done:
    pop r13
    pop r12
    pop rbx
    ret
```

### Challenge 2: Linear Search
Return index of first occurrence of value.

### Challenge 3: Array Reversal
Reverse array in-place.

### Challenge 4: Calculate Average
Sum all elements and divide by count.

## Next Steps

Once you complete this assignment, move on to:
- [03-string-compare](../03-string-compare/) - Comparing strings

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Memory Addressing](../../resources/instruction-reference.md#memory-addressing)
