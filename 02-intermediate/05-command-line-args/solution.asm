section .data
    newline db 10                  ; Newline character

section .text
global _start

_start:
    ; Load argc from stack (argc is at [rsp])
    mov r13, [rsp]                 ; r13 = argc (save for exit code)

    ; Calculate address of argv (argv is at rsp+8)
    lea rsi, [rsp+8]               ; rsi = base address of argv array

    ; Initialize loop counter
    xor r12, r12                   ; r12 = 0 (current argument index)

print_loop:
    ; Check if we've printed all arguments
    cmp r12, r13                   ; Is counter >= argc?
    jge exit                       ; If yes, we're done

    ; Load pointer to current argument string
    mov rdi, [rsi + r12*8]         ; rdi = argv[r12] (pointer to string)

    ; Calculate length of string
    xor rdx, rdx                   ; rdx = 0 (length counter)

strlen_loop:
    cmp byte [rdi + rdx], 0        ; Is current byte null?
    je strlen_done                 ; If yes, we have the length
    inc rdx                        ; length++
    jmp strlen_loop

strlen_done:
    ; rdx now contains the string length
    ; rdi still points to the string

    ; Print the argument string
    push rdi                       ; Save string pointer
    mov rax, 1                     ; sys_write
    mov rdi, 1                     ; stdout
    pop rsi                        ; rsi = string pointer (from saved rdi)
    ; rdx already contains length
    syscall

    ; Print newline after the argument
    mov rax, 1                     ; sys_write
    mov rdi, 1                     ; stdout
    mov rsi, newline               ; pointer to newline character
    mov rdx, 1                     ; length = 1
    syscall

    ; Move to next argument
    inc r12                        ; counter++
    jmp print_loop

exit:
    ; Exit with argc as exit code
    mov rdi, r13                   ; exit code = argc
    mov rax, 60                    ; sys_exit
    syscall
