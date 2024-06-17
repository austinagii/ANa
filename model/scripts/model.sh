#!/usr/bin/env bash

USAGE_MSG=$(cat <<-"END"

Usage: ana model <command> [options]

Commands used to manage and interact with the ANa language model

Options:
    -h, --help      Show this message

Commands:
      dev           Start the language model devcontainer
                    Example: ana model dev 

      train         Train the ANa language model locally
                    Example: ana model train

Try 'ana train <command> --help' for more information on a specific command
END
)

if [ $# -eq 0 ]; then
    echo "$USAGE_MSG"
    exit 1
fi

# Show a usage message if either 'help' option is specified
if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "$USAGE_MSG"
    exit 0
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
MODEL_ROOT_DIR=$(dirname "$SCRIPT_DIR")
if [ -z "$HOST_PATH" ]; then 
  HOST_PATH=$(dirname "$MODEL_ROOT_DIR")
fi

COMMAND="$1"

case $COMMAND in 
    dev)
        docker image build -t ana-model -f "$MODEL_ROOT_DIR/dockerfile" "$MODEL_ROOT_DIR" \
          && docker container run -it --rm --name ana-model-dev \
            --mount type=bind,src="$HOST_PATH/model",dst=/model ana-model
        ;;
    chat)
        docker image build -t ana-model -f "$MODEL_ROOT_DIR/dockerfile" "$MODEL_ROOT_DIR" \
          && docker container run -it --rm --name ana-model-train \
          --mount type=bind,src="$HOST_PATH/model",dst=/model \
          ana-model pipenv run python src/main.py -m train 
        ;;
    *)
        echo "ana model '$COMMAND' is not a recognized command" >&2
        echo "See 'ana model --help' for a list of available commands" >&2
        exit 1
        ;;
esac
