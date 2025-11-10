# Dynamic Memory Allocation (The Heap)

## Overview

In this assignment, you'll learn how to allocate and manage dynamic memory (the heap) in x86-64 assembly using the `brk` and `mmap` system calls. This is fundamental to understanding how `malloc()` and `free()` work in C.

## Learning Objectives

- Understand the difference between stack and heap memory
- Learn how the program break (`brk`) works
- Use the `brk` system call to allocate memory
- Learn about `mmap` for larger allocations
- Implement a simple memory allocator
- Manage dynamically allocated memory regions

## Memory Regions in a Linux Process

When your program runs, it has several memory regions:

```
High addresses
┌─────────────────┐
│  Kernel Space   │  (not accessible)
├─────────────────┤
│     Stack       │  ↓ grows down
│                 │
│       ↕         │
│                 │
│      Heap       │  ↑ grows up
├─────────────────┤
│   BSS (.bss)    │  Uninitialized data
├─────────────────┤
│   Data (.data)  │  Initialized data
├─────────────────┤
│   Text (.text)  │  Code
└─────────────────┘
Low addresses
```

### Key Points:

1. **Stack**: Automatic memory, managed by the CPU
   - Local variables, function parameters
   - Limited size (usually ~8MB on Linux)
   - Fast allocation/deallocation

2. **Heap**: Dynamic memory, managed by your program
   - Allocated explicitly with syscalls
   - Can grow much larger than stack
   - Persists until explicitly freed

## The Program Break (`brk`)

The "program break" is a pointer to the end of your heap. Initially, it's set just after your BSS section. When you need more heap memory, you ask the OS to move the break higher.

### Visualizing the Break:

```
Before allocation:
┌──────────┐
│   BSS    │
├──────────┤ ← program break (sbrk(0) returns this address)
│          │
│ (unused) │
│          │
└──────────┘

After brk(break + 1024):
┌──────────┐
│   BSS    │
├──────────┤ ← old break
│          │
│   1024   │  Your allocated memory
│  bytes   │
├──────────┤ ← new program break
│          │
│ (unused) │
└──────────┘
```

## System Calls for Heap Allocation

### 1. `brk` - Set Program Break (syscall 12)

Changes the program break to a new address.

**Arguments:**
- `rdi`: New break address (or 0 to query current break)

**Returns:**
- `rax`: 0 on success, -1 on failure (or current break if rdi=0)

**Example:**
```nasm
; Get current break
mov rax, 12         ; sys_brk
xor rdi, rdi        ; 0 = query current
syscall
; rax now contains current break address

; Allocate 1024 bytes
mov rdi, rax        ; Current break
add rdi, 1024       ; Add 1024 bytes
mov rax, 12         ; sys_brk
syscall
; If rax >= 0, allocation succeeded
```

**Note:** Modern Linux `brk` returns the new break address on success (not 0), so check if `rax >= old_break`.

### 2. `mmap` - Memory Map (syscall 9)

More flexible than `brk`, allows allocating memory at specific addresses and with specific permissions.

**Arguments:**
- `rdi`: Address hint (0 = let kernel choose)
- `rsi`: Length in bytes
- `rdx`: Protection flags (PROT_READ=1, PROT_WRITE=2, PROT_EXEC=4)
- `r10`: Flags (MAP_PRIVATE=2, MAP_ANONYMOUS=32)
- `r8`: File descriptor (-1 for anonymous mapping)
- `r9`: Offset (0 for anonymous mapping)

**Returns:**
- `rax`: Address of allocated memory (or negative error code)

**Example:**
```nasm
; Allocate 4096 bytes (1 page) with mmap
xor rdi, rdi        ; Let kernel choose address
mov rsi, 4096       ; Size
mov rdx, 3          ; PROT_READ | PROT_WRITE
mov r10, 34         ; MAP_PRIVATE | MAP_ANONYMOUS
mov r8, -1          ; No file descriptor
xor r9, r9          ; No offset
mov rax, 9          ; sys_mmap
syscall
; rax contains address of allocated memory
```

### 3. `munmap` - Unmap Memory (syscall 11)

Frees memory allocated with `mmap`.

**Arguments:**
- `rdi`: Address to unmap
- `rsi`: Length in bytes

**Returns:**
- `rax`: 0 on success, negative error code on failure

## When to Use `brk` vs `mmap`

**Use `brk` when:**
- Allocating small amounts of memory (< 1 page)
- You want contiguous heap growth
- Implementing a simple allocator

**Use `mmap` when:**
- Allocating large blocks (typically >= 128KB)
- You want isolated memory regions
- You need specific permissions or mapping files

**In practice**: `malloc()` in glibc uses:
- `brk` for allocations < 128KB
- `mmap` for allocations >= 128KB

## Building a Simple Allocator

A basic allocator needs to:

1. **Track allocated blocks** - Know what's in use
2. **Find free space** - Reuse freed blocks
3. **Grow the heap** - Request more memory when needed
4. **Free blocks** - Mark memory as available

