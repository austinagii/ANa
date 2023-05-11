#!/bin/bash

USAGE_MSG=$(cat <<-END

Usage: gibber start [options] <component>

Starts the specified component

Available components:
    api     The gibber REST API
    ui      The gibber web UI

Options:
    -e, --environment <environment>     The environment where the component should be started (default: production)
                                        'prod': The production environment
    -h, --help                          Show this message

END
)

# Show usage message if no arguments are provided
if [[ $# -eq 0 ]]; then
    echo "$USAGE_MSG"
    exit 1
fi

# Initialize variables with default values
COMPONENT=""
ENVIRONMENT="production"

# Parse the provided arguments
PARSED_ARGS=$(getopt -o e: -l environment: -- "$@")
eval set -- "$PARSED_ARGS"

# Initialize environment variables using the command line arguments
while true; do
    case $1 in 
        -h|--help)
            echo "$USAGE_MSG"
            exit 0
            ;;
        -e|--environment)
            ENVIRONMENT=$2
            shift 2
            ;;
        --)
            COMPONENT=$2
            break
            ;;
        *)
            echo "Unrecognized option '$1'"
            exit 1
            ;;
    esac
done

# validate the arguments
case $ENVIRONMENT in
    production)
        ;;
    *)
        echo "Unsupported environment: '$ENVIRONMENT'"
        echo "See 'gibber start --help'"
        exit 1
        ;;
esac

if [[ -z $COMPONENT ]]; then
    echo "$USAGE_MSG"
else 
    case $COMPONENT in 
        api|ui)
            ;;
        *)
            echo "Unsupported component: '$COMPONENT'"
            echo "See 'gibber start --help'"
            exit 1
            ;;
    esac
fi

# load the environment variables for the specified environment 
source $CONFIG_DIR/$ENVIRONMENT/.env

# start the latest version of the specified component
ssh -i $CONFIG_DIR/$ENVIRONMENT/.keys/gibber_key.pem $VM_USER@$VM_IP \
    "sudo docker container stop"

if [[ "$COMPONENT" == "api" ]]; then
    ssh -i $CONFIG_DIR/$ENVIRONMENT/.keys/gibber_key.pem $VM_USER@$VM_IP \
    "sudo docker container stop gibber-api_$VERSION \
        austinagi/gibber-$COMPONENT:latest"
elif [[ "$COMPONENT" == "ui" ]]; then
    ssh -i $CONFIG_DIR/$ENVIRONMENT/.keys/gibber_key.pem $VM_USER@$VM_IP \
    "sudo docker container stop gibber-ui_$VERSION \
        austinagi/gibber-$COMPONENT:latest"
else
    echo "Failure"
    exit 1
fi