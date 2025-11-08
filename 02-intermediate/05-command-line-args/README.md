# Assignment 5: Command-Line Arguments

Learn how to access and process command-line arguments passed to your program.

## Learning Objectives

- Access argc (argument count) from the stack
- Access argv (argument vector) from the stack
- Understand the stack layout at program start
- Iterate through the argv array
- Print strings with sys_write
- Work with null-terminated string arrays

## Background

When a program starts, the operating system sets up the stack with command-line arguments:

```c
int main(int argc, char **argv) {
    // argc = number of arguments (including program name)
    // argv = array of pointers to argument strings
    // argv[argc] = NULL (end marker)

    for (int i = 0; i < argc; i++) {
        printf("%s\n", argv[i]);
    }
    return argc;
}
```

In assembly, instead of receiving these as parameters, they're placed on the stack before your program starts.

## The Task

Write a program that:
1. Reads argc from the stack
2. Reads argv from the stack
3. Prints each argument on its own line
4. Exits with argc as the exit code

For example, running:
```bash
./args hello world test
```

Should print:
```
./args
hello
world
test
```

And exit with code 4 (4 arguments total, including the program name).

## Stack Layout at Program Start

When your program begins, the stack looks like this:

```
Higher addresses
+------------------+
| envp[n] = NULL   |  Environment variables end
+------------------+
| envp[n-1]        |
| ...              |
| envp[0]          |
+------------------+
| argv[argc] = NULL|  Arguments end (NULL terminator)
+------------------+
| argv[argc-1]     |  Last argument (pointer to string)
+------------------+
| ...              |
| argv[1]          |  First argument after program name
+------------------+
| argv[0]          |  Program name (pointer to string)
+------------------+
| argc             |  <-- [rsp] at _start (argument count)
+------------------+
Lower addresses
```

**Key points**:
- `argc` is at `[rsp]` (8 bytes, qword)
- `argv[0]` is at `[rsp+8]` (pointer to program name string)
- `argv[1]` is at `[rsp+16]` (pointer to first argument)
- `argv[i]` is at `[rsp+8+i*8]` (each pointer is 8 bytes)
- `argv[argc]` is NULL (marks end of array)

Each `argv[i]` points to a null-terminated string stored elsewhere in memory.

## Starter Code

The file `args.asm` contains a template with TODOs:

```asm
section .data
    newline db 10                  ; Newline character

section .text
global _start

_start:
    ; TODO: Load argc from stack
    ; Hint: argc is at [rsp]

    ; TODO: Calculate address of argv (argv is at rsp+8)

    ; TODO: Initialize loop counter to 0

print_loop:
    ; TODO: Check if counter >= argc
    ; If yes, jump to exit

    ; TODO: Load argv[counter] (pointer to string)
    ; Hint: Each pointer is 8 bytes, so argv[i] is at [argv_base + i*8]

    ; TODO: Calculate length of current argument string
    ; Hint: Call strlen or inline the string length calculation

    ; TODO: Print the argument with sys_write

    ; TODO: Print newline

    ; TODO: Increment counter

    ; TODO: Jump back to print_loop

exit:
    ; TODO: Exit with argc as exit code
```

## Step by Step Guide

### Step 1: Read argc from the stack

```asm
_start:
    mov rcx, [rsp]          ; rcx = argc (number of arguments)
```

**Important**: Don't use `pop` because we need to keep the stack intact to access argv.

### Step 2: Calculate argv base address

```asm
    lea rsi, [rsp+8]        ; rsi = address of argv[0]
```

`lea` (Load Effective Address) calculates the address without dereferencing.

### Step 3: Set up loop

```asm
    xor r12, r12            ; r12 = 0 (loop counter)
    mov r13, rcx            ; r13 = argc (save for later)
```

We use `r12` and `r13` because they're callee-saved registers.

### Step 4: Load pointer to current argument

```asm
print_loop:
    cmp r12, r13            ; Is counter >= argc?
    jge exit                ; If yes, we're done

    mov rdi, [rsi + r12*8]  ; rdi = argv[counter] (pointer to string)
```

Each pointer in argv is 8 bytes, so we multiply the index by 8.

### Step 5: Calculate string length

We need to know how many bytes to write. We'll implement a simple strlen:

```asm
    ; Calculate length of string in rdi
    xor rdx, rdx            ; rdx = 0 (length counter)

strlen_loop:
    cmp byte [rdi + rdx], 0 ; Is current byte null?
    je strlen_done          ; If yes, we have the length
    inc rdx                 ; length++
    jmp strlen_loop

strlen_done:
    ; rdx now contains the length
```

### Step 6: Print the argument

```asm
    ; Print string
    push rdi                ; Save string pointer
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    pop rsi                 ; rsi = string pointer
    ; rdx already has length
    syscall
```

**Note**: We need to juggle registers because sys_write needs the file descriptor in `rdi`, but our string pointer is also in `rdi`.

