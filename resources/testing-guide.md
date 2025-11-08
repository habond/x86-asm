# Testing Assembly Programs

A comprehensive guide to testing your x86-64 assembly code.

## Why Test Assembly Code?

Testing helps you:
- **Verify correctness** - Ensure your code does what it should
- **Catch regressions** - Make sure changes don't break existing functionality
- **Learn faster** - Get immediate feedback on your work
- **Build confidence** - Know your code works before moving on

## Testing Methods

### 1. Exit Code Testing

The simplest form of testing - check if the program exits with the expected code.

```bash
./program
exit_code=$?
if [ $exit_code -eq 42 ]; then
    echo "PASS"
else
    echo "FAIL: Expected 42, got $exit_code"
fi
```

**Example test script:**
```bash
#!/bin/bash
./add
result=$?
expected=69

if [ $result -eq $expected ]; then
    echo "✓ Test passed: 42 + 27 = $result"
    exit 0
else
    echo "✗ Test failed: Expected $expected, got $result"
    exit 1
fi
```

### 2. Output Testing

Compare program output against expected strings.

```bash
output=$(./program)
expected="Hello, World!"

if [ "$output" = "$expected" ]; then
    echo "PASS"
else
    echo "FAIL"
fi
```

**Example test script:**
```bash
#!/bin/bash
output=$(./hello)
expected="Hello, World!"

if [ "$output" = "$expected" ]; then
    echo "✓ Output correct"
else
    echo "✗ Output mismatch"
    echo "  Expected: $expected"
    echo "  Got:      $output"
fi
```

### 3. Multiple Test Cases

Test with different inputs or scenarios.

```bash
#!/bin/bash

test_count=0
pass_count=0

run_test() {
    local name=$1
    local expected=$2
    local actual=$3

    test_count=$((test_count + 1))

    if [ "$expected" = "$actual" ]; then
        echo "✓ $name"
        pass_count=$((pass_count + 1))
    else
        echo "✗ $name - Expected: $expected, Got: $actual"
    fi
}

# Test 1
./program1
run_test "Test 1" "42" "$?"

# Test 2
output=$(./program2)
run_test "Test 2" "Hello" "$output"

echo ""
echo "$pass_count/$test_count tests passed"
```

### 4. GDB Automated Testing

Use GDB with commands file to inspect program state.

**test_commands.gdb:**
```gdb
break _start
run
# Check initial state
if $rax != 0
    echo FAIL: rax should be 0\n
    quit 1
end

# Step through
stepi
stepi

# Check result
if $rax != 42
    echo FAIL: rax should be 42\n
    quit 1
end

echo PASS: All checks succeeded\n
quit 0
```

**Run with:**
```bash
gdb -batch -x test_commands.gdb ./program
```

### 5. Calling from C

Test assembly functions by calling them from C code.

**test_strlen.c:**
```c
#include <stdio.h>
#include <string.h>
#include <assert.h>

// Declare assembly function
extern size_t my_strlen(const char *str);

int main() {
    // Test 1: Normal string
    const char *s1 = "Hello";
    assert(my_strlen(s1) == strlen(s1));
    printf("✓ Test 1 passed\n");

    // Test 2: Empty string
    const char *s2 = "";
    assert(my_strlen(s2) == 0);
    printf("✓ Test 2 passed\n");

    // Test 3: Long string
    const char *s3 = "This is a longer string!";
    assert(my_strlen(s3) == strlen(s3));
    printf("✓ Test 3 passed\n");

    printf("\nAll tests passed!\n");
    return 0;
}
```

**strlen_for_c.asm:**
```asm
section .text
global my_strlen

my_strlen:
    xor rax, rax
loop_start:
    cmp byte [rdi], 0
    je done
    inc rax
    inc rdi
    jmp loop_start
done:
    ret
```

**Build and test:**
```bash
nasm -f elf64 strlen_for_c.asm -o strlen_for_c.o
gcc test_strlen.c strlen_for_c.o -o test_strlen
./test_strlen
```

### 6. Property-Based Testing

Test with many random inputs (advanced).

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

extern size_t my_strlen(const char *str);

void generate_random_string(char *buf, size_t len) {
    for (size_t i = 0; i < len; i++) {
        buf[i] = 'a' + (rand() % 26);
    }
    buf[len] = '\0';
}

int main() {
    srand(time(NULL));
    int tests = 100;
    int passed = 0;

    for (int i = 0; i < tests; i++) {
        size_t len = rand() % 100;
        char buf[101];
        generate_random_string(buf, len);

        if (my_strlen(buf) == strlen(buf)) {
            passed++;
        } else {
            printf("✗ Failed on string of length %zu\n", len);
        }
    }

    printf("%d/%d tests passed\n", passed, tests);
    return passed == tests ? 0 : 1;
}
```

## Test Script Template

Here's a reusable test script template:

```bash
#!/bin/bash

# Configuration
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0

# Helper function
run_test() {
    local name=$1
    local expected=$2
    local actual=$3

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓${NC} $name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $name"
        echo "  Expected: $expected"
        echo "  Got:      $actual"
    fi
}

# Your tests here
./program > /dev/null
run_test "Exit code test" "0" "$?"

output=$(./program)
run_test "Output test" "Expected output" "$output"

# Summary
echo ""
echo "Tests: $TESTS_PASSED/$TESTS_RUN passed"
[ $TESTS_PASSED -eq $TESTS_RUN ] && exit 0 || exit 1
```

## Testing Different Aspects

### Testing Exit Codes

```bash
./factorial
result=$?
expected=120

