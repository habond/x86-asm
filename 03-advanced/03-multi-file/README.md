# Assignment 3: Multi-File Projects

Learn to organize code across multiple files and link them together.

## Learning Objectives

- Split code into multiple source files
- Use `global` to export symbols
- Use `extern` to import symbols
- Link multiple object files together
- Create reusable library functions
- Understand the linking process

## Background

Real projects are split across multiple files for:
- **Organization** - Group related functions together
- **Reusability** - Share functions across programs
- **Maintainability** - Easier to find and fix code
- **Compilation speed** - Only recompile changed files

## The Task

Create a program split across three files:
1. **main.asm** - Entry point that calls library functions
2. **string_utils.asm** - String utility functions (strlen, strcmp)
3. **math_utils.asm** - Math utility functions (max, min, abs)

The program should test all utility functions and exit with a success code.

## Symbol Visibility

### `global` - Export a symbol

```asm
; In string_utils.asm
section .text
global my_strlen        ; Make my_strlen available to other files

my_strlen:
    ; Implementation
    ret
```

### `extern` - Import a symbol

```asm
; In main.asm
section .text
extern my_strlen        ; Declare that my_strlen exists elsewhere

_start:
    call my_strlen      ; Call the external function
```

## Project Structure

```
03-multi-file/
├── main.asm              # Entry point
├── string_utils.asm      # String functions
├── math_utils.asm        # Math functions
├── Makefile              # Build script
└── README.md
```

## File 1: string_utils.asm

```asm
section .text

; Export these functions
global my_strlen
global my_strcmp

; Function: my_strlen
; Arguments: rdi = pointer to null-terminated string
; Returns: rax = length of string
my_strlen:
    xor rax, rax        ; counter = 0

.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop

.done:
    ret

; Function: my_strcmp
; Arguments: rdi = string1, rsi = string2
; Returns: rax = 0 if equal, -1 if s1 < s2, 1 if s1 > s2
my_strcmp:
    xor rcx, rcx        ; index = 0

.loop:
    mov al, [rdi + rcx]
    mov bl, [rsi + rcx]

    cmp al, bl
    jl .less
    jg .greater

    test al, al         ; End of string?
    jz .equal

    inc rcx
    jmp .loop

.equal:
    xor rax, rax        ; return 0
    ret

.less:
    mov rax, -1         ; return -1
    ret

.greater:
    mov rax, 1          ; return 1
    ret
```

## File 2: math_utils.asm

```asm
section .text

; Export these functions
global find_max
global find_min
global absolute

; Function: find_max
; Arguments: rdi = a, rsi = b
; Returns: rax = max(a, b)
find_max:
    mov rax, rdi
    cmp rdi, rsi
    jge .done
    mov rax, rsi

.done:
    ret

; Function: find_min
; Arguments: rdi = a, rsi = b
; Returns: rax = min(a, b)
find_min:
    mov rax, rdi
    cmp rdi, rsi
    jle .done
    mov rax, rsi

.done:
    ret

; Function: absolute
; Arguments: rdi = signed number
; Returns: rax = |n|
absolute:
    mov rax, rdi
    test rax, rax       ; Check sign
    jns .done           ; If non-negative, done

    neg rax             ; Make positive

.done:
    ret
```

## File 3: main.asm

```asm
section .data
    str1 db "Hello", 0
    str2 db "World", 0
    str3 db "Hello", 0

section .text
global _start

; Import external functions
extern my_strlen
extern my_strcmp
extern find_max
extern find_min
extern absolute

_start:
    ; Test strlen
    mov rdi, str1
    call my_strlen      ; Should return 5

    ; Test strcmp (str1 vs str2)
    mov rdi, str1
    mov rsi, str2
    call my_strcmp      ; Should return -1 (Hello < World)

    ; Test strcmp (str1 vs str3)
    mov rdi, str1
    mov rsi, str3
    call my_strcmp      ; Should return 0 (equal)

    ; Test find_max
    mov rdi, 42
    mov rsi, 17
    call find_max       ; Should return 42

    ; Test find_min
    mov rdi, 42
    mov rsi, 17
    call find_min       ; Should return 17

    ; Test absolute
    mov rdi, -25
    call absolute       ; Should return 25

    ; Exit with success
    mov rdi, 0
    mov rax, 60
    syscall
```

## Building Multi-File Projects

### Manual Build

```bash
# Assemble each file to object code
nasm -f elf64 main.asm -o main.o
nasm -f elf64 string_utils.asm -o string_utils.o
nasm -f elf64 math_utils.asm -o math_utils.o

# Link all object files together
ld -o program main.o string_utils.o math_utils.o

# Run
./program
```

### Using Makefile

```makefile
AS = nasm
ASFLAGS = -f elf64
LD = ld

OBJS = main.o string_utils.o math_utils.o
TARGET = program

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS)

%.o: %.asm
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean
```

## Local Labels

Use local labels (starting with `.`) to avoid name conflicts:

```asm
; Global function
my_function:
    ; Local labels (only visible within my_function)
    jmp .loop

.loop:
    ; ...
    jnz .loop
    ret

another_function:
    ; This has its own .loop (doesn't conflict)
.loop:
    ; ...
    ret
```

