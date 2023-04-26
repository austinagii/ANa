import pytest

from core.codec import TokenCodec, OutOfVocabularyError

@pytest.fixture
def codec():
    return TokenCodec()

@pytest.fixture 
def tokens():
    return [token for token in "Today is an Automic day"]

def test_number_of_encoded_tokens_equals_number_of_tokens(codec, tokens):
    num_tokens = len(tokens)
    encoded_text = codec.encode(tokens)
    assert len(encoded_text) == num_tokens

def test_each_token_has_a_unique_encoding(codec, tokens):
    token_by_encoding = {}
    encoded_tokens = codec.encode(tokens)
    # Ensure the each encoding is unique to a given token
    # i.e a single encoding does not map to more than one token 
    for i in range(len(encoded_tokens)):
        token, encoding = tokens[i], encoded_tokens[i]
        if (mapped_token := token_by_encoding.get(encoding)) is None:
            token_by_encoding[encoding] = token 
        else:
            assert mapped_token == token

def test_encoded_tokens_are_decoded_correctly(codec, tokens):
    encoded_tokens = codec.encode(tokens)
    decoded_tokens = codec.decode(encoded_tokens)
    assert "".join(decoded_tokens) == "Today is an Automic day"

def test_error_is_raised_if_encoding_out_of_vocab_token(codec, tokens):
    codec.encode(tokens)
    codec.is_frozen = True
    try:
        codec.encode("zimbabwe")
        assert False
    except Exception as e:
        assert isinstance(e, OutOfVocabularyError)

# TODO: Add test cases for boundary conditions and organize test cases by method