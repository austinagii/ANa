#!/bin/bash

USAGE_MSG=$(cat <<-END

Usage: ana build [options] <component>

Build an image of a component from its dockerfile

Available components:
    api     The ANa REST API
    ui      The ANa web UI

Options:
    -f, --force             Forces the image to be built with the components current version number 
                            even if that image already exists
    -s, --show-version      Shows the version of the component that would be build without executing
                            the build
    -h, --help              Show this message
END
)

exitWithMessageIfNoArgs $@ "$USAGE_MSG"

# validate the command line arguments
PARSED_ARGS=$(getopt -o fsh -l force,show-version,help --name build -- "$@")
if [ $? -gt 0 ]; then
    echo "See 'ana build --help' for a list of valid options"
    exit 1
fi 

# Create variables to store the argument values 
COMPONENT=""
FORCE=false
SHOW_VERSION=false

# parse the command line arguments and store them in their associated variables
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
        -s|--show-version)
            SHOW_VERSION=true
            shift 1
            ;;
        --)
            COMPONENT=$2
            break
            ;;
    esac
done 

# Exit with an error if an invalid component is specified
isValidComponent $COMPONENT || {
    echo "Invalid component '$COMPONENT'"
    echo "see 'ana build --help'"
    exit 1
}

# Get the current version of the specified component
case $COMPONENT in
    api)
        VERSION=$(cat $API_ROOT_DIR/version)
        BUILD_DIR=$API_ROOT_DIR
        ;;
    ui)
        VERSION=$(jq -r '.version' $UI_ROOT_DIR/package.json)
        BUILD_DIR=$UI_ROOT_DIR
        ;;
    core)
        VERSION=$(awk -F "=" '/version/ {print $2}' $CORE_ROOT_DIR/setup.cfg | tr -d ' ')
        BUILD_DIR=$CORE_ROOT_DIR
        ;;
esac

# If requested, show the version of the component that would be built
if $SHOW_VERSION; then 
    echo $VERSION
    exit 0;
fi

# build the specified component
IMAGE_NAME=$USERNAME/$PROJECT_NAME-$COMPONENT:$VERSION
# check whether a docker image for the specified component and version exists locally or on dockerhub 
SHOULD_BUILD=true
if (docker image inspect $IMAGE_NAME >/dev/null 2>&1 || \
        docker manifest inspect $IMAGE_NAME >/dev/null 2>&1) && \
        ! $FORCE; then 
    SHOULD_BUILD=false
fi

if $SHOULD_BUILD; then
    docker image build -t $IMAGE_NAME $BUILD_DIR
else
    echo "build: an image for the specified version already exists"
    exit 1
fi