from collections.abc import Generator
from typing import Iterable, TypeAlias

import datasets
import torch

Token: TypeAlias = str
TokenId: TypeAlias = int


class Tokenizer:
    def __init__(self, lazy: str = False):
        self.lazy = lazy 

    def tokenize(
        self, 
        text: str | Iterable[str],
    ) ->  list[Token] | Generator[Token, None, None] | Iterable[Generator[Token, None, None]]:
        if not isinstance(text, str):
            raise TypeError(f"Argument 'text' expects a string, but received '{type(text).__name__}' instead.")

        tokens = (token for token in text.split())
        return tokens if self.lazy else list(tokens)

    def tokenize_all(self, texts: list[str], flatten=False):
        if not isinstance(texts, list):
            raise TypeError(f"Argument 'texts' expects a list, but received '{type(text).__name__}' instead.")

        for ix, text in enumerate(texts):
            if not isinstance(text, str):
                raise TypeError(f"All elements in 'texts' must be strings, but receieved '{type(text).__name__}' at index '{ix}'.")

        if flatten:
            token_seq = (token for text in texts for token in self.tokenize(text))
            return token_seq if self.lazy else list(token_seq)
        else:
            token_seqs = ((token for token in self.tokenize(text)) for text in texts)
            return token_seqs if self.lazy else [list(token_seq) for token_seq in token_seqs]


class Codec:
    UNKNOWN_TOKEN = "UNK"

    def __init__(self, tokens: Iterable[Token]):
        # TODO: Add type checking.
        self._vocab = set([Codec.UNKNOWN_TOKEN])
        for token in tokens:
            self._vocab.add(token)
        self._id_by_token = {token: token_id for token_id, token in enumerate(self.vocab)}
        self._token_by_id = {token_id: token for token_id, token in self._id_by_token.items()}

    def encode(self, token: Token) -> TokenId:
        return self._id_by_token[(token if token in self.vocab else Codec.UNKNOWN_TOKEN)]

    def encode_all(self, tokens: Iterable[Token]) -> list[TokenId]:
        encoded = []
        for item in tokens:
            if isinstance(item, Token):
                encoded.append(self.encode(item))
            elif isinstance(item, Iterable):
                encoded.append(self.encode_all(item))
            else:
                raise TypeError("Invalid type")
        return encoded


    def decode(self, token_id: TokenId) -> Token:
        pass

    def decode_all(self, token_ids: Iterable[TokenId]) -> list[Token]:
        pass

    @property
    def vocab(self):
        return self._vocab

    @property
    def vocab_size(self):
        return len(self._vocab)

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


def to_batches(dataset: datasets.Dataset, batch_size: int = 32) -> Generator[datasets.Dataset, None, None]:
    for i in range(0, len(dataset), batch_size):
        batch = dataset[i:i+batch_size]
        if len(batch['text']) < batch_size:
            continue
        yield batch['text'], batch['label']

def to_bow(encoded_documents: list[list[int]], vocab_size: int) -> torch.Tensor:
    """Converts a list of encoded documents into a tensor.

    The shape of the tensor is (num_documents, vocab_size).
    """
    bow = torch.zeros(len(encoded_documents), vocab_size)
    for i, encoded_document in enumerate(encoded_documents):
        bow[i, encoded_document] = 1 
    return bow
