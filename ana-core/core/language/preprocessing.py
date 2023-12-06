from collections.abc import Generator
from typing import Iterable

import datasets
import torch

class Tokenizer:
    def __init__(self, dataset: datasets.Dataset):
        self.vocab = set(['UNK']) | set((word for document in dataset for word in document['text'].split()))
        self.vocab_size = len(self.vocab)
        self.id_by_word = {word: id for id, word in enumerate(self.vocab)}

    def tokenize(self, document: str) -> list[int]:
        if isinstance(document, str):
            get_id = lambda w: self.id_by_word[(w if w in self.vocab else 'UNK')]
            return list(map(get_id, document.split()))
        elif isinstance(document, Iterable):
            return [self.tokenize(sentence) for sentence in document]
        else:    
            raise TypeError("Expected str or Iterable[str]")

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
