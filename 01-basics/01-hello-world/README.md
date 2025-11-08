# Assignment 1: Hello World

Welcome to your first x86-64 assembly program!

## Learning Objectives

- Understand basic program structure
- Use the write system call
- Exit a program properly
- Work with data sections

## Background

Every assembly program has three main parts:

1. **Data section** (`.data`): Where you define constants and initialized data
2. **BSS section** (`.bss`): Where you reserve space for uninitialized data
3. **Text section** (`.text`): Where your code goes

A minimal program needs to:
1. Write something to stdout
2. Exit cleanly

## The Task

Write a program that prints "Hello, World!" followed by a newline to stdout.

## System Calls You'll Need

### sys_write (1)
Writes data to a file descriptor.

**Arguments**:
- `rax`: 1 (syscall number for write)
- `rdi`: file descriptor (1 = stdout)
- `rsi`: pointer to the data to write
- `rdx`: number of bytes to write

**Returns**: Number of bytes written in `rax`

### sys_exit (60)
Exits the program with a status code.

**Arguments**:
- `rax`: 60 (syscall number for exit)
- `rdi`: exit status (0 = success)

**Returns**: Does not return

## Starter Code

The file `hello.asm` contains a template with TODOs:

```asm
section .data
    msg db "Hello, World!", 10    ; String with newline (10 = \n)
    len equ $ - msg                ; Calculate length

section .text
global _start

_start:
    ; TODO: Write "Hello, World!\n" to stdout
    ; Hint: Use sys_write (syscall 1)
    ; rdi = 1 (stdout)
    ; rsi = msg (pointer to string)
    ; rdx = len (length)

    ; TODO: Exit program with status 0
    ; Hint: Use sys_exit (syscall 60)
    ; rdi = 0 (success)
```

## Step by Step Guide

### Step 1: Understand the data section

```asm
section .data
    msg db "Hello, World!", 10    ; Define bytes: our string + newline
    len equ $ - msg                ; $ is current address, so len = current - start of msg
```

- `db` means "define bytes"
- The number `10` is the newline character (ASCII `\n`)
- `equ` defines a constant (the length of our string)
- `$` is the current address
- `$ - msg` calculates the length automatically

### Step 2: Write to stdout

To write to stdout, you need to:

1. Put the syscall number (1) in `rax`
2. Put the file descriptor (1 for stdout) in `rdi`
3. Put the address of the string in `rsi`
4. Put the length in `rdx`
5. Call `syscall`

```asm
mov rax, 1          ; sys_write
mov rdi, 1          ; stdout
mov rsi, msg        ; pointer to string
mov rdx, len        ; length
syscall             ; make the system call
```

**Notice**: When you use `mov rsi, msg`, you're loading the **address** of msg, not its contents!

### Step 3: Exit the program

After writing, you must exit:

```asm
mov rax, 60         ; sys_exit
mov rdi, 0          ; status = 0 (success)
syscall             ; exit
```

Or more concisely:
```asm
xor rdi, rdi        ; rdi = 0 (shorter than mov)
mov rax, 60
syscall
```

## Building and Running

### Assemble
```bash
nasm -f elf64 hello.asm -o hello.o
```

This converts your assembly code to an object file.

### Link
```bash
ld -o hello hello.o
```

This creates the executable.

### Run
```bash
./hello
```

You should see:
```
Hello, World!
```

### Check exit status
```bash
echo $?
```

Should print `0` (success).

## Using the Makefile

A Makefile is provided for convenience:

```bash
make            # Build the program
make run        # Build and run
make solution   # Build and run the solution
make test       # Run automated tests
make clean      # Remove build files
```

## Expected Output

```
$ ./hello
Hello, World!
$ echo $?
0
```

## Testing Your Solution

### Automated Tests

Run the automated test suite to verify your implementation:

```bash
make test
```

This will check:
- ✓ Program builds successfully
- ✓ Program is executable
- ✓ Output is exactly "Hello, World!"
- ✓ Exit code is 0
- ✓ Output ends with a newline

**Example output:**
```
Running tests...

Testing solution.asm (reference)...
================================
✓ Program exists
✓ Program is executable
✓ Output is correct
✓ Exit code is correct
✓ Output ends with newline

Testing hello.asm (your code)...
================================
✓ Program exists
✓ Program is executable
✓ Output is correct
✓ Exit code is correct
✓ Output ends with newline

========================================
  Test Summary
========================================
Tests run:    10
Tests passed: 10
Tests failed: 0

All tests passed! ✓
```

### Manual Testing

You can also test manually:

```bash
./hello                 # Should print: Hello, World!
echo $?                 # Should print: 0
```

Your program is correct if:
1. It prints "Hello, World!" followed by a newline
2. It exits with status code 0
3. It produces no errors or warnings during assembly and linking

## Common Mistakes

### Mistake 1: Forgetting the newline
```asm
msg db "Hello, World!"    ; No newline!
```

**Fix**: Add `10` at the end:
```asm
msg db "Hello, World!", 10
```

### Mistake 2: Wrong syscall numbers
```asm
mov rax, 4              ; This is the macOS syscall number!
```

**Fix**: Use the Linux numbers:
```asm
mov rax, 1              ; sys_write
mov rax, 60             ; sys_exit
```

### Mistake 3: Wrong file descriptor
```asm
mov rdi, 0              ; 0 is stdin, not stdout!
```

**Fix**:
```asm
mov rdi, 1              ; 1 is stdout
```

### Mistake 4: Not exiting
If you forget to exit, you'll get a segmentation fault!

**Always end with**:
```asm
mov rax, 60
xor rdi, rdi
syscall
```

### Mistake 5: Wrong length calculation
```asm
msg db "Hello, World!", 10
len equ 13                    ; Hardcoded, will break if msg changes!
```

**Fix**: Use automatic calculation:
```asm
len equ $ - msg               ; Always correct!
```

## Going Further

Once you have it working, try:

1. **Change the message**: Print your name instead
2. **Print twice**: Call sys_write twice to print two different strings
3. **Exit with different code**: Exit with status 42 and check with `echo $?`
4. **Print to stderr**: Use file descriptor 2 instead of 1

## Debugging Tips

### Using GDB

If something goes wrong:

```bash
# Assemble with debug info
nasm -f elf64 -g hello.asm -o hello.o
ld -o hello hello.o

# Start debugger
gdb ./hello

# Set breakpoint and run
(gdb) break _start
(gdb) run
(gdb) stepi                  # Step one instruction
(gdb) info registers         # See all registers
(gdb) x/s $rsi               # Examine string at rsi
(gdb) continue
```

### Using strace

See what system calls your program makes:

```bash
strace ./hello
```

You should see:
```
write(1, "Hello, World!\n", 14)         = 14
exit(0)                                  = ?
```

## Solution

When you're done trying on your own, check `solution.asm` to see a working implementation.

## Next Steps

Once you complete this assignment, move on to:
- [02-add-numbers](../02-add-numbers/) - Basic arithmetic

## Resources

- [System Calls Reference](../../resources/syscalls-linux.md)
- [Instruction Reference](../../resources/instruction-reference.md)
- [Getting Started Guide](../../resources/getting-started.md)
