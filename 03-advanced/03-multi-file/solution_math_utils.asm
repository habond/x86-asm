section .text

; Export these functions
global find_max
global find_min
global absolute

; Function: find_max
; Arguments: rdi = a, rsi = b
; Returns: rax = max(a, b)
find_max:
    mov rax, rdi
    cmp rdi, rsi
    jge .done
    mov rax, rsi

.done:
    ret

; Function: find_min
; Arguments: rdi = a, rsi = b
; Returns: rax = min(a, b)
find_min:
    mov rax, rdi
    cmp rdi, rsi
    jle .done
    mov rax, rsi

.done:
    ret

; Function: absolute
; Arguments: rdi = signed number
; Returns: rax = |n|
absolute:
    mov rax, rdi
    test rax, rax       ; Check sign
    jns .done           ; If non-negative, done

    neg rax             ; Make positive

.done:
    ret
