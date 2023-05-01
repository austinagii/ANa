
import logging 
import sys
import argparse
from pathlib import Path 

import pandas as pd 
from featuretoggles import TogglesList

from core.language.models import NGramModel 

logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger("ANa")

def _load_training_corpus():
        # load the dataset
        dataset_path = Path(__file__).absolute().joinpath("../../data/text_emotion.csv").resolve()
        log.info('Loading dataset from {dataset_path}')
        if not dataset_path.exists():
            log.fatal(f'The dataset was not found at the specified path: "{dataset_path}"')
            sys.exit(-1)
        else:
            log.info('Dataset successfully loaded')
        dataset = pd.read_csv(dataset_path)
        return dataset['content'].str.cat(sep=' ')

if __name__ == "__main__":
    # load the application configuration
    parser = argparse.ArgumentParser(description='Generate text using a trained model')
    parser.add_argument('--ngram-size', type=int, default=2, help='The size of the ngrams to use')
    args = parser.parse_args()
    
    # create and train the model
    model = NGramModel(**vars(args))
    model.train(_load_training_corpus())
    # respond to the user's prompts until they wish to stop
    while (prompt := input('Give me a prompt: ')) != 'bye':
        print(model(prompt))