import grpc
import api.rpc.core_pb2 as core_pb2
import api.rpc.core_pb2_grpc as core_pb2_grpc

import api.chat as chat


def complete_prompt(prompt: str) -> str:
    # NOTE(gRPC Python Team): .close() is possible on a channel and should be
    # used in circumstances in which the with statement does not fit the needs
    # of the code.
    with grpc.insecure_channel('localhost:50051') as channel:
        stub = core_pb2_grpc.ModelStub(channel)
        response = stub.completePrompt(core_pb2.Prompt(text=prompt))
    return response.text