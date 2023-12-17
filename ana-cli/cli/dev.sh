#!/usr/env/bin sh

USAGE_MSG=$(cat <<-END

Usage: ana dev [options] <component>

Start a devcontainer for a given component 

Available components:
    core    The ANa language model

Options:
    -r, --rebuild           Show this message
    -h, --help              Show this message
END
)
exitWithMessageIfNoArgs $@ "$USAGE_MSG"

# Validate the command line arguments.
PARSED_ARGS=$(getopt -o rh -l rebuild,help --name dev -- "$@")
if [ $? -gt 0 ]; then
    echo "See 'ana dev --help' for a list of valid options"
    exit 1
fi 

# Create variables to store the argument values.
COMPONENT=""
SHOULD_REBUILD=1

# Parse the command line arguments and store them in their associated variables.
eval set -- "$PARSED_ARGS"
while true; do
    case $1 in
        --help|-h)
          echo "$USAGE_MSG"
          exit 0
          ;;
        -r|--rebuild)
          SHOULD_REBUILD=0
          shift 1
          ;;
        --)
          COMPONENT=$2
          break
          ;;
    esac
done 

# Exit with an error if an invalid component is specified.
isValidComponent $COMPONENT || {
    echo "Invalid component '$COMPONENT'"
    echo "see 'ana build --help'"
    exit 1
}

IMAGE_NAME=$USERNAME/$PROJECT_NAME-$COMPONENT-devcontainer
CONTAINER_NAME=$PROJECT_NAME-$COMPONENT-devcontainer

IMAGE_EXISTS=$(docker image inspect $IMAGE_NAME >/dev/null 2>&1; echo $?)

# TODO: Log any failures in this script to a file.
if [ $IMAGE_EXISTS -eq 0 ] && [ $SHOULD_REBUILD -eq 0 ]; then 
  docker container rm $CONTAINER_NAME >/dev/null 2>&1
  docker image rm $IMAGE_NAME >/dev/null 2>&1
  IMAGE_EXISTS=1
fi

if [ $IMAGE_EXISTS -eq 1 ]; then
  docker build \
    -t $USERNAME/$PROJECT_NAME-$COMPONENT-devcontainer:latest \
    --file $CORE_ROOT_DIR/dev.dockerfile $CORE_ROOT_DIR 
fi

# TODO: Check if the container is already running.
if docker container inspect $CONTAINER_NAME >/dev/null 2>&1; then 
  docker container attach $CONTAINER_NAME
else 
  docker container run -it --rm \
    --name $PROJECT_NAME-$COMPONENT-devcontainer \
    --mount type=bind,src=$CORE_ROOT_DIR,dst=/$PROJECT_NAME-$COMPONENT \
    $IMAGE_NAME
fi