### Step 7: Print newline

```asm
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, newline        ; pointer to newline
    mov rdx, 1              ; length = 1
    syscall
```

### Step 8: Continue loop

```asm
    inc r12                 ; counter++
    jmp print_loop
```

### Step 9: Exit with argc

```asm
exit:
    mov rdi, r13            ; exit code = argc
    mov rax, 60             ; sys_exit
    syscall
```

## Complete Solution Overview

The algorithm:
1. Load argc from `[rsp]`
2. Calculate argv base address as `rsp+8`
3. For each argument (i from 0 to argc-1):
   - Load argv[i] (pointer at `[rsp+8+i*8]`)
   - Calculate string length
   - Print string
   - Print newline
4. Exit with argc as status

## Building and Running

```bash
nasm -f elf64 args.asm -o args.o
ld -o args args.o
./args hello world test
echo $?             # Should print 4
```

Or with Make:
```bash
make run            # Runs with example arguments
echo $?
```

## Expected Output

```bash
$ ./args hello world test
./args
hello
world
test
$ echo $?
4
```

## Testing Different Arguments

Try various combinations:

**Test 1**: No arguments
```bash
$ ./args
./args
$ echo $?
1
```

**Test 2**: Single argument
```bash
$ ./args testing
./args
testing
$ echo $?
2
```

**Test 3**: Many arguments
```bash
$ ./args one two three four five
./args
one
two
three
four
five
$ echo $?
6
```

**Test 4**: Arguments with spaces (quoted)
```bash
$ ./args "hello world" test
./args
hello world
test
$ echo $?
3
```

## Common Mistakes

### Mistake 1: Using pop to access argc

```asm
pop rcx             ; Wrong! This modifies the stack
```

**Fix**: Use direct memory access
```asm
mov rcx, [rsp]      ; Correct! Reads without modifying stack
```

### Mistake 2: Wrong argv offset calculation

```asm
mov rdi, [rsp + r12]    ; Wrong! Not scaling by 8
```

**Fix**: Scale by pointer size (8 bytes)
```asm
mov rdi, [rsi + r12*8]  ; Correct! Each pointer is 8 bytes
```

### Mistake 3: Forgetting argc includes program name

argc always includes the program name as argv[0]. So with no arguments, argc = 1, not 0.

### Mistake 4: Not preserving registers across syscalls

```asm
; r12 contains loop counter
syscall                 ; sys_write might clobber registers!
inc r12                 ; r12 might have changed!
```

**Fix**: Use callee-saved registers (r12-r15, rbx, rbp) for values that must survive syscalls.

### Mistake 5: Reading past the end of argv

```asm
cmp r12, r13
jg exit                 ; Wrong! Allows reading argv[argc]
```

**Fix**: Use >= comparison
```asm
cmp r12, r13
jge exit                ; Correct! Stops at argc
```

### Mistake 6: Overwriting needed values

```asm
mov rdi, [rsi + r12*8]  ; rdi = string pointer
mov rax, 1              ; sys_write
mov rdi, 1              ; Oops! Lost string pointer
mov rsi, rdi            ; Now rsi = 1, not the string!
```

**Fix**: Save values before overwriting
```asm
mov rdi, [rsi + r12*8]  ; rdi = string pointer
push rdi                ; Save it
mov rax, 1
mov rdi, 1
pop rsi                 ; Restore to correct register
syscall
```

## Alternative Implementations

### Method 1: Using a helper function for strlen

```asm
; Function: strlen
; Input: rdi = pointer to string
; Output: rax = length
strlen:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

; Then in main:
print_loop:
    mov rdi, [rsi + r12*8]
    call strlen             ; rax = length
    mov rdx, rax            ; rdx = length for sys_write
    ; ... print
```

### Method 2: Checking for NULL instead of counting

```asm
_start:
    lea rsi, [rsp+8]        ; rsi = argv base

print_loop:
    mov rdi, [rsi]          ; rdi = current argv entry
    cmp rdi, 0              ; Is it NULL?
    je exit                 ; If yes, done

    ; Calculate length and print
    ; ...

    add rsi, 8              ; Move to next argv entry
    jmp print_loop
```

### Method 3: Using SCASB for length (advanced)

```asm
    mov rdi, [rsi + r12*8]  ; rdi = string pointer
    push rdi                ; Save pointer
    mov rcx, -1             ; Maximum count
    xor al, al              ; Search for 0
    repne scasb             ; Scan for null
    not rcx                 ; rcx = -(remaining+1)
    dec rcx                 ; rcx = length
    mov rdx, rcx
    pop rsi                 ; rsi = string pointer
    ; ... print
```

## Debugging with GDB

```bash
nasm -f elf64 -g args.asm -o args.o
ld -o args args.o
gdb --args ./args hello world

(gdb) break _start
(gdb) run
(gdb) x/8gx $rsp        # View stack (8 quadwords in hex)
(gdb) x/s *($rsp+8)     # View argv[0] as string
(gdb) x/s *($rsp+16)    # View argv[1] as string
(gdb) print $rcx        # Check argc value
```

