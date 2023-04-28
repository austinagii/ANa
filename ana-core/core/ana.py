
import logging 
import sys
import torch 
import torch.random
import argparse
import pandas as pd 

from models import NGramModel, BigramModel
from pathlib import Path 
from featuretoggles import TogglesList

class FeatureFlags(TogglesList):
    configurable_ngram_size: bool

feature_flags = FeatureFlags('features.yaml')


class ANa:
    def __init__(self, ngram_size: int = None):
        """Load the dataset and model"""
        log = logging.getLogger(ANa.__name__)
        # load the dataset
        dataset_path = Path(__file__).absolute().joinpath("../../data/text_emotion.csv").resolve()
        log.info('Loading dataset from {dataset_path}')
        if not dataset_path.exists():
            log.fatal(f'The dataset was not found at the specified path: "{dataset_path}"')
            sys.exit(-1)
        else:
            log.info('Dataset successfully loaded')
        dataset = pd.read_csv(dataset_path)
        corpus = dataset['content'].str.cat(sep=' ')
        
        if feature_flags.configurable_ngram_size:
            self.model = NGramModel(ngram_size=ngram_size)
        else:
            self.model = BigramModel()
        self.model.train(corpus)

    def generate_text(self, prompt: str, max_length: int = 120) -> str:
        """Generates text until a full stop is encountered or until the max length is reached"""
        return self.model(prompt) 
        
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    parser = argparse.ArgumentParser(description='Generate text using a trained model')
    if feature_flags.configurable_ngram_size:
        parser.add_argument('--ngram-size', type=int, default=2, help='The size of the ngrams to use')
    args = parser.parse_args()

    ana = ANa(**vars(args))
    while (prompt := input('Give me a prompt: ')) != 'bye':
        print(ana.generate_text(prompt))