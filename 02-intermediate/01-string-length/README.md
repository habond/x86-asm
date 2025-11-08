# Assignment 1: String Length

Learn how to traverse memory and calculate the length of a null-terminated string.

## Learning Objectives

- Access memory using pointers
- Understand byte-level operations
- Work with null-terminated strings
- Implement strlen function
- Use memory addressing modes

## Background

In C, strings are arrays of characters terminated by a null byte (0):
```c
char str[] = "Hello";  // Actually: ['H', 'e', 'l', 'l', 'o', '\0']
```

The `strlen` function counts characters until it finds the null terminator:
```c
size_t strlen(const char *str) {
    size_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}
```

## The Task

Write a program that:
1. Defines a string in the `.data` section
2. Implements a `strlen` function that calculates the string's length
3. Returns the length as the exit code

For the string "Hello, Assembly!" (16 characters), the program should exit with code 16.

## Memory Layout

A string in memory looks like this:

```
Address:    0x00  0x01  0x02  0x03  0x04  0x05
Content:    'H'   'e'   'l'   'l'   'o'   '\0'
Hex:        0x48  0x65  0x6C  0x6C  0x6F  0x00
```

## Memory Addressing Modes

### Direct Addressing
```asm
mov rsi, mystring       ; Load address of mystring into rsi
```

### Indirect Addressing
```asm
mov al, [rsi]           ; Load byte from address in rsi
```

### Indexed Addressing
```asm
mov al, [rsi+5]         ; Load byte from rsi + 5
mov al, [rsi+rcx]       ; Load byte from rsi + rcx
```

### Pointer Increment
```asm
inc rsi                 ; Move pointer to next byte
add rsi, 4              ; Move pointer forward 4 bytes
```

## Starter Code

```asm
section .data
    mystring db "Hello, Assembly!", 0    ; Null-terminated string

section .text
global _start

; Function: strlen
; Arguments: rdi = pointer to null-terminated string
; Returns: rax = length of string
strlen:
    ; TODO: Initialize counter to 0 (use rax)

loop_start:
    ; TODO: Load byte from string at current position
    ; Hint: Use [rdi] to load from address in rdi

    ; TODO: Check if byte is 0 (null terminator)
    ; Hint: cmp al, 0

    ; TODO: If zero, jump to done

    ; TODO: Increment counter (inc rax)

    ; TODO: Move to next character (inc rdi)

    ; TODO: Jump back to loop_start

done:
    ; TODO: Return (rax already contains length)

_start:
    ; TODO: Load address of mystring into rdi

    ; TODO: Call strlen

    ; Exit with result
    mov rdi, rax        ; Exit code = string length
    mov rax, 60         ; sys_exit
    syscall
```

## Step by Step

### Step 1: Initialize the counter
```asm
strlen:
    xor rax, rax        ; rax = 0 (length counter)
```

### Step 2: Load current byte
```asm
loop_start:
    mov al, [rdi]       ; Load byte at address in rdi
```

**Note**: We use `al` (8-bit) not `rax` because we're loading a single byte.

### Step 3: Check for null terminator
```asm
    cmp al, 0           ; Is this the null terminator?
    je done             ; If yes, we're done
```

### Step 4: Increment counter
```asm
    inc rax             ; length++
```

**Note**: Using `inc rax` preserves the upper bits of rax (only al was modified by the load).

### Step 5: Move to next character
```asm
    inc rdi             ; Move pointer to next byte
```

### Step 6: Repeat
```asm
    jmp loop_start      ; Check next character
```

### Step 7: Return
```asm
done:
    ret                 ; Return with length in rax
```

## Complete Solution Overview

The algorithm:
1. Set counter (rax) to 0
2. Load byte from current position
3. If byte is 0, return counter
4. Otherwise, increment counter and pointer
5. Repeat from step 2

## Building and Running

```bash
nasm -f elf64 strlen.asm -o strlen.o
ld -o strlen strlen.o
./strlen
echo $?             # Should print 16 for "Hello, Assembly!"
```

Or with Make:
```bash
make run
echo $?
```

## Expected Output

```bash
$ ./strlen
$ echo $?
16
```

## Testing Different Strings

Try changing the string to test your implementation:

**Test 1**: "Hello" → length 5
```asm
mystring db "Hello", 0
```

**Test 2**: Empty string → length 0
```asm
mystring db 0
```

**Test 3**: Single character → length 1
```asm
mystring db "X", 0
```

**Test 4**: Long string → length 26
```asm
mystring db "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
```

## Common Mistakes

### Mistake 1: Loading full register instead of byte
```asm
mov rax, [rdi]      ; Wrong! Loads 8 bytes
```

**Fix**: Use byte register
```asm
mov al, [rdi]       ; Correct! Loads 1 byte
```

### Mistake 2: Forgetting to increment pointer
```asm
loop_start:
    mov al, [rdi]
    cmp al, 0
    je done
    inc rax             ; Incremented counter
    ; Forgot to inc rdi! Infinite loop!
    jmp loop_start
```

**Fix**: Increment both counter and pointer
```asm
    inc rax
    inc rdi             ; Don't forget!
    jmp loop_start
```

### Mistake 3: Not handling empty string
```asm
strlen:
    xor rax, rax
    ; If string is empty (starts with null), should return 0
    ; Make sure to check for null before incrementing
```

The solution handles this correctly because it checks *before* incrementing.

### Mistake 4: Using wrong comparison
```asm
cmp rax, 0          ; Wrong! Comparing counter, not character
```

**Fix**: Compare the loaded byte
```asm
cmp al, 0           ; Correct! Comparing character
```

### Mistake 5: Overwriting counter with byte
```asm
mov rax, [rdi]      ; Wrong! Overwrites entire rax (our counter!)
```

