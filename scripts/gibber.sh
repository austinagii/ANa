#!/bin/bash

USAGE_MSG=$(cat <<-END
 
Usage: gibber <command> 

A micro language model that creates twitter length text when prompted with a topic

Available commands:
    build       builds a docker container with the current version of the specified component
    connect     creates an ssh connection with the specified resource
END
)

# Show a usage message if no command is specified
if [[ $# -eq 0 ]]; then
    echo "$USAGE_MSG"
    exit 1
fi

# cover the following commands
# build
# usage: gibber build ui || gibber build api || gibber build
# deploy 
# start 
# stop 
# connect

case $1 in
    --help)
        echo "$USAGE_MSG"
        ;;
    build) 
        bash $SCRIPT_DIR/gibber-build.sh $2
        ;;
    deploy)
        bash $SCRIPT_DIR/gibber-deploy.sh $2
        ;;
    connect)
        bash $SCRIPT_DIR/gibber-connect.sh $2
        ;;
    build)
        bash $SCRIPT_DIR/gibber-build.sh $2
        ;;
    *)
        echo "gibber build '$1' is not a recognized command"
        echo "See gibber build --help for a list of available commands"
        ;;
esac