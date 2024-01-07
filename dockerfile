FROM python:3.10.11

RUN apt update && apt upgrade

RUN pip install pipenv

WORKDIR /ana-core

COPY . .

ENV PYTHONPATH=/ana-core
