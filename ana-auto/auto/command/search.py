import json

from .base import Command
from ..agent import ChatMessage
from typing import TypeAlias, Tuple, Dict
from duckduckgo_search import ddg

SearchResult: TypeAlias = Tuple[str, str]
SearchResults: TypeAlias = Dict[int, SearchResult]

class Search(Command):
    def __init__(self, task, query, num_results=20):
        self.task = task
        self.query = query
        search_results = self.get_search_results(query, self.num_results)
        self.prompt = self.generate_search_result_selection_prompt(search_results)
    
    def get_search_results(self, query: str, num_results: int) -> dict[int, tuple[str, str]]:
        """Returns a numbered collection of search results for the specified query"""
        return {_id: (result['href'], result['body']) for _id, result in enumerate(ddg(keywords=query, max_results=num_results))}
    
    def generate_search_result_selection_prompt(self, results) -> str:
        """Generates a prompt requesting that the agent select one of the numbered search results"""
        prompt = "Choose exactly one of the below numbered hyperlinks that would best achieve this task: '{self.task}'" \
            'Provide your response in JSON in accordance with this format: {"choice": <chosen number>}'
        prompt += "Search results:\n"
        for (_id, (href, body)) in results.items():
            prompt += f"\t{_id}. {href} {body}"
        return prompt
    
    def handle_agent_response(self, chat_message: ChatMessage) -> int:
        json_response = json.loads(chat_message)
        self.choice = json_response['choice']
