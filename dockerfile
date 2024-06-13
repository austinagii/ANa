FROM python:3.12.4-bullseye

RUN apt update -y && apt upgrade -y

RUN pip install pipenv

WORKDIR /ANa

EXPOSE 8888

ENV PYTHONPATH=/ANa/ana

CMD ["bash"]