**Fix**: Only load into al
```asm
mov al, [rdi]       ; al is the low byte of rax, doesn't affect upper bits
```

## Alternative Implementations

### Method 1: Using Index (instead of incrementing pointer)
```asm
strlen:
    xor rax, rax        ; rax = length (also used as index)

loop_start:
    mov bl, [rdi+rax]   ; Load byte at rdi + rax
    cmp bl, 0
    je done
    inc rax             ; Increment index/length
    jmp loop_start

done:
    ret
```

### Method 2: Using separate counter and pointer
```asm
strlen:
    xor rax, rax        ; rax = length
    mov rsi, rdi        ; rsi = pointer (preserve rdi)

loop_start:
    mov bl, [rsi]
    cmp bl, 0
    je done
    inc rax
    inc rsi
    jmp loop_start

done:
    ret
```

### Method 3: Using SCASB (advanced)
```asm
strlen:
    mov rdi, rdi        ; Ensure rdi is set
    mov rcx, -1         ; Maximum possible length
    xor al, al          ; Search for 0
    repne scasb         ; Repeat while not equal (scan bytes)
    not rcx             ; Flip bits
    dec rcx             ; rcx now contains length
    mov rax, rcx
    ret
```

## Debugging with GDB

```bash
nasm -f elf64 -g strlen.asm -o strlen.o
ld -o strlen strlen.o
gdb ./strlen

(gdb) break strlen
(gdb) run
(gdb) x/s $rdi              # View string
(gdb) print $rax            # Check length counter
(gdb) stepi                 # Step one instruction
(gdb) x/c $rdi              # View current character
(gdb) continue
```

Useful commands:
```bash
# View string as characters
(gdb) x/20c $rdi

# View string as hex bytes
(gdb) x/20bx $rdi

# View string as string
(gdb) x/s $rdi

# Print current character
(gdb) print (char)$al
```

## Experiments

### 1. Count until specific character
Find position of first 'A':
```asm
section .data
    str db "Hello Assembly", 0

find_char:
    xor rax, rax
    mov bl, 'A'         ; Character to find

loop_start:
    mov cl, [rdi+rax]
    cmp cl, 0           ; End of string?
    je not_found
    cmp cl, bl          ; Found target?
    je found
    inc rax
    jmp loop_start

found:
    ret                 ; rax = position

not_found:
    mov rax, -1         ; Return -1 if not found
    ret
```

### 2. Count specific character
Count how many 'l' characters:
```asm
count_char:
    xor rax, rax        ; count = 0
    xor rcx, rcx        ; index = 0
    mov bl, 'l'         ; character to count

loop_start:
    mov dl, [rdi+rcx]
    cmp dl, 0
    je done
    cmp dl, bl          ; Is it 'l'?
    jne skip
    inc rax             ; count++

skip:
    inc rcx
    jmp loop_start

done:
    ret
```

### 3. String length with limit
Stop counting at max length:
```asm
; rdi = string, rsi = max_length
strlen_bounded:
    xor rax, rax

loop_start:
    cmp rax, rsi        ; Reached max?
    jge done
    mov bl, [rdi+rax]
    cmp bl, 0
    je done
    inc rax
    jmp loop_start

done:
    ret
```

## Going Further

### Challenge 1: Count Words
Count spaces + 1 to get word count:
```asm
section .data
    str db "Hello World Assembly", 0

count_words:
    xor rax, rax        ; word_count = 0
    xor rcx, rcx        ; index = 0
    mov r8, 0           ; in_word flag

loop:
    mov bl, [rdi+rcx]
    cmp bl, 0
    je done

    ; Check if space
    cmp bl, ' '
    je space

    ; Non-space character
    cmp r8, 0           ; Already in word?
    jne continue
    inc rax             ; New word
    mov r8, 1           ; Now in word
    jmp continue

space:
    mov r8, 0           ; Not in word

continue:
    inc rcx
    jmp loop

done:
    ret
```

### Challenge 2: Validate String (only letters)
Check if string contains only letters:
```asm
is_alpha_string:
    xor rcx, rcx

loop:
    mov al, [rdi+rcx]
    cmp al, 0
    je valid

    ; Check if 'A' <= al <= 'Z'
    cmp al, 'A'
    jl invalid
    cmp al, 'Z'
    jle continue

    ; Check if 'a' <= al <= 'z'
    cmp al, 'a'
    jl invalid
    cmp al, 'z'
    jg invalid

continue:
    inc rcx
    jmp loop

valid:
    mov rax, 1          ; Return 1 (true)
    ret

invalid:
    xor rax, rax        ; Return 0 (false)
    ret
```

### Challenge 3: Reverse String (in-place)
```asm
reverse_string:
    ; Find length first
    push rdi
    call strlen         ; rax = length
    pop rdi

    cmp rax, 0
    je done

    ; Set up pointers
    mov rsi, rdi        ; Start pointer
    lea rcx, [rdi+rax-1] ; End pointer

reverse_loop:
    cmp rsi, rcx
    jge done

    ; Swap bytes
    mov al, [rsi]
    mov bl, [rcx]
    mov [rsi], bl
    mov [rcx], al

    inc rsi
    dec rcx
    jmp reverse_loop

done:
    ret
```

## Real-World Applications

String length is used in:
- **Buffer allocation**: Knowing how much memory to allocate
- **String validation**: Checking length constraints
- **String copying**: Knowing how many bytes to copy
- **Protocol parsing**: Reading length-prefixed strings
- **Text processing**: Any string manipulation

## Next Steps

Once you complete this assignment, move on to:
- [02-arrays](../02-arrays/) - Working with arrays and indexed data

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Memory Addressing](../../resources/instruction-reference.md#memory-addressing)
