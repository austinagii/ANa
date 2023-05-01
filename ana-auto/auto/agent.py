import openai

from typing import TypeAlias, Any, Dict
from .command import BaseCommand

ChatMessage: TypeAlias = Dict[str, str]

class Agent:
    def __init__(self, config):
        self.config = config 

    def __call__(self, command: BaseCommand) -> Any:
        chat_completion_request = self.build_chat_completion_request(command.prompt)
        chat_message = self.get_chat_completion(chat_completion_request)
        return command.extract_result(chat_message)

    def build_chat_completion_request(prompt: str) -> openai.chat.Completion:
        return {
            "model": "gpt-3.5-turbo",
            "messages": [
                {"role": "system", "content": "You are Automic, an expert AI capable to surfing the web and performing actions on behalf of users"},
                {"role": "user", "content": prompt}
            ]
        } 
    
    def get_chat_completion(chat_completion_request) -> ChatMessage:
        chat_completion_response = openai.ChatCompletion.create(**chat_completion_request)
        return chat_completion_response.choices[0].message
