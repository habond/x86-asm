section .data
    ; Array of 5 quad-words (8 bytes each)
    array dq 10, 25, 3, 42, 17
    array_len equ 5

section .text
global _start

; Function: find_max
; Arguments: rdi = pointer to array, rsi = array length
; Returns: rax = maximum value
find_max:
    mov rax, [rdi]      ; Load first element as initial max
    mov rcx, 1          ; Start counter at 1 (already have first element)

loop_start:
    cmp rcx, rsi        ; Check if counter >= array length
    jge done            ; If yes, we're done

    mov rbx, [rdi + rcx*8]  ; Load current element (array[counter])
                            ; Multiply by 8 because each qword is 8 bytes

    cmp rbx, rax        ; Compare current element with max
    jle skip            ; If current <= max, skip update
    mov rax, rbx        ; Update max with current element

skip:
    inc rcx             ; Increment counter
    jmp loop_start      ; Continue loop

done:
    ret                 ; Return max in rax

_start:
    mov rdi, array      ; Load array address into rdi
    mov rsi, array_len  ; Load array length into rsi
    call find_max       ; Call find_max (result in rax)

    ; Exit with max value as exit code
    mov rdi, rax        ; Exit code = max value (42)
    mov rax, 60         ; sys_exit
    syscall
