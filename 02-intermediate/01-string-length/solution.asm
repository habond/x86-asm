section .data
    mystring db "Hello, Assembly!", 0    ; Null-terminated string (16 chars)

section .text
global _start

; Function: strlen
; Arguments: rdi = pointer to null-terminated string
; Returns: rax = length of string
strlen:
    xor rax, rax        ; rax = 0 (length counter)

loop_start:
    cmp byte [rdi], 0   ; Check if current byte is null terminator
    je done             ; If null, we're done

    inc rax             ; Increment length counter
    inc rdi             ; Move pointer to next character
    jmp loop_start      ; Repeat

done:
    ret                 ; Return with length in rax

_start:
    mov rdi, mystring   ; Load address of string into rdi
    call strlen         ; Call strlen function (result in rax)

    ; Exit with string length as exit code
    mov rdi, rax        ; Exit code = length (16)
    mov rax, 60         ; sys_exit
    syscall
