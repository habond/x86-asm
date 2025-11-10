# Advanced Heap Allocation Concepts

This document dives deeper into memory allocation concepts beyond the basic tutorial.

## Table of Contents

1. [Memory Layout Deep Dive](#memory-layout-deep-dive)
2. [Advanced Allocator Techniques](#advanced-allocator-techniques)
3. [Implementing malloc/free](#implementing-mallocfree)
4. [Performance Considerations](#performance-considerations)
5. [Real-World Allocators](#real-world-allocators)

## Memory Layout Deep Dive

### Virtual vs Physical Memory

When your program requests memory with `brk` or `mmap`, it receives **virtual** memory addresses, not physical RAM addresses. The kernel's Memory Management Unit (MMU) translates these.

```
Virtual Address Space (per process):
┌──────────────────┐ 0xFFFFFFFFFFFFFFFF
│   Kernel Space   │  High addresses
│  (not accessible)│
├──────────────────┤ 0x00007FFFFFFFFFFF
│      Stack       │  ↓ grows down
│                  │
│                  │
│       ↕          │  Unmapped gap
│                  │
│      Heap        │  ↑ grows up
├──────────────────┤
│   BSS (.bss)     │  Uninitialized data
├──────────────────┤
│   Data (.data)   │  Initialized data
├──────────────────┤
│   Text (.text)   │  Code (read-only)
└──────────────────┘ 0x0000000000400000 (typical)
```

### Page-Based Allocation

The kernel allocates memory in **pages** (typically 4096 bytes on x86-64). When you call `brk`, the kernel rounds up to the next page boundary internally.

```nasm
; Request 100 bytes
mov rdi, current_break
add rdi, 100
mov rax, 12         ; sys_brk
syscall

; Kernel actually allocates a full 4096-byte page
; Your program gets 100 bytes, rest is "wasted" but available
```

### Memory Permissions

Memory regions have permissions (read, write, execute):

```
Section      | Permissions | Purpose
-------------|-------------|------------------
.text        | R-X         | Code (no writing!)
.data        | RW-         | Data (no executing!)
.bss         | RW-         | Uninitialized data
heap (brk)   | RW-         | Dynamic allocations
heap (mmap)  | RW- or RWX  | Configurable
stack        | RW-         | Stack frames
```

You can see this with:
```bash
cat /proc/self/maps
```

## Advanced Allocator Techniques

### 1. Free Lists

Instead of always growing the heap, maintain a list of freed blocks:

```nasm
; Block structure with free list
struc Block
    .size:   resq 1     ; Block size (including header)
    .free:   resq 1     ; 1 = free, 0 = allocated
    .next:   resq 1     ; Next block in free list
    .prev:   resq 1     ; Previous block (for coalescing)
    .data:              ; User data starts here
endstruc

section .bss
    free_list_head resq 1   ; Pointer to first free block
```

**malloc algorithm**:
1. Search `free_list_head` for suitable block
2. If found, remove from list and return
3. If not found, grow heap

**free algorithm**:
1. Mark block as free
2. Add to `free_list_head`
3. Optionally: coalesce with adjacent free blocks

### 2. Block Coalescing

When you free a block next to another free block, merge them:

```
Before free:
┌──────────┐
│  Block A │  (allocated)
├──────────┤
│  Block B │  (free)
├──────────┤
│  Block C │  (allocated)
├──────────┤
│  Block D │  (free)
└──────────┘

After freeing Block A:
┌──────────┐
│ Block A+B│  (free, merged!)
├──────────┤
│  Block C │  (allocated)
├──────────┤
│  Block D │  (free)
└──────────┘

After freeing Block C:
┌──────────┐
│ Block A+B│  (free)
├──────────┤
│Block C+D │  (free, merged!)
└──────────┘
```

**Coalescing algorithm**:
```nasm
free_block:
    ; Mark block as free
    mov qword [rdi + Block.free], 1

    ; Check if next block is free
    mov rax, [rdi + Block.size]
    add rax, rdi                    ; rax = next block address
    cmp qword [rax + Block.free], 1
    jne .check_prev

    ; Merge with next block
    mov rbx, [rax + Block.size]
    add [rdi + Block.size], rbx     ; Grow current block
    mov rcx, [rax + Block.next]
    mov [rdi + Block.next], rcx     ; Update next pointer

.check_prev:
    ; Similar logic for previous block...
    ret
```

### 3. Size Classes (Bins)

Organize free blocks by size for faster searches:

```nasm
section .bss
    ; Fast bins: < 64 bytes (8-byte increments)
    fast_bins resq 8        ; 8, 16, 24, 32, 40, 48, 56, 64

    ; Small bins: 64-512 bytes (16-byte increments)
    small_bins resq 28      ; 64, 80, 96, ..., 512

    ; Large bins: > 512 bytes (sorted by size)
    large_bins resq 1
```

**malloc with bins**:
```nasm
my_malloc:
    ; Determine size class
    cmp rdi, 64
    jl .fast_bin
    cmp rdi, 512
    jl .small_bin
    jmp .large_bin

.fast_bin:
    ; Calculate bin index: (size / 8) - 1
    mov rax, rdi
    shr rax, 3
    dec rax

    ; Get block from bin[rax]
    lea rbx, [rel fast_bins]
    mov rcx, [rbx + rax*8]
    test rcx, rcx
    jz .grow_heap          ; Bin empty, need to grow

    ; Remove from bin and return
    mov rdx, [rcx + Block.next]
    mov [rbx + rax*8], rdx
    mov rax, rcx
    ret
```

### 4. Alignment Requirements

Some data types need specific alignment:

- `char`: 1-byte aligned
- `short`: 2-byte aligned
- `int`: 4-byte aligned
- `long/pointer`: 8-byte aligned
- `SIMD types`: 16-byte or 32-byte aligned

**Alignment formula**:
```nasm
; Align size to N-byte boundary
; Formula: (size + N-1) & ~(N-1)

align_16:
    add rdi, 15
    and rdi, -16        ; Clear low 4 bits
    ret

align_32:
    add rdi, 31
    and rdi, -32        ; Clear low 5 bits
    ret
```

### 5. Metadata Packing

Save space by packing metadata:

```nasm
; Instead of separate size and free fields,
; pack them into one word:
; Bits 0-2: Flags (free, mmapped, etc.)
; Bits 3-63: Size (already 8-byte aligned, so low 3 bits free!)

struc CompactBlock
    .size_and_flags: resq 1     ; Combined
    .next:          resq 1
    .prev:          resq 1
    .data:                      ; User data
endstruc

; Get size
get_size:
    mov rax, [rdi + CompactBlock.size_and_flags]
    and rax, -8                 ; Clear low 3 bits
    ret

; Check if free
is_free:
    mov rax, [rdi + CompactBlock.size_and_flags]
    and rax, 1                  ; Check bit 0
    ret

; Set size (preserving flags)
set_size:
    mov rax, [rdi + CompactBlock.size_and_flags]
    and rax, 7                  ; Keep only flags
    or rax, rsi                 ; Add size (must be aligned!)
    mov [rdi + CompactBlock.size_and_flags], rax
    ret
```

## Implementing malloc/free

Here's a more complete allocator:

```nasm
section .data
    heap_start dq 0
    heap_end dq 0

section .bss
    struc Block
        .size:  resq 1
        .free:  resq 1
        .next:  resq 1
        .data:              ; 24-byte header
    endstruc

section .text

; Initialize heap
init_heap:
    call get_current_break
    mov [rel heap_start], rax
    mov [rel heap_end], rax
    ret

; Find free block of at least 'rdi' bytes
; Returns: rax = block address (or 0 if not found)
find_free_block:
    push rbx
    mov rbx, rdi                    ; Save requested size
    mov rax, [rel heap_start]

.loop:
    cmp rax, [rel heap_end]
    jge .not_found

    ; Check if block is free and large enough
    cmp qword [rax + Block.free], 1
    jne .next

    mov rcx, [rax + Block.size]
    cmp rcx, rbx
    jl .next

    ; Found suitable block
    pop rbx
    ret

.next:
    mov rax, [rax + Block.next]
    jmp .loop

.not_found:
    xor rax, rax
    pop rbx
    ret

; Allocate new block from heap
; Input: rdi = size (including header)
; Returns: rax = block address (or -1 on error)
alloc_new_block:
    push rdi
    call grow_heap
    test rax, rax
    js .error

    ; Initialize block header
    pop rdi
    mov [rax + Block.size], rdi     ; Set size
    mov qword [rax + Block.free], 0 ; Mark allocated

    ; Update next pointer
    add rdi, rax
    mov [rax + Block.next], rdi
    mov [rel heap_end], rdi

    ret

.error:
    pop rdi
    mov rax, -1
    ret

; Public malloc interface
; Input: rdi = requested size
; Output: rax = pointer to memory (or -1 on error)
my_malloc:
    push rbx

    ; Add header size and align
    add rdi, 24                     ; Header = 24 bytes
    add rdi, 15
    and rdi, -16                    ; 16-byte alignment

    mov rbx, rdi                    ; Save total size

    ; Try to find free block
    call find_free_block
    test rax, rax
    jz .alloc_new

    ; Reuse free block
    mov qword [rax + Block.free], 0
    add rax, 24                     ; Return data pointer
    pop rbx
    ret

.alloc_new:
    mov rdi, rbx
    call alloc_new_block
    test rax, rax
    js .error

    add rax, 24                     ; Return data pointer
    pop rbx
    ret

.error:
    mov rax, -1
    pop rbx
    ret

; Public free interface
; Input: rdi = pointer to free
my_free:
    ; Get block header
    sub rdi, 24

    ; Mark as free
    mov qword [rdi + Block.free], 1

    ; TODO: Coalesce with adjacent free blocks

    ret
```

## Performance Considerations

### 1. Fragmentation

**External fragmentation**: Free memory exists but is scattered in small blocks

```
┌──┬────┬──┬──┬────┬──┐
│A │free│B │C │free│D │
└──┴────┴──┴──┴────┴──┘
        ^          ^
        |          |
    Can't allocate large block even though
    total free space is sufficient!
```

**Solutions**:
- Coalescing (merge adjacent free blocks)
- Best-fit allocation (find smallest suitable block)
- Compaction (move allocated blocks together)

**Internal fragmentation**: Allocated more than requested

```
Requested: 100 bytes
Allocated: 128 bytes (due to alignment)
Wasted: 28 bytes
```

**Solutions**:
- Size classes (reduce per-allocation waste)
- Metadata packing (reduce header overhead)

### 2. Allocation Speed

**Fast paths**:
- Keep recently freed blocks in a cache
- Use size-specific free lists
- Avoid system calls when possible

**Slow paths**:
- Growing the heap (syscall)
- Searching large free lists
- Coalescing many blocks

### 3. Thread Safety

For multi-threaded programs:

```nasm
; Option 1: Global lock (simple but slow)
malloc:
    call acquire_lock
    ; ... allocate ...
    call release_lock
    ret

; Option 2: Per-thread arenas (faster)
malloc:
    ; Each thread has its own heap region
    call get_thread_arena
    ; ... allocate from thread-local heap ...
    ret
```

## Real-World Allocators

### glibc malloc (ptmalloc2)

Features:
- **Bins**: fastbins, smallbins, largebins, unsorted bin
- **Thread arenas**: Reduce contention
- **mmap threshold**: Large allocations use mmap
- **Top chunk**: Expandable region at heap end

Bin sizes:
```
Fastbins: 16, 24, 32, ..., 64 bytes (singly-linked)
Smallbins: 16, 24, 32, ..., 512 bytes (doubly-linked)
Largebins: 512+, sorted by size (doubly-linked)
```

### jemalloc

Used by: Firefox, Facebook, FreeBSD

Features:
- **Size classes**: Logarithmically spaced
- **Thread caching**: Per-thread cache of small allocations
- **Arenas**: Multiple independent heaps
- **Low fragmentation**: Advanced coalescing

### tcmalloc (Thread-Caching Malloc)

Used by: Chrome, Google

Features:
- **Thread-local caches**: Very fast for small allocations
- **Central free lists**: Per-size-class
- **Page heap**: Manages large blocks
- **Minimal lock contention**: Lock-free in common case

### mimalloc

By Microsoft, used in various MS products

Features:
- **Free list sharding**: Reduce false sharing
- **Secure**: Guards against heap exploits
- **Fast**: Optimized for modern CPUs
- **Compact**: Low memory overhead

## Further Reading

### Books
- "Understanding the Linux Kernel" by Bovet & Cesati
- "Computer Systems: A Programmer's Perspective" by Bryant & O'Hallaron
- "The Linux Programming Interface" by Michael Kerrisk

### Papers
- "The Memory Fragmentation Problem: Solved?" by Wilson et al.
- "Hoard: A Scalable Memory Allocator" by Berger et al.
- "TCMalloc: Thread-Caching Malloc" (Google)

### Source Code
- glibc malloc: `glibc/malloc/malloc.c`
- jemalloc: https://github.com/jemalloc/jemalloc
- tcmalloc: https://github.com/google/tcmalloc
- mimalloc: https://github.com/microsoft/mimalloc

### Online Resources
- Linux memory management: https://www.kernel.org/doc/html/latest/vm/
- Understanding glibc malloc: https://sourceware.org/glibc/wiki/MallocInternals
- Malloc tutorial: https://danluu.com/malloc-tutorial/

## Exercises

1. **Implement my_free**: Add proper freeing with free list management
2. **Add coalescing**: Merge adjacent free blocks
3. **Size classes**: Implement fast bins for small allocations
4. **Best-fit**: Find smallest suitable free block instead of first-fit
5. **Split blocks**: Split large free blocks when allocating small sizes
6. **Alignment parameter**: Support custom alignment (8, 16, 32, 64 bytes)
7. **Statistics**: Track total allocated, freed, overhead, fragmentation
8. **Use mmap**: Switch to mmap for allocations > 128KB
9. **Thread-local cache**: Simple per-thread allocation cache
10. **Heap dump**: Print all blocks showing size, status, addresses

Happy hacking! 🚀
