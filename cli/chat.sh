#!/usr/bin/env bash

USAGE_MSG=$(cat <<-END

Usage: ana chat 

Start a chat with the ANa agent

Options:
    -h, --help              Show this message
END
)

# validate the command line arguments
PARSED_ARGS=$(getopt -o h -l help --name chat -- "$@") || {
  echo "See 'ana chat --help' for a list of valid options"
  exit 1
}

# parse the command line arguments and store them in their associated variables
eval set -- "$PARSED_ARGS"
while true; do
    case $1 in
        --help|-h)
            echo "$USAGE_MSG"
            exit 0
            ;;
        --)
            break
            ;;
        *)
            echo "Invalid option :$1"
            echo "$USAGE_MSG"
            exit 1
            ;;
    esac
done 

docker image build -t ana-agent -f $AGENT_DIR/dockerfile $AGENT_DIR || {
  echo "An error occurred while building the agent container" >&2
  exit 1
}

docker container run -it --rm \
  --mount type=bind,src=$HOST_PATH/agent,dst=/agent \
  --env-file=$AGENT_DIR/env.properties \
  ana-agent pipenv run python agent
