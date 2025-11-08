AS = nasm
ASFLAGS = -f elf64
LD = ld
TARGET = filecp
SRC = filecp.asm
OBJ = filecp.o

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -o $(TARGET) $(OBJ)

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) $(SRC) -o $(OBJ)

run: $(TARGET)
	@echo "Creating test input file..."
	@echo "This is a test file for file copy operation." > test_input.txt
	@echo "It has multiple lines." >> test_input.txt
	@echo "Let's see if it copies correctly!" >> test_input.txt
	@echo ""
	@echo "Running: ./$(TARGET) test_input.txt test_output.txt"
	./$(TARGET) test_input.txt test_output.txt
	@echo ""
	@echo "Contents of test_output.txt:"
	@cat test_output.txt
	@echo ""
	@echo "Comparing files:"
	@diff test_input.txt test_output.txt && echo "Files are identical!" || echo "Files differ!"

solution: solution.o
	$(LD) -o solution solution.o

solution.o: solution.asm
	$(AS) $(ASFLAGS) solution.asm -o solution.o

run-solution: solution
	@echo "Creating test input file..."
	@echo "This is a test file for file copy operation." > test_input.txt
	@echo "It has multiple lines." >> test_input.txt
	@echo "Let's see if it copies correctly!" >> test_input.txt
	@echo ""
	@echo "Running: ./solution test_input.txt test_output.txt"
	./solution test_input.txt test_output.txt
	@echo ""
	@echo "Contents of test_output.txt:"
	@cat test_output.txt
	@echo ""
	@echo "Comparing files:"
	@diff test_input.txt test_output.txt && echo "Files are identical!" || echo "Files differ!"

test: $(TARGET) solution
	@echo "Running tests..."
	@./test.sh

reset: clean
	@if [ -f $(SRC).template ]; then \
		cp $(SRC).template $(SRC); \
		echo "Reset $(SRC) to template"; \
	else \
		echo "Template file $(SRC).template not found"; \
	fi

clean:
	rm -f $(OBJ) $(TARGET) solution.o solution test_input.txt test_output.txt test_*.txt

.PHONY: all run clean solution run-solution reset test
