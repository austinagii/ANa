import logging 
import torch

from core.codec import TokenCodec
from core.tokenizer import Tokenizer
from core.reader import NGramReader
        
class NGramModel:
    def __init__(self, 
                 ngram_size: int = 2, 
                 max_response_length: int = 120):
        self.log = logging.getLogger(NGramModel.__class__.__name__)
        self.log.info(f"Initializing a {ngram_size}-gram model")
        self.ngram_size = ngram_size
        self.max_response_length = max_response_length
        self.tokenizer = Tokenizer() 
        self.codec = TokenCodec()
        self.reader = NGramReader(ngram_size=ngram_size)
        
    def train(self, corpus):
        """Train the model on the tokens from the training corpus"""
        tokens = self.tokenizer.tokenize(corpus)
        encoded_tokens = self.codec.encode(tokens)
        encoded_ngrams = self.reader.read(encoded_tokens, inplace=True)
        self._ngram_frequencies = {}
        for encoded_ngram in encoded_ngrams:
            encoded_ngram = tuple(encoded_ngram) # are we wasting memory here by converting to a tuple?
            self._ngram_frequencies[encoded_ngram] = self._ngram_frequencies.get(encoded_ngram, 0) + 1

        self._ngram_proba = torch.zeros(self.ngram_size * [len(self.codec.vocabulary)], 
                                              dtype=torch.int32)
        # # build a probability distribution based on the ngram frequencies
        for ngram, frequency in self._ngram_frequencies.items():
            self._ngram_proba[ngram] = frequency
        self._ngram_proba = self._ngram_proba / self._ngram_proba.sum(axis=self.ngram_size - 1, keepdims=True)
        self._ngram_proba = torch.where(self._ngram_proba > 0, self._ngram_proba, 0)
        # return self
    
    def __call__(self, prompt=None):
        pass
        # # TODO: handle the case where the prompt is shorter than the ngram size
        # # choose a random letter as the starting prompt is none is provided
        # if prompt is None or prompt == "":
        #     # prompt = self._vocabulary[random.randint(0, len(self._vocabulary))]
        #     prompt = "dog"
        # # initialize the response with the prompt as the lead 
        # response = codec.encode(prompt)
        # # build the remainder of the response one token at a time using the ngram model
        # next_token = None
        # count 