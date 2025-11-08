# Assignment 6: Hash Table

Implement a simple hash table data structure with string keys and integer values.

## Learning Objectives

- Understand hash table fundamentals
- Implement a hash function for strings
- Handle collision resolution with linear probing
- Perform insert, lookup, and delete operations
- Work with key-value pairs in memory
- Manage dynamic data structures

## Background

Hash tables are one of the most important data structures in computer science. They provide:
- **O(1) average-case** lookup, insert, and delete
- **Efficient storage** for key-value mappings
- **Foundation** for dictionaries, sets, caches, and databases

Hash tables are used in:
- **Compilers** (symbol tables)
- **Databases** (indexing)
- **Caches** (key-value stores like Redis)
- **Programming languages** (JavaScript objects, Python dicts)

## The Task

Implement a hash table that:
1. Stores string keys with integer values
2. Uses a simple hash function (string sum modulo table size)
3. Handles collisions with linear probing
4. Supports insert, lookup, and delete operations

## Hash Table Fundamentals

### What is a Hash Table?

A hash table maps keys to values using a hash function:

```
Key → Hash Function → Index → Value

"alice" → hash("alice") → 3 → 100
"bob"   → hash("bob")   → 7 → 200
```

### Hash Function

A good hash function:
- **Deterministic**: Same key always produces same hash
- **Uniform**: Distributes keys evenly across table
- **Fast**: O(1) computation

Simple string hash (sum of ASCII values):

```asm
; Hash function: sum all characters mod table_size
; Input: rdi = pointer to null-terminated string
; Output: rax = hash value (0 to table_size-1)
hash_string:
    xor rax, rax            ; sum = 0
hash_loop:
    movzx rbx, byte [rdi]   ; Load character
    test rbx, rbx           ; Check for null terminator
    jz hash_done
    add rax, rbx            ; sum += char
    inc rdi
    jmp hash_loop
hash_done:
    xor rdx, rdx
    mov rbx, TABLE_SIZE
    div rbx                 ; rax = sum % TABLE_SIZE
    mov rax, rdx            ; Return remainder (0 to TABLE_SIZE-1)
    ret
```

### Collision Resolution: Linear Probing

When two keys hash to the same index, we need collision resolution.

**Linear probing**: If slot is occupied, try the next slot:

```
hash(key) = 3, but slot 3 is occupied
Try slot 4, then 5, then 6... until we find empty slot
```

```asm
; Linear probing pseudocode
index = hash(key)
while table[index] is occupied:
    if table[index].key == key:
        return table[index]  ; Found it
    index = (index + 1) % TABLE_SIZE  ; Try next slot
```

## Memory Layout

Each hash table entry contains:
- **Key pointer** (8 bytes): Points to null-terminated string
- **Value** (8 bytes): Integer value
- **Occupied flag** (1 byte): 1 if slot used, 0 if empty

```
Hash Table (array of entries):
+-------------------+
| Entry 0:          |
|   key_ptr   (8)   | → "alice\0"
|   value     (8)   | → 100
|   occupied  (1)   | → 1
+-------------------+
| Entry 1:          |
|   key_ptr   (8)   | → null
|   value     (8)   | → 0
|   occupied  (1)   | → 0
+-------------------+
| Entry 2:          |
|   key_ptr   (8)   | → "bob\0"
|   value     (8)   | → 200
|   occupied  (1)   | → 1
+-------------------+
...
```

Entry structure (24 bytes per entry):
```asm
struc HashEntry
    .key_ptr:   resq 1    ; 8 bytes: pointer to key string
    .value:     resq 1    ; 8 bytes: integer value
    .occupied:  resb 1    ; 1 byte: occupied flag
    .padding:   resb 7    ; 7 bytes padding (alignment)
endstruc
```

## Starter Code

```asm
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
    ; TODO: Sum all character values
    ; TODO: Return sum % TABLE_SIZE
    ret

; Function: ht_insert
; Arguments: rdi = key (string pointer), rsi = value
; Returns: rax = 1 if inserted, 0 if failed
ht_insert:
    ; TODO: Hash the key
    ; TODO: Linear probe to find empty slot
    ; TODO: Store key_ptr, value, set occupied=1
    ret

; Function: ht_lookup
; Arguments: rdi = key (string pointer)
; Returns: rax = value if found, -1 if not found
ht_lookup:
    ; TODO: Hash the key
    ; TODO: Linear probe to find matching key
    ; TODO: Return value or -1
    ret

; Function: strcmp
; Arguments: rdi = string1, rsi = string2
; Returns: rax = 0 if equal, non-zero otherwise
strcmp:
    ; TODO: Compare strings character by character
    ret

_start:
    ; Insert some key-value pairs
    mov rdi, key1           ; "alice"
    mov rsi, 100
    call ht_insert

    mov rdi, key2           ; "bob"
    mov rsi, 200
    call ht_insert

    ; Lookup a value
    mov rdi, key1           ; "alice"
    call ht_lookup          ; Should return 100

    ; Exit with result
    mov rdi, rax
    mov rax, 60
    syscall
```

