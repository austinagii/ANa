import copy 
from typing import Generator

from core.language.coretypes import Token


class NGramReader:
    """Reads ngrams from a sequence of tokens"""
    def __init__(self, ngram_size: int = 2):
        if ngram_size < 1:
            raise ValueError("ngram_size must be greater than 0")
        self.ngram_size = ngram_size 

    def read(
        self,
        tokens: Generator[Token, None, None],
        inplace: bool = False
    ) -> Generator[list[str], None, None]:
        """Reads ngrams from the provided token generator until that generator is empty

        If `inplace` is True, the same list object representing the ngram will be modified
        and yielded every time. This is valuable if you want to conserve memory but 
        may result in unexpected behaviour when calling list() on the generator.
        If `inplace` is False, a new list object will be created for each ngram. 
        """
        ngram = [None] * self.ngram_size
        # read the first ngram
        for i in range(self.ngram_size):
            try:
                ngram[i] = next(tokens)
            except StopIteration:
                # if the number of tokens received is less than the ngram size
                # just return the tokens extracted so far
                pass
        yield ngram if inplace else copy.copy(ngram)
        # read all subsequent ngrams
        for token in tokens:
            # shift all tokens in the ngram to the left
            for i in range(self.ngram_size - 1):
                ngram[i] = ngram[i + 1]
            # add the new token to the end of the ngram
            ngram[self.ngram_size - 1] = token 
            yield ngram if inplace else copy.copy(ngram)