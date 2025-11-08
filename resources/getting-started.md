# Getting Started with x86-64 Assembly on Linux

## Why x86-64 Linux?

This curriculum uses x86-64 assembly on Linux because:
- **Simple toolchain**: No complex address loading or platform quirks
- **Abundant resources**: Most assembly tutorials use x86-64
- **Clear syscall interface**: Straightforward system call conventions
- **Easy to set up**: Works in Docker, VM, or native Linux

## Development Environment Setup

Since you're on macOS, you'll need a Linux environment. Here are your options from easiest to most complete:

### Option 1: Docker (Recommended for Beginners)

This is the fastest way to get started!

**1. Install Docker Desktop**
Download from [docker.com](https://www.docker.com/products/docker-desktop/)

**2. Create a working directory on your Mac**
```bash
mkdir ~/x86-asm
cd ~/x86-asm
```

**3. Run the development container**
```bash
docker run -it --rm --platform linux/amd64 \
  -v $(pwd):/code \
  -w /code \
  ubuntu:22.04 bash
```

This command:
- `-it`: Interactive terminal
- `--rm`: Auto-delete container when you exit (your files are safe in ~/x86-asm)
- `--platform linux/amd64`: Use x86-64 architecture
- `-v $(pwd):/code`: Mount your current directory inside the container
- `-w /code`: Start in the /code directory

**4. Inside the container, install tools**
```bash
apt update
apt install -y nasm make gdb vim nano binutils
```

**5. Test it works**
```bash
echo 'section .data
msg db "Hello!", 10
len equ $ - msg

section .text
global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall' > test.asm

nasm -f elf64 test.asm
ld -o test test.o
./test
```

You should see "Hello!" printed!

**6. Workflow**
- Edit files on your Mac using VS Code or any editor
- Run the Docker command to enter the Linux environment
- Assemble and run inside Docker
- Exit with `exit` or Ctrl+D

**Quick start script**: Create a file `~/x86-asm/linux.sh`:
```bash
#!/bin/bash
docker run -it --rm --platform linux/amd64 \
  -v $(pwd):/code \
  -w /code \
  ubuntu:22.04 bash
```

Make it executable: `chmod +x linux.sh`

Then just run `./linux.sh` to enter your environment!

### Option 2: UTM Virtual Machine (Most Like Real Linux)

**1. Install UTM**
Download from [mac.getutm.app](https://mac.getutm.app/)

**2. Download Ubuntu**
Get Ubuntu Server 22.04 LTS (x86-64) ISO from [ubuntu.com](https://ubuntu.com/download/server)

**3. Create VM in UTM**
- Click "Create a New Virtual Machine"
- Choose "Virtualize"
- Select "Linux"
- Browse and select your Ubuntu ISO
- Allocate resources (4GB RAM, 20GB disk is plenty)
- Finish and start the VM

**4. Install Ubuntu**
- Follow the installation prompts (accept defaults)
- Create a user account
- Select "Install OpenSSH server" when prompted
- Complete installation and reboot

**5. Install development tools**
```bash
sudo apt update
sudo apt install -y nasm make gdb build-essential vim
```

**6. Test**
Create and run the same test program from Docker Option 1

**Advantages**:
- Full Linux experience
- Persistent (no need to reinstall tools)
- Can use graphical tools if needed

### Option 3: Multipass (Clean and Simple)

**1. Install Multipass**
```bash
brew install multipass
```

**2. Create an x86-64 Ubuntu instance**
```bash
multipass launch --name asm-dev --cpus 2 --memory 2G --disk 10G
```

**3. Enter your instance**
```bash
multipass shell asm-dev
```

**4. Install tools**
```bash
sudo apt update
sudo apt install -y nasm make gdb vim
```

**5. Mount your Mac folder inside the VM**
```bash
# On your Mac
multipass mount ~/x86-asm asm-dev:/home/ubuntu/code
```

Now files in `~/x86-asm` on your Mac appear in `/home/ubuntu/code` in the VM!

## Understanding the Toolchain

### NASM Assembler

NASM (Netwide Assembler) is the most popular x86 assembler.

```bash
nasm -f elf64 program.asm -o program.o
```

Options:
- `-f elf64`: Create 64-bit Linux object file
- `-g`: Include debug information
- `-l program.lst`: Generate assembly listing

### Linker (ld)

Links object files into executables:

```bash
ld -o program program.o
```

Options:
- `-o program`: Output file name
- `-e _start`: Entry point (default for _start)
- `-dynamic-linker /lib64/ld-linux-x86-64.so.2`: For dynamic linking

### Make

Automates the build process:

```bash
make        # Build
make run    # Build and run
make clean  # Remove build files
```

## Basic Workflow

1. **Write code**: Edit `.asm` file
2. **Assemble**: `nasm -f elf64 file.asm`
3. **Link**: `ld -o program file.o`
4. **Run**: `./program`
5. **Check exit code**: `echo $?`

Or use the Makefile: `make && ./program`

## Debugging with GDB

```bash
# Compile with debug info
nasm -f elf64 -g program.asm
ld -o program program.o

# Start GDB
gdb ./program

# Useful commands:
(gdb) break _start          # Set breakpoint at _start
(gdb) run                   # Run program
(gdb) stepi                 # Step one instruction
(gdb) info registers        # View all registers
(gdb) print $rax            # View specific register
(gdb) x/10x $rsp            # Examine 10 words at stack pointer
(gdb) disassemble           # Show assembly code
(gdb) continue              # Continue execution
(gdb) quit                  # Exit GDB
```

## Common Issues and Solutions

### "command not found"
**Problem**: Tool not installed
**Solution**: Run `apt install -y nasm make gdb binutils`

### "Permission denied" when running program
**Problem**: File not executable
**Solution**: `chmod +x program` or use `./program` after linking

### "Segmentation fault"
**Problem**: Invalid memory access
**Solutions**:
- Use GDB to find where it crashes
- Check pointer values
- Ensure you're not accessing uninitialized data

### Docker container resets
**Problem**: Lost installed packages when restarting container
**Solution**:
- This is normal with `--rm` flag
- Your code files are safe (they're on your Mac)
- Use a VM if you want persistence
- Or create a Dockerfile

## Editor Setup

### VS Code (Recommended)

**1. Install extensions**:
- "x86 and x86_64 Assembly" by 13xforever
- "Remote - Containers" (if using Docker)

**2. Edit files locally**:
Files in `~/x86-asm` can be edited on your Mac with VS Code while running in Docker/VM

**3. Configure tasks** (optional - `.vscode/tasks.json`):
```json
{
    "version": "2.0.0",
    "tasks": [{
        "label": "build",
        "type": "shell",
        "command": "make",
        "group": {
            "kind": "build",
            "isDefault": true
        }
    }]
}
```

### Vim (In VM/Docker)

```bash
# Install
apt install vim

# Basic usage
vim program.asm    # Open file
i                  # Enter insert mode
ESC                # Exit insert mode
:w                 # Save
:q                 # Quit
:wq                # Save and quit
```

## Learning Resources

### Official Documentation
- [NASM Documentation](https://www.nasm.us/doc/)
- [Intel 64 and IA-32 Architectures Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

### Online References
- [x86-64 Assembly Language Programming](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
- [Linux Syscall Reference](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)

### This Curriculum
Start with the basics and work your way through:
1. 01-hello-world
2. 02-add-numbers
3. 03-conditionals
4. Continue in order...

## Register Overview (Quick Reference)

x86-64 has these general-purpose registers:

| Register | Purpose | Preserved? |
|----------|---------|------------|
| RAX | Return value, syscall number | No |
| RBX | General purpose | Yes |
| RCX | 4th argument | No |
| RDX | 3rd argument | No |
| RSI | 2nd argument | No |
| RDI | 1st argument | No |
| RBP | Base pointer | Yes |
| RSP | Stack pointer | Yes |
| R8-R9 | 5th-6th arguments | No |
| R10-R11 | General purpose | No |
| R12-R15 | General purpose | Yes |

## System Calls (Quick Reference)

Common Linux syscalls:

| RAX | Name | RDI | RSI | RDX |
|-----|------|-----|-----|-----|
| 0 | read | fd | buffer | count |
| 1 | write | fd | buffer | count |
| 60 | exit | status | - | - |

Usage:
```asm
mov rax, 1      ; syscall number
mov rdi, 1      ; first argument
mov rsi, msg    ; second argument
mov rdx, len    ; third argument
syscall         ; invoke
```

## Next Steps

1. **Choose your setup method** (Docker recommended for quick start)
2. **Set up your environment**
3. **Test with the hello world example above**
4. **Read** [instruction-reference.md](instruction-reference.md)
5. **Start** with [01-basics/01-hello-world](../01-basics/01-hello-world/)

Happy assembling!