## Step by Step

### Step 1: Implement hash_string

```asm
hash_string:
    push rbx                ; Save rbx (callee-saved)
    xor rax, rax            ; sum = 0

hash_loop:
    movzx rbx, byte [rdi]   ; Load character (zero-extended)
    test rbx, rbx           ; Check for null terminator
    jz hash_done
    add rax, rbx            ; sum += character
    inc rdi                 ; Next character
    jmp hash_loop

hash_done:
    xor rdx, rdx            ; Clear rdx for division
    mov rbx, TABLE_SIZE
    div rbx                 ; rdx = rax % TABLE_SIZE
    mov rax, rdx            ; Return remainder

    pop rbx
    ret
```

### Step 2: Implement strcmp

```asm
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
```

### Step 3: Implement ht_insert

```asm
ht_insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    ; r12 = key, r13 = value
    mov r12, rdi
    mov r13, rsi

    ; Get hash
    call hash_string        ; rax = hash
    mov rbx, rax            ; rbx = index

insert_probe:
    ; Calculate entry address: hash_table + (index * ENTRY_SIZE)
    mov rax, rbx
    mov rcx, ENTRY_SIZE
    mul rcx                 ; rax = index * ENTRY_SIZE
    lea rdi, [hash_table + rax]  ; rdi = entry address

    ; Check if occupied
    movzx rcx, byte [rdi + 16]  ; Load occupied flag
    test rcx, rcx
    jz insert_here          ; If empty, insert here

    ; Slot occupied, try next (linear probing)
    inc rbx
    cmp rbx, TABLE_SIZE
    jl insert_probe
    xor rbx, rbx            ; Wrap around to 0
    jmp insert_probe

insert_here:
    ; Store entry
    mov [rdi], r12          ; key_ptr
    mov [rdi + 8], r13      ; value
    mov byte [rdi + 16], 1  ; occupied = 1

    mov rax, 1              ; Success

    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
```

### Step 4: Implement ht_lookup

```asm
ht_lookup:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov r12, rdi            ; Save key

    ; Get hash
    call hash_string
    mov rbx, rax            ; rbx = index

lookup_probe:
    ; Calculate entry address
    mov rax, rbx
    mov rcx, ENTRY_SIZE
    mul rcx
    lea rdi, [hash_table + rax]

    ; Check if occupied
    movzx rcx, byte [rdi + 16]
    test rcx, rcx
    jz lookup_not_found     ; Empty slot, key not found

    ; Compare keys
    push rdi                ; Save entry address
    mov rdi, r12            ; Our search key
    mov rsi, [rsp]          ; Entry's key_ptr (from stack)
    mov rsi, [rsi]          ; Dereference
    call strcmp
    pop rdi                 ; Restore entry address

    test rax, rax
    jz lookup_found         ; Keys match!

    ; Try next slot
    inc rbx
    cmp rbx, TABLE_SIZE
    jl lookup_probe
    xor rbx, rbx            ; Wrap around
    jmp lookup_probe

lookup_found:
    mov rax, [rdi + 8]      ; Return value
    pop r12
    pop rbx
    pop rbp
    ret

lookup_not_found:
    mov rax, -1             ; Not found
    pop r12
    pop rbx
    pop rbp
    ret
```

## Building and Running

```bash
make                # Build hashtable
make run            # Run your code
echo $?             # See exit code

make solution       # Build solution
make run-solution   # Run solution

make test           # Run test suite
```

## Testing

The test script will verify:
- Insert operations work correctly
- Lookup returns correct values
- Handling of non-existent keys
- Multiple insert/lookup operations

Manual testing:

```asm
; Insert "alice" → 100
mov rdi, key1
mov rsi, 100
call ht_insert      ; Should return 1 (success)

; Lookup "alice"
mov rdi, key1
call ht_lookup      ; Should return 100

; Lookup non-existent key
mov rdi, key_missing
call ht_lookup      ; Should return -1
```

## Going Further

### Challenge 1: Delete Operation

Implement `ht_delete` that removes a key-value pair:

```asm
; Function: ht_delete
; Arguments: rdi = key
; Returns: rax = 1 if deleted, 0 if not found
ht_delete:
    ; TODO: Find entry and mark as deleted
    ; Problem: Simple occupied=0 breaks linear probing!
    ; Solution: Use tombstone (occupied=2 for deleted)
    ret
```

