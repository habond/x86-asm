section .text
global _start

; Function: count_bits
; Arguments: rdi = 64-bit number
; Returns: rax = count of set bits
count_bits:
    xor rax, rax        ; counter = 0
    mov rcx, 64         ; 64 bits to check
    mov rbx, rdi        ; Work with copy to preserve input

loop_start:
    test rbx, 1         ; Test bit 0 (lowest bit)
    jz skip             ; If zero, skip increment
    inc rax             ; Increment counter if bit is set

skip:
    shr rbx, 1          ; Shift right by 1 (next bit becomes lowest)
    dec rcx             ; Decrement bit counter
    jnz loop_start      ; Continue if bits remaining

    ret                 ; Return count in rax

_start:
    ; Test with value 0x0F (binary: 00001111, should have 4 set bits)
    mov rdi, 0x0F
    call count_bits

    ; Exit with the count as exit code (should be 4)
    mov rdi, rax
    mov rax, 60
    syscall
