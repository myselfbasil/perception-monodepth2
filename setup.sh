#!/bin/bash

echo "Setting up Perception System..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo apt-get update
    sudo apt-get install -y docker-compose
fi

# Clean up any existing containers and images
echo "Cleaning up existing Docker resources..."
docker-compose down 2>/dev/null
docker system prune -f

# Build and start the container
echo "Building and starting the perception system..."
docker-compose up --build

echo "Setup complete!"
