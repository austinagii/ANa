import torch 

from collections.abc import Sequence
from typing import TypeAlias


Token: TypeAlias = str

class TokenCodec:
    """Encodes and decodes tokens"""
    def __init__(self):
        self._frozen = False
        self._id_by_token: dict[Token, int] = {} # mapping of tokens to ids for encoding
        self._token_by_id: dict[int, Token] = {} # reverse mapping of ids to tokens for decoding
        self._next_id = 0
            
    def encode(self, tokens: Sequence[Token]) -> list[int]:
        """Returns the encoding of the provided tokens"""
        encoded_tokens = torch.empty(len(tokens), dtype=torch.int32)
        for i, token in enumerate(tokens):
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
            encoded_tokens[i] = token_id
        return encoded_tokens

    def decode(self, encoded_text: Sequence[int]) -> str:
        return "".join([self._token_by_id[_id.item()] for _id in encoded_text])

    @property 
    def is_frozen(self):
        return self._frozen
    
    @is_frozen.setter
    def is_frozen(self, is_frozen):
        if not isinstance(is_frozen, bool):
            raise ValueError("Argument must be a boolean value")
        self._frozen = is_frozen


class OutOfVocabularyError(Exception):
    message_template = "Could not encode token '{token}' as it could not be found in this encoder's vocabulary"
    
    def __init__(self, token: Token):
        super().__init__(self, OutOfVocabularyError.message_template.format(token=token))