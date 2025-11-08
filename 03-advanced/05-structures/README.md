# Assignment 5: Structures

Learn to work with C-like structures in assembly, managing complex data layouts and memory organization.

## Learning Objectives

- Define structure layouts and field offsets
- Access structure fields using base+offset addressing
- Work with arrays of structures
- Pass structures to functions
- Understand memory alignment and padding
- Implement structure-based algorithms

## Background

Structures (or records) are fundamental to organizing complex data. In assembly, you must:
- **Calculate offsets** manually for each field
- **Manage alignment** to ensure efficient memory access
- **Handle pointers** to structures correctly
- **Understand layout** in memory

Real-world uses:
- **Operating systems** (process control blocks, file descriptors)
- **Networking** (packet headers, socket structures)
- **Graphics** (vertex data, scene graphs)
- **Databases** (record layouts, indexes)

## The Task

Implement functions to manage an array of Student structures:

```c
// Equivalent C structure
struct Student {
    uint64_t id;      // 8 bytes, offset 0
    uint64_t age;     // 8 bytes, offset 8
    uint64_t grade;   // 8 bytes, offset 16
    char name[24];    // 24 bytes, offset 24
};                    // Total: 48 bytes
```

Your program should:
1. Define an array of students
2. Find a student by ID
3. Calculate the average grade
4. Access and modify structure fields

## Structure Layout in Memory

```
Student structure (48 bytes total):
+------------------+
| id (8 bytes)     | Offset 0
+------------------+
| age (8 bytes)    | Offset 8
+------------------+
| grade (8 bytes)  | Offset 16
+------------------+
| name[0..7]       | Offset 24
+------------------+
| name[8..15]      | Offset 32
+------------------+
| name[16..23]     | Offset 40
+------------------+

Array of students:
Student[0] at base + 0*48
Student[1] at base + 1*48
Student[2] at base + 2*48
```

## Defining Structures

### Using EQU for Offsets

```asm
section .data
    ; Structure field offsets
    STUDENT_ID      equ 0
    STUDENT_AGE     equ 8
    STUDENT_GRADE   equ 16
    STUDENT_NAME    equ 24
    STUDENT_SIZE    equ 48

    ; Array of students
    students:
        ; Student 0: id=101, age=20, grade=85, name="Alice"
        dq 101                      ; id
        dq 20                       ; age
        dq 85                       ; grade
        db "Alice", 0               ; name (null-terminated)
        times 19 db 0               ; padding to 24 bytes

        ; Student 1: id=102, age=21, grade=92, name="Bob"
        dq 102
        dq 21
        dq 92
        db "Bob", 0
        times 21 db 0

        ; Student 2: id=103, age=19, grade=78, name="Charlie"
        dq 103
        dq 19
        dq 78
        db "Charlie", 0
        times 17 db 0

    student_count equ 3
```

## Accessing Structure Fields

### Reading a Field

```asm
; Get the grade of student at index i
; rdi = array base address
; rsi = index
; Returns: rax = grade

get_grade:
    ; Calculate address: base + index * STUDENT_SIZE
    mov rax, rsi
    mov rcx, STUDENT_SIZE
    mul rcx                 ; rax = index * size
    add rax, rdi           ; rax = base + offset

    ; Read grade field
    mov rax, [rax + STUDENT_GRADE]
    ret
```

### Writing a Field

```asm
; Set the grade of student at index i
; rdi = array base address
; rsi = index
; rdx = new grade

set_grade:
    ; Calculate address
    mov rax, rsi
    mov rcx, STUDENT_SIZE
    mul rcx
    add rax, rdi

    ; Write grade field
    mov [rax + STUDENT_GRADE], rdx
    ret
```

## Iterating Over Structures

