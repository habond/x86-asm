section .data
    msg db "Hello, World!", 10
    len equ $ - msg

section .text
global _start

_start:
    ; TODO: Write message to stdout

    ; TODO: Exit with status 0
