# MonoDepth2 + RealSense Perception System

A real-time scene understanding system that combines MonoDepth2 monocular depth estimation with Intel RealSense D435i stereo depth data.

## Prerequisites

- Ubuntu 22.04.05
- NVIDIA GPU with CUDA support
- Docker and Docker Compose
- NVIDIA Container Toolkit
- Intel RealSense D435i camera
- USB 3.0 port

## Installation

### Option 1: Using Docker (Recommended)

1. Install Docker and NVIDIA Container Toolkit:
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

2. Build and run using Docker Compose:
```bash
# Build the Docker image
docker-compose build

# Run the system
docker-compose up
```

### Option 2: Manual Installation

1. Install RealSense SDK:
```bash
# Install required packages
sudo apt-get update
sudo apt-get install -y software-properties-common gnupg2 curl

# Add Intel RealSense repository
sudo mkdir -p /etc/apt/keyrings
curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | sudo gpg --dearmor -o /etc/apt/keyrings/librealsense.gpg
echo "deb [signed-by=/etc/apt/keyrings/librealsense.gpg] https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/librealsense.list

# Install RealSense SDK
sudo apt-get update
sudo apt-get install -y librealsense2-dkms librealsense2-utils librealsense2-dev
```

2. Set up Python environment:
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

3. Install MonoDepth2:
```bash
git clone https://github.com/nianticlabs/monodepth2.git
cd monodepth2
pip install -r requirements.txt
```

4. Download pretrained model:
```bash
wget https://storage.googleapis.com/niantic-lon-static/research/monodepth2/mono%2Bstereo_640x192.zip
unzip mono+stereo_640x192.zip -d models/
```

## Usage

1. Connect RealSense D435i camera

2. Run the perception system:
```bash
python main.py
```

3. Press 'q' to quit

## System Components

- `perception_core.py`: Main perception system implementation
- `main.py`: Script to run the system
- `requirements.txt`: Python dependencies

## Features

- Real-time RGB and depth visualization
- Threaded frame processing
- RealSense depth stream integration
- MonoDepth2 integration (TODO)
- Depth map fusion (TODO)

## Performance

- Target frame rate: 10-15 FPS
- Detection range: 0.3m to 10m
- Processing latency: <100ms