## Common Patterns

### Pattern 1: Library Structure

```
lib/
├── string.asm        # String functions
├── io.asm            # I/O functions
├── math.asm          # Math functions
└── utils.asm         # Utility functions

src/
└── main.asm          # Main program
```

### Pattern 2: Shared Constants

```asm
; constants.asm
section .data
global BUFFER_SIZE
global MAX_PATH_LEN

BUFFER_SIZE equ 4096
MAX_PATH_LEN equ 256

; main.asm
extern BUFFER_SIZE
extern MAX_PATH_LEN

section .bss
    buffer resb BUFFER_SIZE
    path resb MAX_PATH_LEN
```

### Pattern 3: Shared Data

```asm
; data.asm
section .data
global shared_counter

shared_counter dq 0

; file1.asm
extern shared_counter

increment:
    inc qword [shared_counter]
    ret

; file2.asm
extern shared_counter

get_count:
    mov rax, [shared_counter]
    ret
```

## Testing Each Module

### Test string_utils.asm independently

```asm
; test_string.asm
extern my_strlen
extern my_strcmp

section .data
    test_str db "Test", 0

section .text
global _start

_start:
    mov rdi, test_str
    call my_strlen

    ; Exit with length (should be 4)
    mov rdi, rax
    mov rax, 60
    syscall
```

```bash
nasm -f elf64 test_string.asm -o test_string.o
nasm -f elf64 string_utils.asm -o string_utils.o
ld -o test_string test_string.o string_utils.o
./test_string
echo $?  # Should print 4
```

## Starter Code

The assignment provides three template files with TODOs:

**main.asm.template**:
```asm
section .data
    ; TODO: Define test strings

section .text
global _start

; TODO: Declare external functions

_start:
    ; TODO: Call utility functions to test them

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

**string_utils.asm.template**:
```asm
section .text

; TODO: Export functions

; TODO: Implement my_strlen

; TODO: Implement my_strcmp
```

**math_utils.asm.template**:
```asm
section .text

; TODO: Export functions

; TODO: Implement find_max

; TODO: Implement find_min

; TODO: Implement absolute
```

## Building and Running

```bash
make                # Build everything
make run            # Build and run
make test           # Run tests
make clean          # Clean up
```

## Debugging Multi-File Programs

```bash
# Assemble with debug info
nasm -f elf64 -g main.asm -o main.o
nasm -f elf64 -g string_utils.asm -o string_utils.o
ld -o program main.o string_utils.o

# Debug with GDB
gdb ./program

# List functions from all files
(gdb) info functions

# Set breakpoints
(gdb) break _start
(gdb) break my_strlen
(gdb) break find_max

# View source
(gdb) list my_strlen
```

## Common Mistakes

### Mistake 1: Forgetting to export

```asm
; Wrong - function not exported
my_strlen:
    ret

; main.asm will get "undefined reference to my_strlen"
```

**Fix**: Add `global my_strlen`

### Mistake 2: Forgetting to import

```asm
; Wrong - function not declared
_start:
    call my_strlen      ; Error: undefined symbol

; Right - declare it
extern my_strlen

_start:
    call my_strlen
```

### Mistake 3: Name conflicts

```asm
; string.asm
loop:               ; Global label
    ret

; math.asm
loop:               ; Error: duplicate symbol
    ret
```

**Fix**: Use local labels (`.loop`) or unique names

### Mistake 4: Wrong linking order

Sometimes order matters when using libraries. Generally link files that depend on others first:

```bash
# Wrong (may fail with some linkers)
ld -o program string_utils.o main.o

# Right
ld -o program main.o string_utils.o
```

## Going Further

### Challenge 1: Add more string functions

Implement in string_utils.asm:
- `strcpy` - Copy string
- `strcat` - Concatenate strings
- `strchr` - Find character in string

### Challenge 2: Create an array module

**array_utils.asm**:
- `array_sum` - Sum array elements
- `array_max` - Find maximum
- `array_reverse` - Reverse array

### Challenge 3: Build a mini-libc

Create multiple utility files that work together:
- `string.asm` - String functions
- `io.asm` - printf-like output
- `mem.asm` - Memory operations
- `conv.asm` - Number to string conversion

### Challenge 4: Separate data and code

Split data into separate files:
```asm
; messages.asm
section .data
global msg_hello
global msg_error

msg_hello db "Hello!", 10, 0
msg_error db "Error!", 10, 0
```

## Real-World Example Structure

```
project/
├── src/
│   ├── main.asm
│   └── cli.asm
├── lib/
│   ├── string/
│   │   ├── strlen.asm
│   │   ├── strcmp.asm
│   │   └── strcpy.asm
│   ├── io/
│   │   ├── print.asm
│   │   └── read.asm
│   └── math/
│       ├── basic.asm
│       └── advanced.asm
├── include/
│   └── constants.asm
└── Makefile
```

## Next Steps

Once you complete this assignment, move on to:
- [04-file-io](../04-file-io/) - Reading and writing files

## Resources

- [NASM Documentation - Multi-File Programs](https://www.nasm.us/doc/)
- [Linker Documentation](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_mono/ld.html)
