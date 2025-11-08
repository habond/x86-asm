# Assignment 3: String Comparison

Learn how to compare strings byte-by-byte and implement lexicographic ordering.

## Learning Objectives

- Compare strings character by character
- Understand lexicographic (dictionary) ordering
- Implement strcmp function
- Work with signed comparisons
- Handle string equality and inequality

## Background

In C, the `strcmp` function compares two strings lexicographically:
```c
int strcmp(const char *s1, const char *s2) {
    while (*s1 && *s2) {
        if (*s1 != *s2) {
            return (*s1 < *s2) ? -1 : 1;
        }
        s1++;
        s2++;
    }
    // Reached end of one or both strings
    if (*s1 == *s2) return 0;      // Both ended (equal)
    return (*s1 < *s2) ? -1 : 1;   // One ended before other
}
```

Return values:
- **-1** if s1 < s2 (s1 comes before s2 alphabetically)
- **0** if s1 == s2 (strings are identical)
- **1** if s1 > s2 (s1 comes after s2 alphabetically)

## The Task

Write a program that:
1. Defines two strings in the `.data` section
2. Implements a `strcmp` function that compares them byte-by-byte
3. Returns -1, 0, or 1 based on the comparison result

Examples:
- `strcmp("Hello", "Hello")` → 0 (equal)
- `strcmp("Apple", "Banana")` → -1 (Apple < Banana)
- `strcmp("Zebra", "Apple")` → 1 (Zebra > Apple)

## String Comparison Logic

### Lexicographic Ordering

Strings are compared character by character using ASCII values:

```
"Apple" vs "Banana"
  'A' (65) < 'B' (66)  →  return -1

"Hello" vs "Hello"
  All characters match, both end at same time  →  return 0

"abc" vs "ab"
  'a' == 'a', 'b' == 'b', 'c' vs '\0'
  'c' (99) > '\0' (0)  →  return 1
```

### ASCII Values (useful for comparison)

```
Character ranges:
'A' - 'Z':  65 - 90
'a' - 'z':  97 - 122
'0' - '9':  48 - 57

Examples:
'A' (65) < 'B' (66) < 'Z' (90)
'a' (97) < 'b' (98) < 'z' (122)
'A' (65) < 'a' (97)  (uppercase < lowercase)
```

## Comparison Algorithm

```
1. Load character from both strings
2. If characters are different:
   - Return -1 if s1[i] < s2[i]
   - Return 1 if s1[i] > s2[i]
3. If either character is null terminator:
   - Both null → strings equal, return 0
   - One null → shorter string is "less", return accordingly
4. Move to next character in both strings
5. Repeat from step 1
```

## Starter Code

```asm
section .data
    str1 db "Apple", 0
    str2 db "Banana", 0

section .text
global _start

; Function: strcmp
; Arguments: rdi = pointer to first string
;            rsi = pointer to second string
; Returns: rax = -1 (s1 < s2), 0 (s1 == s2), or 1 (s1 > s2)
strcmp:
    ; TODO: Initialize index or use pointers directly

loop_start:
    ; TODO: Load byte from both strings
    ; Hint: mov al, [rdi] and mov bl, [rsi]

    ; TODO: Compare the two bytes
    ; Hint: cmp al, bl

    ; TODO: If bytes are different, determine which is greater
    ; Hint: Use conditional jumps (jl, jg)

    ; TODO: Check if we've reached end of string (null terminator)
    ; Hint: Check if al is 0

    ; TODO: If both strings continue, move to next character
    ; Hint: inc rdi and inc rsi

    ; TODO: Jump back to loop_start

str1_less:
    ; TODO: Return -1 in rax

str1_greater:
    ; TODO: Return 1 in rax

strings_equal:
    ; TODO: Return 0 in rax

_start:
    ; TODO: Load addresses of both strings

    ; TODO: Call strcmp

    ; Convert result to positive exit code (0, 1, or 2)
    add rax, 1          ; -1→0, 0→1, 1→2
    mov rdi, rax
    mov rax, 60         ; sys_exit
    syscall
```

## Step by Step

### Step 1: Load characters from both strings
```asm
strcmp:
loop_start:
    mov al, [rdi]       ; Load byte from first string
    mov bl, [rsi]       ; Load byte from second string
```

**Note**: We use `al` and `bl` (8-bit registers) because strings are byte arrays.

### Step 2: Compare the characters
```asm
    cmp al, bl          ; Compare characters
    jl str1_less        ; If al < bl, first string is less
    jg str1_greater     ; If al > bl, first string is greater
```

