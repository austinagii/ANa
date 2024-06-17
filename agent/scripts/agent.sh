#!/usr/bin/env bash

USAGE_MSG=$(cat <<-"END"

Usage: ana agent <command> [options]

Commands used to manage and interact with the ANa agent

Options:
    -h, --help      Show this message

Commands:
      dev           Start the agent devcontainer
                    Example: ana agent dev 

      chat          Start a chat with the agent
                    Example: ana agent chat

Try 'ana agent <command> --help' for more information on a specific command
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
AGENT_ROOT_DIR=$(dirname "$SCRIPT_DIR")
if [ -z "$HOST_PATH" ]; then 
  HOST_PATH=$(dirname "$AGENT_ROOT_DIR")
fi

COMMAND="$1"

case $COMMAND in 
    dev)
        docker image build -t ana-agent -f "$AGENT_ROOT_DIR/dockerfile" "$AGENT_ROOT_DIR" \
          && docker container run -it --rm --name ana-agent-dev \
            --mount type=bind,src="$HOST_PATH/agent",dst=/agent ana-agent
        ;;
    chat)
        docker image build -t ana-agent -f "$AGENT_ROOT_DIR/dockerfile" "$AGENT_ROOT_DIR" \
          && docker container run -it --rm --name ana-agent-chat \
          --mount type=bind,src="$HOST_PATH/agent",dst=/agent \
          ana-agent pipenv run python agent 
        ;;
    *)
        echo "ana agent '$COMMAND' is not a recognized command" >&2
        echo "See 'ana agent --help' for a list of available commands" >&2
        exit 1
        ;;
esac
