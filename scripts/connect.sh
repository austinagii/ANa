#!/bin/bash

USAGE_MSG=$(cat <<-END

Usage: ana connect <environment>

Creates an ssh connection with the specified resource

Available environments:
    prod        connects to the production environment
END
)

# Show a usage message if no arguments are specified
if [[ $# -eq 0 ]]; then
    echo "$USAGE_MSG"
    exit 1
fi

# Validate and assign the environment variable
case $1 in
    prod)
        ENVIRONMENT=$1
        ;;
    *)
        echo "Unsupported environment '$1'"
        echo "See 'ana connect --help'"
        exit 1
        ;; 
esac

# load the config for the specified environment
ENVIRONMENT_CONFIG_DIR=$CONFIG_DIR/$1
source $ENVIRONMENT_CONFIG_DIR/.env

# Connect to the specified environment's virtual machine
ssh -i $ENVIRONMENT_CONFIG_DIR/.keys/vm_key.pem $VM_USER@$VM_IP