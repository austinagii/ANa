import json 

from . import Command, CommandRegistry 

prompt_template = """You will be given an objective. Think step by step; output a numbered list of steps describing how you would complete the request. 

Each step MUST correspond to one of the available commands and must be structured in accordance with the format of the command. At the end of every command you should output a description of what you intend to achieve.

These are your available commands: 
{commands}
    
This is your objective: {objective}"""

class Plan(Command):
    name = "PLAN"
    description = "Given an objective, this command creates a numbered list of tasks to accomplish that objective"
    args = {
        "objective": "The goal / outcome that needs to be accomplished"   
    }

    def __init__(self, objective: str):
        super(self)
        commands = ""
        for (_id, command) in CommandRegistry.commands.items():
            commands += f"\t{_id}. {type(command).description}"
        self.prompt = prompt_template.format(commands=commands, objective=object)

    def handle_agent_response(self, response) -> list[Command]:
        # TODO: Validate the returned plan to ensure the commands and arguments are valid
        return json.loads(response['content'])['plan']

CommandRegistry.register(Plan)