```asm
; Calculate sum of all grades
; rdi = array base address
; rsi = count
; Returns: rax = sum

sum_grades:
    xor rax, rax           ; sum = 0
    xor rcx, rcx           ; i = 0

loop:
    cmp rcx, rsi           ; i < count?
    jge done

    ; Calculate address of student[i]
    mov rbx, rcx
    mov rdx, STUDENT_SIZE
    push rax               ; Save sum
    mov rax, rbx
    mul rdx                ; rax = i * STUDENT_SIZE
    pop rbx                ; Restore sum to rbx
    add rax, rdi           ; rax = &students[i]

    ; Add grade to sum
    mov rdx, [rax + STUDENT_GRADE]
    add rbx, rdx

    inc rcx
    mov rax, rbx           ; Move sum back to rax
    jmp loop

done:
    mov rax, rbx
    ret
```

## Searching Structures

```asm
; Find student by ID
; rdi = array base address
; rsi = count
; rdx = target ID
; Returns: rax = index (or -1 if not found)

find_by_id:
    xor rcx, rcx           ; i = 0

search_loop:
    cmp rcx, rsi           ; i < count?
    jge not_found

    ; Calculate address of student[i]
    push rcx               ; Save i
    mov rax, rcx
    mov rbx, STUDENT_SIZE
    mul rbx                ; rax = i * size
    add rax, rdi           ; rax = &students[i]

    ; Compare ID
    mov rbx, [rax + STUDENT_ID]
    cmp rbx, rdx
    pop rcx                ; Restore i
    je found

    inc rcx
    jmp search_loop

not_found:
    mov rax, -1
    ret

found:
    mov rax, rcx           ; Return index
    ret
```

## Passing Structures to Functions

### By Pointer (Recommended)

```asm
; Print student info
; rdi = pointer to student structure

print_student:
    push rbp
    mov rbp, rsp

    ; Access fields via pointer
    mov rax, [rdi + STUDENT_ID]
    mov rbx, [rdi + STUDENT_AGE]
    mov rcx, [rdi + STUDENT_GRADE]
    lea rdx, [rdi + STUDENT_NAME]

    ; ... print the values ...

    pop rbp
    ret
```

### Multiple Arguments

```asm
; Update student
; rdi = pointer to student
; rsi = new age
; rdx = new grade

update_student:
    mov [rdi + STUDENT_AGE], rsi
    mov [rdi + STUDENT_GRADE], rdx
    ret
```

## Starter Code

```asm
section .data
    ; Structure offsets
    STUDENT_ID      equ 0
    STUDENT_AGE     equ 8
    STUDENT_GRADE   equ 16
    STUDENT_NAME    equ 24
    STUDENT_SIZE    equ 48

    ; Array of students
    students:
        ; Define your students here
        ; TODO: Create 3-4 students

    student_count equ 3

section .text
global _start

; TODO: Implement find_student_by_id
; Arguments: rdi = target ID
; Returns: rax = index or -1
find_student_by_id:
    ; TODO: Search through students array
    ret

; TODO: Implement calculate_average
; Arguments: none (uses global students array)
; Returns: rax = average grade
calculate_average:
    ; TODO: Sum all grades and divide by count
    ret

_start:
    ; Test find_student_by_id(102)
    mov rdi, 102
    call find_student_by_id

    ; Exit with index (or 255 if not found)
    cmp rax, -1
    je not_found
    mov rdi, rax
    jmp exit

not_found:
    mov rdi, 255

exit:
    mov rax, 60
    syscall
```

## Building and Running

```bash
nasm -f elf64 student.asm -o student.o
ld -o student student.o
./student
echo $?                 # Should print 1 (index of student 102)
```

## Testing

Expected results:
- `find_student_by_id(101)` → 0 (first student)
- `find_student_by_id(102)` → 1 (second student)
- `find_student_by_id(999)` → -1 (not found) → exit 255
- `calculate_average()` → depends on your grades

## Memory Alignment

### Why Alignment Matters

