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
    ; TODO: Search through students array
    ; Hint: Loop through each student, compare ID field
    ; Use STUDENT_SIZE to calculate addresses

    ret

; Function: calculate_average
; Arguments: none (uses global students array and student_count)
; Returns: rax = average grade
calculate_average:
    ; TODO: Sum all grades
    ; TODO: Divide by student_count
    ; Hint: Loop through students, access STUDENT_GRADE field

    ret

_start:
    ; Test 1: Find student with ID 102 (should return index 1)
    mov rdi, 102
    call find_student_by_id

    ; Save result
    mov rbx, rax

    ; Test 2: Calculate average grade
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
