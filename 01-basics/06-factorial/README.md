# Assignment 6: Factorial

Put everything together: loops, conditionals, and recursive functions to calculate factorial.

## Learning Objectives

- Implement recursive functions
- Properly manage the stack
- Preserve registers across calls
- Apply all concepts from previous assignments
- Understand stack frames

## Background

Factorial is defined as:
```
n! = n × (n-1) × (n-2) × ... × 2 × 1
5! = 5 × 4 × 3 × 2 × 1 = 120
```

It can be expressed recursively:
```c
int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}
```

Or iteratively:
```c
int factorial(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}
```

## The Task

Write a program that:
1. Implements a recursive `factorial` function
2. Calculates 5! (factorial of 5)
3. Exits with the result (120)

## Recursive Approach

### Call Graph for factorial(5)
```
factorial(5)
  = 5 × factorial(4)
      = 4 × factorial(3)
          = 3 × factorial(2)
              = 2 × factorial(1)
                  = 1 (base case)
              = 2 × 1 = 2
          = 3 × 2 = 6
      = 4 × 6 = 24
  = 5 × 24 = 120
```

### Stack During Recursion
```
factorial(5) called:
┌─────────────┐
│ n = 5       │ ← rsp
└─────────────┘

factorial(4) called:
┌─────────────┐
│ n = 4       │ ← rsp
├─────────────┤
│ return addr │
├─────────────┤
│ n = 5       │
└─────────────┘

factorial(3) called:
┌─────────────┐
│ n = 3       │ ← rsp
├─────────────┤
│ return addr │
├─────────────┤
│ n = 4       │
├─────────────┤
│ return addr │
├─────────────┤
│ n = 5       │
└─────────────┘

... and so on until factorial(1)
```

## Instructions You'll Need

### IMUL - Signed Multiplication
```asm
imul dest, src      ; dest = dest × src
```

Example:
```asm
mov rax, 5
imul rax, 4         ; rax = 20
```

## Starter Code

```asm
section .text
global _start

; Function: factorial
; Arguments: rdi = n
; Returns: rax = n!
factorial:
    ; TODO: Base case - if n <= 1, return 1
    ; Hint: cmp rdi, 1; jle base_case

    ; Recursive case - return n * factorial(n-1)

    ; TODO: Save n on the stack (we'll need it after recursive call)

    ; TODO: Calculate n - 1 and put in rdi

    ; TODO: Call factorial recursively

    ; TODO: Restore n from stack

    ; TODO: Multiply n by the result of factorial(n-1)

    ; TODO: Return

base_case:
    ; TODO: Return 1 in rax

_start:
    ; TODO: Load 5 into rdi (calculate 5!)

    ; TODO: Call factorial

    ; Exit with result
    mov rdi, rax        ; Exit code = result
    mov rax, 60         ; sys_exit
    syscall
```

## Step by Step (Recursive Solution)

### Step 1: Base case
```asm
factorial:
    cmp rdi, 1          ; Is n <= 1?
    jle base_case       ; If yes, return 1

; ... recursive case ...

base_case:
    mov rax, 1          ; Return 1
    ret
```

### Step 2: Save the argument
```asm
    ; We need to preserve rdi (n) because the recursive call will overwrite it
    push rdi            ; Save n on stack
```

### Step 3: Make the recursive call
```asm
    dec rdi             ; rdi = n - 1
    call factorial      ; rax = factorial(n-1)
```

### Step 4: Restore and multiply
```asm
    pop rdi             ; Restore n
    imul rax, rdi       ; rax = factorial(n-1) × n
    ret                 ; Return result
```

### Complete Recursive Function
```asm
factorial:
    cmp rdi, 1
    jle base_case

    push rdi            ; Save n
    dec rdi             ; n - 1
    call factorial      ; factorial(n-1)
    pop rdi             ; Restore n
    imul rax, rdi       ; n × factorial(n-1)
    ret

base_case:
    mov rax, 1
    ret
```

## Building and Running

```bash
nasm -f elf64 factorial.asm -o factorial.o
ld -o factorial factorial.o
./factorial
echo $?             # Should print 120
```

Or with Make:
```bash
make run
echo $?
```

## Expected Output

```bash
$ ./factorial
$ echo $?
120
```

The result 5! = 120, so the exit code is 120.

## Testing Different Values

**Test 1**: 5! = 120
```asm
mov rdi, 5
call factorial
; rax = 120
```

**Test 2**: 3! = 6
```asm
mov rdi, 3
call factorial
; rax = 6
```

**Test 3**: 1! = 1
```asm
mov rdi, 1
call factorial
; rax = 1
```

**Test 4**: 0! = 1 (by definition)
```asm
mov rdi, 0
call factorial
; rax = 1
```

**Test 5**: 6! = 720
```asm
mov rdi, 6
call factorial
; rax = 720 (but exit code = 720 % 256 = 208)
```

