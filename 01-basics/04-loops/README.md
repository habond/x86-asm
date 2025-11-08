# Assignment 4: Loops

Learn how to repeat operations using loops in assembly.

## Learning Objectives

- Implement loop counters
- Combine conditionals and jumps for loops
- Create while and for loop patterns
- Understand loop control flow

## Background

In high-level languages, you use loops:
```c
// For loop
for (int i = 0; i < 10; i++) {
    // Do something
}

// While loop
int i = 0;
while (i < 10) {
    // Do something
    i++;
}
```

In assembly, loops are built from:
1. **Initialize** a counter
2. **Compare** counter with limit
3. **Jump** if done
4. **Execute** loop body
5. **Increment** counter
6. **Jump** back to comparison

## The Task

Write a program that:
1. Counts from 1 to 10
2. Sums all the numbers (1 + 2 + 3 + ... + 10)
3. Exits with the result as the exit code (should be 55)

## Loop Pattern

### For Loop Pattern
```asm
    mov rcx, 0          ; counter = 0

loop_start:
    cmp rcx, 10         ; if counter >= 10
    jge loop_end        ; exit loop

    ; --- Loop body here ---

    inc rcx             ; counter++
    jmp loop_start      ; repeat

loop_end:
    ; Continue after loop
```

### While Loop Pattern
```asm
    mov rcx, 0          ; counter = 0

while_loop:
    cmp rcx, 10         ; while counter < 10
    jge end_while

    ; --- Loop body here ---

    inc rcx             ; counter++
    jmp while_loop

end_while:
    ; Continue after loop
```

### Countdown Loop (simpler)
```asm
    mov rcx, 10         ; Start at 10

loop:
    ; --- Loop body here ---

    dec rcx             ; Decrement counter
    jnz loop            ; Jump if Not Zero

    ; Continue (rcx is now 0)
```

## Starter Code

```asm
section .text
global _start

_start:
    ; TODO: Initialize sum to 0 (use rax)

    ; TODO: Initialize counter to 1 (use rcx)

loop_start:
    ; TODO: Check if counter > 10, if so jump to loop_end

    ; TODO: Add counter to sum (add rax, rcx)

    ; TODO: Increment counter (inc rcx)

    ; TODO: Jump back to loop_start

loop_end:
    ; Exit with sum as exit code
    mov rdi, rax        ; Exit code = sum
    mov rax, 60         ; sys_exit
    syscall
```

## Step by Step

### Step 1: Initialize variables
```asm
mov rax, 0          ; sum = 0
mov rcx, 1          ; counter = 1
```

### Step 2: Loop condition
```asm
loop_start:
cmp rcx, 10         ; Compare counter with 10
jg loop_end         ; If counter > 10, exit loop
```

### Step 3: Loop body
```asm
add rax, rcx        ; sum += counter
```

### Step 4: Increment counter
```asm
inc rcx             ; counter++
```

### Step 5: Repeat
```asm
jmp loop_start      ; Go back to condition check
```

### Step 6: After loop
```asm
loop_end:
; rax now contains 1+2+3+...+10 = 55
mov rdi, rax
mov rax, 60
syscall
```

## Building and Running

```bash
nasm -f elf64 loop.asm -o loop.o
ld -o loop loop.o
./loop
echo $?             # Should print 55
```

Or with Make:
```bash
make run
echo $?
```

## Expected Output

```bash
$ ./loop
$ echo $?
55
```

The sum 1+2+3+...+10 = 55, so the exit code is 55.

## Verification

Let's verify: 1+2+3+4+5+6+7+8+9+10 = 55 ✓

Or use the formula: n(n+1)/2 = 10(11)/2 = 110/2 = 55 ✓

## Common Mistakes

### Mistake 1: Infinite loop (wrong condition)
```asm
loop_start:
cmp rcx, 10
jl loop_start       ; Oops! Always jumps (infinite loop)
```

**Fix**: Jump to loop_end when done
```asm
cmp rcx, 10
jg loop_end         ; Exit when counter > 10
```

