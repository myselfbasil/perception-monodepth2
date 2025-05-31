#!/usr/bin/env python3

import pyrealsense2 as rs
import numpy as np
import cv2
import torch
import time
from pathlib import Path
import threading
from queue import Queue

class PerceptionSystem:
    def __init__(self, model_path='models/mono+stereo_640x192'):
        """Initialize the perception system with RealSense and MonoDepth2."""
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        print(f"Using device: {self.device}")
        
        # Initialize queues for threaded processing
        self.frame_queue = Queue(maxsize=2)
        self.result_queue = Queue(maxsize=2)
        
        self.running = False
        self.setup_realsense()
        self.setup_monodepth2(model_path)

    def setup_realsense(self):
        """Configure and start the RealSense pipeline."""
        self.pipeline = rs.pipeline()
        self.config = rs.config()
        
        # Configure streams
        self.config.enable_stream(rs.stream.color, 640, 480, rs.format.bgr8, 30)
        self.config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 30)
        
        # Start streaming
        self.profile = self.pipeline.start(self.config)
        
        # Get camera intrinsics
        self.color_stream = self.profile.get_stream(rs.stream.color)
        self.intrinsics = self.color_stream.as_video_stream_profile().get_intrinsics()
        
        # Create align object
        self.align = rs.align(rs.stream.color)

    def setup_monodepth2(self, model_path):
        """Load and configure MonoDepth2 model."""
        if not Path(model_path).exists():
            raise FileNotFoundError(f"Model path {model_path} does not exist. Please download the model first.")
            
        self.encoder_path = Path(model_path) / "encoder.pth"
        self.depth_decoder_path = Path(model_path) / "depth.pth"
        
        # Load model (placeholder - you'll need to implement actual model loading)
        # self.model = ...
        print("MonoDepth2 model loaded successfully")

    def process_frames(self):
        """Main processing loop running in a separate thread."""
        while self.running:
            try:
                # Wait for frames
                frames = self.pipeline.wait_for_frames()
                aligned_frames = self.align.process(frames)
                
                # Get color and depth frames
                color_frame = aligned_frames.get_color_frame()
                depth_frame = aligned_frames.get_depth_frame()
                
                if not color_frame or not depth_frame:
                    continue
                
                # Convert frames to numpy arrays
                color_image = np.asanyarray(color_frame.get_data())
                depth_image = np.asanyarray(depth_frame.get_data())
                
                # Process depth
                depth_colormap = cv2.applyColorMap(
                    cv2.convertScaleAbs(depth_image, alpha=0.03), 
                    cv2.COLORMAP_JET
                )
                
                # Store results
                result = {
                    'color': color_image,
                    'depth': depth_image,
                    'depth_colormap': depth_colormap,
                    'timestamp': time.time()
                }
                
                # Add to queue, skip if queue is full
                if not self.result_queue.full():
                    self.result_queue.put(result)
                
            except Exception as e:
                print(f"Error in process_frames: {e}")
                break

    def start(self):
        """Start the perception system."""
        self.running = True
        self.process_thread = threading.Thread(target=self.process_frames)
        self.process_thread.start()
        print("Perception system started")

    def stop(self):
        """Stop the perception system."""
        self.running = False
        if hasattr(self, 'process_thread'):
            self.process_thread.join()
        self.pipeline.stop()
        print("Perception system stopped")

    def get_latest_result(self):
        """Get the latest processing result."""
        if self.result_queue.empty():
            return None
        return self.result_queue.get()

    def fuse_depth_maps(self, mono_depth, stereo_depth):
        """Fuse MonoDepth2 and RealSense depth maps."""
        # TODO: Implement depth fusion
        pass