### Challenge 2: Resize Table

Implement dynamic resizing when table gets too full:

```asm
; Resize when load factor > 0.75
; 1. Allocate larger table (2x size)
; 2. Rehash all entries into new table
; 3. Free old table
```

### Challenge 3: Better Hash Function

Implement a better hash function (DJB2 or FNV-1a):

```asm
; DJB2 hash
hash_djb2:
    mov rax, 5381           ; Initial value
hash_loop:
    movzx rbx, byte [rdi]
    test rbx, rbx
    jz done
    shl rax, 5              ; rax *= 32
    add rax, rax            ; (total: *= 33)
    xor rax, rbx            ; hash = hash * 33 ^ c
    inc rdi
    jmp hash_loop
done:
    ret
```

### Challenge 4: Separate Chaining

Implement collision resolution using linked lists instead of linear probing:

```
Each table entry points to a linked list of key-value pairs
+-------+
| [0] --------> [key1,val1] -> [key2,val2] -> NULL
| [1] --------> NULL
| [2] --------> [key3,val3] -> NULL
+-------+
```

### Challenge 5: String Values

Extend to support string values (not just integers):

```asm
; Entry: [key_ptr | value_ptr | occupied]
; Both key and value are pointers to strings
```

## Hash Table Statistics

Calculate and display statistics:

```asm
; Count occupied slots
; Calculate load factor: occupied / TABLE_SIZE
; Find longest probe sequence
; Count collisions
```

## Common Mistakes

### Mistake 1: Forgetting to preserve registers

```asm
; Wrong - destroys input
hash_string:
    xor rax, rax
    add rax, [rdi]
    inc rdi             ; Modifies input pointer!

; Right - work with copy or restore
hash_string:
    push rdi            ; Save
    ; ... work ...
    pop rdi
    ret
```

### Mistake 2: Infinite loop in probing

```asm
; Wrong - can loop forever if table full
probe_loop:
    ; Check slot
    inc index
    jmp probe_loop      ; Never exits if table full!

; Right - limit iterations or check for wrap
    mov rcx, TABLE_SIZE
probe_loop:
    ; Check slot
    inc index
    cmp index, TABLE_SIZE
    jl no_wrap
    xor index, index
no_wrap:
    dec rcx
    jnz probe_loop
```

### Mistake 3: Incorrect entry offset calculation

```asm
; Wrong - doesn't account for entry size
mov rax, [hash_table + rbx]  ; rbx is index, not byte offset!

; Right - multiply by entry size
mov rax, rbx
mov rcx, ENTRY_SIZE
mul rcx
mov rax, [hash_table + rax]
```

### Mistake 4: Not handling string comparison

```asm
; Wrong - compares pointers, not strings
mov rax, [entry_key_ptr]
cmp rax, search_key     ; Compares addresses!

; Right - use strcmp
mov rdi, [entry_key_ptr]
mov rsi, search_key
call strcmp
```

## Real-World Applications

### Symbol Table (Compiler)

```asm
; Map variable names to memory addresses
insert "count" → 0x1000
insert "total" → 0x1008
lookup "count" → 0x1000
```

### Cache Implementation

```asm
; Store computed results
insert "fibonacci(10)" → 55
insert "factorial(5)" → 120
```

### Dictionary

```asm
; Word definitions
insert "hash" → "A function mapping data to fixed-size values"
lookup "hash" → "A function..."
```

## Performance Analysis

### Time Complexity

- **Average case**: O(1) for insert, lookup, delete
- **Worst case**: O(n) when all keys hash to same slot
- **Load factor** (α = n/m) affects performance:
  - α < 0.5: Very fast, few collisions
  - α = 0.75: Good balance
  - α > 0.9: Many collisions, slower

### Space Complexity

- O(n) for n entries
- Trade-off: Larger table → fewer collisions, more memory

## Debugging

```bash
# In GDB
(gdb) break ht_insert
(gdb) run
(gdb) print/x $rax          # View hash value
(gdb) x/16gx hash_table     # View table memory

# View string at pointer
(gdb) x/s $rdi

# View entry structure
(gdb) x/3gx hash_table      # First entry (key_ptr, value, occupied)
```

## Next Steps

Hash tables are fundamental to many advanced topics:
- **Databases**: Indexing and query optimization
- **Caching**: Memoization and LRU caches
- **Networking**: Routing tables
- **Security**: Password hashing, bloom filters

## Resources

- [Hash Table Wikipedia](https://en.wikipedia.org/wiki/Hash_table)
- [Instruction Reference](../../resources/instruction-reference.md)
- [Calling Conventions](../../resources/calling-conventions.md)
