section .data
    ; Error messages
    msg_usage db "Usage: filecp <source> <destination>", 10
    msg_usage_len equ $ - msg_usage

    msg_open_src db "Error: Cannot open source file", 10
    msg_open_src_len equ $ - msg_open_src

    msg_open_dst db "Error: Cannot create destination file", 10
    msg_open_dst_len equ $ - msg_open_dst

    msg_read db "Error: Failed to read from source file", 10
    msg_read_len equ $ - msg_read

    msg_write db "Error: Failed to write to destination file", 10
    msg_write_len equ $ - msg_write

section .bss
    buffer resb 4096             ; 4KB buffer for reading/writing

section .text
global _start

_start:
    ; Check argument count (argc should be 3)
    mov rax, [rsp]               ; rax = argc
    cmp rax, 3                   ; Need exactly 3 arguments
    jne error_usage              ; Jump to error if not 3

    ; Get source filename pointer (argv[1])
    mov r12, [rsp + 16]          ; r12 = pointer to source filename

    ; Get destination filename pointer (argv[2])
    mov r13, [rsp + 24]          ; r13 = pointer to destination filename

open_source:
    ; Open source file for reading
    mov rax, 2                   ; sys_open
    mov rdi, r12                 ; source filename
    mov rsi, 0                   ; O_RDONLY
    xor rdx, rdx                 ; mode not needed for reading
    syscall

    ; Check for error (negative return value)
    test rax, rax
    js error_open_source         ; Jump if sign flag set (negative)

    mov r14, rax                 ; Save source fd in r14

open_dest:
    ; Open/create destination file for writing
    mov rax, 2                   ; sys_open
    mov rdi, r13                 ; destination filename
    mov rsi, 577                 ; O_WRONLY | O_CREAT | O_TRUNC (1 | 64 | 512)
    mov rdx, 0644o               ; Permissions: rw-r--r-- (octal!)
    syscall

    ; Check for error
    test rax, rax
    js error_open_destination    ; Jump if negative

    mov r15, rax                 ; Save destination fd in r15

copy_loop:
    ; Read from source file
    mov rax, 0                   ; sys_read
    mov rdi, r14                 ; source fd
    mov rsi, buffer              ; buffer to read into
    mov rdx, 4096                ; bytes to read (max)
    syscall

    ; Check for errors
    test rax, rax
    js error_reading             ; Negative = error
    jz copy_done                 ; Zero = EOF, we're done

    ; Save number of bytes read
    mov rdx, rax                 ; rdx = bytes to write

    ; Write to destination file
    mov rax, 1                   ; sys_write
    mov rdi, r15                 ; destination fd
    mov rsi, buffer              ; data to write
    ; rdx already has bytes to write
    syscall

    ; Check for errors
    test rax, rax
    js error_writing             ; Negative = error

    ; Continue loop
    jmp copy_loop

copy_done:
    ; Close source file
    mov rax, 3                   ; sys_close
    mov rdi, r14                 ; source fd
    syscall

    ; Close destination file
    mov rax, 3                   ; sys_close
    mov rdi, r15                 ; destination fd
    syscall

    ; Exit with success
    mov rax, 60                  ; sys_exit
    xor rdi, rdi                 ; status = 0
    syscall

; Error handlers
error_usage:
    ; Print usage error message to stderr
    mov rax, 1                   ; sys_write
    mov rdi, 2                   ; stderr
    mov rsi, msg_usage           ; error message
    mov rdx, msg_usage_len       ; message length
    syscall

    ; Exit with error status
    mov rax, 60                  ; sys_exit
    mov rdi, 1                   ; status = 1 (error)
    syscall

error_open_source:
    ; Print error message to stderr
    mov rax, 1                   ; sys_write
    mov rdi, 2                   ; stderr
    mov rsi, msg_open_src
    mov rdx, msg_open_src_len
    syscall

    ; Exit with error status
    mov rax, 60                  ; sys_exit
    mov rdi, 1                   ; status = 1
    syscall

error_open_destination:
    ; Close source file first (it's already open!)
    mov rax, 3                   ; sys_close
    mov rdi, r14                 ; source fd
    syscall

    ; Print error message to stderr
    mov rax, 1                   ; sys_write
    mov rdi, 2                   ; stderr
    mov rsi, msg_open_dst
    mov rdx, msg_open_dst_len
    syscall

    ; Exit with error status
    mov rax, 60                  ; sys_exit
    mov rdi, 1                   ; status = 1
    syscall

error_reading:
    ; Close source file
    mov rax, 3                   ; sys_close
    mov rdi, r14                 ; source fd
    syscall

    ; Close destination file
    mov rax, 3                   ; sys_close
    mov rdi, r15                 ; destination fd
    syscall

    ; Print error message to stderr
    mov rax, 1                   ; sys_write
    mov rdi, 2                   ; stderr
    mov rsi, msg_read
    mov rdx, msg_read_len
    syscall

    ; Exit with error status
    mov rax, 60                  ; sys_exit
    mov rdi, 1                   ; status = 1
    syscall

error_writing:
    ; Close source file
    mov rax, 3                   ; sys_close
    mov rdi, r14                 ; source fd
    syscall

    ; Close destination file
    mov rax, 3                   ; sys_close
    mov rdi, r15                 ; destination fd
    syscall

    ; Print error message to stderr
    mov rax, 1                   ; sys_write
    mov rdi, 2                   ; stderr
    mov rsi, msg_write
    mov rdx, msg_write_len
    syscall

    ; Exit with error status
    mov rax, 60                  ; sys_exit
    mov rdi, 1                   ; status = 1
    syscall
