section .text
global _start

; Function: count_bits
; Arguments: rdi = 64-bit number
; Returns: rax = count of set bits
count_bits:
    ; TODO: Count number of 1 bits in rdi

    ret

_start:
    ; Test with value 0x0F (binary: 00001111, should have 4 set bits)
    mov rdi, 0x0F
    call count_bits

    ; Exit with the count as exit code (should be 4)
    mov rdi, rax
    mov rax, 60
    syscall
