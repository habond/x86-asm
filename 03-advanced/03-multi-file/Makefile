AS = nasm
ASFLAGS = -f elf64
LD = ld

# Student's implementation
OBJS = main.o string_utils.o math_utils.o
TARGET = program

# Solution files
SOLUTION_OBJS = solution_main.o solution_string_utils.o solution_math_utils.o
SOLUTION = solution

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS)

%.o: %.asm
	$(AS) $(ASFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

solution: $(SOLUTION)

$(SOLUTION): $(SOLUTION_OBJS)
	$(LD) -o $(SOLUTION) $(SOLUTION_OBJS)

solution_%.o: solution_%.asm
	$(AS) $(ASFLAGS) $< -o $@

run-solution: $(SOLUTION)
	./$(SOLUTION)

test: $(TARGET) $(SOLUTION)
	@echo "Running tests..."
	@./test.sh

reset: clean
	@for f in main string_utils math_utils; do \
		if [ -f $$f.asm.template ]; then \
			cp $$f.asm.template $$f.asm; \
			echo "Reset $$f.asm to template"; \
		fi; \
	done

clean:
	rm -f $(OBJS) $(TARGET) $(SOLUTION_OBJS) $(SOLUTION)

.PHONY: all run solution run-solution test reset clean