## Iterative Solution (Alternative)

You can also solve this with a loop instead of recursion:

```asm
section .text
global _start

; Function: factorial_iterative
; Arguments: rdi = n
; Returns: rax = n!
factorial_iterative:
    mov rax, 1          ; result = 1
    mov rcx, 2          ; counter = 2 (start from 2, since 1! = 1)

loop_start:
    cmp rcx, rdi        ; Is counter > n?
    jg loop_end         ; If yes, we're done

    imul rax, rcx       ; result *= counter
    inc rcx             ; counter++
    jmp loop_start

loop_end:
    ret                 ; Return result in rax

_start:
    mov rdi, 5          ; Calculate 5!
    call factorial_iterative

    mov rdi, rax        ; Exit code = result
    mov rax, 60         ; sys_exit
    syscall
```

## Common Mistakes

### Mistake 1: Not preserving argument
```asm
factorial:
    cmp rdi, 1
    jle base_case

    dec rdi             ; rdi = n - 1
    call factorial      ; rax = factorial(n-1)
    ; Oops! rdi is now 0 or 1 (from recursive calls)
    imul rax, rdi       ; Wrong value!
    ret
```

**Fix**: Save and restore rdi
```asm
    push rdi            ; Save
    dec rdi
    call factorial
    pop rdi             ; Restore
    imul rax, rdi
    ret
```

### Mistake 2: Wrong base case
```asm
factorial:
    cmp rdi, 0          ; Only checking for 0
    je base_case        ; Missing n = 1 case!
```

**Fix**: Check for n <= 1
```asm
    cmp rdi, 1
    jle base_case       ; Handles 0 and 1
```

### Mistake 3: Stack imbalance
```asm
factorial:
    cmp rdi, 1
    jle base_case

    push rdi
    dec rdi
    call factorial
    imul rax, rdi       ; Forgot to pop! Stack corrupted
    ret

base_case:
    mov rax, 1
    ret                 ; Unbalanced stack on return
```

**Fix**: Always pop what you push
```asm
    push rdi
    dec rdi
    call factorial
    pop rdi             ; Must pop before using rdi
    imul rax, rdi
    ret
```

### Mistake 4: Using wrong multiply instruction
```asm
    mul rdi             ; Wrong! mul uses implicit operands
    ; mul multiplies rax by operand, stores in rdx:rax
```

**Fix**: Use imul with two operands
```asm
    imul rax, rdi       ; rax = rax × rdi
```

## Stack Trace Example

Let's trace factorial(3):

```
1. _start calls factorial(3)
   Stack: [return_to_exit]
   rdi = 3

2. factorial(3): 3 > 1, recursive case
   push rdi            ; Save 3
   Stack: [3, return_to_exit]
   dec rdi → rdi = 2
   call factorial(2)

3. factorial(2): 2 > 1, recursive case
   push rdi            ; Save 2
   Stack: [2, return_to_2, 3, return_to_exit]
   dec rdi → rdi = 1
   call factorial(1)

4. factorial(1): 1 <= 1, base case
   rax = 1
   ret → back to factorial(2)

5. factorial(2) continues:
   Stack: [2, return_to_2, 3, return_to_exit]
   pop rdi → rdi = 2
   imul rax, rdi → rax = 1 × 2 = 2
   ret → back to factorial(3)

6. factorial(3) continues:
   Stack: [3, return_to_exit]
   pop rdi → rdi = 3
   imul rax, rdi → rax = 2 × 3 = 6
   ret → back to _start

7. _start:
   rax = 6
   Exit with code 6
```

## Debugging with GDB

```bash
nasm -f elf64 -g factorial.asm -o factorial.o
ld -o factorial factorial.o
gdb ./factorial

(gdb) break factorial
(gdb) run
(gdb) print $rdi            # Check n
(gdb) continue              # Next call
(gdb) bt                    # Backtrace - see call stack
(gdb) print $rax            # Check return value
(gdb) finish                # Run until function returns
```

Useful GDB commands for recursion:
```
(gdb) bt        # Show entire call stack
(gdb) frame 0   # Switch to top frame
(gdb) frame 1   # Switch to caller's frame
(gdb) info frame # Show frame info
```

## Visualizing the Recursion

```
factorial(5)
│
├─ Is 5 <= 1? No
├─ Save 5
├─ Call factorial(4)
│  │
│  ├─ Is 4 <= 1? No
│  ├─ Save 4
│  ├─ Call factorial(3)
│  │  │
│  │  ├─ Is 3 <= 1? No
│  │  ├─ Save 3
│  │  ├─ Call factorial(2)
│  │  │  │
│  │  │  ├─ Is 2 <= 1? No
│  │  │  ├─ Save 2
│  │  │  ├─ Call factorial(1)
│  │  │  │  │
│  │  │  │  ├─ Is 1 <= 1? Yes
│  │  │  │  └─ Return 1
│  │  │  │
│  │  │  ├─ Restore 2
│  │  │  ├─ 1 × 2 = 2
│  │  │  └─ Return 2
│  │  │
│  │  ├─ Restore 3
│  │  ├─ 2 × 3 = 6
│  │  └─ Return 6
│  │
│  ├─ Restore 4
│  ├─ 6 × 4 = 24
│  └─ Return 24
│
├─ Restore 5
├─ 24 × 5 = 120
└─ Return 120
```

