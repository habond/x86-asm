#!/bin/bash

# Test script for hello-world assignment
# Tests both the student's implementation and the solution


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
    local test_name=$1
    local result=$2
    local expected=$3
    local actual=$4

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  Expected: $expected"
        echo -e "  Got:      $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to test a program
test_program() {
    local program=$1
    local description=$2

    echo ""
    echo "Testing $description..."
    echo "================================"

    # Test 1: Check if program exists
    if [ ! -f "$program" ]; then
        print_result "Program exists" "FAIL" "File exists" "File not found"
        return
    fi
    print_result "Program exists" "PASS" "" ""

    # Test 2: Program is executable
    if [ ! -x "$program" ]; then
        print_result "Program is executable" "FAIL" "Executable" "Not executable"
        return
    fi
    print_result "Program is executable" "PASS" "" ""

    # Test 3: Check output
    output=$(./"$program" 2>&1)
    expected_output="Hello, World!"

    if [ "$output" = "$expected_output" ]; then
        print_result "Output is correct" "PASS" "" ""
    else
        print_result "Output is correct" "FAIL" "$expected_output" "$output"
    fi

    # Test 4: Check exit code
    ./"$program" > /dev/null 2>&1
    exit_code=$?
    expected_exit=0

    if [ "$exit_code" -eq "$expected_exit" ]; then
        print_result "Exit code is correct" "PASS" "" ""
    else
        print_result "Exit code is correct" "FAIL" "$expected_exit" "$exit_code"
    fi

    # Test 5: Check for newline at end
    output_hex=$(./  "$program" 2>&1 | od -An -tx1 | tr -d ' \n')
    # "Hello, World!\n" in hex: 48656c6c6f2c20576f726c64210a
    if [[ "$output_hex" == *"0a" ]]; then
        print_result "Output ends with newline" "PASS" "" ""
    else
        print_result "Output ends with newline" "FAIL" "Ends with \\n (0x0a)" "No newline found"
    fi
}

# Main test execution
echo "========================================"
echo "  Hello World - Assembly Test Suite"
echo "========================================"

# Test solution first (to verify tests work)
if [ -f "solution" ]; then
    test_program "solution" "solution.asm (reference)"
else
    echo -e "${YELLOW}Warning: solution not built. Run 'make solution' first.${NC}"
fi

# Test student's implementation
if [ -f "hello" ]; then
    test_program "hello" "hello.asm (your code)"
else
    echo -e "${YELLOW}Warning: hello not built. Run 'make' first.${NC}"
fi

# Print summary
echo ""
echo "========================================"
echo "  Test Summary"
echo "========================================"
echo "Tests run:    $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
else
    echo -e "Tests failed: $TESTS_FAILED"
fi

echo ""
if [ $TESTS_FAILED -eq 0 ] && [ $TESTS_RUN -gt 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
