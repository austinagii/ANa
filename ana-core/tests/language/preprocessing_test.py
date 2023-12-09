import pytest 

from core.language import preprocessing as pp 
from core.language import coretypes as types 

class TestTokenizer:
    @pytest.fixture
    def tokenizer(self):
        return pp.Tokenizer()

    def test_correctly_tokenizes_text_into_words(self, tokenizer):
        assert tokenizer.tokenize("Test") == ["Test"]
        assert tokenizer.tokenize("This is a test") == ["This", "is", "a", "test"] 

    def test_returns_no_tokens_if_text_is_empty(self, tokenizer):
        assert list(tokenizer.tokenize("")) == []
        assert list(tokenizer.tokenize("   ")) == []

    def test_raises_error_if_text_is_none(self, tokenizer):
        with pytest.raises(TypeError):
            tokenizer.tokenize(None) 

    def test_raises_error_for_invalid_argument_type(self, tokenizer):
        with pytest.raises(TypeError):
            tokenizer.tokenize(24) 


class TestCodec:
    @pytest.fixture
    def codec(self):
        return pp.Codec(["This", "is", "a", "test"])

    def test_vocab_contains_at_least_the_unknown_token(self):
        codec = pp.Codec([])
        assert codec.vocab_size == 1
        assert pp.Codec.UNKNOWN_TOKEN in codec.vocab

    def test_vocab_contains_no_duplicate_tokens(self):
        codec = pp.Codec(["this", "this", "token", "token", "test"])

        assert codec.vocab_size == 4  # This includes the unknown token.
        for token in ["this", "token", "test"]:
            assert token in codec.vocab

    def test_each_token_is_assigned_a_unique_id(self, codec):
        assigned_token_ids = set()
        for token in codec.vocab:
            token_id = codec.encode(token)
            assert token_id not in assigned_token_ids, f"Token ID {token_id} for token '{token}' is not unique"
            assigned_token_ids.add(token_id)

    def test_encoding_all_tokens_produces_a_list_of_token_ids(self, codec):
        results = codec.encode_all(["This", "is", "a", "test"])

        assert isinstance(results, list)
        for item in results:
            assert isinstance(item, types.TokenId)
