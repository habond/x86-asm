section .text
global _start

; Function: add_numbers
; Arguments: rdi = first number, rsi = second number
; Returns: rax = sum
add_numbers:
    mov rax, rdi        ; Load first argument into rax
    add rax, rsi        ; Add second argument to rax
    ret                 ; Return to caller (result in rax)

_start:
    ; Prepare arguments for add_numbers
    mov rdi, 12         ; First argument = 12
    mov rsi, 30         ; Second argument = 30

    ; Call the function
    call add_numbers    ; Result returned in rax (12 + 30 = 42)

    ; Exit with result as exit code
    mov rdi, rax        ; Exit code = 42
    mov rax, 60         ; sys_exit
    syscall
