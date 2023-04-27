
import logging 
import sys
import torch 
import torch.random

import pandas as pd 

from pathlib import Path 

class ANa:
    def __init__(self):
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
        # preprocess the dataset
        tokens = list(dataset['content'].str.cat(sep=' '))
        unique_tokens = sorted(list(set(tokens)))
        alphabet_size = len(unique_tokens)
        token_mappings = list(zip(*[((token, idx), (idx, token)) for idx, token in enumerate(unique_tokens)]))
        idx_by_token = dict(token_mappings[0])
        self.token_by_idx = dict(token_mappings[1])
        # encode the tokens
        encoded_tokens = [idx_by_token[token] for token in tokens]
        # generate the bigrams
        bigrams = list(zip(encoded_tokens, encoded_tokens[1:]))
        # count the bigram frequencies
        bigram_frequencies = torch.zeros((alphabet_size, alphabet_size), dtype=torch.int32)
        for bigram in bigrams:
            bigram_frequencies[bigram[0], bigram[1]] += 1
        # calculate the bigram probabilities
        self.bigram_probabilities = bigram_frequencies / bigram_frequencies.sum(1, keepdims=True)

    def generate_text(self, max_length: int = 120) -> str:
        """Generates text until a full stop is encountered or until the max length is reached"""
        current_sequence_length = 0
        current_token = 10 # full stop
        current_sequence = ''
        while current_token != 14 and current_sequence_length <= max_length:
            current_token = torch.multinomial(self.bigram_probabilities[current_token], num_samples=1).item()
            current_sequence += self.token_by_idx[current_token]
            current_sequence_length += 1
        return current_sequence