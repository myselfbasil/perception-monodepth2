FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    git \
    wget \
    unzip \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
COPY requirements.txt .
COPY perception_core.py .
COPY main.py .
COPY README.md .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Clone MonoDepth2
RUN git clone https://github.com/nianticlabs/monodepth2.git \
    && cd monodepth2 \
    && pip3 install --no-cache-dir \
        torch>=1.0.0 \
        torchvision>=0.2.1 \
        opencv-python>=3.4

# Download model
RUN wget https://storage.googleapis.com/niantic-lon-static/research/monodepth2/mono%2Bstereo_640x192.zip \
    && unzip mono+stereo_640x192.zip -d models/ \
    && rm mono+stereo_640x192.zip

CMD ["python3", "main.py"]
