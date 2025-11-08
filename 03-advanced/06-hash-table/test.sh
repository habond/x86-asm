#!/bin/bash

# Test script for hash-table assignment

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

    # Test 1: Lookup "alice" should return 100
    ./"$program" > /dev/null 2>&1
    exit_code=$?
    expected_exit=100

    if [ "$exit_code" -eq "$expected_exit" ]; then
        print_result "Insert and lookup 'alice' = 100" "PASS" "" ""
    else
        print_result "Insert and lookup 'alice' = 100" "FAIL" "$expected_exit" "$exit_code"
    fi
}

# Create a test program that does multiple operations
create_test_program() {
    local test_file=$1
    local key=$2
    local expected=$3

    cat > "$test_file" << 'EOF'
section .data
    TABLE_SIZE equ 16
    ENTRY_SIZE equ 24

    key1 db "alice", 0
    key2 db "bob", 0
    key3 db "charlie", 0
    key4 db "david", 0

section .bss
    hash_table resb TABLE_SIZE * ENTRY_SIZE

section .text
global _start
EOF

    # Append the functions from solution
    tail -n +16 solution.asm | head -n -17 >> "$test_file"

    # Custom main based on test
    cat >> "$test_file" << EOF

_start:
    ; Insert multiple values
    mov rdi, key1
    mov rsi, 100
    call ht_insert

    mov rdi, key2
    mov rsi, 200
    call ht_insert

    mov rdi, key3
    mov rsi, 300
    call ht_insert

    mov rdi, key4
    mov rsi, 400
    call ht_insert

    ; Lookup $key
    mov rdi, $key
    call ht_lookup

    ; Exit with result
    mov rdi, rax
    mov rax, 60
    syscall
EOF
}

test_multiple_operations() {
    local description=$1

    echo ""
    echo "Testing $description with multiple operations..."
    echo "================================"

    if [ ! -f "solution" ]; then
        echo -e "${YELLOW}Skipping - solution not built${NC}"
        return
    fi

    # Test lookup of bob (200)
    rm -f test_bob.asm test_bob.o test_bob
    create_test_program "test_bob.asm" "key2" 200
    nasm -f elf64 test_bob.asm -o test_bob.o 2>/dev/null
    ld -o test_bob test_bob.o 2>/dev/null

    if [ -f "test_bob" ]; then
        ./test_bob > /dev/null 2>&1
        exit_code=$?
        if [ "$exit_code" -eq 200 ]; then
            print_result "Lookup 'bob' after multiple inserts" "PASS" "" ""
        else
            print_result "Lookup 'bob' after multiple inserts" "FAIL" "200" "$exit_code"
        fi
        rm -f test_bob test_bob.o test_bob.asm
    fi

    # Test lookup of charlie (300)
    rm -f test_charlie.asm test_charlie.o test_charlie
    create_test_program "test_charlie.asm" "key3" 300
    nasm -f elf64 test_charlie.asm -o test_charlie.o 2>/dev/null
    ld -o test_charlie test_charlie.o 2>/dev/null

    if [ -f "test_charlie" ]; then
        ./test_charlie > /dev/null 2>&1
        exit_code=$?
        if [ "$exit_code" -eq 44 ]; then  # 300 % 256 = 44
            print_result "Lookup 'charlie' after multiple inserts" "PASS" "" ""
        else
            print_result "Lookup 'charlie' after multiple inserts" "FAIL" "44" "$exit_code"
        fi
        rm -f test_charlie test_charlie.o test_charlie.asm
    fi

    # Test lookup of david (400 % 256 = 144)
    rm -f test_david.asm test_david.o test_david
    create_test_program "test_david.asm" "key4" 400
    nasm -f elf64 test_david.asm -o test_david.o 2>/dev/null
    ld -o test_david test_david.o 2>/dev/null

    if [ -f "test_david" ]; then
        ./test_david > /dev/null 2>&1
        exit_code=$?
        if [ "$exit_code" -eq 144 ]; then  # 400 % 256 = 144
            print_result "Lookup 'david' after multiple inserts" "PASS" "" ""
        else
            print_result "Lookup 'david' after multiple inserts" "FAIL" "144" "$exit_code"
        fi
        rm -f test_david test_david.o test_david.asm
    fi
}

echo "========================================"
echo "  Hash Table - Test Suite"
echo "========================================"

if [ -f "solution" ]; then
    test_program "solution" "solution.asm (reference)"
    test_multiple_operations "solution.asm"
else
    echo -e "${YELLOW}Warning: solution not built.${NC}"
fi

if [ -f "hashtable" ]; then
    test_program "hashtable" "hashtable.asm (your code)"
else
    echo -e "${YELLOW}Warning: hashtable not built.${NC}"
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
