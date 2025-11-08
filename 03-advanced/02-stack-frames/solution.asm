section .text
global _start

; Function: fibonacci
; Arguments: rdi = n
; Returns: rax = fibonacci(n)
fibonacci:
    ; Set up stack frame
    push rbp
    mov rbp, rsp
    sub rsp, 16         ; Allocate space for two local qwords
                        ; [rbp-8] = fib(n-1)
                        ; [rbp-16] = fib(n-2)

    ; Base case: if n <= 1, return n
    cmp rdi, 1
    jg recursive_case

    ; Base case
    mov rax, rdi        ; return n
    jmp epilogue

recursive_case:
    ; Save n because we'll need it
    push rdi

    ; Calculate fibonacci(n-1)
    dec rdi             ; n-1
    call fibonacci      ; rax = fib(n-1)

    ; Save result of fib(n-1)
    mov [rbp-8], rax

    ; Restore n
    pop rdi

    ; Calculate fibonacci(n-2)
    sub rdi, 2          ; n-2
    call fibonacci      ; rax = fib(n-2)

    ; Save result of fib(n-2)
    mov [rbp-16], rax

    ; Return fib(n-1) + fib(n-2)
    mov rax, [rbp-8]
    add rax, [rbp-16]

epilogue:
    ; Clean up stack frame
    mov rsp, rbp
    pop rbp
    ret

_start:
    ; Calculate fibonacci(10) = 55
    mov rdi, 10
    call fibonacci

    ; Exit with result (should be 55)
    mov rdi, rax
    mov rax, 60
    syscall
