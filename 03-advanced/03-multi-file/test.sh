#!/bin/bash

# Test script for multi-file assignment

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
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
        if [ -n "$expected" ]; then
            echo -e "  Expected: $expected"
            echo -e "  Got:      $actual"
        fi
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

test_program() {
    local program=$1
    local description=$2

    echo ""
    echo "Testing $description..."
    echo "================================"

    if [ ! -f "$program" ]; then
        print_result "Program exists" "FAIL" "File exists" "File not found"
        return
    fi
    print_result "Program exists" "PASS" "" ""

    if [ ! -x "$program" ]; then
        print_result "Program is executable" "FAIL" "Executable" "Not executable"
        return
    fi
    print_result "Program is executable" "PASS" "" ""

    # Test: program should exit with code 0
    ./"$program" > /dev/null 2>&1
    exit_code=$?
    expected_exit=0

    if [ "$exit_code" -eq "$expected_exit" ]; then
        print_result "Program exits successfully" "PASS" "" ""
    else
        print_result "Program exits successfully" "FAIL" "$expected_exit" "$exit_code"
    fi

    # Test: check that all object files were created
    if [ "$program" = "program" ]; then
        if [ -f "main.o" ] && [ -f "string_utils.o" ] && [ -f "math_utils.o" ]; then
            print_result "All object files created" "PASS" "" ""
        else
            print_result "All object files created" "FAIL" "3 .o files" "Missing files"
        fi
    fi
}

echo "========================================"
echo "  Multi-File Project - Test Suite"
echo "========================================"

if [ -f "solution" ]; then
    test_program "solution" "solution (reference)"
else
    echo -e "${YELLOW}Warning: solution not built.${NC}"
fi

if [ -f "program" ]; then
    test_program "program" "program (your code)"
else
    echo -e "${YELLOW}Warning: program not built.${NC}"
fi

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
    echo "Your program successfully:"
    echo "  - Compiled multiple .asm files"
    echo "  - Linked them together"
    echo "  - Used extern/global correctly"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
