from concurrent import futures
import logging

import grpc

from core.language.models import NGramModel
from core.language import DataLoader
import core.rpc.core_pb2 as core_pb2
import core.rpc.core_pb2_grpc as core_pb2_grpc


class Server(core_pb2_grpc.ModelServicer):
    def __init__(self, **model_kwargs):
        super().__init__()
        print("Initializing model...")
        self.model = NGramModel(**model_kwargs)
        self.model.train(DataLoader().load_training_corpus())

    def completePrompt(self, request, context):
        return core_pb2.PromptCompletion(text=self.model(request.text))
    

def serve(**model_kwargs):
    port = '50051'
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    core_pb2_grpc.add_ModelServicer_to_server(Server(**model_kwargs), server)
    server.add_insecure_port('[::]:' + port)
    server.start()
    print("Server started, listening on " + port)
    server.wait_for_termination()