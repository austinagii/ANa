from abc import ABCMeta, abstractmethod

class BaseCommand(ABCMeta):
    @abstractmethod
    def execute(self):
        pass