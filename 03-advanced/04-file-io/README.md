# Assignment 4: File I/O Operations

Master file I/O system calls and implement a simple file copy program.

## Learning Objectives

- Open files for reading and writing
- Read data from files in chunks
- Write data to files
- Close file descriptors properly
- Handle file I/O errors
- Work with file permissions
- Implement buffered file operations

## Background

File I/O is one of the most common operations in systems programming. In assembly, you interact with files directly through system calls without any library abstractions.

In C, a file copy program looks like this:

```c
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char **argv) {
    int src_fd = open(argv[1], O_RDONLY);
    int dst_fd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);

    char buffer[4096];
    ssize_t bytes_read;

    while ((bytes_read = read(src_fd, buffer, 4096)) > 0) {
        write(dst_fd, buffer, bytes_read);
    }

    close(src_fd);
    close(dst_fd);
    return 0;
}
```

In assembly, we'll do the same thing using syscalls directly.

## The Task

Write a program that copies a file from a source path to a destination path:

```bash
./filecp source.txt destination.txt
```

The program should:
1. Open the source file for reading
2. Create/open the destination file for writing
3. Read data from source in chunks (4096 bytes)
4. Write each chunk to destination
5. Close both files
6. Handle errors appropriately

## File I/O System Calls

### open (syscall 2)

Opens a file and returns a file descriptor.

**Arguments**:
- rax: 2 (sys_open)
- rdi: pointer to filename (null-terminated string)
- rsi: flags (how to open the file)
- rdx: mode/permissions (for creating files)

**Flags** (can be combined with OR):
- O_RDONLY (0): Read-only
- O_WRONLY (1): Write-only
- O_RDWR (2): Read and write
- O_CREAT (64): Create file if it doesn't exist
- O_TRUNC (512): Truncate file to 0 length
- O_APPEND (1024): Append to end of file

**Permissions** (octal):
- 0644: rw-r--r-- (owner can read/write, others can read)
- 0755: rwxr-xr-x (owner can execute, others can read/execute)
- 0600: rw------- (only owner can read/write)

**Return**: File descriptor (>=3), or negative on error

```asm
section .data
    filename db "test.txt", 0

section .text
    ; Open for reading
    mov rax, 2                   ; sys_open
    mov rdi, filename            ; filename pointer
    mov rsi, 0                   ; O_RDONLY
    xor rdx, rdx                 ; mode not needed for reading
    syscall
    ; rax now contains file descriptor (or negative if error)
```

### read (syscall 0)

Reads data from a file descriptor into a buffer.

**Arguments**:
- rax: 0 (sys_read)
- rdi: file descriptor
- rsi: pointer to buffer
- rdx: maximum bytes to read

**Return**: Number of bytes read (0 = EOF, negative = error)

```asm
section .bss
    buffer resb 4096             ; 4KB buffer

section .text
    mov rax, 0                   ; sys_read
    mov rdi, r12                 ; file descriptor
    mov rsi, buffer              ; buffer pointer
    mov rdx, 4096                ; bytes to read
    syscall
    ; rax contains bytes read
```

### write (syscall 1)

Writes data from a buffer to a file descriptor.

**Arguments**:
- rax: 1 (sys_write)
- rdi: file descriptor
- rsi: pointer to data
- rdx: number of bytes to write

**Return**: Number of bytes written (negative = error)

```asm
    mov rax, 1                   ; sys_write
    mov rdi, r13                 ; file descriptor
    mov rsi, buffer              ; data pointer
    mov rdx, r14                 ; bytes to write
    syscall
    ; rax contains bytes written
```

### close (syscall 3)

Closes a file descriptor.

**Arguments**:
- rax: 3 (sys_close)
- rdi: file descriptor

**Return**: 0 on success, negative on error

```asm
    mov rax, 3                   ; sys_close
    mov rdi, r12                 ; file descriptor
    syscall
```

## File Descriptors

