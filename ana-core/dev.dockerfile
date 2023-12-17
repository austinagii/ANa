
FROM python:3.10.11

RUN apt -y update && apt -y upgrade

RUN pip install pipenv

WORKDIR /ana-core

COPY . .

ENV PYTHONPATH=/ana-core

RUN pipenv sync --dev

ENTRYPOINT ["/usr/bin/env", "sh"] 
