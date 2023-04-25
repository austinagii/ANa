import copy

from typing import Generator
from collections import UserDict


class NGramTokenizer:
    def __init__(self, ngram_size=2):
        # drop in replacement for an nltk tokenizer following the same interface
        # makes it easier to swap out tokenizer later
        if ngram_size < 1:
            raise ValueError("ngram_size must be greater than 0")
        self.ngram_size = ngram_size
        self.tokenizer = UserDict()
        self.tokenizer.span_tokenize = lambda text: (
            (i, i + 1) for i in range(len(text)))

    def tokenize_to_ngrams(
        self,
        text: str,
        inplace: bool = False
    ) -> Generator[list[str], None, None]:
        """Tokenizes the text into ngrams of size ngram_size

        If `inplace` is True, the same list representing the ngram will be modified
        and yielded every time. This is valuable if you want to conserve memory but 
        may result in unexpected behaviour when calling list() on the generator.
        If `inplace` is False, a new list will be created for each ngram. 
        """
        ngram = [None] * self.ngram_size
        token_stream = self.tokenizer.span_tokenize(text)
        for i in range(self.ngram_size):
            try:
                token_start, token_end = next(token_stream)
                ngram[i] = text[token_start: token_end]
            except StopIteration:
                # if the text is shorter than the ngram size, return the tokens extracted so far
                pass
        yield ngram if inplace else copy.copy(ngram)

        for token_start, token_end in token_stream:
            # shift all tokens in the ngram to the left
            for i in range(self.ngram_size - 1):
                ngram[i] = ngram[i + 1]
            # add the new token to the end of the ngram
            ngram[self.ngram_size - 1] = text[token_start: token_end]
            yield ngram if inplace else copy.copy(ngram)
