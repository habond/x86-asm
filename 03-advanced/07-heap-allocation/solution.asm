; Dynamic Memory Allocation (The Heap) - SOLUTION
;
; This solution implements a simple bump allocator using the brk system call.
; It demonstrates:
; - Getting the current program break
; - Growing the heap to allocate memory
; - A basic malloc implementation
; - Testing with multiple allocations

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

; get_current_break - Get the current program break
; Input: none
; Output: rax = current break address
get_current_break:
    mov rax, 12         ; sys_brk
    xor rdi, rdi        ; 0 = query current break
    syscall             ; Returns current break in rax
    ret

; grow_heap - Allocate memory by growing the heap
; Input: rdi = number of bytes to allocate
; Output: rax = address of allocated memory (or -1 on error)
grow_heap:
    push rbx            ; Save callee-saved register
    push rdi            ; Save requested size

    ; Get current break
    call get_current_break
    mov rbx, rax        ; Save old break in rbx

    ; Calculate new break
    pop rdi             ; Restore size
    add rdi, rbx        ; new_break = old_break + size

    ; Set new break
    mov rax, 12         ; sys_brk
    syscall

    ; Check if allocation succeeded
    ; On success, rax should be >= old_break + size
    ; On failure, rax will be the old break (unchanged)
    cmp rax, rbx
    jg .success         ; If new > old, we got at least some memory

    ; Allocation failed
    mov rax, -1
    pop rbx
    ret

.success:
    ; Return the old break (start of new memory)
    mov rax, rbx
    pop rbx
    ret

; my_malloc - Simple bump allocator
; Input: rdi = size in bytes
; Output: rax = pointer to allocated memory (or -1 on error)
my_malloc:
    push rbx

    ; Check for zero size
    test rdi, rdi
    jz .error

    ; Add space for header (16 bytes)
    ; Even though we're not using it in this simple version,
    ; it's good practice to reserve space
    add rdi, 16

    ; Align to 16-byte boundary
    ; Formula: (size + 15) & ~15
    add rdi, 15
    and rdi, -16        ; Clear low 4 bits

    ; Grow the heap
    call grow_heap

    ; Check for error
    test rax, rax
    js .error

    ; Return pointer to data section (skip 16-byte header)
    add rax, 16
    pop rbx
    ret

.error:
    mov rax, -1
    pop rbx
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

    mov rdi, [rel ptr2]
    mov byte [rdi], 'X'
    mov byte [rdi+1], 'Y'
    mov byte [rdi+2], 'Z'

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
