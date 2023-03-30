#!/bin/bash

USAGE_MSG=$(cat <<-END

Usage: gibber push [option] <component> <version>

Push the docker container of the specified component to dockerhub

Available components:
    api     The gibber REST API
    ui      The gibber web UI

Options:
    -f, --force             Force push the image to dockerhub even if that image is already present
    -h, --help              Show this message
END
)

# Show a usage message if no arguments are passed
if [ $# -lt 2 ]; then
    echo "$USAGE_MSG"
    exit 1
fi

#  Create variables to store the arguments values 
COMPONENT=""
FORCE=false

# parse the command line arguments and store them in their associated variables
PARSED_ARGS=$(getopt -o fh -l force,help --name push -- "$@")
eval set -- "$PARSED_ARGS"

while true; do
    case $1 in
        --help|-h)
            echo "$USAGE_MSG"
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift 1
            ;;
        --)
            COMPONENT=$2
            VERSION=$3
            break
            ;;
        *)
            echo "Error: Invalid option '$1'"
            echo "See 'gibber push --help' for a list of valid options"
            ;;
    esac
done 

# Get the current version of the specified component
case $COMPONENT in
    api|ui) 
        ;;
    *)
        echo "push: Invalid component '$COMPONENT'"
        echo "see 'gibber push --help'"
        exit 1
        ;;
esac

IMAGE_NAME=$USERNAME/$PROJECT_NAME-$COMPONENT:$VERSION
if ! docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo "No image for version '$VERSION' of '$COMPONENT' exists locally"
    exit 1;
fi

# push the image only if it doesnt already exist on docker (unless the --force flag is specified) 
SHOULD_PUSH=true
if docker manifest inspect $IMAGE_NAME >/dev/null 2>&1 && ! $FORCE; then 
    SHOULD_PUSH=false
fi

if $SHOULD_PUSH; then
    docker push $IMAGE_NAME 
else
    echo "push: an image for the specified version already exists"
    exit 1
fi