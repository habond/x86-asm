#!/bin/bash

# Test script for conditionals assignment
# Tests that the program correctly compares 15 > 10 and returns 1


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

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

test_program() {
    local program=$1
    local description=$2

    echo ""
    echo "Testing $description..."
    echo "================================"

    # Test 1: Program exists
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

    # Test 3: Exit code is 1 (15 > 10 is true)
    ./"$program" > /dev/null 2>&1
    exit_code=$?
    expected_exit=1

    if [ "$exit_code" -eq "$expected_exit" ]; then
        print_result "Returns 1 (15 > 10)" "PASS" "" ""
    else
        print_result "Returns 1 (15 > 10)" "FAIL" "$expected_exit" "$exit_code"
    fi

    # Test 4: No output (should be silent)
    output=$(./"$program" 2>&1)
    if [ -z "$output" ]; then
        print_result "No output (silent exit)" "PASS" "" ""
    else
        print_result "No output (silent exit)" "FAIL" "(no output)" "$output"
    fi
}

echo "========================================"
echo "  Conditionals - Assembly Test Suite"
echo "========================================"

# Test solution first
if [ -f "solution" ]; then
    test_program "solution" "solution.asm (reference)"
else
    echo -e "${YELLOW}Warning: solution not built. Run 'make solution' first.${NC}"
fi

# Test student's implementation
if [ -f "conditional" ]; then
    test_program "conditional" "conditional.asm (your code)"
else
    echo -e "${YELLOW}Warning: conditional not built. Run 'make' first.${NC}"
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
    echo ""
    echo "💡 Try modifying the numbers in conditional.asm:"
    echo "   - Change to 5 and 10 → should return 0"
    echo "   - Change to 10 and 10 → should return 0"
    echo "   - Change to 20 and 10 → should return 1"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
