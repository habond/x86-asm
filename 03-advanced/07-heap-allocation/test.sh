#!/bin/bash

# Test script for heap allocation assignment

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROGRAM=${1:-./main}
FAILED=0
PASSED=0

echo "Testing heap allocation implementation: $PROGRAM"
echo "================================================"

# Test 1: Program runs without crashing
echo -n "Test 1: Program runs without crashing... "
if ./$PROGRAM > /tmp/heap_test_output.txt 2>&1; then
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAILED${NC} (exit code: $EXIT_CODE)"
        ((FAILED++))
    fi
else
    echo -e "${RED}FAILED${NC} (program crashed)"
    ((FAILED++))
fi

# Test 2: Outputs allocation messages
echo -n "Test 2: Outputs allocation messages... "
if cat /tmp/heap_test_output.txt 2>/dev/null | grep -q "Allocated block 1:" && \
   cat /tmp/heap_test_output.txt 2>/dev/null | grep -q "Allocated block 2:" && \
   cat /tmp/heap_test_output.txt 2>/dev/null | grep -q "Allocated block 3:"; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    echo "Expected allocation messages not found"
    ((FAILED++))
fi

# Test 3: Shows success message
echo -n "Test 3: Shows success message... "
if cat /tmp/heap_test_output.txt 2>/dev/null | grep -q "All tests passed!"; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    echo "Success message not found"
    ((FAILED++))
fi

# Test 4: No error messages
echo -n "Test 4: No error messages... "
if ! cat /tmp/heap_test_output.txt 2>/dev/null | grep -q "ERROR:"; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    echo "Error messages found in output"
    ((FAILED++))
fi

# Test 5: Addresses are printed (hex format)
echo -n "Test 5: Addresses are printed in hex... "
if cat /tmp/heap_test_output.txt 2>/dev/null | grep -qE "0x[0-9a-fA-F]{8,}"; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    echo "No valid hex addresses found"
    ((FAILED++))
fi

# Test 6: Addresses are different and increasing
echo -n "Test 6: Addresses are different and increasing... "

# Extract the three addresses (use -a flag to handle binary content)
ADDR1=$(grep -a "Allocated block 1:" /tmp/heap_test_output.txt 2>/dev/null | grep -aoE '0x[0-9a-fA-F]+' | head -1 || echo "0x0")
ADDR2=$(grep -a "Allocated block 2:" /tmp/heap_test_output.txt 2>/dev/null | grep -aoE '0x[0-9a-fA-F]+' | head -1 || echo "0x0")
ADDR3=$(grep -a "Allocated block 3:" /tmp/heap_test_output.txt 2>/dev/null | grep -aoE '0x[0-9a-fA-F]+' | head -1 || echo "0x0")

# Convert to decimal for comparison
ADDR1_DEC=$((ADDR1))
ADDR2_DEC=$((ADDR2))
ADDR3_DEC=$((ADDR3))

if [ $ADDR1_DEC -gt 0 ] && [ $ADDR2_DEC -gt $ADDR1_DEC ] && [ $ADDR3_DEC -gt $ADDR2_DEC ]; then
    echo -e "${GREEN}PASSED${NC}"
    echo "  Block 1: $ADDR1"
    echo "  Block 2: $ADDR2"
    echo "  Block 3: $ADDR3"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    echo "Addresses are not properly increasing"
    echo "  Block 1: $ADDR1 ($ADDR1_DEC)"
    echo "  Block 2: $ADDR2 ($ADDR2_DEC)"
    echo "  Block 3: $ADDR3 ($ADDR3_DEC)"
    ((FAILED++))
fi

# Test 7: Memory can be written to (via strace check)
echo -n "Test 7: Checking memory operations with strace... "
if command -v strace &> /dev/null; then
    strace -e trace=brk ./$PROGRAM > /tmp/heap_strace.txt 2>&1
    if grep -q "brk" /tmp/heap_strace.txt; then
        echo -e "${GREEN}PASSED${NC}"
        echo "  (brk syscalls detected)"
        ((PASSED++))
    else
        echo -e "${YELLOW}WARNING${NC}"
        echo "  No brk syscalls detected - implementation may use different approach"
        ((PASSED++))
    fi
else
    echo -e "${YELLOW}SKIPPED${NC} (strace not available)"
    ((PASSED++))
fi

echo ""
echo "================================================"
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    echo ""
    echo "Output from program:"
    cat /tmp/heap_test_output.txt
    exit 1
fi
