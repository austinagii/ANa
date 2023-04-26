import pytest 

from core.reader import NGramReader

@pytest.fixture
def tokens():
    def _get_tokens():
        return (token for token in "Hello")
    return _get_tokens

def test_reads_all_ngrams_from_from_token_stream(tokens):
    reader = NGramReader(ngram_size=1)
    assert list(reader.read(tokens())) == [["H"], ["e"], ["l"], ["l"], ["o"]]
    reader = NGramReader(ngram_size=2)
    assert list(reader.read(tokens())) == [["H", "e"], ["e", "l"], ["l", "l"], ["l", "o"]]
    reader = NGramReader(ngram_size=3)
    assert list(reader.read(tokens())) == [["H", "e", "l"], ["e", "l", "l"], ["l", "l", "o"]]
    reader = NGramReader(ngram_size=4)
    assert list(reader.read(tokens())) == [["H", "e", "l", "l"], ["e", "l", "l", "o"]]

def test_error_is_thrown_when_ngram_size_is_less_than_one():
    with pytest.raises(ValueError):
        NGramReader(ngram_size=0)
    with pytest.raises(ValueError):
        NGramReader(ngram_size=-1)

def test_single_ngram_is_returned_if_token_stream_contains_less_than_ngram_size_tokens(tokens):
    reader = NGramReader(ngram_size=6)
    assert list(reader.read(tokens())) == [["H", "e", "l", "l", "o", None]]
