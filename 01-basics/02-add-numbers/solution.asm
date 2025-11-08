section .text
global _start

_start:
    ; Load 42 into rax
    mov rax, 42

    ; Load 27 into rbx
    mov rbx, 27

    ; Add rbx to rax (rax = rax + rbx)
    add rax, rbx                   ; rax = 42 + 27 = 69

    ; Exit with result in rax
    mov rdi, rax                   ; Exit code = 69
    mov rax, 60                    ; sys_exit
    syscall
