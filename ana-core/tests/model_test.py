import torch
from core.model import NGramModel
from core.tokenizer import Tokenizer


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

def test_successful_response_generation():
    text = """Argo Navis (the Ship Argo), or simply Argo, is one of the 48 Ptolemy's constellations, 
    now a grouping of three IAU constellations. It is formerly a single large constellation in the 
    southern sky. The genitive is "Argus Navis", abbreviated "Arg". Flamsteed and other early modern 
    astronomers called it Navis (the Ship), genitive "Navis", abbreviated "Nav". The constellation proved
    to be of unwieldy size, as it was 28 percent larger than the next largest constellation and had more than 160 
    easily visible stars. The 1755 catalogue of Nicolas Louis de Lacaille divided it into the three modern 
    constellations that occupy much of the same area: Carina (the keel), Puppis (the poop deck) and 
    Vela (the sails). Argo derived from the ship Argo in Greek mythology, sailed by Jason and the Argonauts 
    to Colchis in search of the Golden Fleece.[1] Some stars of Puppis and Vela can be seen from Mediterranean 
    latitudes in winter and spring, the ship appearing to skim along the "river of the Milky Way."[2] Due to 
    precession of the equinoxes, the position of the stars from Earth's viewpoint has shifted southward, and 
    though most of the constellation was visible in Classical times, the constellation is now not easily visible 
    from most of the northern hemisphere.[3] All the stars of Argo Navis are easily visible from the tropics 
    southward, and pass near zenith from southern temperate latitudes. The brightest of these is Canopus 
    (α Carinae), the second-brightest night-time star, now assigned to Carina."""
    model = NGramModel(ngram_size=5)
    model.train(text)
    for i in range(100):
        response = model("Argo ")
        response_length = len(list(Tokenizer().tokenize(response)))
        assert response_length <= model.max_response_length
        if response_length < model.max_response_length:
            assert response[-1] == "."