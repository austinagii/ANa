import pytest 

from core.tokenizer import NGramTokenizer

def test_successfully_extracts_all_ngrams_from_text():
    text = "Hello"
    tokenizer = NGramTokenizer(ngram_size=1)
    assert list(tokenizer.tokenize_to_ngrams(text)) == [["H"], ["e"], ["l"], ["l"], ["o"]]
    tokenizer = NGramTokenizer(ngram_size=2)
    assert list(tokenizer.tokenize_to_ngrams(text)) == [["H", "e"], ["e", "l"], ["l", "l"], ["l", "o"]]
    tokenizer = NGramTokenizer(ngram_size=3)
    assert list(tokenizer.tokenize_to_ngrams(text)) == [["H", "e", "l"], ["e", "l", "l"], ["l", "l", "o"]]
    tokenizer = NGramTokenizer(ngram_size=4)
    assert list(tokenizer.tokenize_to_ngrams(text)) == [["H", "e", "l", "l"], ["e", "l", "l", "o"]]

def test_error_is_thrown_when_ngram_size_is_less_than_one():
    with pytest.raises(ValueError):
        NGramTokenizer(ngram_size=0)
    with pytest.raises(ValueError):
        NGramTokenizer(ngram_size=-1)

def test_single_ngram_is_returned_if_text_is_shorter_than_ngram_length():
    text = "Hello"
    tokenizer = NGramTokenizer(ngram_size=6)
    assert list(tokenizer.tokenize_to_ngrams(text)) == [["H", "e", "l", "l", "o", None]]
