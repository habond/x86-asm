# Assignment 3: Conditionals

Learn how to make decisions in assembly with comparisons and conditional jumps.

## Learning Objectives

- Use CMP to compare values
- Understand conditional jumps (JE, JNE, JG, JL, etc.)
- Implement if/else logic
- Work with the flags register

## Background

In high-level languages, you use if/else statements:
```c
if (x > 10) {
    return 1;
} else {
    return 0;
}
```

In assembly, this becomes:
1. **Compare** values with `CMP`
2. **Jump** conditionally based on the result
3. **Execute** different code paths

## The Task

Write a program that:
1. Loads two numbers (e.g., 15 and 10)
2. Compares them
3. If the first number is greater, exit with code 1
4. Otherwise, exit with code 0

## Instructions You'll Need

### CMP - Compare
```asm
cmp op1, op2        ; Compare op1 with op2 (sets flags)
```

**How it works**:
- Performs `op1 - op2` without storing the result
- Updates the flags register (ZF, CF, SF, OF)
- Used before conditional jumps

Examples:
```asm
cmp rax, 10         ; Compare rax with 10
cmp rax, rbx        ; Compare rax with rbx
```

### Conditional Jumps

After a `CMP`, you can jump based on the relationship:

**Equality**:
- `je label` - Jump if equal (ZF=1)
- `jne label` - Jump if not equal (ZF=0)

**Unsigned comparisons** (for positive numbers):
- `ja label` - Jump if above (greater than)
- `jb label` - Jump if below (less than)
- `jae label` - Jump if above or equal
- `jbe label` - Jump if below or equal

**Signed comparisons** (for positive and negative):
- `jg label` - Jump if greater
- `jl label` - Jump if less
- `jge label` - Jump if greater or equal
- `jle label` - Jump if less or equal

**Example**:
```asm
cmp rax, rbx
jg greater          ; Jump to 'greater' if rax > rbx
; Code here runs if rax <= rbx
mov rdi, 0
jmp done

greater:
; Code here runs if rax > rbx
mov rdi, 1

done:
; Continue execution
```

### JMP - Unconditional Jump
```asm
jmp label           ; Always jump to label
```

## Starter Code

```asm
section .text
global _start

_start:
    ; TODO: Load 15 into rax

    ; TODO: Load 10 into rbx

    ; TODO: Compare rax with rbx

    ; TODO: If rax > rbx, jump to 'greater' label

    ; If we get here, rax <= rbx
    mov rdi, 0          ; Exit code 0
    jmp exit

greater:
    mov rdi, 1          ; Exit code 1

exit:
    mov rax, 60         ; sys_exit
    syscall
```

## Step by Step

### Step 1: Load the values
```asm
mov rax, 15         ; First number
mov rbx, 10         ; Second number
```

### Step 2: Compare
```asm
cmp rax, rbx        ; Compare rax with rbx (15 vs 10)
```

This sets flags based on the result:
- Since 15 > 10, the flags indicate "greater"

### Step 3: Conditional jump
```asm
jg greater          ; Jump to 'greater' if rax > rbx
```

Since 15 > 10, this jump will be taken.

### Step 4: Define the branches
```asm
; This runs if rax <= rbx
mov rdi, 0
jmp exit

greater:
; This runs if rax > rbx
mov rdi, 1

exit:
mov rax, 60
syscall
```

## Building and Running

```bash
nasm -f elf64 conditional.asm -o conditional.o
ld -o conditional conditional.o
./conditional
echo $?             # Should print 1 (since 15 > 10)
```

Or with Make:
```bash
make run
echo $?
```

## Expected Output

```bash
$ ./conditional
$ echo $?
1
```

The exit code should be `1` because 15 > 10.

## Testing

Try changing the numbers:

**Test 1**: 15 > 10 → exit code 1 ✓
```asm
mov rax, 15
mov rbx, 10
```

**Test 2**: 5 < 10 → exit code 0
```asm
mov rax, 5
mov rbx, 10
```

**Test 3**: 10 = 10 → exit code 0
```asm
mov rax, 10
mov rbx, 10
```

## Common Mistakes

### Mistake 1: Wrong jump instruction
```asm
cmp rax, rbx
jl greater          ; Wrong! This jumps if LESS, not greater
```

**Fix**: Use the correct condition
```asm
cmp rax, rbx
jg greater          ; Jump if greater
```

### Mistake 2: Comparing wrong operands
```asm
cmp rbx, rax        ; This compares rbx with rax (backwards!)
jg greater          ; Now checking if rbx > rax
```

**Fix**: Compare in the right order
```asm
cmp rax, rbx        ; Check if rax > rbx
jg greater
```

### Mistake 3: Forgetting unconditional jump
```asm
cmp rax, rbx
jg greater
mov rdi, 0
; Oops! Falls through to 'greater' even when false

greater:
mov rdi, 1
```

