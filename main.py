#!/usr/bin/env python3

import torch
import numpy as np

def main():
    print("Testing CUDA availability:", torch.cuda.is_available())
    print("Number of CUDA devices:", torch.cuda.device_count())
    if torch.cuda.is_available():
        print("CUDA device name:", torch.cuda.get_device_name(0))
    
    # Test numpy
    arr = np.random.rand(3, 3)
    print("\nNumPy test:")
    print(arr)

if __name__ == "__main__":
    main()
