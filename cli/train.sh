#!/usr/bin/env bash

USAGE_MSG=$(cat <<-END 

Usage: ana train [options]

Train the ANa language model locally

Options:
  -h, --help     Show this message

END
)

# Fix: No help message is displayed if -h flag is specified.
PARSED_ARGS=$(getopt -o h -l help --name train -- "$@") || {
  echo "See 'ana train --help' for a list of valid options" >&2
  exit 1
}

docker image build -t ana-core -f $CORE_DIR/dockerfile $CORE_DIR || {
  echo "An error occurred while training the model" >&2
  exit 1
}

docker container run -it --rm --name ana-core-train \
  --mount type=bind,src=$HOST_PATH/core,dst=/core \
  ana-core pipenv run python core -m train
