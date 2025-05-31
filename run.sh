#!/bin/bash

echo "Starting Perception System..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run as root/sudo. Running as root can cause permission issues."
    exit 1
fi

# Check if user is in docker group
if ! groups | grep -q docker; then
    echo "Error: Your user must be in the docker group."
    echo "Ask your administrator to run: sudo usermod -aG docker $USER"
    exit 1
fi

# Check if container exists and remove it if it does
CONTAINER_NAME="perception-container"
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Removing existing container..."
    docker rm -f $CONTAINER_NAME
fi

# Create cache directory if it doesn't exist
CACHE_DIR="$HOME/.cache/perception"
mkdir -p "$CACHE_DIR"

# Ensure proper permissions for X11
xhost +local:docker > /dev/null 2>&1 || true

# Run the container with all necessary permissions
echo "Running container..."
docker run \
    --name $CONTAINER_NAME \
    --runtime=nvidia \
    --gpus all \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    --network host \
    --ipc host \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v $(pwd):/app \
    -v $CACHE_DIR:/root/.cache \
    --device /dev/video0:/dev/video0 \
    --device /dev/video1:/dev/video1 \
    --group-add $(getent group video | cut -d: -f3) \
    --cap-add SYS_PTRACE \
    -it \
    perception-monodepth2-perception

# Cleanup
echo "Cleaning up X11 permissions..."
xhost -local:docker > /dev/null 2>&1 || true

echo "Container started! Press Ctrl+C to stop."

# Trap Ctrl+C and cleanup
trap 'echo "\nStopping container..."; docker stop $CONTAINER_NAME > /dev/null 2>&1; exit 0' INT
