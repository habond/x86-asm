#!/bin/bash

# Test script for bit-manipulation assignment

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

# Function to test a program with specific input
test_bitcount() {
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

    # Test 3: Default test (0x0F should give 4)
    ./"$program" > /dev/null 2>&1
    exit_code=$?
    expected_exit=4

    if [ "$exit_code" -eq "$expected_exit" ]; then
        print_result "count_bits(0x0F) = 4" "PASS" "" ""
    else
        print_result "count_bits(0x0F) = 4" "FAIL" "$expected_exit" "$exit_code"
    fi
}

# Main test execution
echo "========================================"
echo "  Bit Manipulation - Test Suite"
echo "========================================"

# Test solution first
if [ -f "solution" ]; then
    test_bitcount "solution" "solution.asm (reference)"
else
    echo -e "${YELLOW}Warning: solution not built. Run 'make solution' first.${NC}"
fi

# Test student's implementation
if [ -f "bitcount" ]; then
    test_bitcount "bitcount" "bitcount.asm (your code)"
else
    echo -e "${YELLOW}Warning: bitcount not built. Run 'make' first.${NC}"
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
    echo "Try these additional tests manually:"
    echo "  echo \$? after running with different values:"
    echo "  - 0x00 should give 0"
    echo "  - 0xFF should give 8"
    echo "  - 0xFFFFFFFFFFFFFFFF should give 64"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
