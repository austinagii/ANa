#!/bin/bash

USAGE_MSG=$(cat <<-END

Usage: gibber connect <environment>

Creates an ssh connection with the specified resource

Available environments:
    prod        connects to the production environment
END
)

# Show a usage message if no environment is specified
if [[ $# -eq 0 ]]; then
    echo "$USAGE_MSG"
    exit 1
fi

# Get the path to the directory containing this script
SCRIPT_DIR=$(dirname $(realpath $0))
BASE_DIR=$(dirname $SCRIPT_DIR)

# Read the gibber host connection properties from the .env file
CONFIG=$(cat $BASE_DIR/.env/env.json)
PROD_VM_IP=$(echo $CONFIG | jq -r '.environments.prod.vm.ip')
PROD_VM_USER=$(echo $CONFIG | jq -r '.environments.prod.vm.user')
PROD_VM_KEY=$(echo $CONFIG | jq -r '.environments.prod.vm.key')

# Connect to the specified environment's virtual machine
case $1 in
    prod)
        ssh -i $BASE_DIR/$PROD_VM_KEY $PROD_VM_USER@$PROD_VM_IP
        ;;
    *)
        echo "Unsupported environment '$1'"
        ;; 
esac