#!/bin/bash

# Test script for file-io assignment
# Tests file copy functionality and error handling

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

    # Test 1: Copy simple text file
    echo "Hello, World!" > test_source.txt
    ./"$program" test_source.txt test_dest.txt > /dev/null 2>&1
    exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        print_result "Exit code = 0 (success)" "PASS" "" ""
    else
        print_result "Exit code = 0 (success)" "FAIL" "0" "$exit_code"
    fi

    if [ -f test_dest.txt ]; then
        print_result "Destination file created" "PASS" "" ""
    else
        print_result "Destination file created" "FAIL" "File exists" "File not created"
        rm -f test_source.txt
        return
    fi

    # Test 2: Verify content matches
    if diff -q test_source.txt test_dest.txt > /dev/null 2>&1; then
        print_result "Files are identical (simple text)" "PASS" "" ""
    else
        print_result "Files are identical (simple text)" "FAIL" "Files match" "Files differ"
    fi

    rm -f test_source.txt test_dest.txt

    # Test 3: Copy multi-line file
    cat > test_multiline.txt <<EOF
Line 1
Line 2
Line 3
Line 4
EOF

    ./"$program" test_multiline.txt test_multiline_copy.txt > /dev/null 2>&1
    if diff -q test_multiline.txt test_multiline_copy.txt > /dev/null 2>&1; then
        print_result "Multi-line file copy works" "PASS" "" ""
    else
        print_result "Multi-line file copy works" "FAIL" "Files match" "Files differ"
    fi

    rm -f test_multiline.txt test_multiline_copy.txt

    # Test 4: Copy larger file (tests buffering)
    dd if=/dev/urandom of=test_large.bin bs=1024 count=10 > /dev/null 2>&1
    ./"$program" test_large.bin test_large_copy.bin > /dev/null 2>&1

    if diff -q test_large.bin test_large_copy.bin > /dev/null 2>&1; then
        print_result "Large file copy works (10KB)" "PASS" "" ""
    else
        print_result "Large file copy works (10KB)" "FAIL" "Files match" "Files differ"
    fi

    rm -f test_large.bin test_large_copy.bin

    # Test 5: Copy file with special characters
    echo -e "Line with\ttabs" > test_special.txt
    echo -e "Line with spaces  " >> test_special.txt
    echo "" >> test_special.txt
    echo "Empty line above" >> test_special.txt

    ./"$program" test_special.txt test_special_copy.txt > /dev/null 2>&1
    if diff -q test_special.txt test_special_copy.txt > /dev/null 2>&1; then
        print_result "Special characters preserved" "PASS" "" ""
    else
        print_result "Special characters preserved" "FAIL" "Files match" "Files differ"
    fi

    rm -f test_special.txt test_special_copy.txt

    # Test 6: Error handling - no arguments
    ./"$program" > /dev/null 2>&1
    exit_code=$?
    if [ "$exit_code" -ne 0 ]; then
        print_result "Error on no arguments (exit != 0)" "PASS" "" ""
    else
        print_result "Error on no arguments (exit != 0)" "FAIL" "Non-zero" "0"
    fi

    # Test 7: Error handling - one argument
    ./"$program" onefile.txt > /dev/null 2>&1
    exit_code=$?
    if [ "$exit_code" -ne 0 ]; then
        print_result "Error on one argument (exit != 0)" "PASS" "" ""
    else
        print_result "Error on one argument (exit != 0)" "FAIL" "Non-zero" "0"
    fi

    # Test 8: Error handling - missing source file
    rm -f nonexistent_file.txt
    ./"$program" nonexistent_file.txt dest.txt > /dev/null 2>&1
    exit_code=$?
    if [ "$exit_code" -ne 0 ]; then
        print_result "Error on missing source file" "PASS" "" ""
    else
        print_result "Error on missing source file" "FAIL" "Non-zero" "0"
    fi
    rm -f dest.txt

    # Test 9: Copy empty file
    touch test_empty.txt
    ./"$program" test_empty.txt test_empty_copy.txt > /dev/null 2>&1
    exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        print_result "Copy empty file succeeds" "PASS" "" ""
    else
        print_result "Copy empty file succeeds" "FAIL" "0" "$exit_code"
    fi

    if [ -f test_empty_copy.txt ]; then
        size=$(stat -f %z test_empty_copy.txt 2>/dev/null || stat -c %s test_empty_copy.txt 2>/dev/null)
        if [ "$size" -eq 0 ]; then
            print_result "Empty file remains empty" "PASS" "" ""
        else
            print_result "Empty file remains empty" "FAIL" "0 bytes" "$size bytes"
        fi
    fi

    rm -f test_empty.txt test_empty_copy.txt

    # Test 10: Overwrite existing file
    echo "Original content" > test_overwrite.txt
    echo "New content" > test_source_ow.txt
    ./"$program" test_source_ow.txt test_overwrite.txt > /dev/null 2>&1

    content=$(cat test_overwrite.txt)
    if [ "$content" = "New content" ]; then
        print_result "Overwrites existing file" "PASS" "" ""
    else
        print_result "Overwrites existing file" "FAIL" "New content" "$content"
    fi

    rm -f test_overwrite.txt test_source_ow.txt
}

echo "========================================"
echo "  File I/O - Assembly Test Suite"
echo "========================================"

if [ -f "solution" ]; then
    test_program "solution" "solution.asm (reference)"
else
    echo -e "${YELLOW}Warning: solution not built. Run 'make solution' first.${NC}"
fi

if [ -f "filecp" ]; then
    test_program "filecp" "filecp.asm (your code)"
else
    echo -e "${YELLOW}Warning: filecp not built. Run 'make' first.${NC}"
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
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
