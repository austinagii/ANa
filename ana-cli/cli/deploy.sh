#!/bin/bash

USAGE_MSG=$(cat <<-EOF

Usage: ana deploy [options] <component> <version>

Deploy a component to a target environment

Components:
    api     The ANa REST API
    ui      The ANa UI

Options:
    -e, --environment <environment>     The target environment (default: prod) 
    -h, --help                          Show this message
EOF
)

# Show usage message if no arguments are provided
if [[ $# -eq 0 ]]; then
    echo "$USAGE_MSG"
    exit 1
fi

# Initialize variables with default values  
ENVIRONMENT="prod"
COMPONENT=""

# Parse the command line arguments
TEMP=$(getopt -o e -l environment: -- "$@")
eval set -- "$TEMP"

# Capture the argument values in their corresponding variables
while true; do
    case $1 in
        -e|--environment)
            ENVIRONMENT=$2 
            shift 2    
            ;;
        --)
            COMPONENT=$2
            VERSION=$3
            break
            ;;
        *)
            echo "deploy: Invalid option: $1" >&2
            echo "See 'ana deploy --help' for a list of valid options"
            exit 1
            ;;
    esac
done


# Validate arguments provided by the user
case $COMPONENT in 
    api|ui)
        ;;
    *)
        echo "deploy: invalid component '$COMPONENT'"
        echo "See 'ana deploy --help' for a list of valid components"
        exit 1
        ;;
esac

case $ENVIRONMENT in
    prod)
        ;;
    *)
        echo "Invalid environment: $ENVIRONMENT" >&2
        echo "See 'ana deploy --help'"
        exit 1
        ;;
esac

# TODO: add error handling in cases where commands could fail
# load the environment variables for the specified environment
source $CONFIG_DIR/$ENVIRONMENT/.env
# check if the host VM is running
VM_STATUS=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query powerState -o tsv)
if [[ $VM_STATUS != "VM running" ]]; then
    echo "The host VM for '$ENVIRONMENT' is not running. Please start the VM before deploying."
    exit 1
else
    # deploy the component
    echo "Deploying $COMPONENT v'$VERSION' to '$ENVIRONMENT' environment"
    if [[ $(ssh -i $CONFIG_DIR/$ENVIRONMENT/.keys/vm_key.pem austinagi@$VM_IP \
            "sudo docker pull austinagi/ana-$COMPONENT:$VERSION 2> /dev/null") ]]; then
        echo "deploy: deployment completed"
    else
        echo "$COMPONENT v'$VERSION' could not be found in docker registry" >&2
        exit 1
    fi
fi