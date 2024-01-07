#!/usr/bin/env bash

USAGE_MSG=$(cat <<-END 

Usage: ana train [options]

Train the ANa large language model locally

Options:
  -h, --help     Show this message

END
)

PARSED_ARGS=$(getopt -o h -l help --name train -- "$@") || {
  echo "See 'ana train --help' for a list of valid options" >&2
  exit 1
}

cd $ROOT_DIR && pipenv run python -m ana train || {
  echo "An error occurred while training the model" >&2
  exit 1
}
