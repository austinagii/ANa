import logging
import sys
from pathlib import Path

import pandas as pd

class DataLoader:
    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)

    def load_training_corpus(self):
        # load the dataset
        dataset_path = Path(__file__).absolute().joinpath("../../../data/text_emotion.csv").resolve()
        self.log.info(f'Loading dataset from {dataset_path}')
        if not dataset_path.exists():
            self.log.fatal(f'The dataset was not found at the specified path: "{dataset_path}"')
            sys.exit(-1)
        else:
            self.log.info('Dataset successfully loaded')
        dataset = pd.read_csv(dataset_path)
        return dataset['content'].str.cat(sep=' ')