### Step 3: Characters are equal, check for end
```asm
    ; Characters are equal here
    cmp al, 0           ; Is it null terminator?
    je strings_equal    ; If yes, both strings ended, they're equal
```

**Important**: Since `al == bl` at this point, if `al` is 0, then `bl` is also 0, so both strings ended simultaneously.

### Step 4: Continue to next character
```asm
    inc rdi             ; Move to next char in str1
    inc rsi             ; Move to next char in str2
    jmp loop_start      ; Check next pair of characters
```

### Step 5: Return appropriate values
```asm
str1_less:
    mov rax, -1         ; str1 < str2
    ret

str1_greater:
    mov rax, 1          ; str1 > str2
    ret

strings_equal:
    xor rax, rax        ; rax = 0 (strings equal)
    ret
```

## Building and Running

```bash
nasm -f elf64 strcmp.asm -o strcmp.o
ld -o strcmp strcmp.o
./strcmp
echo $?             # Should print 0 for "Apple" vs "Banana" (-1 + 1)
```

Or with Make:
```bash
make run
echo $?
```

## Expected Results

Test cases and their exit codes (remember: we add 1 to convert -1/0/1 to 0/1/2):

| str1 | str2 | strcmp result | exit code |
|------|------|---------------|-----------|
| "Apple" | "Banana" | -1 | 0 |
| "Hello" | "Hello" | 0 | 1 |
| "Zebra" | "Apple" | 1 | 2 |
| "abc" | "ab" | 1 | 2 |
| "ab" | "abc" | -1 | 0 |

## Testing Different String Pairs

### Test 1: Equal strings
```asm
str1 db "Hello", 0
str2 db "Hello", 0
; Result: 0 (equal), exit code: 1
```

### Test 2: First less than second
```asm
str1 db "Apple", 0
str2 db "Banana", 0
; Result: -1 (A < B), exit code: 0
```

### Test 3: First greater than second
```asm
str1 db "Zebra", 0
str2 db "Apple", 0
; Result: 1 (Z > A), exit code: 2
```

### Test 4: Prefix relationship
```asm
str1 db "test", 0
str2 db "testing", 0
; Result: -1 (shorter < longer when prefix), exit code: 0
```

### Test 5: Different lengths, not prefix
```asm
str1 db "cat", 0
str2 db "dog", 0
; Result: -1 (c < d), exit code: 0
```

## Common Mistakes

### Mistake 1: Not handling equal characters
```asm
cmp al, bl
jl str1_less
; Forgot to check jg!
; Falls through even when str1 > str2
```

**Fix**: Check both less and greater
```asm
cmp al, bl
jl str1_less
jg str1_greater
; Now only equal characters continue
```

### Mistake 2: Checking only one string for null
```asm
cmp al, 0           ; Only checks first string
je strings_equal    ; Wrong! Second string might continue
```

**Fix**: Since we only reach this point when `al == bl`, checking one is sufficient:
```asm
cmp al, 0           ; If al is 0, bl is also 0 (they're equal)
je strings_equal    ; Both strings ended
```

### Mistake 3: Not incrementing both pointers
```asm
inc rdi             ; Incremented first string
; Forgot to increment rsi!
jmp loop_start
```

**Fix**: Increment both
```asm
inc rdi
inc rsi
jmp loop_start
```

### Mistake 4: Wrong comparison direction
```asm
cmp al, bl
jl str1_greater     ; Wrong direction!
jg str1_less        ; Wrong direction!
```

**Fix**: Use correct labels
```asm
cmp al, bl
jl str1_less        ; If al < bl, str1 is less
jg str1_greater     ; If al > bl, str1 is greater
```

### Mistake 5: Using unsigned vs signed comparison
For ASCII characters, both work the same, but be aware:
```asm
cmp al, bl
jl ...              ; Signed less than
jb ...              ; Unsigned below (less than)
```

For standard ASCII strings, both `jl` and `jb` work identically.

## Alternative Implementation

### Using index instead of incrementing pointers:
```asm
strcmp:
    xor rcx, rcx        ; rcx = index = 0

loop_start:
    mov al, [rdi + rcx] ; Load str1[index]
    mov bl, [rsi + rcx] ; Load str2[index]

    cmp al, bl
    jl str1_less
    jg str1_greater

    cmp al, 0
    je strings_equal

    inc rcx             ; index++
    jmp loop_start

str1_less:
    mov rax, -1
    ret

str1_greater:
    mov rax, 1
    ret

strings_equal:
    xor rax, rax
    ret
```

