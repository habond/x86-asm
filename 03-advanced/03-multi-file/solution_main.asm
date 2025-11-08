section .data
    str1 db "Hello", 0
    str2 db "World", 0
    str3 db "Hello", 0

section .text
global _start

; Import external functions
extern my_strlen
extern my_strcmp
extern find_max
extern find_min
extern absolute

_start:
    ; Test strlen("Hello") = 5
    mov rdi, str1
    call my_strlen

    ; Test strcmp("Hello", "World") = -1
    mov rdi, str1
    mov rsi, str2
    call my_strcmp

    ; Test strcmp("Hello", "Hello") = 0
    mov rdi, str1
    mov rsi, str3
    call my_strcmp

    ; Test find_max(42, 17) = 42
    mov rdi, 42
    mov rsi, 17
    call find_max

    ; Test find_min(42, 17) = 17
    mov rdi, 42
    mov rsi, 17
    call find_min

    ; Test absolute(-25) = 25
    mov rdi, -25
    call absolute

    ; Exit with success
    mov rax, 60
    xor rdi, rdi
    syscall
