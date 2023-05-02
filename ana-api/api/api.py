
import logging 
import sys
import torch 
import torch.random

import pandas as pd 

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

import api.rpc.client as client 
import api.chat as chat

app = FastAPI()

# define the cors configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['GET'],
    allow_headers=['*']
)

@app.post("/prompt-completion")
def get_prompt_completion(request: chat.PromptCompletionRequest):
    return chat.PromptCompletion(completion=client.complete_prompt(request.prompt))