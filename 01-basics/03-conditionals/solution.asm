section .text
global _start

_start:
    ; Load two numbers to compare
    mov rax, 15         ; First number
    mov rbx, 10         ; Second number

    ; Compare rax with rbx
    cmp rax, rbx        ; Sets flags based on (rax - rbx)

    ; Jump to 'greater' if rax > rbx
    jg greater          ; Jump if greater (signed comparison)

    ; If we get here, rax <= rbx
    mov rdi, 0          ; Exit code 0 (not greater)
    jmp exit            ; Skip the 'greater' block

greater:
    ; This code runs if rax > rbx
    mov rdi, 1          ; Exit code 1 (is greater)

exit:
    ; Exit the program
    mov rax, 60         ; sys_exit
    syscall