### Mistake 2: Off-by-one error
```asm
mov rcx, 0          ; Starting at 0
cmp rcx, 10
jge loop_end        ; Stops at 9, not 10!
```

**Fix**: Start at 1 or use `jg` instead of `jge`
```asm
mov rcx, 1          ; Start at 1
cmp rcx, 10
jg loop_end         ; Loop while counter <= 10
```

### Mistake 3: Forgetting to increment
```asm
loop_start:
cmp rcx, 10
jg loop_end
add rax, rcx
jmp loop_start      ; Infinite! Forgot to increment rcx
```

**Fix**: Always increment the counter
```asm
add rax, rcx
inc rcx             ; Don't forget!
jmp loop_start
```

### Mistake 4: Wrong jump destination
```asm
loop_start:
cmp rcx, 10
jg loop_end
add rax, rcx
inc rcx
jmp loop_end        ; Wrong! Should jump to loop_start
```

**Fix**: Jump back to the beginning
```asm
jmp loop_start
```

## Understanding Loop Iterations

Let's trace through the loop:

```
Iteration 1: rax=0, rcx=1  → rax=0+1=1,  rcx→2
Iteration 2: rax=1, rcx=2  → rax=1+2=3,  rcx→3
Iteration 3: rax=3, rcx=3  → rax=3+3=6,  rcx→4
Iteration 4: rax=6, rcx=4  → rax=6+4=10, rcx→5
Iteration 5: rax=10, rcx=5 → rax=10+5=15, rcx→6
Iteration 6: rax=15, rcx=6 → rax=15+6=21, rcx→7
Iteration 7: rax=21, rcx=7 → rax=21+7=28, rcx→8
Iteration 8: rax=28, rcx=8 → rax=28+8=36, rcx→9
Iteration 9: rax=36, rcx=9 → rax=36+9=45, rcx→10
Iteration 10: rax=45, rcx=10 → rax=45+10=55, rcx→11
Check: rcx=11 > 10, exit loop
Result: rax=55
```

## Loop Types

### 1. Counting Up (1 to N)
```asm
mov rcx, 1
loop_start:
cmp rcx, 10
jg loop_end
; loop body
inc rcx
jmp loop_start
loop_end:
```

### 2. Counting Down (N to 1)
```asm
mov rcx, 10
loop_start:
cmp rcx, 0
jle loop_end
; loop body
dec rcx
jmp loop_start
loop_end:
```

### 3. Countdown with JNZ (most compact)
```asm
mov rcx, 10
loop_start:
; loop body
dec rcx
jnz loop_start      ; Jump if not zero
; rcx is now 0
```

### 4. Do-While Loop (body runs at least once)
```asm
mov rcx, 1
loop_start:
; loop body (runs at least once)
inc rcx
cmp rcx, 10
jle loop_start
```

## Experiments

### 1. Count to 100
Sum 1 to 100 (result: 5050):
```asm
mov rax, 0
mov rcx, 1

loop_start:
cmp rcx, 100
jg loop_end
add rax, rcx
inc rcx
jmp loop_start

loop_end:
; rax = 5050 (but exit code will be 5050 % 256 = 186)
```

### 2. Count by 2s
Sum 2+4+6+8+10:
```asm
mov rax, 0
mov rcx, 2

loop_start:
cmp rcx, 10
jg loop_end
add rax, rcx
add rcx, 2          ; Increment by 2
jmp loop_start

loop_end:
; rax = 30
```

### 3. Multiplication via repeated addition
Calculate 7 × 8:
```asm
mov rax, 0          ; result
mov rbx, 7          ; multiplicand
mov rcx, 8          ; multiplier

loop_start:
cmp rcx, 0
jle loop_end
add rax, rbx        ; Add 7 each time
dec rcx
jmp loop_start

loop_end:
; rax = 56
```

