section .text
global _start

_start:
    ; Initialize variables
    mov rax, 0          ; sum = 0
    mov rcx, 1          ; counter = 1

loop_start:
    ; Check if counter > 10
    cmp rcx, 10         ; Compare counter with 10
    jg loop_end         ; If counter > 10, exit loop

    ; Loop body: add counter to sum
    add rax, rcx        ; sum += counter

    ; Increment counter
    inc rcx             ; counter++

    ; Repeat the loop
    jmp loop_start      ; Go back to loop condition

loop_end:
    ; Exit with sum as exit code
    ; rax contains 1+2+3+...+10 = 55
    mov rdi, rax        ; Exit code = sum (55)
    mov rax, 60         ; sys_exit
    syscall