This preserves the original pointers, which can be useful in some contexts.

## Debugging with GDB

```bash
nasm -f elf64 -g strcmp.asm -o strcmp.o
ld -o strcmp strcmp.o
gdb ./strcmp

(gdb) break strcmp
(gdb) run
(gdb) x/s $rdi              # View first string
(gdb) x/s $rsi              # View second string
(gdb) stepi                 # Step through comparison
(gdb) print (char)$al       # Check current characters
(gdb) print (char)$bl
(gdb) print $rax            # Check final result
```

Useful during loop:
```bash
# View both characters being compared
(gdb) printf "al='%c'(%d) bl='%c'(%d)\n", $al, $al, $bl, $bl

# View remaining strings
(gdb) x/s $rdi
(gdb) x/s $rsi
```

## Experiments

### 1. Case-Insensitive Comparison
Compare strings ignoring case differences:
```asm
; Function: strcasecmp
; Compares strings case-insensitively
strcasecmp:
    xor rcx, rcx

loop:
    mov al, [rdi + rcx]
    mov bl, [rsi + rcx]

    ; Convert both to lowercase
    call to_lower_al
    call to_lower_bl

    cmp al, bl
    jl str1_less
    jg str1_greater

    cmp al, 0
    je equal

    inc rcx
    jmp loop

to_lower_al:
    cmp al, 'A'
    jl done_al
    cmp al, 'Z'
    jg done_al
    add al, 32          ; Convert to lowercase
done_al:
    ret

to_lower_bl:
    cmp bl, 'A'
    jl done_bl
    cmp bl, 'Z'
    jg done_bl
    add bl, 32
done_bl:
    ret
```

### 2. String Starts With (Prefix Check)
Check if str1 starts with str2:
```asm
; Returns: 1 if str1 starts with str2, 0 otherwise
starts_with:
    xor rcx, rcx

loop:
    mov bl, [rsi + rcx]     ; Character from prefix
    cmp bl, 0               ; End of prefix?
    je match                ; Yes, we matched entire prefix

    mov al, [rdi + rcx]     ; Character from main string
    cmp al, bl              ; Do they match?
    jne no_match

    inc rcx
    jmp loop

match:
    mov rax, 1              ; True
    ret

no_match:
    xor rax, rax            ; False
    ret
```

### 3. Find First Difference Position
Return index of first differing character:
```asm
find_diff_pos:
    xor rcx, rcx

loop:
    mov al, [rdi + rcx]
    mov bl, [rsi + rcx]

    cmp al, bl
    jne found_diff

    cmp al, 0               ; Both ended?
    je no_diff

    inc rcx
    jmp loop

found_diff:
    mov rax, rcx            ; Return index
    ret

no_diff:
    mov rax, -1             ; Return -1 (no difference)
    ret
```

## Going Further

### Challenge 1: Implement strncmp
Compare only first N characters:
```asm
; Arguments: rdi = str1, rsi = str2, rdx = n
; Returns: -1, 0, or 1
strncmp:
    xor rcx, rcx

loop:
    cmp rcx, rdx            ; Compared n characters?
    je equal                ; Yes, consider equal

    mov al, [rdi + rcx]
    mov bl, [rsi + rcx]

    cmp al, bl
    jl str1_less
    jg str1_greater

    cmp al, 0
    je equal

    inc rcx
    jmp loop

str1_less:
    mov rax, -1
    ret

str1_greater:
    mov rax, 1
    ret

equal:
    xor rax, rax
    ret
```

### Challenge 2: Compare with Length Limit and Count
Return both comparison result and number of characters compared.

### Challenge 3: String Contains Substring
Implement a function to check if one string contains another as a substring.

### Challenge 4: Lexicographic String Array Sort
Given an array of string pointers, sort them lexicographically using strcmp.

## Real-World Applications

String comparison is used in:
- **Sorting**: Alphabetical ordering of data
- **Search**: Binary search in sorted string arrays
- **Authentication**: Password/username verification
- **Parsing**: Command-line argument processing
- **Data Structures**: Binary search trees, hash tables with string keys
- **File Systems**: Directory listings, file name matching

## Next Steps

Once you complete this assignment, move on to:
- [04-buffer-operations](../04-buffer-operations/) - Memory copying and manipulation

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Conditional Jumps](../../resources/instruction-reference.md#conditional-jumps)
- [ASCII Table](https://www.asciitable.com/)
