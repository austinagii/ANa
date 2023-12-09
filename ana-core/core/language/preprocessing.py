from collections.abc import Generator
from typing import Iterable

import datasets
import torch

from .coretypes import Token, TokenId

class Tokenizer:
    def tokenize(self, text: str) -> Generator[str, None, None]:
        if not isinstance(text, str):
            raise TypeError(f"Argument 'text' expects a string, but received {type(text).__name__} instead")
        return [token for token in text.split()]


class Codec:
    UNKNOWN_TOKEN = "UNK"

    def __init__(self, tokens: Iterable[Token]):
        self._vocab = set([Codec.UNKNOWN_TOKEN])
        for token in tokens:
            self._vocab.add(token)
        self._id_by_token = {token: token_id for token_id, token in enumerate(self.vocab)}
        self._token_by_id = {token_id: token for token_id, token in self._id_by_token.items()}

    def encode(self, token: Token) -> TokenId:
        return self._id_by_token[(token if token in self.vocab else Codec.UNKNOWN_TOKEN)]

    def encode_all(self, tokens: Iterable[Token]) -> list[TokenId]:
        return [self.encode(token) for token in tokens]

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


def to_batches(dataset: datasets.Dataset, batch_size: int = 32) -> Generator[datasets.Dataset, None, None]:
    for i in range(0, len(dataset), batch_size):
        batch = dataset[i:i+batch_size]
        if len(batch['text']) < batch_size:
            continue
        yield batch['text'], batch['label']

def to_bow(encoded_documents: list[list[int]], 
           tokenizer: Tokenizer,
           codec: Codec) -> torch.Tensor:
    """Converts a list of encoded documents into a tensor.

    The shape of the tensor is (num_documents, vocab_size).
    """
    bow = torch.zeros(len(encoded_documents), codec.vocab_size)
    for i, encoded_document in enumerate(encoded_documents):
        bow[i, encoded_document] = 1 
    return bow