**Fix**: Jump to exit
```asm
cmp rax, rbx
jg greater
mov rdi, 0
jmp exit            ; Don't fall through!

greater:
mov rdi, 1

exit:
```

### Mistake 4: Using signed vs unsigned jumps incorrectly
```asm
; For negative numbers, use signed jumps
mov rax, -5
mov rbx, 10
cmp rax, rbx
ja greater          ; Wrong! 'ja' is unsigned, treats -5 as huge positive
```

**Fix**: Use signed jumps for signed numbers
```asm
jg greater          ; Correct for signed comparison
```

## Understanding Flags

The `CMP` instruction sets flags in the FLAGS register:

- **ZF (Zero Flag)**: Set if op1 == op2
- **CF (Carry Flag)**: Set if unsigned op1 < op2
- **SF (Sign Flag)**: Set if result is negative
- **OF (Overflow Flag)**: Set if signed overflow occurred

**Example**: `cmp rax, rbx` where rax=15, rbx=10

```
15 - 10 = 5 (positive, non-zero)
ZF = 0  (not zero)
CF = 0  (no borrow needed)
SF = 0  (positive result)
```

The jump instructions check these flags:
- `jg`: SF==OF AND ZF==0 (greater for signed)
- `je`: ZF==1 (equal)
- `jne`: ZF==0 (not equal)

## Experiments

### 1. Check for equality
```asm
mov rax, 42
mov rbx, 42
cmp rax, rbx
je equal            ; Jump if equal

not_equal:
mov rdi, 0
jmp exit

equal:
mov rdi, 1

exit:
mov rax, 60
syscall
```

### 2. Three-way comparison
```asm
mov rax, 15
mov rbx, 10
cmp rax, rbx
jg greater
je equal
; If we're here, rax < rbx
mov rdi, 0          ; less than
jmp exit

greater:
mov rdi, 1
jmp exit

equal:
mov rdi, 2

exit:
mov rax, 60
syscall
```

### 3. Check if zero
```asm
mov rax, 0
cmp rax, 0
je is_zero          ; Or use: test rax, rax; jz is_zero

not_zero:
mov rdi, 1
jmp exit

is_zero:
mov rdi, 0

exit:
mov rax, 60
syscall
```

### 4. Range check (10 <= x <= 20)
```asm
mov rax, 15

; Check if rax >= 10
cmp rax, 10
jl out_of_range     ; Jump if less than 10

; Check if rax <= 20
cmp rax, 20
jg out_of_range     ; Jump if greater than 20

; If we're here, 10 <= rax <= 20
mov rdi, 1
jmp exit

out_of_range:
mov rdi, 0

exit:
mov rax, 60
syscall
```

## Debugging with GDB

```bash
nasm -f elf64 -g conditional.asm -o conditional.o
ld -o conditional conditional.o
gdb ./conditional

(gdb) break _start
(gdb) run
(gdb) stepi                 # Step through instructions
(gdb) info registers rflags # View flags register
(gdb) print $ZF             # Check individual flags
(gdb) continue
```

## Visualizing Execution Flow

```
Start
  ↓
Load rax = 15
  ↓
Load rbx = 10
  ↓
Compare (15 vs 10)
  ↓
[Decision Point]
  ↓
Is rax > rbx?
  ├─ YES → Jump to 'greater' → Set rdi=1 → Exit
  └─ NO  → Set rdi=0 → Jump to exit → Exit
```

## Going Further

### Challenge 1: Find maximum
Return the larger of two numbers (not just 0 or 1):
```asm
mov rax, 42
mov rbx, 27
cmp rax, rbx
jg rax_larger

; rbx is larger
mov rdi, rbx
jmp exit

rax_larger:
mov rdi, rax

exit:
mov rax, 60
syscall
```

### Challenge 2: Absolute value
Return |x| (absolute value):
```asm
mov rax, -15        ; Or any number
cmp rax, 0
jge positive        ; Jump if >= 0

; Negative: negate it
neg rax             ; rax = -rax

positive:
mov rdi, rax
mov rax, 60
syscall
```

### Challenge 3: Clamp value (min/max bounds)
Clamp rax to range [10, 20]:
```asm
mov rax, 25         ; Test value

; Check minimum
cmp rax, 10
jge check_max
mov rax, 10         ; Clamp to min

check_max:
cmp rax, 20
jle done
mov rax, 20         ; Clamp to max

done:
mov rdi, rax
mov rax, 60
syscall
```

## Next Steps

Once you complete this assignment, move on to:
- [04-loops](../04-loops/) - Repetition with loops

## Resources

- [Instruction Reference](../../resources/instruction-reference.md)
- [Conditional Jumps](../../resources/instruction-reference.md#conditional-jumps)
