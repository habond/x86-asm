section .data
    str1 db "Apple", 0       ; First string to compare
    str2 db "Banana", 0      ; Second string to compare

section .text
global _start

; Function: strcmp
; Arguments: rdi = pointer to first string
;            rsi = pointer to second string
; Returns: rax = -1 (s1 < s2), 0 (s1 == s2), or 1 (s1 > s2)
;
; Algorithm:
; 1. Load corresponding bytes from both strings
; 2. If bytes differ, return based on which is larger
; 3. If bytes are equal and null terminator, strings are equal
; 4. Otherwise, advance both pointers and repeat
strcmp:
loop_start:
    mov al, [rdi]           ; Load byte from first string
    mov bl, [rsi]           ; Load byte from second string

    cmp al, bl              ; Compare the two bytes
    jl str1_less            ; If al < bl, first string is less
    jg str1_greater         ; If al > bl, first string is greater

    ; Bytes are equal - check if we've reached the end
    cmp al, 0               ; Is it the null terminator?
    je strings_equal        ; If yes, both strings ended (equal)

    ; Continue to next character
    inc rdi                 ; Move to next char in first string
    inc rsi                 ; Move to next char in second string
    jmp loop_start          ; Compare next pair

str1_less:
    mov rax, -1             ; First string < second string
    ret

str1_greater:
    mov rax, 1              ; First string > second string
    ret

strings_equal:
    xor rax, rax            ; rax = 0 (strings are equal)
    ret

_start:
    mov rdi, str1           ; Load address of first string
    mov rsi, str2           ; Load address of second string
    call strcmp             ; Compare strings (result in rax)

    ; Convert result to positive exit code for testing
    ; -1 → 0, 0 → 1, 1 → 2
    add rax, 1
    mov rdi, rax            ; Exit code
    mov rax, 60             ; sys_exit
    syscall
