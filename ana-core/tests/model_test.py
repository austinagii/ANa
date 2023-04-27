import torch
from core.model import NGramModel


def test_successfully_trains_model():
    text = "Hello"

    # test unigram model
    expected_unigram_proba = torch.tensor([.2, .2, .4, .2])
    unigram_model = NGramModel(ngram_size=1)
    unigram_model.train(text)
    assert torch.all(unigram_model._ngram_proba == expected_unigram_proba)

    # test bigram model
    expected_bigram_proba = torch.tensor(
        [[0, 1, 0, 0],
         [0, 0, 1, 0],
         [0, 0, .5, .5],
         [0, 0, 0, 0]]
    )
    bigram_model = NGramModel(ngram_size=2)
    bigram_model.train(text)
    assert torch.all(bigram_model._ngram_proba == expected_bigram_proba)

    # test trigram model
    expected_trigram_proba = torch.tensor(
        [[[0, 0, 0, 0],
          [0, 0, 1, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0]],
         [[0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 1, 0],
          [0, 0, 0, 0]],
         [[0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 1],
          [0, 0, 0, 0]],
         [[0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0]]]
    )
    trigram_model = NGramModel(ngram_size=3)
    trigram_model.train(text)
    assert torch.all(trigram_model._ngram_proba == expected_trigram_proba)
