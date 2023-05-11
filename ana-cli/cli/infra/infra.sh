#!/bin/sh


USAGE_MSG=$(cat <<-END

Usage: ana infra [options] <command>

Manage the deployment infrastructure of ANa

Options:
    -h, --help      Show this message
 
Commands:
    setup       Provision the ANa infrastructure
                Example: ana infra setup

    teardown    Deprovision the ANa infrastructure
                Example: ana infra teardown
END
)

exitWithMessageIfNoArgs $@ "$USAGE_MSG"

# Load the infra configuration
export CONFIG_DIR=$ROOT_DIR/config
export INFRA_CONFIG_ROOT_DIR=$CONFIG_DIR/infrastructure
export SECURITY_CONFIG_ROOT_DIR=$CONFIG_DIR/security
export CERT_ROOT_DIR=$SECURITY_CONFIG_ROOT_DIR/certs

source $INFRA_CONFIG_ROOT_DIR/azure.config

PARSED_ARGS=$(getopt -o h -l help -- "$@")
eval set -- "$PARSED_ARGS"

while true; do
    case $1 in
        -h|--help)
            echo "$USAGE_MSG"
            exit 0
            ;;
        --)
            COMMAND=$2
            break
            ;;
        *)
            echo "Unrecognized option '$1'. See 'ana infra --help' for a list of valid options"
            exit 1
            ;;
    esac
done

case $COMMAND in
    setup)
        bash $SCRIPT_DIR/infra/setup.sh "$@"
        ;;
    teardown)
        bash $SCRIPT_DIR/infra/teardown.sh "$@"
        ;;
    *)
        echo "Unrecognized command '$COMMAND'. See 'ana infra --help' for a list of valid commands"
esac 