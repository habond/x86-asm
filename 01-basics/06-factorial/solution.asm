section .text
global _start

; Function: factorial
; Arguments: rdi = n
; Returns: rax = n!
factorial:
    ; Base case: if n <= 1, return 1
    cmp rdi, 1          ; Compare n with 1
    jle base_case       ; If n <= 1, jump to base case

    ; Recursive case: return n * factorial(n-1)
    push rdi            ; Save n on the stack (we'll need it after the call)
    dec rdi             ; rdi = n - 1
    call factorial      ; rax = factorial(n-1)
    pop rdi             ; Restore n from the stack
    imul rax, rdi       ; rax = n * factorial(n-1)
    ret                 ; Return result in rax

base_case:
    mov rax, 1          ; Return 1
    ret

_start:
    ; Calculate factorial of 5
    mov rdi, 5          ; Argument: n = 5
    call factorial      ; rax = 5! = 120

    ; Exit with result as exit code
    mov rdi, rax        ; Exit code = 120
    mov rax, 60         ; sys_exit
    syscall
