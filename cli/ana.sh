#!/usr/bin/env bash

# Load shared variables from the rc file 
SCRIPT_DIR=$(dirname $(realpath $0))
source $SCRIPT_DIR/.anarc

USAGE_MSG=$(cat <<-END
 
Usage: ana [options] <command> 

A(rgo) Na(vis) is an interactive agent that can be prompted with a goal and autonomously create and execute a plan to achieve that goal with appropriate human interaction

Options:
    -h, --help      Show this message
    -v, --version   Show the current version number

Commands:
    agent           Manage or interact with the ANa agent
                    Example: ana agent chat

    model           Manage or interact with the ANa language model 
                    Example: ana model train 

Try 'ana <command> --help' for more information on a specific commnad
END
)

exitWithMessageIfNoArgs $@ "$USAGE_MSG"

# Show a usage message if either 'help' option is specified
if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "$USAGE_MSG"
    exit 0
fi

# Show the version number if the version flag is specified 
if [[ $1 == "-v" || $1 == "--version" ]]; then
    version=$(getConfigValue "VERSION" $SCRIPT_DIR/project.conf)
    name=$(getConfigValue "NAME" $SCRIPT_DIR/project.conf)
    echo "$name version $version"
    exit 0
fi


# Execute the script corresponding to the specified command 
COMMAND=$1
shift
case $COMMAND in
  # component management commands
  agent)
    bash $AGENT_DIR/scripts/agent.sh "$@"
    ;;
  model)
    bash $MODEL_DIR/scripts/model.sh "$@"
    ;;
  *)
    echo "ana '$COMMAND' is not a recognized command" >/dev/stderr
    echo "See 'ana --help' for a list of available commands" >/dev/stderr
    exit 1
    ;;
esac
