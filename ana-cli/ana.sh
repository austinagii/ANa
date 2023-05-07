#!/bin/bash

# Load shared variables from the rc file 
SCRIPT_DIR=$(dirname $(realpath $0))
source $SCRIPT_DIR/.anarc

USAGE_MSG=$(cat <<-END
 
Usage: ana [options] <command> 

A(rgo) Na(vis) is a language model that generates short text obout a prompted topic

Options:
    -h, --help  Show this message

Agent commands:
    chat        Start a chat with ANa
                Example: ana chat

Component management commands:
    build       Build an image of a component from its dockerfile
                Example: ana build api 
    
    deploy      Deploy an image of a component to a target environment
                Example: ana deploy api 1.0.0

    push        Push an image of a component to dockerhub
                Example: ana push api 1.0.0

    start       Start an instance of a component 
                Example: ana start api 1.0.0

    stop        Stop a running instance of a component 
                Example: ana stop api 1.0.0

Other commands:
    connect     Create an ssh connection to a given environments virtual machine 
                Example: ana connect production

    infra       Manage the cloud infrastructure where ANa is deployed

Try 'ana <command> --help' for more information on a specific commnad
END
)

exitWithMessageIfNoArgs $@ "$USAGE_MSG"

# Show a usage message if either 'help' option is specified
if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "$USAGE_MSG"
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
    deploy)
        bash $SCRIPT_DIR/deploy.sh "$@"
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
    # other commands
    connect)
        bash $SCRIPT_DIR/connect.sh "$@"
        ;;
    infra)
        bash $SCRIPT_DIR/infra/infra.sh "$@"
        ;;
    *)
        echo "ana '$COMMAND' is not a recognized command"
        echo "See 'ana --help' for a list of available commands"
        ;;
esac