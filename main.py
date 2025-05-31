#!/usr/bin/env python3

import cv2
import numpy as np
from perception_core import PerceptionSystem
import time

def main():
    # Initialize perception system
    perception = PerceptionSystem()
    
    try:
        # Start the system
        perception.start()
        
        while True:
            # Get latest result
            result = perception.get_latest_result()
            if result is None:
                continue
            
            # Display results
            images = np.hstack((result['color'], result['depth_colormap']))
            cv2.imshow('Perception System Output', images)
            
            # Break on 'q' press
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
                
    except KeyboardInterrupt:
        print("Stopping...")
    finally:
        perception.stop()
        cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
