# Linux System Calls for x86-64

A reference for commonly used Linux system calls in x86-64 assembly.

## System Call Convention

On x86-64 Linux, system calls use the `syscall` instruction with the following convention:

| Register | Purpose |
|----------|---------|
| rax | System call number |
| rdi | 1st argument |
| rsi | 2nd argument |
| rdx | 3rd argument |
| r10 | 4th argument |
| r8 | 5th argument |
| r9 | 6th argument |

**Return value**: Stored in rax (negative values indicate errors)

## Basic Template

```asm
section .text
global _start

_start:
    mov rax, <syscall_number>   ; System call number
    mov rdi, <arg1>              ; First argument
    mov rsi, <arg2>              ; Second argument
    mov rdx, <arg3>              ; Third argument
    syscall                      ; Invoke system call
    ; Result is now in rax
```

## Common System Calls

### read (0) - Read from file descriptor

**Purpose**: Read data from a file or stdin

**Arguments**:
- rax: 0 (sys_read)
- rdi: file descriptor (0 = stdin, 3+ = opened files)
- rsi: pointer to buffer
- rdx: number of bytes to read

**Return**: Number of bytes read, or -1 on error

```asm
section .bss
    buffer resb 100              ; Reserve 100 bytes for input

section .text
    mov rax, 0                   ; sys_read
    mov rdi, 0                   ; stdin
    mov rsi, buffer              ; buffer to read into
    mov rdx, 100                 ; max bytes to read
    syscall
    ; rax now contains number of bytes read
```

### write (1) - Write to file descriptor

**Purpose**: Write data to a file or stdout/stderr

**Arguments**:
- rax: 1 (sys_write)
- rdi: file descriptor (1 = stdout, 2 = stderr)
- rsi: pointer to data
- rdx: number of bytes to write

**Return**: Number of bytes written, or -1 on error

```asm
section .data
    msg db "Hello, World!", 10   ; 10 = newline
    len equ $ - msg              ; Calculate length

section .text
    mov rax, 1                   ; sys_write
    mov rdi, 1                   ; stdout
    mov rsi, msg                 ; pointer to string
    mov rdx, len                 ; length
    syscall
```

### open (2) - Open file

**Purpose**: Open a file and get a file descriptor

**Arguments**:
- rax: 2 (sys_open)
- rdi: pointer to filename string
- rsi: flags (O_RDONLY=0, O_WRONLY=1, O_RDWR=2, O_CREAT=64, O_TRUNC=512)
- rdx: mode/permissions (0644 = rw-r--r--)

**Return**: File descriptor (>=0), or -1 on error

```asm
section .data
    filename db "test.txt", 0    ; Null-terminated filename

section .text
    mov rax, 2                   ; sys_open
    mov rdi, filename            ; filename
    mov rsi, 0                   ; O_RDONLY
    mov rdx, 0                   ; mode (not used for reading)
    syscall
    ; rax now contains file descriptor (or -1 if error)
    mov r12, rax                 ; Save fd for later use
```

### close (3) - Close file descriptor

**Purpose**: Close an open file descriptor

**Arguments**:
- rax: 3 (sys_close)
- rdi: file descriptor to close

**Return**: 0 on success, -1 on error

```asm
    mov rax, 3                   ; sys_close
    mov rdi, r12                 ; file descriptor
    syscall
```

### exit (60) - Exit program

**Purpose**: Terminate the program with an exit status

**Arguments**:
- rax: 60 (sys_exit)
- rdi: exit status (0 = success, non-zero = error)

**Return**: Does not return

```asm
    mov rax, 60                  ; sys_exit
    mov rdi, 0                   ; status = 0 (success)
    syscall
```

**Common pattern**:
```asm
; Exit with success
xor rdi, rdi                     ; rdi = 0 (shorter than mov)
mov rax, 60
syscall

; Exit with error code
mov rdi, 1                       ; status = 1
mov rax, 60
syscall
```

## File I/O System Calls

### creat (85) - Create file

**Purpose**: Create a new file (shortcut for open with O_CREAT|O_WRONLY|O_TRUNC)

