section .data
    msg db "Hello, World!", 10    ; String with newline (10 = \n)
    len equ $ - msg                ; Calculate length

section .text
global _start

_start:
    ; Write "Hello, World!\n" to stdout
    mov rax, 1                     ; sys_write
    mov rdi, 1                     ; stdout
    mov rsi, msg                   ; pointer to string
    mov rdx, len                   ; length
    syscall                        ; invoke system call

    ; Exit program with status 0
    mov rax, 60                    ; sys_exit
    xor rdi, rdi                   ; status = 0
    syscall                        ; exit
