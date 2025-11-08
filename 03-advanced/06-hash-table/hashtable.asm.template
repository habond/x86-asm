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
    ; TODO: Implement hash function
    ; 1. Initialize sum to 0
    ; 2. Loop through each character
    ; 3. Add character value to sum
    ; 4. Return sum % TABLE_SIZE

    xor rax, rax        ; sum = 0

    ; Your code here

    ret

; Function: strcmp
; Arguments: rdi = string1, rsi = string2
; Returns: rax = 0 if equal, non-zero otherwise
strcmp:
    ; TODO: Compare strings character by character
    ; 1. Load characters from both strings
    ; 2. Compare them
    ; 3. If different, return non-zero
    ; 4. If null terminator, return 0 (equal)
    ; 5. Continue to next character

    ; Your code here

    ret

; Function: ht_insert
; Arguments: rdi = key (string pointer), rsi = value
; Returns: rax = 1 if inserted, 0 if failed
ht_insert:
    ; TODO: Insert key-value pair into hash table
    ; 1. Save key and value
    ; 2. Hash the key
    ; 3. Linear probe to find empty slot
    ; 4. Store key_ptr, value, set occupied=1
    ; 5. Return 1 for success

    ; Your code here

    ret

; Function: ht_lookup
; Arguments: rdi = key (string pointer)
; Returns: rax = value if found, -1 if not found
ht_lookup:
    ; TODO: Lookup value by key
    ; 1. Save key
    ; 2. Hash the key
    ; 3. Linear probe to find matching key
    ; 4. Compare keys using strcmp
    ; 5. Return value if found, -1 if not found

    ; Your code here

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

    ; Exit with result
    mov rdi, rax
    mov rax, 60
    syscall