### Metadata Structure

Each allocated block has metadata:

```
┌──────────────┐
│ Size (8B)    │  How many bytes (including header)
├──────────────┤
│ Is Free? (8B)│  1 = free, 0 = allocated
├──────────────┤
│              │
│  User Data   │  The memory you actually use
│              │
└──────────────┘
```

### Example Allocator Structure:

```nasm
; Block header structure (16 bytes)
struc Block
    .size:   resq 1     ; Total size including header
    .free:   resq 1     ; 1 if free, 0 if allocated
    .data:              ; Start of user data
endstruc

; Allocation logic:
; 1. Search existing blocks for free space
; 2. If found, mark as allocated and return
; 3. If not found, grow heap with brk
; 4. Add new block and return
```

## Assignment: Implement a Memory Allocator

In this assignment, you'll implement:

1. **my_malloc(size)** - Allocate `size` bytes
   - Search for a free block of sufficient size
   - If found, mark it allocated and return pointer
   - If not found, grow heap and create new block

2. **my_free(ptr)** - Free allocated memory
   - Find the block containing `ptr`
   - Mark it as free

3. **Demonstration program** - Show it works
   - Allocate several blocks
   - Free some blocks
   - Allocate again (should reuse freed space)
   - Print addresses to verify behavior

## Implementation Steps

### Step 1: Get Initial Break

```nasm
get_break:
    mov rax, 12         ; sys_brk
    xor rdi, rdi        ; Query current break
    syscall
    ret                 ; Returns break in rax
```

### Step 2: Grow Heap

```nasm
grow_heap:
    ; Input: rdi = number of bytes to grow
    ; Output: rax = address of new memory (or -1 on error)

    push rdi            ; Save size
    call get_break      ; Get current break
    mov r8, rax         ; Save old break

    pop rdi             ; Restore size
    add rdi, rax        ; New break = old + size
    mov rax, 12         ; sys_brk
    syscall

    ; Check if allocation succeeded
    cmp rax, r8
    jl .error           ; If new < old, failed
    mov rax, r8         ; Return old break (start of new memory)
    ret
.error:
    mov rax, -1
    ret
```

### Step 3: Simple Allocator

For this assignment, we'll implement a **simple bump allocator** (no freeing, just keeps growing):

```nasm
my_malloc:
    ; Input: rdi = size in bytes
    ; Output: rax = pointer to allocated memory

    ; Add space for header (16 bytes)
    add rdi, 16

    ; Align to 16-byte boundary
    add rdi, 15
    and rdi, -16

    ; Grow heap
    call grow_heap

    ; rax now points to allocated memory
    ; We'll return rax + 16 (skip header)
    add rax, 16
    ret
```

### Step 4: Test It

```nasm
_start:
    ; Allocate 100 bytes
    mov rdi, 100
    call my_malloc
    mov [buffer1], rax  ; Save pointer

    ; Allocate 200 bytes
    mov rdi, 200
    call my_malloc
    mov [buffer2], rax  ; Save pointer

    ; Use the memory
    mov rdi, [buffer1]
    mov byte [rdi], 'A'

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```

## Going Further: Full Allocator with Freeing

To implement `my_free`, you need to:

1. **Store metadata** in the header
2. **Maintain a free list** of available blocks
3. **Search the free list** in my_malloc before growing heap
4. **Coalesce adjacent blocks** when freeing

### Block Header with Free List:

```nasm
struc Block
    .size:   resq 1     ; Total size including header
    .free:   resq 1     ; 1 = free, 0 = allocated
    .next:   resq 1     ; Pointer to next block (or 0)
    .data:              ; Start of user data (24 bytes offset)
endstruc
```

### Enhanced malloc:

```nasm
my_malloc:
    ; 1. Search free list for suitable block
    ; 2. If found, mark allocated and return
    ; 3. If not, grow heap, add to list, return

my_free:
    ; 1. Find block header (ptr - 24)
    ; 2. Mark as free
    ; 3. Optionally: coalesce with neighbors
```

## Debugging Tips

### 1. Print Addresses

To see what's happening:

```nasm
; Print address in rax (hex)
print_hex:
    ; Convert rax to hex string and print
    ; (see string formatting examples)
```

### 2. Use GDB to Inspect Memory

```bash
(gdb) x/32gx $rax      # Examine 32 quadwords at address in rax
(gdb) print/x $rax     # Print rax in hex
(gdb) info proc map    # Show memory mappings
```

### 3. Check for Errors

Always check syscall return values:

```nasm
mov rax, 12         ; sys_brk
mov rdi, new_break
syscall
test rax, rax
js .error           ; Jump if sign flag set (negative)
```

### 4. Verify Alignment

Heap allocations should be 16-byte aligned:

```nasm
test rax, 15        ; Check low 4 bits
jnz .misaligned     ; Should be zero
```

## Common Mistakes

### 1. Not Checking Return Values

