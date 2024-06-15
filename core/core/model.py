import torch 
import datasets

from core.preprocessing import Tokenizer, Codec
import core.preprocessing as prep


class Model(torch.nn.Module):
    def __init__(self, vocab_size: int, n_classes: int):
        super().__init__()
        self.linear = torch.nn.Linear(vocab_size, 20_000)
        self.linear2 = torch.nn.Linear(20_000, n_classes)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = self.linear(x)
        return self.linear2(x)
    

def train(model: torch.nn.Module, 
          dataset: datasets.Dataset, 
          tokenizer: Tokenizer,
          codec: Codec,
          optimizer: torch.optim.Optimizer,
          device: torch.device,
          batch_size: int = 32):
    total_loss = 0
    for batch_no, (inputs, labels) in enumerate(prep.to_batches(dataset, batch_size=batch_size), start=1):
        X = prep.to_bow(codec.encode_all(tokenizer.tokenize_all(inputs)), codec.vocab_size).to(device)
        y = torch.tensor(labels, dtype=torch.long).to(device)
        optimizer.zero_grad()
        logits = model(X)
        loss = torch.nn.functional.cross_entropy(logits, y)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    avg_loss = total_loss / batch_no
    return total_loss, avg_loss

def eval(model: torch.nn.Module, 
         dataset: datasets.Dataset, 
         tokenizer: Tokenizer,
         codec: Codec,
         device: torch.device,
         batch_size: int = 32):
    total_loss = 0
    for batch_no, (inputs, labels) in enumerate(prep.to_batches(dataset, batch_size=batch_size), start=1):
        X = prep.to_bow(codec.encode_all(tokenizer.tokenize_all(inputs)), codec.vocab_size).to(device)
        y = torch.tensor(labels, dtype=torch.long).to(device)
        with torch.no_grad():
            logits = model(X)
            loss = torch.nn.functional.cross_entropy(logits, y)
            total_loss += loss.item()
    avg_loss = total_loss / batch_no
    return total_loss, avg_loss
