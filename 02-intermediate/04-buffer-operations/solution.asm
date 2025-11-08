section .data
    source db "Hello, Assembly!", 0    ; Source string (17 bytes including null)

section .bss
    dest resb 20                        ; Reserve 20 bytes for destination

section .text
global _start

; Function: memcpy
; Arguments: rdi = dest, rsi = source, rdx = count (number of bytes)
; Returns: rax = dest pointer
memcpy:
    mov rax, rdi        ; Save original destination pointer for return value
    xor rcx, rcx        ; rcx = 0 (byte counter)

loop_start:
    cmp rcx, rdx        ; Have we copied rdx bytes?
    jge done            ; If yes, we're done

    mov r8b, [rsi + rcx]    ; Load byte from source[rcx]
    mov [rdi + rcx], r8b    ; Store byte to dest[rcx]

    inc rcx             ; Increment counter
    jmp loop_start      ; Repeat

done:
    ret                 ; Return dest pointer in rax

_start:
    ; Set up memcpy arguments
    mov rdi, dest       ; rdi = destination buffer
    mov rsi, source     ; rsi = source buffer
    mov rdx, 17         ; rdx = 17 bytes to copy (including null terminator)

    ; Call memcpy
    call memcpy

    ; Verify the copy worked by loading first byte from dest
    ; The destination should now contain "Hello, Assembly!"
    mov rdi, dest
    movzx rax, byte [rdi]   ; Load first character ('H' = 72 in ASCII)

    ; Exit with first character as exit code
    mov rdi, rax            ; Exit code = 72 ('H')
    mov rax, 60             ; sys_exit
    syscall
