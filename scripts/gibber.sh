#!/bin/bash

USAGE_MSG=$(cat <<-END
 
Usage: gibber <command> 

A micro language model that creates twitter length text when prompted with a topic

Available commands:
    connect     creates an ssh connection with the specified resource
END
)

# Show a usage message if no command is specified
if [[ $# -eq 0 ]]; then
    echo "$USAGE_MSG"
    exit 1
fi

# Get the path to the directory containing this script  
SCRIPT_DIR=$(dirname $(realpath $0))
BASE_DIR=$(dirname $SCRIPT_DIR)

case $1 in
    --help)
        echo "$USAGE_MSG"
        ;;
    connect)
        bash $SCRIPT_DIR/gibber-connect.sh $2
        ;;
    *)
        echo "gibber '$1' is not a recognized command"
        echo "See gibber --help for a list of available commands"
        ;;
esac