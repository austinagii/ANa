import pytest 

from core.tokenizer import Tokenizer

@pytest.fixture
def tokenizer():
    return Tokenizer()

def test_successfully_tokenizes_text(tokenizer):
    """This test case will need to be updated as the tokenizer implementation changes"""
    text = "Hello"
    assert list(tokenizer.tokenize(text)) == ["H", "e", "l", "l", "o"]