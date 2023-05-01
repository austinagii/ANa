import torch

class BigramModel:
    def __init__(self, max_response_length: int = 120):
        self.max_response_length = max_response_length

    def train(self, corpus):
        tokens = list(corpus)
        unique_tokens = sorted(list(set(tokens)))
        alphabet_size = len(unique_tokens)
        token_mappings = list(zip(*[((token, idx), (idx, token)) for idx, token in enumerate(unique_tokens)]))
        idx_by_token = dict(token_mappings[0])
        self.token_by_idx = dict(token_mappings[1])
        # encode the tokens
        encoded_tokens = [idx_by_token[token] for token in tokens]
        # generate the bigrams
        bigrams = list(zip(encoded_tokens, encoded_tokens[1:]))
        # count the bigram frequencies
        bigram_frequencies = torch.zeros((alphabet_size, alphabet_size), dtype=torch.int32)
        for bigram in bigrams:
            bigram_frequencies[bigram[0], bigram[1]] += 1
        # calculate the bigram probabilities
        self.bigram_probabilities = bigram_frequencies / bigram_frequencies.sum(1, keepdims=True)
        return self
    
    def __call__(self, prompt):
        current_sequence_length = 0
        current_token = 10 # full stop
        current_sequence = ''
        while current_token != 14 and current_sequence_length <= self.max_response_length:
            current_token = torch.multinomial(self.bigram_probabilities[current_token], num_samples=1).item()
            current_sequence += self.token_by_idx[current_token]
            current_sequence_length += 1
        return current_sequence