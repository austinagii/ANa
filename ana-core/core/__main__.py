
import logging 
import sys
import argparse
from pathlib import Path 

import pandas as pd 

from core.language import DataLoader
from core.language.models import NGramModel 

logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger("ANa")

if __name__ == "__main__":
    # load the application configuration
    parser = argparse.ArgumentParser(description='Generate text using a trained model')
    parser.add_argument('--ngram-size', type=int, default=2, help='The size of the ngrams to use')
    args = parser.parse_args()
    
    # create and train the model
    model = NGramModel(**vars(args))
    dataloader = DataLoader()
    model.train(dataloader.load_training_corpus())
    # respond to the user's prompts until they wish to stop
    while (prompt := input('Give me a prompt: ')) != 'bye':
        print(model(prompt))