### 4. Nested loops
Sum of 1+2+3+4+5, repeated 3 times:
```asm
mov rax, 0          ; total sum
mov rbx, 3          ; outer loop counter

outer_loop:
cmp rbx, 0
jle outer_end

; Inner loop: sum 1 to 5
mov rcx, 1

inner_loop:
cmp rcx, 5
jg inner_end
add rax, rcx
inc rcx
jmp inner_loop

inner_end:
dec rbx
jmp outer_loop

outer_end:
; rax = (1+2+3+4+5) × 3 = 15 × 3 = 45
```

## Debugging with GDB

```bash
nasm -f elf64 -g loop.asm -o loop.o
ld -o loop loop.o
gdb ./loop

(gdb) break _start
(gdb) run
(gdb) break loop_start      # Break at loop start
(gdb) continue
(gdb) print $rax            # Check sum
(gdb) print $rcx            # Check counter
(gdb) continue              # Continue to next iteration
```

You can also set a conditional breakpoint:
```
(gdb) break loop_start if $rcx == 5
(gdb) continue              # Stops when counter is 5
```

## Visualizing Loop Flow

```
Start
  ↓
rax = 0 (sum)
rcx = 1 (counter)
  ↓
  ┌──────────────┐
  │ loop_start:  │←─────┐
  │ Is rcx > 10? │      │
  └──────────────┘      │
    │           │       │
   YES         NO       │
    │           │       │
    ↓           ↓       │
  Exit      sum += i    │
            i++         │
            └───────────┘
```

## Going Further

### Challenge 1: Factorial
Calculate 5! (5 × 4 × 3 × 2 × 1 = 120):
```asm
mov rax, 1          ; result
mov rcx, 5          ; counter

loop_start:
cmp rcx, 1
jle loop_end
imul rax, rcx       ; result *= counter
dec rcx
jmp loop_start

loop_end:
; rax = 120
```

### Challenge 2: Fibonacci
Calculate 10th Fibonacci number:
```asm
mov rax, 0          ; fib(0)
mov rbx, 1          ; fib(1)
mov rcx, 10         ; counter

loop_start:
cmp rcx, 0
jle loop_end

mov rdx, rax        ; temp = fib(n-2)
add rax, rbx        ; fib(n) = fib(n-1) + fib(n-2)
mov rbx, rdx        ; fib(n-1) = temp

dec rcx
jmp loop_start

loop_end:
; rbx = 55 (10th Fibonacci)
```

### Challenge 3: Sum of squares
Sum 1²+2²+3²+...+10² = 385:
```asm
mov rax, 0          ; sum
mov rcx, 1          ; counter

loop_start:
cmp rcx, 10
jg loop_end

mov rdx, rcx        ; rdx = counter
imul rdx, rcx       ; rdx = counter²
add rax, rdx        ; sum += counter²

inc rcx
jmp loop_start

loop_end:
; rax = 385 (but exit code = 385 % 256 = 129)
```

### Challenge 4: Count down and print
Use sys_write in a loop to print numbers (advanced):
```asm
section .data
    digit db '0', 10    ; Single digit + newline

section .text
global _start

_start:
    mov rcx, 10

loop_start:
    cmp rcx, 0
    jle loop_end

    ; Convert counter to ASCII digit
    mov rax, rcx
    add rax, 48         ; Convert to ASCII ('0' = 48)
    mov [digit], al     ; Store in memory

    ; Print the digit
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, digit      ; pointer to digit
    mov rdx, 2          ; length (digit + newline)
    syscall

    dec rcx
    jmp loop_start

loop_end:
    mov rax, 60
    xor rdi, rdi
    syscall
```

## Performance Note

In real code, you might use the `LOOP` instruction:
```asm
mov rcx, 10
loop_start:
; loop body
loop loop_start     ; Decrements rcx and jumps if rcx != 0
```

However, `LOOP` is slower on modern CPUs, so `dec rcx; jnz` is preferred.

## Next Steps

Once you complete this assignment, move on to:
- [05-functions](../05-functions/) - Code organization with functions

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Jump Instructions](../../resources/instruction-reference.md#jumps)