**Arguments**:
- rax: 85 (sys_creat)
- rdi: pointer to filename
- rsi: mode/permissions (e.g., 0644)

**Return**: File descriptor, or -1 on error

```asm
section .data
    filename db "output.txt", 0

section .text
    mov rax, 85                  ; sys_creat
    mov rdi, filename
    mov rsi, 0644o               ; rw-r--r-- (octal)
    syscall
```

### lseek (8) - Seek in file

**Purpose**: Move file position pointer

**Arguments**:
- rax: 8 (sys_lseek)
- rdi: file descriptor
- rsi: offset
- rdx: whence (SEEK_SET=0, SEEK_CUR=1, SEEK_END=2)

**Return**: New file position, or -1 on error

```asm
    mov rax, 8                   ; sys_lseek
    mov rdi, r12                 ; file descriptor
    mov rsi, 0                   ; offset 0
    mov rdx, 0                   ; SEEK_SET (from beginning)
    syscall
```

## Memory Management

### brk (12) - Change data segment size

**Purpose**: Grow or shrink heap

**Arguments**:
- rax: 12 (sys_brk)
- rdi: new break address (or 0 to query current)

**Return**: New break address

```asm
    mov rax, 12                  ; sys_brk
    xor rdi, rdi                 ; Query current break
    syscall
    ; rax now contains current break address
```

### mmap (9) - Map memory

**Purpose**: Allocate memory region

**Arguments**:
- rax: 9 (sys_mmap)
- rdi: address (0 = let kernel choose)
- rsi: length
- rdx: protection (PROT_READ=1, PROT_WRITE=2, PROT_EXEC=4)
- r10: flags (MAP_PRIVATE=2, MAP_ANONYMOUS=32)
- r8: file descriptor (or -1 for anonymous)
- r9: offset

**Return**: Address of mapped region, or -1 on error

```asm
    mov rax, 9                   ; sys_mmap
    xor rdi, rdi                 ; addr = 0 (kernel chooses)
    mov rsi, 4096                ; length = 4KB
    mov rdx, 3                   ; PROT_READ | PROT_WRITE
    mov r10, 34                  ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                   ; no file descriptor
    xor r9, r9                   ; offset = 0
    syscall
    ; rax contains address of allocated memory
```

## Process Control

### fork (57) - Create child process

**Purpose**: Create a copy of the current process

**Arguments**:
- rax: 57 (sys_fork)

**Return**:
- Child: 0
- Parent: child's PID
- Error: -1

```asm
    mov rax, 57                  ; sys_fork
    syscall
    test rax, rax                ; Check return value
    jz child_process             ; If 0, we're in child
    ; Parent continues here
```

### execve (59) - Execute program

**Purpose**: Replace current process with new program

**Arguments**:
- rax: 59 (sys_execve)
- rdi: pointer to program path
- rsi: pointer to argv array
- rdx: pointer to envp array

```asm
section .data
    prog db "/bin/ls", 0
    argv dq prog, 0              ; Null-terminated array

section .text
    mov rax, 59                  ; sys_execve
    mov rdi, prog                ; program
    mov rsi, argv                ; arguments
    xor rdx, rdx                 ; no environment
    syscall
```

### wait4 (61) - Wait for child process

**Purpose**: Wait for child process to terminate

**Arguments**:
- rax: 61 (sys_wait4)
- rdi: PID (-1 = any child)
- rsi: pointer to status variable (or 0)
- rdx: options
- r10: pointer to rusage (or 0)

## Time

### time (201) - Get current time

**Purpose**: Get current Unix timestamp

**Arguments**:
- rax: 201 (sys_time)
- rdi: pointer to time_t (or 0)

**Return**: Current time in seconds since epoch

```asm
    mov rax, 201                 ; sys_time
    xor rdi, rdi                 ; NULL pointer
    syscall
    ; rax contains timestamp
```

### nanosleep (35) - Sleep for specified time

**Purpose**: Sleep for a specific duration

**Arguments**:
- rax: 35 (sys_nanosleep)
- rdi: pointer to timespec struct (seconds, nanoseconds)
- rsi: pointer to remaining time (or 0)

