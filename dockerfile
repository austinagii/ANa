FROM docker:27.0.0-rc.1-cli

RUN apk update && apk upgrade

# Install the Python version used by the model and agent
ENV PYTHON_VERSION=3.12.4
RUN apk add --no-cache \
    bash \
    build-base \
    openssl-dev \
    bzip2-dev \
    zlib-dev \
    readline-dev \
    sqlite-dev \
    wget \
    libffi-dev \
    && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && tar xzf Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure --enable-optimizations \
    && make altinstall \
    && cd .. \
    && rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz \
    && apk del build-base wget

# Verify the installation
RUN python3.12 --version

# Set as the default python
RUN ln -s /usr/local/bin/python3.12 /usr/bin/python
RUN ln -s /usr/local/bin/pip3.12 /usr/bin/pip

# Clean up
RUN apk add --no-cache --virtual .run-deps \
    ca-certificates \
    && apk del build-base

WORKDIR /ANa 

RUN ln -s /ANa/cli/ana.sh /usr/local/bin/ana

CMD ["bash"]
