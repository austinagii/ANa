#!/bin/sh

load_feature_flags

# TODO: Find a cleaner way to do this, minimizing the number of times the echo command is used
#       This will be painful if we want to toggle writing to standard error instead of standard out
function show_usage() {
    echo 
    echo "Usage: ana infra setup [options]"
    echo 
    echo "Provision the Azure infrastructure required to run ANa"
    echo 
    echo "Options:"
    echo "    -h, --help      Show this message"
    echo "    -l, --login     Request login with Azure CLI even if already logged in. Note that this may be required"
    echo "                    if you are not logged in with an id that allows you to create or manage resource groups"
    echo "                    and service principals"
    if [[ $FEATURE_INFRA_SKIP_CREATED == true ]]; then
    echo "    -s, --skip      Do not create resources if they already exist. Note that if these resources are not"
    echo "                    configured properly specifying this option can lead to undefined behavior"
    fi
    echo

}

# Parse the command line options
SHORT_OPTIONS=hl
LONG_OPTIONS=help,login
if [[ $FEATURE_INFRA_SKIP_CREATED == true ]]; then
    SHORT_OPTIONS="$SHORT_OPTIONS""s"
    LONG_OPTIONS="$LONG_OPTIONS"",skip"
fi
# TODO: Do not use getopt error message
PARSED_ARGS=$(getopt -n "setup" -o $SHORT_OPTIONS -l $LONG_OPTIONS -- "$@")
eval set -- "$PARSED_ARGS"

# intialize option variables to default values
LOGIN=false
if [[ $FEATURE_INFRA_SKIP_CREATED == true ]]; then
    SKIP_CREATED=false
fi

while true; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -l|--login)
            LOGIN=true
            shift 1
            ;;
        -s|--skip)
            SKIP_CREATED=true
            shift 1
            ;;
        --)
            COMMAND=$2
            break
            ;;
        *)
            echo "Unrecognized option '$1'. See 'ana infra setup --help' for a list of valid options"
            exit 1
            ;;
    esac
done

# TODO: Move CONFIG_DIR variable to main .anarc file since it will be useful for other commands
CONFIG_DIR=$ROOT_DIR/config
# TODO: Move following variables to infra command to avoid duplication in setup and destroy scripts
INFRA_CONFIG_ROOT_DIR=$CONFIG_DIR/infrastructure
SECURITY_CONFIG_ROOT_DIR=$CONFIG_DIR/security
CERT_ROOT_DIR=$SECURITY_CONFIG_ROOT_DIR/certs

# Load the infrastructure config
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

# Use the authenticated user account to create the resource groups and service principals for those groups
SUBSCRIPTION_ID=$(az account list --query "[?name == '$SUBSCRIPTION_NAME'].id" | jq -r '.[0]')
if [ -z SUBSCRIPTION_ID ]; then 
    echo "Could not find subscription"
    exit 1;
fi
echo "Found subscription '$SUBSCRIPTION_NAME.'"

az account set --subscription $SUBSCRIPTION_ID
if [ $? -ne 0 ]; then
    echo "Could not switch to provided subscription."
    exit 1
fi
echo "Switched to subscription '$SUBSCRIPTION_NAME'"

# Create the resource group if one does not already exist
RESOURCE_GROUP_ID=$(az group list -o tsv --query "[?name == '$RESOURCE_GROUP_NAME'].id | [0]")                 
# Exit with an error if we are not skipping created resources
if [ -n "$RESOURCE_GROUP_ID" ] && [[ $SKIP_CREATED == 'false' ]]; then
    echo "Error: resource group '$RESOURCE_GROUP_NAME' already exists." >&2
    echo "Use the --skip flag to ignore this or use 'ana infra destroy' to reset the environment." >&2
    exit 1
fi
echo "Creating the resource group '$RESOURCE_GROUP_NAME'"
RESOURCE_GROUP_ID=$(az group create --location $RESOURCE_GROUP_LOCATION --resource-group $RESOURCE_GROUP_NAME -o tsv --query "id")
if [ $? -ne 0 ]; then
    echo "Failed to create the resource group" >&2
    exit 1
fi

echo "Generating certificate"
openssl req -x509 -new -newkey rsa:2048 -nodes \
            -config $SECURITY_CONFIG_ROOT_DIR/certs.cfg \
            -keyout $CERT_ROOT_DIR/key.pem \
            -out $CERT_ROOT_DIR/cert.pem &>/dev/null

if [ $? -eq 0 ]; then
    echo "Certificate generated successfully"
else
    # TODO: Add --debug flag 
    echo "An error occurred while generating the certificate. Enable --debug for more detail."
    # clean up any files that may have been created
fi

# create the pem file for use with azure
cat $CERT_ROOT_DIR/key.pem > $CERT_ROOT_DIR/azure.cert.pem 
cat $CERT_ROOT_DIR/cert.pem >> $CERT_ROOT_DIR/azure.cert.pem 

# create the service principal
az ad sp create-for-rbac --name ANaServicePrincipal \
                         --role contributor \
                         --scopes $RESOURCE_GROUP_ID \
                         --cert @$CERT_ROOT_DIR/azure.cert.pem