```nasm
; WRONG: Assume syscall succeeded
call grow_heap
mov [rax], byte 'A'     ; Crash if rax = -1!

; RIGHT: Check for errors
call grow_heap
test rax, rax
js .error
mov [rax], byte 'A'     ; Safe
```

### 2. Forgetting Header Space

```nasm
; WRONG: Return start of block
my_malloc:
    call grow_heap
    ret                 ; User will overwrite header!

; RIGHT: Skip header
my_malloc:
    call grow_heap
    add rax, 16         ; Return data section
    ret
```

### 3. No Alignment

```nasm
; WRONG: Allocate exact size
mov rdi, 100
call grow_heap

; RIGHT: Align to 16 bytes
mov rdi, 100
add rdi, 15
and rdi, -16
call grow_heap
```

### 4. Integer Overflow

When adding header size, check for overflow:

```nasm
; Better: Check for overflow
mov rdi, requested_size
add rdi, 16
jc .overflow            ; Carry flag set if overflow
```

## Testing Your Allocator

### Basic Test:

```nasm
_start:
    ; Test 1: Allocate and use
    mov rdi, 100
    call my_malloc
    test rax, rax
    js .fail

    mov byte [rax], 'H'
    mov byte [rax+1], 'i'
    mov byte [rax+2], 0

    ; Test 2: Multiple allocations
    mov rdi, 50
    call my_malloc
    mov [ptr2], rax

    mov rdi, 200
    call my_malloc
    mov [ptr3], rax

    ; Verify they don't overlap
    ; ptr2 should be > ptr1 + 100
    ; ptr3 should be > ptr2 + 50
```

### Advanced Test (with freeing):

```nasm
    ; Allocate 3 blocks
    mov rdi, 100
    call my_malloc
    mov [ptr1], rax

    mov rdi, 100
    call my_malloc
    mov [ptr2], rax

    mov rdi, 100
    call my_malloc
    mov [ptr3], rax

    ; Free middle block
    mov rdi, [ptr2]
    call my_free

    ; Allocate again (should reuse freed block)
    mov rdi, 100
    call my_malloc
    mov [ptr4], rax

    ; ptr4 should equal ptr2 if reusing worked!
```

## Expected Output

Your program should:

1. Successfully allocate multiple blocks
2. Return valid, aligned pointers
3. Not crash when writing to allocated memory
4. (Bonus) Reuse freed blocks instead of always growing

Example output:

```
Allocated 100 bytes at 0x555555560000
Allocated 200 bytes at 0x555555560070
Allocated 50 bytes at 0x5555555600e0
Freed block at 0x555555560070
Allocated 150 bytes at 0x555555560070  (reused!)
All tests passed!
```

## Building and Running

```bash
# Build your implementation
make

# Run your code
make run

# See the solution
make solution

# Debug with GDB
make debug
```

## Resources

- **brk syscall**: `man 2 brk`
- **mmap syscall**: `man 2 mmap`
- **Linux x86-64 syscalls**: [../../../resources/syscalls-linux.md](../../../resources/syscalls-linux.md)
- **Memory management**: Understanding the Linux Virtual Memory Manager (online)

## Real-World Context

### How glibc malloc Works

The real `malloc()` is much more sophisticated:

1. **Multiple arenas** - Reduces contention in multi-threaded programs
2. **Bins** - Different size classes for efficiency
   - Fast bins (< 64 bytes)
   - Small bins (< 512 bytes)
   - Large bins (>= 512 bytes)
3. **Chunk reuse** - Maintains free lists
4. **Coalescing** - Merges adjacent free blocks
5. **Top chunk** - Expandable region at heap end
6. **mmap threshold** - Large allocations use mmap

### Other Allocators

- **jemalloc** - Used by Firefox, Facebook
- **tcmalloc** - Used by Chrome, Google
- **mimalloc** - Microsoft's allocator

All use similar principles but with different trade-offs for speed, fragmentation, and thread-safety.

## Challenge Exercises

1. **Implement my_free** - Mark blocks as free and reuse them
2. **Block coalescing** - Merge adjacent free blocks
3. **Best-fit search** - Find smallest suitable free block
4. **Alignment parameter** - Support custom alignment (8, 16, 32 bytes)
5. **Use mmap** - Switch to mmap for allocations > 4KB
6. **Error handling** - Return NULL on allocation failure
7. **Statistics** - Track total allocated, freed, and in-use bytes

## Summary

In this assignment, you learned:

- ✅ The difference between stack and heap memory
- ✅ How the program break works
- ✅ Using the `brk` system call to grow the heap
- ✅ Implementing a basic memory allocator
- ✅ Managing dynamically allocated memory
- ✅ The basics of how `malloc()` works

You now understand one of the most fundamental building blocks of system programming!

## Next Steps

After completing this assignment:
- Try [06-hash-table](../06-hash-table/) to use dynamic allocation in a real data structure
- Experiment with different allocation strategies
- Read about memory allocators in operating systems textbooks
- Study the glibc malloc implementation

Good luck! 🚀
