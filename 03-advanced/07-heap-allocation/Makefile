# Makefile for Heap Allocation assignment

AS = nasm
ASFLAGS = -f elf64
LD = ld
TARGET = main
SRC = main.asm
OBJ = main.o

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -o $(TARGET) $(OBJ)

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) $(SRC) -o $(OBJ)

run: $(TARGET)
	./$(TARGET)

solution: solution.o
	$(LD) -o solution solution.o
	@./solution

solution.o: solution.asm
	$(AS) $(ASFLAGS) solution.asm -o solution.o

run-solution: solution
	@./solution

test: $(TARGET)
	@echo "Testing your implementation:"
	@./test.sh $(TARGET)

test-solution: solution
	@echo "Testing solution:"
	@./test.sh solution

debug: ASFLAGS = -f elf64 -g -F dwarf
debug: clean $(TARGET)
	@echo "Built with debug symbols. Run: gdb ./$(TARGET)"

debug-solution: ASFLAGS = -f elf64 -g -F dwarf
debug-solution: clean solution
	@echo "Built solution with debug symbols. Run: gdb ./solution"

listing:
	$(AS) $(ASFLAGS) -l $(SRC:.asm=.lst) $(SRC)

reset: clean
	@if [ -f $(SRC).template ]; then \
		cp $(SRC).template $(SRC); \
		echo "Reset $(SRC) to template"; \
	else \
		echo "Template file $(SRC).template not found"; \
	fi

clean:
	rm -f $(OBJ) $(TARGET) solution.o solution *.lst

help:
	@echo "Available targets:"
	@echo "  make          - Build your implementation (main)"
	@echo "  make run      - Build and run your implementation"
	@echo "  make solution - Build and run the solution"
	@echo "  make test     - Run tests on your implementation"
	@echo "  make debug    - Build with debug symbols"
	@echo "  make listing  - Generate assembly listing file"
	@echo "  make reset    - Reset to template"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make help     - Show this help message"

.PHONY: all run run-solution test test-solution debug debug-solution listing reset clean help
