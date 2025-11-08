AS = nasm
ASFLAGS = -f elf64
LD = ld
TARGET = student
SRC = student.asm
OBJ = student.o

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -o $(TARGET) $(OBJ)

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) $(SRC) -o $(OBJ)

run: $(TARGET)
	./$(TARGET)

solution: solution.o
	$(LD) -o solution solution.o

solution.o: solution.asm
	$(AS) $(ASFLAGS) solution.asm -o solution.o

run-solution: solution
	./solution

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
	rm -f $(OBJ) $(TARGET) solution.o solution

.PHONY: all run clean solution run-solution test reset
