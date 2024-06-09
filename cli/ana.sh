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
    chat            Start a chat with ANa
                    Example: ana chat

    build           Build the docker image for the ANa agent
                    Example: ana build  

    start           Start the ANa agent's docker container 
                    Example: ana start 

    stop            Stop the ANa agent's docker container
                    Example: ana stop 

    train           Train the ANa language model 
                    Example: ana train 

    serve           Serve the ANa language model
                    Example: ana serve 

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
  build) 
    bash $SCRIPT_DIR/build.sh "$@"
    ;;
  chat)
    bash $SCRIPT_DIR/chat.sh "$@"
    ;;
  push)
    bash $SCRIPT_DIR/push.sh "$@"
    ;;
  start)
    bash $SCRIPT_DIR/start.sh "$@"
    ;;
  stop)
    bash $SCRIPT_DIR/stop.sh "$@"
    ;;
  train)
    bash $SCRIPT_DIR/train.sh "$@"
    ;;
  serve)
    bash $SCRIPT_DIR/serve.sh "$@"
    ;;
  *)
    echo "ana '$COMMAND' is not a recognized command" >/dev/stderr
    echo "See 'ana --help' for a list of available commands" >/dev/stderr
    exit 1
    ;;
esac