## Going Further

### Challenge 1: Fibonacci (recursive)
Calculate Fibonacci number:
```asm
; fib(n) = fib(n-1) + fib(n-2)
; fib(0) = 0, fib(1) = 1
fibonacci:
    cmp rdi, 1
    jle base_case       ; fib(0) = 0, fib(1) = 1

    push rdi            ; Save n

    ; Calculate fib(n-1)
    dec rdi
    call fibonacci      ; rax = fib(n-1)
    push rax            ; Save fib(n-1)

    ; Calculate fib(n-2)
    pop rax             ; Restore fib(n-1)
    pop rdi             ; Restore n
    push rax            ; Save fib(n-1) again
    sub rdi, 2
    call fibonacci      ; rax = fib(n-2)

    ; Add them
    pop rbx             ; rbx = fib(n-1)
    add rax, rbx        ; rax = fib(n-1) + fib(n-2)
    ret

base_case:
    mov rax, rdi        ; Return n (0 or 1)
    ret
```

### Challenge 2: GCD (recursive)
Greatest Common Divisor using Euclidean algorithm:
```asm
; gcd(a, b) = gcd(b, a % b) if b != 0
; gcd(a, 0) = a
gcd:
    cmp rsi, 0
    je base_case

    ; Save rdi and rsi
    push rdi
    push rsi

    ; Calculate rdi % rsi
    xor rdx, rdx        ; Clear rdx for division
    mov rax, rdi        ; Dividend
    div rsi             ; rax = rdi / rsi, rdx = rdi % rsi

    ; Prepare for recursive call: gcd(rsi, rdx)
    pop rsi             ; Original rsi
    pop rdi             ; Original rdi (not used)
    mov rdi, rsi        ; First arg = old rsi
    mov rsi, rdx        ; Second arg = rdi % rsi
    call gcd
    ret

base_case:
    mov rax, rdi
    ret
```

### Challenge 3: Power function (recursive)
Calculate base^exponent:
```asm
; power(base, exp) = base × power(base, exp-1)
; power(base, 0) = 1
power:
    ; rdi = base, rsi = exponent
    cmp rsi, 0
    je base_case

    push rdi            ; Save base
    push rsi            ; Save exponent

    dec rsi             ; exponent - 1
    call power          ; rax = power(base, exp-1)

    pop rsi             ; Restore exponent
    pop rdi             ; Restore base
    imul rax, rdi       ; rax = base × power(base, exp-1)
    ret

base_case:
    mov rax, 1
    ret
```

### Challenge 4: Tail-recursive factorial
More efficient (can be optimized by compiler):
```asm
; factorial_tail(n, acc) = factorial_tail(n-1, n × acc)
; factorial_tail(1, acc) = acc
factorial_tail:
    ; rdi = n, rsi = accumulator
    cmp rdi, 1
    jle base_case

    imul rsi, rdi       ; acc = n × acc
    dec rdi             ; n = n - 1
    call factorial_tail ; tail call
    ret

base_case:
    mov rax, rsi        ; Return accumulator
    ret

_start:
    mov rdi, 5          ; n = 5
    mov rsi, 1          ; acc = 1
    call factorial_tail

    mov rdi, rax
    mov rax, 60
    syscall
```

## Performance Considerations

**Recursive**: Simple, elegant, but uses more stack space
- Stack depth: O(n)
- Each call has overhead

**Iterative**: More efficient
- No stack overhead
- Faster execution
- Uses less memory

For production code, the iterative version is usually preferred unless recursion provides significant clarity.

## Summary

You've learned:
- ✅ How to implement recursive functions
- ✅ How to preserve registers and arguments
- ✅ How to manage the stack across multiple calls
- ✅ How to trace recursive execution
- ✅ How to debug complex function calls

Congratulations! You've completed the basics section!

## Next Steps

You now understand the fundamentals of x86-64 assembly:
- Program structure
- Registers and arithmetic
- Conditionals and loops
- Functions and the stack
- Recursion

You're ready to:
- Build more complex programs
- Optimize performance-critical code
- Read and understand compiler output
- Explore advanced topics (SIMD, floating-point, inline assembly)

## Resources

- [Calling Conventions](../../resources/calling-conventions.md)
- [Instruction Reference](../../resources/instruction-reference.md)
- [Stack Management](../../resources/calling-conventions.md#stack-management)
