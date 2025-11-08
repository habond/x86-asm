#!/bin/bash
# Quick script to enter the assembly development environment

if [ -f "docker-compose.yml" ]; then
    echo "Starting development environment with Docker Compose..."
    docker-compose run --rm asm-dev
else
    echo "docker-compose.yml not found. Using plain Docker..."
    docker run -it --rm --platform linux/amd64 \
      -v "$(pwd):/code" -w /code \
      ubuntu:22.04 bash
fi