Every process starts with three open file descriptors:
- **0**: stdin (standard input)
- **1**: stdout (standard output)
- **2**: stderr (standard error)

When you open a file, the kernel assigns the lowest available file descriptor (usually 3, 4, 5, etc.).

**Important**: Always close file descriptors when done to avoid resource leaks.

## Starter Code

The file `filecp.asm` contains a template with TODOs:

```asm
section .data
    ; Error messages
    error_args db "Usage: filecp <source> <destination>", 10
    error_args_len equ $ - error_args

    error_open_src db "Error: Cannot open source file", 10
    error_open_src_len equ $ - error_open_src

    error_open_dst db "Error: Cannot create destination file", 10
    error_open_dst_len equ $ - error_open_dst

section .bss
    buffer resb 4096             ; 4KB buffer for reading/writing

section .text
global _start

_start:
    ; TODO: Check argument count (argc should be 3)
    ; argc is at [rsp]

    ; TODO: Get source filename (argv[1] at [rsp+16])

    ; TODO: Get destination filename (argv[2] at [rsp+24])

    ; TODO: Open source file (O_RDONLY = 0)

    ; TODO: Check if open succeeded (rax >= 0)

    ; TODO: Save source file descriptor

    ; TODO: Open/create destination file (O_WRONLY|O_CREAT|O_TRUNC = 577, mode 0644)

    ; TODO: Check if open succeeded

    ; TODO: Save destination file descriptor

copy_loop:
    ; TODO: Read from source file into buffer

    ; TODO: Check if read succeeded (rax >= 0)

    ; TODO: Check if EOF (rax == 0)

    ; TODO: Write to destination file

    ; TODO: Check if write succeeded

    ; TODO: Loop back to read more

cleanup:
    ; TODO: Close source file

    ; TODO: Close destination file

    ; TODO: Exit with status 0 (success)

error_args:
    ; TODO: Print usage message and exit with status 1

error_open_src:
    ; TODO: Print error message and exit with status 1

error_open_dst:
    ; TODO: Close source file first
    ; TODO: Print error message and exit with status 1
```

## Step by Step Guide

### Step 1: Check Command-Line Arguments

```asm
_start:
    ; Check argc (should be 3: program name, source, destination)
    mov rax, [rsp]               ; rax = argc
    cmp rax, 3                   ; Need exactly 3 arguments
    jne error_usage              ; Jump to error if not
```

### Step 2: Get Filenames from argv

```asm
    ; Get source filename (argv[1])
    mov r12, [rsp + 16]          ; r12 = pointer to source filename

    ; Get destination filename (argv[2])
    mov r13, [rsp + 24]          ; r13 = pointer to destination filename
```

Remember: argv layout is:
- [rsp]: argc
- [rsp+8]: argv[0] (program name)
- [rsp+16]: argv[1] (first argument)
- [rsp+24]: argv[2] (second argument)

### Step 3: Open Source File

```asm
    ; Open source file for reading
    mov rax, 2                   ; sys_open
    mov rdi, r12                 ; source filename
    mov rsi, 0                   ; O_RDONLY
    xor rdx, rdx                 ; mode not needed
    syscall

    ; Check for error (negative return value)
    test rax, rax
    js error_open_source         ; Jump if sign flag set (negative)

    mov r14, rax                 ; Save source fd in r14
```

### Step 4: Open/Create Destination File

```asm
    ; Open/create destination file for writing
    mov rax, 2                   ; sys_open
    mov rdi, r13                 ; destination filename
    mov rsi, 577                 ; O_WRONLY | O_CREAT | O_TRUNC (1 | 64 | 512)
    mov rdx, 0644o               ; Permissions: rw-r--r-- (octal!)
    syscall

    ; Check for error
    test rax, rax
    js error_open_dest           ; Jump if negative

    mov r15, rax                 ; Save destination fd in r15
```

