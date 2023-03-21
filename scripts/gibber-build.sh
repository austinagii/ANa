#!/bin/bash

USAGE_MSG=$(cat <<-END

Usage: gibber build <component>

Builds a docker container with the current version of the component

Available components:
    api     The gibber REST API
    ui      The gibber web UI
END
)

if [ $# -eq 0 ]; then
    echo "$USAGE_MSG"
    echo
fi

# TODO: Change the default behavior to prevent building with the same version number
#       unless the --force flag is specified, also... add --force flag
# Consider separating the steps for building and pushing the docker image
case $1 in
    --help|-h)
        echo "$USAGE_MSG"
        echo
        ;;
    api)
        # Define the image tag to be used
        IMAGE_TAG="austinagi/gibber-api:$(cat $API_ROOT_DIR/version)"
        # Build and push a container with the current version of the Gibber API
        docker image build -t $IMAGE_TAG $API_ROOT_DIR && docker image push $IMAGE_TAG
        ;;
    ui)
        # Define the image tag to be used
        IMAGE_TAG="austinagi/gibber-ui:$(jq -r '.version' $UI_ROOT_DIR/package.json)"
        # Build the Gibber UI
        cd $UI_ROOT_DIR && npm run build 
        # Build and push a container with the current version of the Gibber UI
        docker image build --no-cache -t $IMAGE_TAG $UI_ROOT_DIR && docker image push $IMAGE_TAG
        ;;
    *)
        echo "Error: Unrecognized component '$1'"
        echo "See 'gibber build --help' for a list of available components"
        ;;
esac
