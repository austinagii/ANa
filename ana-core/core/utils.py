import time

import torch

def get_available_device() -> torch.device:
    """Returns the first available device, or CPU if none are available.

    The device returned is either CUDA, MPS, or CPU. If CUDA is available, it
    will be returned. If CUDA is not available, but MPS is, MPS will be
    returned. If neither are available, CPU will be returned. 
    """
    if torch.cuda.is_available():
        device_name = "cuda"
    elif torch.backends.mps.is_available():
        device_name = "mps"
    else:  
        device_name = "cpu"
    return torch.device(device_name)


class Timer:
    def __enter__(self):
        self.start = time.time()
        return self

    def __exit__(self, *args):
        self.end = time.time()
        self.interval = self.end - self.start
