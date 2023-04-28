import logging 
import torch

from core import Token, EncodedToken
from core.codec import TokenCodec
from core.tokenizer import Tokenizer
from core.reader import NGramReader
from typing import Generator, Any
from types import GeneratorType
from collections.abc import Sequence
        
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
    
    def __call__(self, prompt: str = None) -> str:
        """Generate a response to the given prompt

        Raises a VaueError if the prompt is empty 
        """
        # TODO: Handle the condition where the prompt is shorter than the ngram size
        # Raise an error if an empty prompt is provided
        if prompt is None or len(prompt.strip()) == 0:
            raise ValueError("The prompt cannot be empty")
        # Begin the response with the prompt 
        encoded_response = self.codec.encode(prompt)
        # Build the remainder of the response one token at a time until the response
        # is complete or the maximum response length is reached
        current_ngram = self._get_last(self._to_ngram_stream(encoded_response))
        next_token = None
        stop_token = self.codec.encode_token('.')
        while next_token != stop_token and len(encoded_response) < self.max_response_length:
            next_token = self._predict_next_token(current_ngram) 
            encoded_response.append(next_token)
            current_ngram = current_ngram[1:] + (next_token,)
        return self.codec.decode(encoded_response)

    def _to_ngram_stream(
        self, 
        text: Sequence[Token | EncodedToken]
    ) -> Generator[tuple[Token|EncodedToken, ...], None, None]:
        """Convert a sequence of tokens to a stream of ngrams"""
        tokens = self.tokenizer.tokenize(text)
        for encoded_ngram in self.reader.read(tokens):
            yield tuple(encoded_ngram)

    def _get_last(self, input: Sequence[Any] | Generator[Any, None, None]) -> Any:
        """Get the last value from a sequence or generator
        
        Note that if `input` is a generator, this function will exhaust it
        """
        value = None
        match input:
            case Sequence():
                if len(input) > 0:
                    value = input[-1]
            case GeneratorType():
                # Read values from the generator until it is exhausted.
                # value will contain the last value read from the generator 
                for value in input:
                    pass
            case _:
                raise ValueError("The input must be a sequence or generator")
        return value

    def _predict_next_token(self, ngram: tuple[int, ...]) -> int:
        """Predict the next token given the ngram"""
        next_token_proba = self._ngram_proba[ngram[1:]]
        return torch.multinomial(next_token_proba, 1).item()