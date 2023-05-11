#!/bin/sh


USAGE_MSG=$(cat <<-END

Usage: ana infra teardown [options]

Deprovision the Azure infrastructure used to run ANa

Options:
    -h, --help      Show this message
    -l, --login     Request login with Azure CLI even if already logged in
                    Note that this may be required if you are not logged in with an id that allows you to create or manage 
                    resource group and service principals

END
)

exitWithMessageIfNoArgs $@ "$USAGE_MSG"

PARSED_ARGS=$(getopt -o hl -l help,login -- "$@")
eval set -- "$PARSED_ARGS"

LOGIN=false
while true; do
    case $1 in
        -h|--help)
            echo "$USAGE_MSG"
            exit 0
            ;;
        -l|--login)
            LOGIN=true
            shift 1
            ;;
        --)
            break
            ;;
        *)
            echo "Unrecognized option '$1'." 
            echo "See 'ana infra teardown --help' for a list of valid options"
            exit 1
            ;;
    esac
done

source $INFRA_CONFIG_ROOT_DIR/azure.config

# Only login if not already logged in or --login flag is specified 
if az account show &> /dev/null && ! $LOGIN; then
    echo "User already logged in"
else
    # TODO: Set timeout on authentication
    az login &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to authenticate"
        exit 1
    fi
    echo "Authenticated successfully."
fi

echo "Switching to subscription '$SUBSCRIPTION_NAME'"
az account set --subscription $SUBSCRIPTION_NAME
if [ $? -ne 0 ]; then
    echo "Could not switch to provided subscription."
    exit 1
fi
echo "Switched to subscription '$SUBSCRIPTION_NAME'"

# create the service principal
# TODO: Move service principal name to config file
SERVICE_PRINCIPAL_ID=$(az ad sp list -o tsv --all --query "[?displayName == 'ANaServicePrincipal'].id | [0]")
if [ $? -eq 0 ] && [ -n "$SERVICE_PRINCIPAL_ID" ]; then
    az ad sp delete --id $SERVICE_PRINCIPAL_ID            
    if [ $? -ne 0 ]; then
        echo "Failed to delete the service principal"
        exit 1
    fi
fi

# Delete any associated certificates
if [ -f $CERT_ROOT_DIR/azure.cert.pem ]; then
    rm $CERT_ROOT_DIR/azure.cert.pem
fi
if [ -f $CERT_ROOT_DIR/cert.pem ]; then
    rm $CERT_ROOT_DIR/cert.pem
fi
if [ -f $CERT_ROOT_DIR/key.pem ]; then
    rm $CERT_ROOT_DIR/key.pem
fi

# Remove the resource group
RESOURCE_GROUP_ID=$(az group list -o tsv --query "[?name == '$RESOURCE_GROUP_NAME'].id | [0]")                 
if [ $? -eq 0 ] && [ -n "$RESOURCE_GROUP_ID" ]; then 
    az group delete -y --resource-group $RESOURCE_GROUP_NAME
    if [ $? -ne 0 ]; then
        echo "Failed to delete the resource group"
        exit 1
    fi
fi