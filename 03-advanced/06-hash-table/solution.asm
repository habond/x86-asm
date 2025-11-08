section .data
    TABLE_SIZE equ 16           ; Hash table size
    ENTRY_SIZE equ 24           ; Size of each entry (8+8+8)

    ; Test strings
    key1 db "alice", 0
    key2 db "bob", 0
    key3 db "charlie", 0

section .bss
    ; Hash table: array of entries
    ; Each entry: [key_ptr (8) | value (8) | occupied (8)]
    hash_table resb TABLE_SIZE * ENTRY_SIZE

section .text
global _start

; Function: hash_string
; Arguments: rdi = pointer to null-terminated string
; Returns: rax = hash value (0 to TABLE_SIZE-1)
hash_string:
    push rbx
    push rdi            ; Save original pointer

    xor rax, rax        ; sum = 0

hash_loop:
    movzx rbx, byte [rdi]   ; Load character (zero-extended)
    test rbx, rbx           ; Check for null terminator
    jz hash_done
    add rax, rbx            ; sum += character
    inc rdi                 ; Next character
    jmp hash_loop

hash_done:
    ; Calculate sum % TABLE_SIZE
    xor rdx, rdx            ; Clear rdx for division
    mov rbx, TABLE_SIZE
    div rbx                 ; rdx:rax / rbx, remainder in rdx
    mov rax, rdx            ; Return remainder (hash value)

    pop rdi             ; Restore pointer
    pop rbx
    ret

; Function: strcmp
; Arguments: rdi = string1, rsi = string2
; Returns: rax = 0 if equal, non-zero otherwise
strcmp:
    push rbx

strcmp_loop:
    movzx rax, byte [rdi]   ; Load char from string1
    movzx rbx, byte [rsi]   ; Load char from string2

    cmp rax, rbx            ; Compare characters
    jne strcmp_not_equal    ; If different, return non-zero

    test rax, rax           ; Check if null terminator
    jz strcmp_equal         ; Both strings ended, equal

    inc rdi                 ; Next char in string1
    inc rsi                 ; Next char in string2
    jmp strcmp_loop

strcmp_equal:
    xor rax, rax            ; Return 0 (equal)
    pop rbx
    ret

strcmp_not_equal:
    mov rax, 1              ; Return non-zero (not equal)
    pop rbx
    ret

; Function: ht_insert
; Arguments: rdi = key (string pointer), rsi = value
; Returns: rax = 1 if inserted, 0 if failed
ht_insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    ; Save arguments
    mov r12, rdi            ; r12 = key
    mov r13, rsi            ; r13 = value

    ; Get hash
    call hash_string        ; rax = hash index
    mov rbx, rax            ; rbx = current index
    mov r14, rax            ; r14 = starting index (to detect full table)

insert_probe:
    ; Calculate entry address: hash_table + (index * ENTRY_SIZE)
    mov rax, rbx
    mov rcx, ENTRY_SIZE
    mul rcx                 ; rax = index * ENTRY_SIZE
    lea rdi, [rel hash_table]
    add rdi, rax            ; rdi = entry address

    ; Check if occupied
    movzx rcx, byte [rdi + 16]  ; Load occupied flag (offset 16)
    test rcx, rcx
    jz insert_here          ; If empty, insert here

    ; Slot occupied - check if same key (update case)
    push rdi
    mov rsi, [rdi]          ; Load existing key pointer
    mov rdi, r12            ; Our key
    call strcmp
    pop rdi
    test rax, rax
    jz insert_here          ; Same key, update value

    ; Try next slot (linear probing)
    inc rbx
    cmp rbx, TABLE_SIZE
    jl insert_check_wrap
    xor rbx, rbx            ; Wrap around to 0

insert_check_wrap:
    ; Check if we've wrapped around to start (table full)
    cmp rbx, r14
    je insert_failed

    jmp insert_probe

insert_here:
    ; Store entry
    mov [rdi], r12          ; key_ptr
    mov [rdi + 8], r13      ; value
    mov byte [rdi + 16], 1  ; occupied = 1

    mov rax, 1              ; Success

    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

insert_failed:
    xor rax, rax            ; Failure (table full)
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Function: ht_lookup
; Arguments: rdi = key (string pointer)
; Returns: rax = value if found, -1 if not found
ht_lookup:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov r12, rdi            ; Save key

    ; Get hash
    call hash_string
    mov rbx, rax            ; rbx = current index
    mov r13, rax            ; r13 = starting index

lookup_probe:
    ; Calculate entry address
    mov rax, rbx
    mov rcx, ENTRY_SIZE
    mul rcx
    lea rdi, [rel hash_table]
    add rdi, rax            ; rdi = entry address

    ; Check if occupied
    movzx rcx, byte [rdi + 16]
    test rcx, rcx
    jz lookup_not_found     ; Empty slot, key not found

    ; Compare keys
    push rdi                ; Save entry address
    mov rsi, [rdi]          ; Entry's key_ptr
    mov rdi, r12            ; Our search key
    call strcmp
    pop rdi                 ; Restore entry address

    test rax, rax
    jz lookup_found         ; Keys match!

    ; Try next slot
    inc rbx
    cmp rbx, TABLE_SIZE
    jl lookup_check_wrap
    xor rbx, rbx            ; Wrap around

lookup_check_wrap:
    ; Check if we've wrapped around
    cmp rbx, r13
    je lookup_not_found

    jmp lookup_probe

lookup_found:
    mov rax, [rdi + 8]      ; Return value
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

lookup_not_found:
    mov rax, -1             ; Not found
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

_start:
    ; Insert "alice" → 100
    mov rdi, key1
    mov rsi, 100
    call ht_insert

    ; Insert "bob" → 200
    mov rdi, key2
    mov rsi, 200
    call ht_insert

    ; Insert "charlie" → 300
    mov rdi, key3
    mov rsi, 300
    call ht_insert

    ; Lookup "alice" (should return 100)
    mov rdi, key1
    call ht_lookup

    ; Exit with result (should be 100)
    mov rdi, rax
    mov rax, 60
    syscall
