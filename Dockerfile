# Dockerfile for x86-64 Assembly Learning Environment
FROM ubuntu:22.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install all required tools
RUN apt-get update && apt-get install -y \
    nasm \
    make \
    gdb \
    vim \
    binutils \
    strace \
    file \
    less \
    man-db \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /code

# Default command: bash shell
CMD ["/bin/bash"]

# Labels for documentation
LABEL description="x86-64 Assembly programming environment with NASM, GDB, and build tools"
LABEL maintainer="Assembly Learning Path"