```
Unaligned access (slow or crashes on some CPUs):
Address: 0x1003
+----+----+----+----+----+----+----+----+
| XX | QQ | QQ | QQ | QQ | QQ | QQ | QQ |
+----+----+----+----+----+----+----+----+
     ^^^^ 8-byte value not aligned to 8

Aligned access (fast):
Address: 0x1000
+----+----+----+----+----+----+----+----+
| QQ | QQ | QQ | QQ | QQ | QQ | QQ | QQ |
+----+----+----+----+----+----+----+----+
^^^^ 8-byte value aligned to 8
```

### Alignment Rules

- 1-byte values: no alignment needed
- 2-byte values: align to 2-byte boundary
- 4-byte values: align to 4-byte boundary
- 8-byte values: align to 8-byte boundary
- Structures: align to largest field's alignment

### Adding Padding

```asm
; Bad: misaligned fields
struct_bad:
    db 1                ; 1 byte
    dq 100              ; 8 bytes (misaligned!)

; Good: aligned fields
struct_good:
    db 1                ; 1 byte
    times 7 db 0        ; 7 bytes padding
    dq 100              ; 8 bytes (aligned to 8)
```

## Common Patterns

### Calculate Field Address

```asm
; Get address of specific field in array element
; rdi = base address
; rsi = index
; Result in rax

get_student_age_addr:
    mov rax, rsi
    mov rcx, STUDENT_SIZE
    mul rcx                 ; rax = index * size
    add rax, rdi           ; rax = base + offset
    add rax, STUDENT_AGE   ; rax = &student[i].age
    ret
```

### Copy Structure

```asm
; Copy one student to another
; rdi = destination pointer
; rsi = source pointer

copy_student:
    push rcx

    mov rcx, STUDENT_SIZE / 8  ; Number of qwords
copy_loop:
    mov rax, [rsi]
    mov [rdi], rax
    add rsi, 8
    add rdi, 8
    dec rcx
    jnz copy_loop

    pop rcx
    ret
```

### Nested Structures

```asm
; Structure with nested structure
section .data
    ; Offsets for Date
    DATE_YEAR   equ 0
    DATE_MONTH  equ 4
    DATE_DAY    equ 8
    DATE_SIZE   equ 12

    ; Offsets for Student with enrollment date
    STUDENT_ID_2      equ 0
    STUDENT_AGE_2     equ 8
    STUDENT_ENROLLED  equ 16   ; Nested Date structure
    STUDENT_SIZE_2    equ 28

; Access nested field
mov rax, [rdi + STUDENT_ENROLLED + DATE_YEAR]
```

## Debugging Tips

```bash
# In GDB, examine structures
(gdb) x/6gx &students         # View first student (6 qwords)
(gdb) x/s &students+24        # View name field

# Set breakpoints at structure access
(gdb) watch students[0].grade  # Break when grade changes

# Print calculated addresses
(gdb) print/x $rax + 16       # Address of grade field
```

## Common Mistakes

### Mistake 1: Wrong offset calculation

```asm
; Wrong - using wrong size
mov rax, rsi
mul 32                  ; Wrong size!
add rax, rdi

; Right
mov rax, rsi
mov rcx, STUDENT_SIZE   ; Use correct size constant
mul rcx
add rax, rdi
```

### Mistake 2: Forgetting to preserve registers

```asm
; Wrong - mul destroys rdx
sum_grades:
    mov rdx, rdi        ; Save base address
    mov rax, rcx
    mul STUDENT_SIZE    ; rdx destroyed!
    add rax, rdx        ; Wrong value!

; Right - save and restore
sum_grades:
    push rdx
    mov rax, rcx
    mov rbx, STUDENT_SIZE
    mul rbx
    pop rdx
    add rax, rdx
```

### Mistake 3: Incorrect string padding

```asm
; Wrong - name might overflow
db "This is a very long name that exceeds 24 bytes", 0

; Right - exactly 24 bytes
db "Alice", 0
times 19 db 0           ; Pad to 24 total
```