**Note**: The 'o' suffix in `0644o` tells NASM it's octal. Without it, NASM treats it as decimal.

### Step 5: Read-Write Loop

```asm
copy_loop:
    ; Read from source
    mov rax, 0                   ; sys_read
    mov rdi, r14                 ; source fd
    mov rsi, buffer              ; buffer to read into
    mov rdx, 4096                ; bytes to read
    syscall

    ; Check for errors
    test rax, rax
    js error_read                ; Negative = error
    jz copy_done                 ; Zero = EOF, we're done

    ; Save number of bytes read
    mov rdx, rax                 ; rdx = bytes to write

    ; Write to destination
    mov rax, 1                   ; sys_write
    mov rdi, r15                 ; destination fd
    mov rsi, buffer              ; data to write
    ; rdx already has bytes to write
    syscall

    ; Check for errors
    test rax, rax
    js error_write               ; Negative = error

    ; Continue loop
    jmp copy_loop
```

### Step 6: Cleanup and Exit

```asm
copy_done:
    ; Close source file
    mov rax, 3                   ; sys_close
    mov rdi, r14                 ; source fd
    syscall

    ; Close destination file
    mov rax, 3                   ; sys_close
    mov rdi, r15                 ; destination fd
    syscall

    ; Exit with success
    mov rax, 60                  ; sys_exit
    xor rdi, rdi                 ; status = 0
    syscall
```

### Step 7: Error Handling

```asm
error_usage:
    mov rax, 1                   ; sys_write
    mov rdi, 2                   ; stderr
    mov rsi, error_args          ; error message
    mov rdx, error_args_len      ; message length
    syscall

    mov rax, 60                  ; sys_exit
    mov rdi, 1                   ; status = 1 (error)
    syscall

error_open_source:
    mov rax, 1                   ; sys_write
    mov rdi, 2                   ; stderr
    mov rsi, error_open_src
    mov rdx, error_open_src_len
    syscall

    mov rax, 60                  ; sys_exit
    mov rdi, 1                   ; status = 1
    syscall

error_open_dest:
    ; Close source file first
    mov rax, 3                   ; sys_close
    mov rdi, r14                 ; source fd
    syscall

    mov rax, 1                   ; sys_write
    mov rdi, 2                   ; stderr
    mov rsi, error_open_dst
    mov rdx, error_open_dst_len
    syscall

    mov rax, 60                  ; sys_exit
    mov rdi, 1                   ; status = 1
    syscall
```

## Building and Running

```bash
# Build the program
nasm -f elf64 filecp.asm -o filecp.o
ld -o filecp filecp.o

# Create a test file
echo "Hello, World!" > test.txt

# Copy the file
./filecp test.txt copy.txt

# Verify the copy
cat copy.txt                 # Should print: Hello, World!
diff test.txt copy.txt       # Should show no differences
```

Or with Make:
```bash
make                         # Build filecp
make run                     # Run with test files
make test                    # Run test suite
```

## Testing

```bash
# Test 1: Simple text file
echo "Line 1\nLine 2\nLine 3" > source.txt
./filecp source.txt dest.txt
diff source.txt dest.txt
echo $?                      # Should be 0 (files identical)

# Test 2: Large file (tests buffering)
dd if=/dev/urandom of=large.bin bs=1M count=10
./filecp large.bin large_copy.bin
diff large.bin large_copy.bin

# Test 3: Binary file
./filecp /bin/ls ls_copy
chmod +x ls_copy
./ls_copy                    # Should work like ls

# Test 4: Error handling (missing file)
./filecp nonexistent.txt dest.txt
echo $?                      # Should be 1 (error)

# Test 5: Wrong number of arguments
./filecp onefile.txt
echo $?                      # Should be 1 (error)
```

## Common Mistakes

### Mistake 1: Forgetting to check errors

```asm
; Wrong - doesn't check for errors
syscall
mov r14, rax                 ; Could be saving an error code!

; Right - check before using
syscall
test rax, rax
js error_handler             ; Handle error
mov r14, rax                 ; Only save if successful
```

