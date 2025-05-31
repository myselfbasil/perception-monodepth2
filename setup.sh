#!/bin/bash

echo "Setting up Perception System..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or you don't have permission to use it."
    echo "Please ensure:"
    echo "1. Docker is installed"
    echo "2. Your user is in the docker group"
    exit 1
fi

# Build and start the container
echo "Building and starting the perception system..."
docker-compose up --build

echo "Setup complete!"