```asm
section .data
    timespec:
        dq 2                     ; 2 seconds
        dq 500000000             ; 500 million nanoseconds (0.5s)

section .text
    mov rax, 35                  ; sys_nanosleep
    mov rdi, timespec            ; time to sleep: 2.5 seconds
    xor rsi, rsi                 ; don't care about remaining
    syscall
```

## Error Handling

System calls return negative values on error. To check:

```asm
    syscall
    test rax, rax                ; Check if negative
    js error_handler             ; Jump if sign flag set (negative)
    ; Success path
    jmp continue

error_handler:
    ; rax contains negative error code
    ; To get positive errno: neg rax
    neg rax                      ; rax = -rax (positive error code)
    ; Now you can check specific errors
```

Common error codes:
- 1: EPERM (Operation not permitted)
- 2: ENOENT (No such file or directory)
- 9: EBADF (Bad file descriptor)
- 13: EACCES (Permission denied)
- 14: EFAULT (Bad address)
- 22: EINVAL (Invalid argument)

## Complete System Call Table

Here are the most useful system calls:

| Number | Name | Purpose |
|--------|------|---------|
| 0 | read | Read from file descriptor |
| 1 | write | Write to file descriptor |
| 2 | open | Open file |
| 3 | close | Close file descriptor |
| 8 | lseek | Seek in file |
| 9 | mmap | Map memory |
| 11 | munmap | Unmap memory |
| 12 | brk | Change data segment size |
| 35 | nanosleep | Sleep |
| 57 | fork | Create child process |
| 59 | execve | Execute program |
| 60 | exit | Exit program |
| 61 | wait4 | Wait for child |
| 79 | getcwd | Get current directory |
| 80 | chdir | Change directory |
| 85 | creat | Create file |
| 201 | time | Get current time |

For a complete list, see: https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/

## Practical Examples

### Example 1: Write string to stdout
```asm
section .data
    msg db "Hello, World!", 10
    len equ $ - msg

section .text
global _start

_start:
    mov rax, 1                   ; sys_write
    mov rdi, 1                   ; stdout
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 60                  ; sys_exit
    xor rdi, rdi
    syscall
```

### Example 2: Read from stdin
```asm
section .bss
    buffer resb 100

section .text
global _start

_start:
    mov rax, 0                   ; sys_read
    mov rdi, 0                   ; stdin
    mov rsi, buffer
    mov rdx, 100
    syscall

    ; Write what we read
    mov rdx, rax                 ; length = bytes read
    mov rax, 1                   ; sys_write
    mov rdi, 1                   ; stdout
    mov rsi, buffer
    syscall

    mov rax, 60                  ; sys_exit
    xor rdi, rdi
    syscall
```

### Example 3: Create and write to file
```asm
section .data
    filename db "output.txt", 0
    content db "Hello, File!", 10
    len equ $ - content

section .text
global _start

_start:
    ; Create file
    mov rax, 85                  ; sys_creat
    mov rdi, filename
    mov rsi, 0644o               ; permissions
    syscall
    mov r12, rax                 ; save file descriptor

    ; Write to file
    mov rax, 1                   ; sys_write
    mov rdi, r12                 ; file descriptor
    mov rsi, content
    mov rdx, len
    syscall

    ; Close file
    mov rax, 3                   ; sys_close
    mov rdi, r12
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

## Tips

1. **Always check return values** from system calls
2. **Use r12-r15** to preserve values across syscalls (rax, rdi, rsi, rdx are modified)
3. **Zero unused arguments** (some syscalls are picky about garbage values)
4. **Remember to close** file descriptors when done
5. **Use strace** to debug: `strace ./your_program`

## Debugging System Calls

Use `strace` to see what system calls your program makes:

```bash
strace ./program
```

Example output:
```
write(1, "Hello, World!\n", 14)         = 14
exit(0)                                  = ?
```

This shows the syscall name, arguments, and return value.

## Next Steps

- Practice with [01-basics/01-hello-world](../01-basics/01-hello-world/)
- Read [calling-conventions.md](calling-conventions.md)
- Experiment with different syscalls
