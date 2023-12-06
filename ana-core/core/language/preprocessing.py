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



class TokenCodec:
    """Encodes and decodes tokens"""
    def __init__(self):
        self._frozen = False
        self._id_by_token: dict[Token, int] = {} # mapping of tokens to ids for encoding
        self._token_by_id: dict[int, Token] = {} # reverse mapping of ids to tokens for decoding
        self._next_id = 0
            
    def encode(
        self, 
        tokens: Sequence[Token] | Generator[Token, None, None]
    ) -> Sequence[int] | Generator[int, None, None]:
        """Returns the encoding of the provided tokens
        
        The return type of this method depends on the type of the `tokens` argument.
        If `tokens` is a sequence, a sequence of ints will be returned. If `tokens` is
        a generator, a generator of ints will be returned. This allows for the encoding
        to be streamed from disk rather than loaded into memory all at once.
        """
        match tokens:
            case Sequence():
                return [self.encode_token(token) for token in tokens]
            case GeneratorType():
                return (self.encode_token(token) for token in tokens)
            case _:
                raise TypeError("Argument must be a sequence or generator")
            
    def encode_token(self, token: Token) -> int:
        """Returns the encoding of the provided token"""
        # assign a unique id to each token only if one is not already assigned
        if (token_id := self._id_by_token.get(token)) is None:
            if self._frozen:
                raise OutOfVocabularyError(token)
            # assign the token the next available id 
            token_id = self._next_id
            self._id_by_token[token] = token_id
            self._token_by_id[token_id] = token
            # ensure that the next token has a different id
            self._next_id += 1 
        return token_id 

    def decode(self, encoded_text: Sequence[int]) -> str:
        return "".join([self._token_by_id[_id] for _id in encoded_text])

    @property 
    def is_frozen(self):
        return self._frozen
    
    @is_frozen.setter
    def is_frozen(self, is_frozen):
        if not isinstance(is_frozen, bool):
            raise ValueError("Argument must be a boolean value")
        self._frozen = is_frozen

    @property
    def vocabulary(self):
        return set(self._id_by_token.keys())


class OutOfVocabularyError(Exception):
    message_template = "Could not encode token '{token}' as it could not be found in this encoder's vocabulary"
    
    def __init__(self, token: Token):
        super().__init__(self, OutOfVocabularyError.message_template.format(token=token))
