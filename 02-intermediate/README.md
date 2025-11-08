# 02-intermediate - Working with Data

Build on your foundation with practical data manipulation techniques.

## What You'll Learn

By the end of this section, you'll be able to:
- Work with strings and buffers
- Manipulate arrays and memory
- Compare and search data
- Parse command-line arguments
- Implement practical algorithms

## Prerequisites

Before starting:
1. ✅ Complete [01-basics](../01-basics/)
2. ✅ Understand registers, functions, and the stack
3. ✅ Comfortable with GDB debugging
4. ✅ Know how to read and write assembly code

Not done yet? Go back and complete the basics first!

## Assignments

Complete these in order:

### 1. [String Length](01-string-length/)
**Topics**: Memory addressing, byte operations, null terminators

Learn how to:
- Traverse memory byte by byte
- Find null terminators
- Calculate string length
- Work with pointers

**Time**: 1-2 hours

---

### 2. [Arrays](02-arrays/)
**Topics**: Array indexing, memory access patterns, element iteration

Learn how to:
- Define arrays in memory
- Access elements by index
- Iterate through arrays
- Calculate array bounds
- Find min/max values

**Time**: 1-2 hours

---

### 3. [String Compare](03-string-compare/)
**Topics**: String comparison, character-by-character analysis

Learn how to:
- Compare strings lexicographically
- Handle different string lengths
- Return comparison results
- Implement strcmp-like functions

**Time**: 1-2 hours

---

### 4. [Buffer Operations](04-buffer-operations/)
**Topics**: Memory copying, buffer manipulation, memcpy/memset

Learn how to:
- Copy memory regions
- Fill buffers with values
- Handle overlapping buffers
- Optimize memory operations

**Time**: 2-3 hours

---

### 5. [Command-Line Arguments](05-command-line-args/)
**Topics**: argc/argv, parsing arguments, environment variables

Learn how to:
- Access command-line arguments
- Parse argument count
- Iterate through argv
- Print arguments back to stdout

**Time**: 2-3 hours

---

## Learning Path

```
From 01-basics
    ↓
01-string-length (Memory and pointers)
    ↓
02-arrays (Indexed data access)
    ↓
03-string-compare (Data comparison)
    ↓
04-buffer-operations (Memory manipulation)
    ↓
05-command-line-args (Real-world programs)
    ↓
Ready for advanced topics!
```

## Key Concepts

### Memory Addressing

In x86-64, you access memory using square brackets:

```asm
mov al, [rsi]           ; Load byte from address in rsi
mov rax, [rbx+8]        ; Load qword from rbx + 8
mov byte [rdi], 0       ; Store byte to address in rdi
```

### Pointer Arithmetic

Incrementing pointers to traverse data:

```asm
mov rsi, string         ; rsi points to start of string
mov al, [rsi]           ; Load first byte
inc rsi                 ; Point to next byte
mov al, [rsi]           ; Load second byte
```

### Byte vs Word vs Dword vs Qword

Different data sizes:
- `byte` - 8 bits (1 byte)
- `word` - 16 bits (2 bytes)
- `dword` - 32 bits (4 bytes)
- `qword` - 64 bits (8 bytes)

```asm
mov al, [rsi]           ; Load 1 byte
mov ax, [rsi]           ; Load 2 bytes
mov eax, [rsi]          ; Load 4 bytes
mov rax, [rsi]          ; Load 8 bytes
```

### Register Sizes

Understanding register naming:

```
64-bit: rax, rbx, rcx, rdx, rsi, rdi, rbp, rsp, r8-r15
32-bit: eax, ebx, ecx, edx, esi, edi, ebp, esp, r8d-r15d
16-bit: ax,  bx,  cx,  dx,  si,  di,  bp,  sp,  r8w-r15w
8-bit:  al,  bl,  cl,  dl,  sil, dil, bpl, spl, r8b-r15b
8-bit high: ah, bh, ch, dh
```

## Common Patterns

### Pattern 1: String Traversal
```asm
mov rsi, string         ; Pointer to string
xor rcx, rcx            ; Counter = 0

loop:
    mov al, [rsi+rcx]   ; Load byte
    cmp al, 0           ; Check for null
    je done
    ; Process byte in al
    inc rcx             ; Next byte
    jmp loop

done:
```

### Pattern 2: Array Access
```asm
mov rsi, array          ; Pointer to array
mov rcx, 0              ; Index = 0

loop:
    cmp rcx, array_len
    jge done

    ; Access element: array[rcx]
    mov rax, [rsi + rcx*8]  ; For 8-byte elements

    ; Process element
    inc rcx
    jmp loop

done:
```

### Pattern 3: Memory Copy
```asm
mov rsi, source         ; Source pointer
mov rdi, dest           ; Destination pointer
mov rcx, count          ; Byte count

copy_loop:
    cmp rcx, 0
    je done

    mov al, [rsi]       ; Load from source
    mov [rdi], al       ; Store to dest
    inc rsi
    inc rdi
    dec rcx
    jmp copy_loop

done:
```

