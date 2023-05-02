import argparse
import logging

from core.rpc.server import serve


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    
    # load the application configuration
    parser = argparse.ArgumentParser(description='Generate text using a trained model')
    parser.add_argument('--ngram-size', type=int, default=2, help='The size of the ngrams to use')
    args = parser.parse_args()
    serve(**vars(args)) 