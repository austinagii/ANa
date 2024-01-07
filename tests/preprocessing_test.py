import pytest 

from core.language import preprocessing as pp 
from core.language import coretypes as types 

# TODO: Add more test cases for lazy tokenizer.
class TestTokenizer:
    @pytest.fixture
    def tokenizer(self):
        return pp.Tokenizer()

    @pytest.fixture
    def lazy_tokenizer(self):
        return pp.Tokenizer(lazy=True)

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

    def test_correctly_tokenizes_iterable_of_strings(self, tokenizer, lazy_tokenizer):
        input_ = ["This is a", "list of strings"]
        expected_output = [["This", "is", "a"], ["list", "of", "strings"]]
        assert tokenizer.tokenize_all(input_) == expected_output

        actual_output = lazy_tokenizer.tokenize_all(input_)
        for actual_outer, expected_outer in zip(actual_output, expected_output):
            for actual, expected in zip(actual_outer, expected_outer):
                assert actual == expected

        assert tokenizer.tokenize_all(input_, flatten=True) == ["This", "is", "a", "list", "of", "strings"]

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

    def test_encoding_all_tokens_in_a_nested_list_produces_a_nested_list_of_token_ids(self, codec):
        results = codec.encode_all([["This", "is", "a", "test"], ["a", "test", "this", "is"]])

        assert isinstance(results, list)
        for result in results:
            assert isinstance(result, list)
            for item in result:
               assert isinstance(item, types.TokenId)