### Mistake 2: Wrong file flags

```asm
; Wrong - opens destination read-only (can't write)
mov rsi, 0                   ; O_RDONLY

; Right - open for writing with creation
mov rsi, 577                 ; O_WRONLY | O_CREAT | O_TRUNC
```

### Mistake 3: Not using octal for permissions

```asm
; Wrong - 644 in decimal is wrong
mov rdx, 644

; Right - use octal suffix
mov rdx, 0644o               ; rw-r--r--
```

### Mistake 4: Forgetting to close files

```asm
; Wrong - leaks file descriptors
jmp exit                     ; Files still open!

; Right - always close
mov rax, 3
mov rdi, r14
syscall                      ; Close source
mov rax, 3
mov rdi, r15
syscall                      ; Close destination
```

### Mistake 5: Writing more bytes than read

```asm
; Wrong - always writes 4096 bytes
mov rax, 0
mov rdx, 4096
syscall                      ; Read (might read less than 4096)
mov rax, 1
mov rdx, 4096                ; Wrong! Should use bytes actually read
syscall

; Right - write exactly what was read
mov rax, 0
mov rdx, 4096
syscall                      ; rax = bytes read
mov rdx, rax                 ; Use actual bytes read
mov rax, 1
syscall
```

### Mistake 6: Not handling partial writes

In a simple implementation, we assume `write` writes all requested bytes. In production code, you should check if `write` returns less than requested and retry.

```asm
; Production-quality write loop
write_loop:
    mov rax, 1                   ; sys_write
    syscall

    cmp rax, rdx                 ; Did we write everything?
    jl write_partial             ; No, write more
    ; Success
    jmp continue

write_partial:
    ; Update pointers and counters
    add rsi, rax                 ; Advance buffer pointer
    sub rdx, rax                 ; Reduce bytes remaining
    jmp write_loop               ; Try again
```

## Understanding File Descriptors

File descriptors are small integers that represent open files:

```
+-----+------------------+
| FD  | Description      |
+-----+------------------+
|  0  | stdin            |
|  1  | stdout           |
|  2  | stderr           |
|  3  | first opened file|
|  4  | second opened    |
|  5  | third opened     |
| ... | ...              |
+-----+------------------+
```

Each process has its own table. When you `open`, the kernel finds the lowest unused FD.

## Buffer Size Considerations

Why use a 4096-byte buffer?

1. **Page size**: Most systems use 4KB pages, so this aligns with memory page boundaries
2. **Performance**: Larger buffers reduce syscall overhead
3. **Filesystem blocks**: Many filesystems use 4KB blocks
4. **Trade-off**: Bigger isn't always better (cache effects, memory usage)

Common buffer sizes:
- 512 bytes: Disk sector size (traditional)
- 4096 bytes: Page size, good default
- 8192 bytes: Often used for networking
- 65536 bytes: For very large file operations

## Going Further

### Challenge 1: Progress Indicator

Add a progress indicator that shows how many bytes have been copied:

```asm
; After each write, print bytes copied
; Use sys_write to stderr to show progress
```

### Challenge 2: Preserve File Permissions

Use `fstat` (syscall 5) to read source file permissions, then apply them to destination:

```asm
section .bss
    stat_buf resb 144            ; struct stat is 144 bytes

; After opening source file
mov rax, 5                       ; sys_fstat
mov rdi, r14                     ; source fd
mov rsi, stat_buf                ; buffer for stat structure
syscall

; Get permission bits (at offset 24 in struct stat)
mov rdx, [stat_buf + 24]
and rdx, 0777o                   ; Extract permission bits

; Use when creating destination file
mov rsi, 577                     ; flags
; rdx already has permissions from source
```

### Challenge 3: Multiple File Copy

Copy multiple files to a directory:

