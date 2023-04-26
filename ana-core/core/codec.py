import torch 

from collections.abc import Sequence
from types import GeneratorType
from typing import TypeAlias, Generator


Token: TypeAlias = str

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
                return [self._encode(token) for token in tokens]
            case Generator():
                return (self._encode(token) for token in tokens)
            case _:
                raise TypeError("Argument must be a sequence or generator")
            
    def _encode(self, token: Token) -> int:
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