Useful commands:
```bash
# View entire argv array
(gdb) x/10gx $rsp+8

# View string at pointer
(gdb) x/s $rdi

# View argc
(gdb) print *(long*)$rsp
```

## Experiments

### 1. Count arguments only

Simplify to just count arguments without printing:

```asm
_start:
    mov rax, [rsp]          ; rax = argc
    mov rdi, rax            ; exit code = argc
    mov rax, 60             ; sys_exit
    syscall
```

### 2. Find specific argument

Search for an argument containing a specific character:

```asm
find_arg_with_char:
    ; rsi = argv base, r13 = argc, bl = character to find
    xor r12, r12            ; index = 0

.outer:
    cmp r12, r13
    jge .not_found

    mov rdi, [rsi + r12*8]  ; rdi = argv[i]
    xor rcx, rcx            ; char index = 0

.inner:
    mov al, [rdi + rcx]
    cmp al, 0               ; End of string?
    je .next_arg
    cmp al, bl              ; Found target char?
    je .found
    inc rcx
    jmp .inner

.next_arg:
    inc r12
    jmp .outer

.found:
    ; r12 contains the argument index
    ret

.not_found:
    mov r12, -1
    ret
```

### 3. Parse flags (arguments starting with -)

```asm
count_flags:
    ; rsi = argv base, r13 = argc
    xor rax, rax            ; flag_count = 0
    xor r12, r12            ; index = 0

.loop:
    cmp r12, r13
    jge .done

    mov rdi, [rsi + r12*8]  ; rdi = argv[i]
    cmp byte [rdi], '-'     ; Does it start with '-'?
    jne .skip
    inc rax                 ; flag_count++

.skip:
    inc r12
    jmp .loop

.done:
    ; rax contains number of flags
    ret
```

### 4. Print arguments in reverse

```asm
print_reverse:
    mov r12, r13            ; Start at argc

.loop:
    dec r12                 ; Go backwards
    cmp r12, 0
    jl .done

    ; Print argv[r12]
    ; ...

    jmp .loop

.done:
    ret
```

## Going Further

### Challenge 1: Access environment variables

Environment variables come right after argv:

```asm
; envp is at [rsp + 8 + (argc+1)*8]
; Because: 8 bytes to skip argc, then argc+1 pointers for argv
_start:
    mov rcx, [rsp]              ; rcx = argc
    lea rsi, [rsp + 8]          ; rsi = argv base
    lea rdi, [rsi + rcx*8 + 8]  ; rdi = envp base

    ; Now iterate through envp similar to argv
    ; Each envp[i] is a "KEY=value" string
    ; envp array ends with NULL
```

### Challenge 2: Parse key=value arguments

```asm
; For arguments like: ./args name=John age=30
; Parse each as key=value pairs
; Find the '=' character
; Print key and value separately
```

### Challenge 3: Implement simple argument parser

```asm
; Support: ./args --verbose --output file.txt input.txt
; Distinguish between flags (--xxx) and regular arguments
; Build a structure to track what was passed
```

### Challenge 4: Calculate total length of all arguments

```asm
total_arg_length:
    xor rax, rax            ; total = 0
    xor r12, r12            ; index = 0

.loop:
    cmp r12, r13
    jge .done

    mov rdi, [rsi + r12*8]  ; rdi = argv[i]

    ; Calculate strlen
    xor rcx, rcx
.strlen:
    cmp byte [rdi + rcx], 0
    je .add_length
    inc rcx
    jmp .strlen

.add_length:
    add rax, rcx            ; total += length
    inc r12
    jmp .loop

.done:
    ; rax contains total length
    ret
```

## Real-World Applications

Command-line arguments are used in:
- **Configuration**: Passing file paths, URLs, options
- **Batch processing**: Processing multiple files
- **Scripting**: Making programs flexible and reusable
- **Debugging**: Enabling verbose mode, log levels
- **User input**: Interactive programs that take initial input

## Stack and Calling Conventions

Understanding the stack at program start is crucial:

1. **The kernel sets up the stack** before jumping to `_start`
2. **No main() wrapper** in assembly - you get raw argc/argv
3. **Stack grows downward** - lower addresses are "top"
4. **Alignment**: Stack is 16-byte aligned at program start
5. **Auxiliary vector** comes after envp (for advanced use)

## Next Steps

Once you complete this assignment, move on to more advanced topics:
- [03-string-compare](../03-string-compare/) - Comparing strings
- [04-buffer-operations](../04-buffer-operations/) - Memory operations

## Resources

- [System Calls Reference](../../resources/syscalls-linux.md)
- [Instruction Reference](../../resources/instruction-reference.md)
- [Linux x86-64 ABI](https://gitlab.com/x86-psABIs/x86-64-ABI) - Official documentation