```bash
./filecp file1.txt file2.txt file3.txt destination_dir/
```

### Challenge 4: Verify Copy with Hash

After copying, compute a simple checksum of both files to verify:

```asm
; XOR all bytes together for simple checksum
xor rbx, rbx                     ; checksum = 0
xor rcx, rcx                     ; index = 0

checksum_loop:
    cmp rcx, bytes_read
    jge checksum_done

    mov al, [buffer + rcx]
    xor bl, al                   ; checksum ^= byte
    inc rcx
    jmp checksum_loop
```

### Challenge 5: Sparse File Support

Detect runs of zero bytes and use `lseek` to create holes (sparse files):

```asm
; If buffer is all zeros, seek instead of writing
; Check if buffer contains only zeros
call is_all_zeros
test rax, rax
jz normal_write

; Skip this section (create hole)
mov rax, 8                       ; sys_lseek
mov rdi, r15                     ; destination fd
mov rsi, rdx                     ; offset = bytes to skip
mov rdx, 1                       ; SEEK_CUR (from current position)
syscall
jmp copy_loop

normal_write:
    ; Write normally
```

## File Permissions Explained

Unix permissions are a 3-digit octal number (or 4 with special bits):

```
0644 = 0 110 100 100 (binary)
       │ │   │   │
       │ │   │   └─ Others: r-- (read)
       │ │   └───── Group:  r-- (read)
       │ └───────── Owner:  rw- (read, write)
       └─────────── Special bits: none

Each digit is sum of:
4 = read (r)
2 = write (w)
1 = execute (x)

Common permissions:
0644 = rw-r--r--  (file readable by all, writable by owner)
0755 = rwxr-xr-x  (executable readable/runnable by all)
0600 = rw-------  (file private to owner)
0700 = rwx------  (executable private to owner)
```

## Real-World Applications

File I/O is fundamental to:
- **Backup tools**: cp, rsync, tar
- **File utilities**: cat, grep, sed, awk
- **Compilers**: Reading source, writing object files
- **Databases**: Reading/writing data files
- **Web servers**: Serving static files
- **Media players**: Reading audio/video files

## Debugging with strace

See exactly what system calls your program makes:

```bash
strace ./filecp source.txt dest.txt
```

Output:
```
open("source.txt", O_RDONLY)            = 3
open("dest.txt", O_WRONLY|O_CREAT|O_TRUNC, 0644) = 4
read(3, "Hello, World!\n", 4096)        = 14
write(4, "Hello, World!\n", 14)         = 14
read(3, "", 4096)                       = 0
close(3)                                = 0
close(4)                                = 0
exit(0)                                 = ?
```

This shows:
- File descriptors (3 and 4)
- Exact flags and permissions
- Bytes read/written
- Return values

## Performance Optimization

### 1. Larger Buffers for Large Files

```asm
section .bss
    buffer resb 65536            ; 64KB buffer (faster for large files)
```

### 2. Minimize Syscalls

Each syscall has overhead. Reading/writing larger chunks reduces this.

### 3. Use mmap for Large Files (Advanced)

Map the entire file into memory:

```asm
mov rax, 9                       ; sys_mmap
xor rdi, rdi                     ; let kernel choose address
mov rsi, file_size               ; map entire file
mov rdx, 1                       ; PROT_READ
mov r10, 1                       ; MAP_SHARED
mov r8, r14                      ; source file descriptor
xor r9, r9                       ; offset 0
syscall
```

## Next Steps

Once you complete this assignment, move on to:
- String processing with file I/O
- Building more complex file utilities
- Working with directories (openat, getdents)

## Resources

- [System Calls Reference](../../resources/syscalls-linux.md)
- [Instruction Reference](../../resources/instruction-reference.md)
- `man 2 open` - open() syscall documentation
- `man 2 read` - read() syscall documentation
- `man 2 write` - write() syscall documentation
- `man 7 inode` - Understanding file permissions
