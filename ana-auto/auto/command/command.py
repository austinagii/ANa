from abc import ABCMeta, abstractmethod
from typing import Dict

# TODO: Add documentation for creating and registering a new command 
# TODO: Implement mechanism to automatically register subclasses of Command

class Command(ABCMeta):
    """An executable component that can be used by the agent to achieve some goal
    
    All subclasses of command must implement the `__call__` and `handle_agent_response` methods
    """
    def __init__(self):
        Command._fail_if_non_compliant(self)
        
    @staticmethod
    def _fail_if_non_compliant(command):
        call_attr = getattr(command, '__call__', None)
        if not callable(call_attr):
            raise NotImplementedError("All subclasses of Command must implement the '__callable__' method")
        handle_agent_response_attr = getattr(command, 'handle_agent_response', None)
        if not callable(handle_agent_response_attr):
            raise NotImplementedError("All subclasses of Command must implement the 'handle_agent_response' method")

    @abstractmethod
    def handle_agent_response(self):
        pass


class CommandRegistry:
    """Maintains a collection of commands that are available to the agent"""
    commands: Dict = {}
    next_command_id = 1

    @staticmethod
    def register(command: Command) -> None:
        """Adds the specified command to the collection of available commands and returns it's assigned id"""
        command.id = CommandRegistry.next_command_id
        CommandRegistry.commands[command.id] = command
        CommandRegistry.next_command_id += 1