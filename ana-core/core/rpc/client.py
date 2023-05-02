import logging

import grpc
import core.rpc.core_pb2 as core_pb2
import core.rpc.core_pb2_grpc as core_pb2_grpc


def run():
    # NOTE(gRPC Python Team): .close() is possible on a channel and should be
    # used in circumstances in which the with statement does not fit the needs
    # of the code.
    with grpc.insecure_channel('localhost:50051') as channel:
        stub = core_pb2_grpc.ModelStub(channel)
        response = stub.completePrompt(core_pb2.Prompt(text='Today'))
    print("ANa: " + response.text)


if __name__ == '__main__':
    logging.basicConfig()
    run()