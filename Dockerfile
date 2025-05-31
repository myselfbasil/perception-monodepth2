# Use NVIDIA CUDA base image
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    git \
    wget \
    unzip \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install RealSense SDK
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE \
    && add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -y \
    && apt-get update && apt-get install -y \
    librealsense2-dkms \
    librealsense2-utils \
    librealsense2-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY requirements.txt .
COPY perception_core.py .
COPY main.py .
COPY README.md .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Clone and setup MonoDepth2
RUN git clone https://github.com/nianticlabs/monodepth2.git \
    && cd monodepth2 \
    && pip3 install --no-cache-dir -r requirements.txt

# Download pretrained model
RUN wget https://storage.googleapis.com/niantic-lon-static/research/monodepth2/mono%2Bstereo_640x192.zip \
    && unzip mono+stereo_640x192.zip -d models/ \
    && rm mono+stereo_640x192.zip

# Set environment variables for NVIDIA runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

# Run the perception system
CMD ["python3", "main.py"]