### Pattern 4: Find Character
```asm
mov rsi, string         ; String pointer
mov al, 'x'             ; Character to find

find_loop:
    mov bl, [rsi]       ; Load current character
    cmp bl, 0           ; End of string?
    je not_found
    cmp bl, al          ; Found it?
    je found
    inc rsi
    jmp find_loop

found:
    ; rsi points to the character

not_found:
    ; Character not found
```

## Debugging Tips

### 1. Examine Memory
```bash
(gdb) x/s $rsi          # View string at rsi
(gdb) x/10b $rsi        # View 10 bytes at rsi
(gdb) x/10w $rsi        # View 10 words at rsi
(gdb) x/10x $rsi        # View 10 hex values at rsi
```

### 2. Watch Memory Changes
```bash
(gdb) watch *0x12345678     # Break when memory changes
(gdb) watch *(char*)$rdi    # Watch byte at rdi
```

### 3. Print Strings and Arrays
```bash
(gdb) x/s $rsi              # Print string
(gdb) x/10dw array          # Print 10 decimal words
(gdb) print (char*)$rsi     # Print as C string
```

### 4. Examine Registers
```bash
(gdb) info registers        # All registers
(gdb) print $rax            # Specific register
(gdb) print/x $rax          # In hexadecimal
(gdb) print (char)$al       # As character
```

## Common Mistakes

### 1. Wrong Memory Access Size
```asm
; Wrong - loads 8 bytes when string has 1-byte chars
mov rax, [rsi]

; Right - load 1 byte for characters
mov al, [rsi]
```

### 2. Forgetting to Null-Terminate
```asm
section .data
    str db "Hello"      ; Dangerous! No null terminator

; Fix:
    str db "Hello", 0   ; Proper null-terminated string
```

### 3. Off-by-One in Array Access
```asm
mov rcx, array_len
loop:
    mov rax, [rsi+rcx*8]    ; Wrong! Starts beyond array
    dec rcx
    jnz loop

; Fix: Start at index 0
mov rcx, 0
loop:
    cmp rcx, array_len
    jge done
    mov rax, [rsi+rcx*8]    ; Correct
    inc rcx
    jmp loop
```

### 4. Not Preserving Registers
```asm
my_strlen:
    ; Uses rsi but doesn't preserve it
    mov rsi, rdi
    ; ... calculate length ...
    ret                      ; Caller's rsi is corrupted!

; Fix:
my_strlen:
    push rsi                 ; Save
    mov rsi, rdi
    ; ... calculate length ...
    pop rsi                  ; Restore
    ret
```

## Performance Tips

### Use String Instructions

x86-64 has optimized string instructions:

```asm
; MOVSB - Move string byte
rep movsb               ; Copy rcx bytes from rsi to rdi

; STOSB - Store string byte
rep stosb               ; Fill rcx bytes at rdi with al

; SCASB - Scan string byte
repne scasb             ; Find al in string at rdi (rcx bytes)

; CMPSB - Compare string byte
repe cmpsb              ; Compare rcx bytes at rsi and rdi
```

Example - Fast string length:
```asm
; Slow version (what you'll write first)
xor rcx, rcx
loop:
    cmp byte [rsi+rcx], 0
    je done
    inc rcx
    jmp loop
done:

; Fast version (using scasb)
mov rdi, string
mov rcx, -1             ; Max possible length
xor al, al              ; Search for null (0)
repne scasb             ; Scan until al found
not rcx                 ; Length = -(rcx+1)
dec rcx
```

## What You'll Know After Intermediate

After completing this section, you'll understand:
- ✅ How to manipulate memory directly
- ✅ How to work with strings and arrays
- ✅ How to implement common algorithms
- ✅ How to access program arguments
- ✅ How to optimize memory operations
- ✅ How to debug memory-related issues

You'll be ready to:
- Write practical command-line tools
- Implement data structure algorithms
- Work with buffers and I/O
- Parse and process text data

## Practice Suggestions

### Daily Practice (Recommended)
- **Day 1**: String length + experiments
- **Day 2**: Arrays + finding min/max
- **Day 3**: String compare
- **Day 4**: Buffer operations part 1
- **Day 5**: Buffer operations part 2
- **Day 6**: Command-line args
- **Day 7**: Review and challenges

### Challenge Ideas

1. **Palindrome Checker**: Check if a string reads the same forwards and backwards
2. **String Reversal**: Reverse a string in place
3. **Array Sorting**: Implement bubble sort or selection sort
4. **Word Counter**: Count words in a string
5. **String Search**: Find substring within a string (strstr)
6. **Array Sum**: Sum all elements in an integer array
7. **Case Conversion**: Convert string to uppercase/lowercase

## Getting Help

Stuck on an assignment?

1. **Re-read the README** - The solution is usually explained
2. **Check your pointer arithmetic** - Off-by-one errors are common
3. **Use GDB to examine memory** - See what's actually there
4. **Print intermediate values** - Add sys_write calls to debug
5. **Look at the solution** - But only after trying!

## Ready?

Great! Let's start with the first assignment:

### → [01-string-length](01-string-length/)

You've got this! 🚀