if [ $result -eq $expected ]; then
    echo "✓ Exit code: $result"
else
    echo "✗ Expected: $expected, Got: $result"
fi
```

**Note**: Exit codes are 8-bit (0-255), so 256 becomes 0, 257 becomes 1, etc.

### Testing Output

```bash
output=$(./hello 2>&1)  # Capture stdout and stderr
expected="Hello, World!"

if [ "$output" = "$expected" ]; then
    echo "✓ Output matches"
fi
```

### Testing with Arguments

```bash
output=$(./args hello world)
expected_line1="./args"
expected_line2="hello"
expected_line3="world"

line1=$(echo "$output" | sed -n '1p')
line2=$(echo "$output" | sed -n '2p')
line3=$(echo "$output" | sed -n '3p')

[ "$line1" = "$expected_line1" ] && echo "✓ Line 1 correct"
[ "$line2" = "$expected_line2" ] && echo "✓ Line 2 correct"
[ "$line3" = "$expected_line3" ] && echo "✓ Line 3 correct"
```

### Testing with strace

Verify system calls:

```bash
strace -o trace.txt ./hello 2>&1
if grep -q "write(1, \"Hello, World" trace.txt; then
    echo "✓ Correct syscall"
fi
rm trace.txt
```

### Testing Memory Operations

For functions like memcpy, test via C wrapper:

```c
#include <stdio.h>
#include <string.h>

extern void *my_memcpy(void *dest, const void *src, size_t n);

int main() {
    char src[] = "Hello, World!";
    char dest1[20] = {0};
    char dest2[20] = {0};

    // Test our version
    my_memcpy(dest1, src, strlen(src) + 1);

    // Test standard version
    memcpy(dest2, src, strlen(src) + 1);

    // Compare
    if (strcmp(dest1, dest2) == 0) {
        printf("✓ memcpy works correctly\n");
        return 0;
    } else {
        printf("✗ memcpy failed\n");
        printf("  Expected: %s\n", dest2);
        printf("  Got:      %s\n", dest1);
        return 1;
    }
}
```

## Makefile Integration

Add test targets to your Makefile:

```makefile
test: $(TARGET) solution
	@./test.sh

test-gdb: $(TARGET)
	gdb -batch -x test_commands.gdb ./$(TARGET)

test-c: test_program
	./test_program

test_program: test.c function.o
	gcc test.c function.o -o test_program

.PHONY: test test-gdb test-c
```

## Best Practices

### 1. Test Early and Often

Don't wait until you've written 100 lines. Test every few lines.

### 2. Test Both Success and Failure Cases

```bash
# Test normal case
output=$(./validate "abc")
[ $? -eq 0 ] && echo "✓ Valid input accepted"

# Test edge case
output=$(./validate "")
[ $? -eq 1 ] && echo "✓ Empty input rejected"
```

### 3. Use Descriptive Test Names

```bash
# Bad
run_test "Test 1" "42" "$result"

# Good
run_test "Sum of 1 to 10 equals 55" "55" "$result"
```

### 4. Automate Everything

Make testing a single command: `make test`

### 5. Test the Solution First

Always verify your test works by running it on the solution:

```bash
# Build solution
make solution

# Test it
./test.sh solution

# If solution passes, test student code
./test.sh program
```

## Common Testing Pitfalls

### 1. Not Capturing stderr

```bash
# Wrong - only captures stdout
output=$(./program)

# Right - captures both
output=$(./program 2>&1)
```

### 2. String Comparison Issues

```bash
# Wrong - word splitting
if [ $output = "Hello World" ]; then

# Right - quote variables
if [ "$output" = "Hello World" ]; then
```

### 3. Exit Code Range

Remember: exit codes are 0-255. Test accordingly:

```bash
# If your result is 256
./program
result=$?  # Will be 0, not 256!
```

### 4. Newline Handling

```bash
# May include trailing newline
output=$(./program)

# Remove trailing newline if needed
output=$(./program | tr -d '\n')
```

## Debugging Failed Tests

### 1. Use set -x

```bash
#!/bin/bash
set -x  # Print each command before execution

./program
result=$?
# Will show the actual command and result
```

### 2. Print Hex Dump

```bash
# See exact bytes
./program | od -An -tx1

# See as hex and ASCII
./program | hexdump -C
```

### 3. Compare Byte-by-Byte

```bash
./program > actual.txt
echo "Expected output" > expected.txt
diff expected.txt actual.txt
```

### 4. Use GDB

```bash
gdb ./program
(gdb) run
# Check where it failed
(gdb) bt
(gdb) info registers
```

## Example: Complete Test Suite

Here's a complete example for the factorial assignment:

```bash
#!/bin/bash

set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0

run_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$1" = "$2" ]; then
        echo -e "${GREEN}✓${NC} $3"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $3"
        echo "  Expected: $1, Got: $2"
    fi
}

echo "Testing factorial..."

# Test 1: 5! = 120
./factorial
run_test "120" "$?" "5! = 120"

# Test with different values (requires modifying source)
# Or use C wrapper for dynamic testing

echo ""
echo "$TESTS_PASSED/$TESTS_RUN tests passed"
[ $TESTS_PASSED -eq $TESTS_RUN ]
```

## Summary

Testing assembly code is not only possible but essential for learning and development. Choose the method that fits your needs:

- **Exit codes** - Simplest, good for arithmetic programs
- **Output testing** - For programs that print
- **C wrappers** - Best for testing functions with different inputs
- **GDB scripts** - For detailed state inspection
- **Automated scripts** - Combine everything for comprehensive testing

Start simple and add more sophisticated tests as you become comfortable!
