import logging 
import sys
import argparse
import json
from os import path 
from pathlib import Path 

import pandas as pd 
import datasets
import torch
from torch.optim import SGD

from model.model import Model, train as train_model, eval as eval_model
from model.preprocessing import Tokenizer, Codec  
from model import utils

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("ANa")

def train():
    dataset = datasets.load_dataset("emotion")
    train_dataset, validation_dataset = dataset['train'], dataset['validation']
    tokenizer = Tokenizer()
    codec = Codec(Tokenizer(lazy=True).tokenize_all(dataset['train']['text'], flatten=True))
    n_classes = 6
    device = utils.get_available_device()
    model = Model(codec.vocab_size, n_classes).to(device)
    optimizer = SGD(model.parameters(), lr=0.01)

    print(f"Model initalized, starting training on '{device}'...\n")
    epoch = 0
    batch_size = 64
    stopping_criterion = 1e-3
    min_val_loss = float('inf')
    iterations_without_improvement = 0
    while iterations_without_improvement < 3:
        with utils.Timer() as epoch_timer:
            epoch += 1
            total_train_loss, avg_train_loss = train_model(model, train_dataset, tokenizer, codec, optimizer, device, batch_size)
            total_val_loss, avg_val_loss = eval_model(model, validation_dataset, tokenizer, codec, device, batch_size)
            if total_val_loss < min_val_loss - stopping_criterion:
                min_val_loss = total_val_loss
                iterations_without_improvement = 0
            else:
                iterations_without_improvement += 1
        print("Epoch #{:0>3} [{:.2f}s] :: Train loss: '{:.4f}' Validation loss: '{:.4f}'".format(
            epoch, epoch_timer.interval, avg_train_loss, avg_val_loss
        ))

    output_dir = path.join(path.dirname(path.abspath(__file__)), '..', 'artifacts')
    # Save the tokenizer state.
    with open(path.join(output_dir, 'tokenizer.json'), 'w') as f:
        json.dump(tokenizer.id_by_word, f)

    # Save the model.
    with torch.no_grad():
        r = torch.randn((1, tokenizer.vocab_size)).to(device)
        traced_model = torch.jit.trace(model, r)
        traced_model.save(path.join(output_dir, 'model.pt'))

def serve():
    pass

if __name__ == "__main__":
    # load the application configuration
    parser = argparse.ArgumentParser(prog="ANa", description='The ANa language model')
    parser.add_argument('-m', '--mode', dest="mode", choices=['train', 'serve'], default='serve', required=False)
    args = parser.parse_args()

    if args.mode == 'train':
        train()
    elif args.mode == 'serve':
        serve()
    else:
        print("No mode specified")
