
FROM python:3.10.11

RUN apt -y update && apt -y upgrade

RUN apt -y install less neovim tree

RUN pip install pipenv

WORKDIR /ana

COPY ./Pipfile.lock ./Pipfile.lock

ENV PYTHONPATH=/ana

RUN pipenv sync --dev

RUN ln -s /ana/cli/ana.sh /usr/local/bin/ana

RUN echo "PS1='\[\e[32m\]\u@ana-dev:\w\[\e[0m\]$ '" >> /root/.bashrc

ENTRYPOINT ["/usr/bin/env", "bash"] 
