#!/bin/bash

USAGE_MSG=$(cat <<-END

Usage: gibber start [options] <component>

Starts the specified component

Available components:
    api     The gibber REST API
    ui      The gibber web UI

Options:
    -e, --environment <environment>     The environment where the component should be started (default: production)
                                        'local': The local environment
                                        'production': The production environment
    -v, --version <version>             The version of the component to be deployed (default: latest)
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
ENVIRONMENT="local"
VERSION="latest"

# Parse the provided arguments
PARSED_ARGS=$(getopt -o e:v: -l environment:,version -- "$@")
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
        -v|--version)
            VERSION=$2
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
    local|production)
        ;;
    *)
        echo "Unsupported environment: '$ENVIRONMENT'"
        echo "See 'ana start --help'"
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
            echo "See 'ana start --help'"
            exit 1
            ;;
    esac
fi

# run the components in non dockerized dev mode if local environment is specified
if [[ $ENVIRONMENT == "local" ]]; then
    case $COMPONENT in
        api)
            cd $API_ROOT_DIR && \
                pipenv sync && \
                pipenv run uvicorn --reload src.ana:app
            ;;
        ui) 
            cd $UI_ROOT_DIR && npm run dev
            ;;
    esac
else # run the dockerized version of the component
    # load the configuration for the specified environment 
    source $CONFIG_DIR/$ENVIRONMENT/.env

    if [[ "$COMPONENT" == "api" ]]; then
        ssh -i $CONFIG_DIR/$ENVIRONMENT/.keys/vm_key.pem $VM_USER@$VM_IP \
        "sudo docker container run -d --rm -p 8080:8080 --name $PROJECT_NAME-$COMPONENT_$VERSION \
            $USERNAME/$PROJECT_NAME-$COMPONENT:latest"
    elif [[ "$COMPONENT" == "ui" ]]; then
        ssh -i $CONFIG_DIR/$ENVIRONMENT/.keys/vm_key.pem $VM_USER@$VM_IP \
        "sudo docker container run -d --rm -p 8000:80 --name $PROJECT_NAME-$COMPONENT_$VERSION \
            $USERNAME/$PROJECT_NAME-$COMPONENT:latest"
    else
        echo "Failure"
        exit 1
    fi
fi