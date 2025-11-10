; Dynamic Memory Allocation (The Heap)
;
; In this assignment, you'll implement a simple memory allocator using the brk system call.
;
; Your tasks:
; 1. Implement get_current_break - Get the current program break
; 2. Implement grow_heap - Allocate memory by growing the heap
; 3. Implement my_malloc - Simple bump allocator
; 4. Test your allocator with multiple allocations

section .data
    test_msg db "Testing memory allocator...", 10, 0
    test_msg_len equ $ - test_msg

    alloc1_msg db "Allocated block 1: ", 0
    alloc1_msg_len equ $ - alloc1_msg

    alloc2_msg db "Allocated block 2: ", 0
    alloc2_msg_len equ $ - alloc2_msg

    alloc3_msg db "Allocated block 3: ", 0
    alloc3_msg_len equ $ - alloc3_msg

    success_msg db "All tests passed!", 10, 0
    success_msg_len equ $ - success_msg

    error_msg db "ERROR: Allocation failed!", 10, 0
    error_msg_len equ $ - error_msg

    newline db 10

section .bss
    ptr1 resq 1     ; Store first allocation
    ptr2 resq 1     ; Store second allocation
    ptr3 resq 1     ; Store third allocation

    hex_buffer resb 20  ; Buffer for hex conversion

section .text
    global _start

; TODO: Implement this function
; get_current_break - Get the current program break
; Input: none
; Output: rax = current break address
get_current_break:
    ; Hint: Use sys_brk (12) with rdi = 0 to query current break
    ; TODO: Your code here

    ret

; TODO: Implement this function
; grow_heap - Allocate memory by growing the heap
; Input: rdi = number of bytes to allocate
; Output: rax = address of allocated memory (or -1 on error)
grow_heap:
    ; Hint:
    ; 1. Get current break
    ; 2. Calculate new break (current + size)
    ; 3. Set new break with sys_brk
    ; 4. Check if it succeeded (new break >= old break)
    ; 5. Return old break (start of new memory)

    ; TODO: Your code here

    ret

; TODO: Implement this function
; my_malloc - Simple bump allocator
; Input: rdi = size in bytes
; Output: rax = pointer to allocated memory (or -1 on error)
my_malloc:
    ; Hints:
    ; 1. Add 16 bytes for metadata (even though we're not using it yet)
    ; 2. Align size to 16-byte boundary: add 15, then AND with -16
    ; 3. Call grow_heap
    ; 4. Return pointer (after header space, so add 16 to result)

    ; TODO: Your code here

    ret

; print_string - Print a null-terminated or length-specified string
; Input: rdi = pointer to string
;        rsi = length (or 0 to auto-detect null terminator)
print_string:
    push rdi
    push rsi
    push rdx

    ; If length is 0, find null terminator
    test rsi, rsi
    jnz .print

    ; Find string length
    mov rcx, rdi
.find_len:
    mov al, [rcx]
    test al, al
    jz .found_len
    inc rcx
    jmp .find_len
.found_len:
    mov rsi, rcx
    sub rsi, rdi    ; Length = end - start

.print:
    mov rdx, rsi    ; Length
    mov rsi, rdi    ; String
    mov rdi, 1      ; STDOUT
    mov rax, 1      ; sys_write
    syscall

    pop rdx
    pop rsi
    pop rdi
    ret

; print_hex - Print a 64-bit value in hexadecimal
; Input: rdi = value to print
print_hex:
    push rbx
    push rcx
    push rdx
    push rdi

    mov rax, rdi
    lea rdi, [rel hex_buffer]
    mov byte [rdi], '0'
    mov byte [rdi+1], 'x'
    add rdi, 2

    ; Print 16 hex digits
    mov rcx, 16
.digit_loop:
    rol rax, 4          ; Rotate left 4 bits
    mov rbx, rax
    and rbx, 0xF        ; Get lowest 4 bits

    cmp rbx, 10
    jl .is_digit
    add rbx, 'a' - 10
    jmp .store
.is_digit:
    add rbx, '0'
.store:
    mov [rdi], bl
    inc rdi
    dec rcx
    jnz .digit_loop

    ; Print the hex buffer
    mov byte [rdi], 0   ; Null terminator
    lea rdi, [rel hex_buffer]
    xor rsi, rsi        ; Auto-detect length
    call print_string

    ; Print newline
    lea rdi, [rel newline]
    mov rsi, 1
    call print_string

    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

_start:
    ; Print test message
    lea rdi, [rel test_msg]
    mov rsi, test_msg_len
    call print_string

    ; Test 1: Allocate 100 bytes
    lea rdi, [rel alloc1_msg]
    mov rsi, alloc1_msg_len
    call print_string

    mov rdi, 100
    call my_malloc

    ; Check for error
    test rax, rax
    js .error

    mov [rel ptr1], rax
    mov rdi, rax
    call print_hex

    ; Test 2: Allocate 200 bytes
    lea rdi, [rel alloc2_msg]
    mov rsi, alloc2_msg_len
    call print_string

    mov rdi, 200
    call my_malloc

    test rax, rax
    js .error

    mov [rel ptr2], rax
    mov rdi, rax
    call print_hex

    ; Test 3: Allocate 50 bytes
    lea rdi, [rel alloc3_msg]
    mov rsi, alloc3_msg_len
    call print_string

    mov rdi, 50
    call my_malloc

    test rax, rax
    js .error

    mov [rel ptr3], rax
    mov rdi, rax
    call print_hex

    ; Verify allocations are different and increasing
    mov rax, [rel ptr1]
    mov rbx, [rel ptr2]
    mov rcx, [rel ptr3]

    cmp rbx, rax
    jle .error      ; ptr2 should be > ptr1

    cmp rcx, rbx
    jle .error      ; ptr3 should be > ptr2

    ; Write to allocated memory to verify it works
    mov rdi, [rel ptr1]
    mov byte [rdi], 'A'
    mov byte [rdi+1], 'B'
    mov byte [rdi+2], 'C'

    ; Success!
    lea rdi, [rel success_msg]
    mov rsi, success_msg_len
    call print_string

    mov rax, 60
    xor rdi, rdi
    syscall

.error:
    lea rdi, [rel error_msg]
    mov rsi, error_msg_len
    call print_string

    mov rax, 60
    mov rdi, 1
    syscall
