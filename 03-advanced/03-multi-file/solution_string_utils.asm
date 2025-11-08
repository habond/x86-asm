section .text

; Export these functions
global my_strlen
global my_strcmp

; Function: my_strlen
; Arguments: rdi = pointer to null-terminated string
; Returns: rax = length of string
my_strlen:
    xor rax, rax        ; counter = 0

.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop

.done:
    ret

; Function: my_strcmp
; Arguments: rdi = string1, rsi = string2
; Returns: rax = 0 if equal, -1 if s1 < s2, 1 if s1 > s2
my_strcmp:
    xor rcx, rcx        ; index = 0

.loop:
    mov al, [rdi + rcx]
    mov bl, [rsi + rcx]

    cmp al, bl
    jl .less
    jg .greater

    test al, al         ; End of string?
    jz .equal

    inc rcx
    jmp .loop

.equal:
    xor rax, rax        ; return 0
    ret

.less:
    mov rax, -1         ; return -1
    ret

.greater:
    mov rax, 1          ; return 1
    ret
