import pydantic

class PromptCompletionRequest(pydantic.BaseModel):
    prompt: str

class PromptCompletion(pydantic.BaseModel):
    completion: str