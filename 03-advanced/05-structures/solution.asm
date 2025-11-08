section .data
    ; Structure field offsets
    STUDENT_ID      equ 0
    STUDENT_AGE     equ 8
    STUDENT_GRADE   equ 16
    STUDENT_NAME    equ 24
    STUDENT_SIZE    equ 48

    ; Array of students
    students:
        ; Student 0: id=101, age=20, grade=85, name="Alice"
        dq 101                      ; id
        dq 20                       ; age
        dq 85                       ; grade
        db "Alice", 0               ; name (null-terminated)
        times 19 db 0               ; padding to 24 bytes

        ; Student 1: id=102, age=21, grade=92, name="Bob"
        dq 102
        dq 21
        dq 92
        db "Bob", 0
        times 21 db 0

        ; Student 2: id=103, age=19, grade=78, name="Charlie"
        dq 103
        dq 19
        dq 78
        db "Charlie", 0
        times 17 db 0

    student_count equ 3

section .text
global _start

; Function: find_student_by_id
; Arguments: rdi = target ID
; Returns: rax = index of student (or -1 if not found)
find_student_by_id:
    push rbx
    push rcx
    push rdx

    lea rax, [students]     ; rax = base address of students array
    xor rcx, rcx            ; rcx = index (i = 0)

search_loop:
    ; Check if we've searched all students
    cmp rcx, student_count
    jge not_found

    ; Calculate address of current student: base + i * STUDENT_SIZE
    mov rbx, rcx
    push rax
    mov rax, rbx
    mov rdx, STUDENT_SIZE
    mul rdx                 ; rax = i * STUDENT_SIZE
    mov rbx, rax
    pop rax
    add rbx, rax            ; rbx = base + (i * STUDENT_SIZE)

    ; Compare ID field
    mov rdx, [rbx + STUDENT_ID]
    cmp rdx, rdi
    je found

    ; Move to next student
    inc rcx
    jmp search_loop

not_found:
    mov rax, -1
    jmp search_done

found:
    mov rax, rcx            ; Return index

search_done:
    pop rdx
    pop rcx
    pop rbx
    ret

; Function: calculate_average
; Arguments: none (uses global students array and student_count)
; Returns: rax = average grade
calculate_average:
    push rbx
    push rcx
    push rdx

    lea rbx, [students]     ; rbx = base address
    xor rax, rax            ; rax = sum of grades
    xor rcx, rcx            ; rcx = index (i = 0)

sum_loop:
    ; Check if we've processed all students
    cmp rcx, student_count
    jge calculate_avg

    ; Calculate address of current student
    push rax                ; Save sum
    mov rax, rcx
    mov rdx, STUDENT_SIZE
    mul rdx                 ; rax = i * STUDENT_SIZE
    add rax, rbx            ; rax = base + (i * STUDENT_SIZE)

    ; Add grade to sum
    mov rdx, [rax + STUDENT_GRADE]
    pop rax                 ; Restore sum
    add rax, rdx

    ; Move to next student
    inc rcx
    jmp sum_loop

calculate_avg:
    ; Divide sum by count
    xor rdx, rdx            ; Clear rdx for division
    mov rcx, student_count
    div rcx                 ; rax = sum / count

    pop rdx
    pop rcx
    pop rbx
    ret

_start:
    ; Test 1: Find student with ID 102 (should return index 1)
    mov rdi, 102
    call find_student_by_id

    ; Save result
    mov rbx, rax

    ; Test 2: Calculate average grade
    ; Average of 85, 92, 78 = 255/3 = 85
    call calculate_average

    ; Exit with find result (should be 1 for student ID 102)
    mov rdi, rbx
    cmp rdi, -1
    jne exit

    ; If not found, exit with 255
    mov rdi, 255

exit:
    mov rax, 60
    syscall