### Mistake 4: Misaligned structures

```asm
; Wrong - fields misaligned
student:
    db 1                ; 1 byte
    dq 101              ; Misaligned!

; Right - proper alignment
student:
    dq 101              ; Start with 8-byte field
    dq 20
    dq 85
    db "Alice", 0       ; String at end is fine
    times 19 db 0
```

## Going Further

### Challenge 1: Sort Students

Implement a bubble sort to sort students by grade (highest first).

```asm
; Hint: Compare grades, swap entire structures
```

### Challenge 2: Student Statistics

Calculate min, max, and average grade in one pass.

```asm
; Return all three values in rax, rbx, rcx
```

### Challenge 3: Dynamic Structure

Implement functions to add and remove students from the array.

```asm
; add_student(id, age, grade, name)
; remove_student(id)
```

### Challenge 4: Structure with Pointers

Create a linked list of students where each student has a pointer to the next.

```asm
struct Student {
    uint64_t id;
    uint64_t age;
    uint64_t grade;
    char name[24];
    Student* next;     ; Pointer to next student
}
```

### Challenge 5: Binary Search

Implement binary search on a sorted array of students.

```asm
; Requires array to be sorted by ID first
; Returns index or -1
```

## Real-World Example: Process Control Block

```asm
section .data
    ; Simplified OS process structure
    PROCESS_ID      equ 0
    PROCESS_STATE   equ 8      ; running, waiting, etc.
    PROCESS_PRIORITY equ 16
    PROCESS_STACK   equ 24     ; Stack pointer
    PROCESS_PC      equ 32     ; Program counter
    PROCESS_SIZE    equ 40

    processes:
        ; Process 0
        dq 1                    ; pid
        dq 1                    ; state (running)
        dq 10                   ; priority
        dq 0x7fff0000           ; stack pointer
        dq 0x400000             ; program counter

        ; Process 1
        dq 2
        dq 2                    ; state (waiting)
        dq 5
        dq 0x7fff8000
        dq 0x401000

section .text

; Find highest priority running process
find_next_process:
    lea rdi, [processes]
    mov rsi, 2              ; process count
    xor rax, rax           ; best index
    mov rbx, 0              ; best priority

find_loop:
    ; Check if running
    mov rcx, [rdi + PROCESS_STATE]
    cmp rcx, 1              ; Running state
    jne skip

    ; Compare priority
    mov rcx, [rdi + PROCESS_PRIORITY]
    cmp rcx, rbx
    jle skip

    ; Update best
    mov rbx, rcx
    mov rax, rdi
    sub rax, processes
    mov rcx, PROCESS_SIZE
    xor rdx, rdx
    div rcx                 ; rax = index

skip:
    add rdi, PROCESS_SIZE
    dec rsi
    jnz find_loop

    ret
```

## Performance Tips

### Use LEA for Address Calculation

```asm
; Slower - separate multiply and add
mov rax, rsi
mov rcx, STUDENT_SIZE
mul rcx
add rax, rdi

; Faster - if size is power of 2 or sum of registers
lea rax, [rdi + rsi*8]     ; For size=8
; Or for size=48 (not power of 2):
lea rax, [rdi + rsi*32]
lea rax, [rax + rsi*16]
```

### Cache Locality

```asm
; Better cache performance - access fields sequentially
mov rax, [rdi + STUDENT_ID]
mov rbx, [rdi + STUDENT_AGE]
mov rcx, [rdi + STUDENT_GRADE]

; Worse - jumping around memory
mov rax, [rdi + STUDENT_GRADE]
mov rbx, [rdi + STUDENT_ID]
mov rcx, [rdi + STUDENT_AGE]
```

## Next Steps

Once you complete this assignment, move on to:
- [06-hash-table](../06-hash-table/) - Implement a hash table with structures

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Calling Conventions](../../resources/calling-conventions.md)
- [System V ABI Documentation](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf)
