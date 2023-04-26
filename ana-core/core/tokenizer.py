import copy

from core import Token
from typing import Generator
from collections import UserDict


class Tokenizer:
    def __init__(self):
        # drop in replacement for an nltk tokenizer following the same interface
        # makes it easier to change tokenizer implementation later
        self._tokenizer = UserDict()
        self._tokenizer.span_tokenize = lambda text: (
            (i, i + 1) for i in range(len(text)))

    def tokenize(self, text: str) -> Generator[Token, None, None]:
        token_stream = self._tokenizer.span_tokenize(text)
        for token_start, token_end in token_stream:
            yield text[token_start: token_end]