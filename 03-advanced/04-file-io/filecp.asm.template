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
    ; TODO: Check argument count (argc should be 3)
    ; Hint: argc is at [rsp]
    ; Compare with 3 and jump to error_usage if not equal

    ; TODO: Get source filename pointer
    ; Hint: argv[1] is at [rsp+16]
    ; Save it in a callee-saved register (e.g., r12)

    ; TODO: Get destination filename pointer
    ; Hint: argv[2] is at [rsp+24]
    ; Save it in a callee-saved register (e.g., r13)

open_source:
    ; TODO: Open source file for reading
    ; Hint: Use sys_open (rax=2)
    ; Use O_RDONLY (rsi=0)
    ; Check if result is negative (error)
    ; Save file descriptor in r14

open_dest:
    ; TODO: Open/create destination file for writing
    ; Hint: Use sys_open (rax=2)
    ; Use O_WRONLY|O_CREAT|O_TRUNC (rsi=577)
    ; Use permissions 0644o (rdx=0644o) - note the 'o' for octal!
    ; Check if result is negative (error)
    ; Save file descriptor in r15

copy_loop:
    ; TODO: Read from source file
    ; Hint: Use sys_read (rax=0)
    ; Read into buffer (rsi=buffer)
    ; Read up to 4096 bytes (rdx=4096)
    ; Check if result is negative (error)
    ; Check if result is 0 (EOF - end of file)
    ; Save number of bytes read for writing

    ; TODO: Write to destination file
    ; Hint: Use sys_write (rax=1)
    ; Write from buffer (rsi=buffer)
    ; Write exactly the number of bytes that were read (rdx=bytes_read)
    ; Check if result is negative (error)

    ; TODO: Loop back to copy_loop to read/write more data

copy_done:
    ; TODO: Close source file
    ; Hint: Use sys_close (rax=3)
    ; Pass source file descriptor (rdi=r14)

    ; TODO: Close destination file
    ; Hint: Use sys_close (rax=3)
    ; Pass destination file descriptor (rdi=r15)

    ; TODO: Exit with success status (0)
    ; Hint: Use sys_exit (rax=60)
    ; Pass status 0 (rdi=0)

; Error handlers
error_usage:
    ; TODO: Print usage error message to stderr
    ; Hint: Use sys_write (rax=1)
    ; Write to stderr (rdi=2)
    ; Print msg_usage message

    ; TODO: Exit with error status (1)
    ; Hint: Use sys_exit (rax=60)
    ; Pass status 1 (rdi=1)

error_open_source:
    ; TODO: Print error message to stderr
    ; Hint: Use sys_write to print msg_open_src

    ; TODO: Exit with error status (1)

error_open_destination:
    ; TODO: Close source file first (it's already open!)
    ; Hint: Use sys_close on r14

    ; TODO: Print error message to stderr
    ; Hint: Use sys_write to print msg_open_dst

    ; TODO: Exit with error status (1)

error_reading:
    ; TODO: Close both files

    ; TODO: Print error message to stderr
    ; Hint: Use sys_write to print msg_read

    ; TODO: Exit with error status (1)

error_writing:
    ; TODO: Close both files

    ; TODO: Print error message to stderr
    ; Hint: Use sys_write to print msg_write

    ; TODO: Exit with error status (1)
