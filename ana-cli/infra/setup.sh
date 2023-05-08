#!/bin/sh


USAGE_MSG=$(cat <<-END

Usage: ana infra setup [options] <command>

Provision the Azure infrastructure required to run ANa

Options:
    -h, --help      Show this message
    -m, --mode      How the infrastructure should be set up. Valid modes are:
                    - default:  Create a resource group each for dev and non dev containing their respective resources
                    - shared:   Create a single resource group with both dev and non dev resources
                    - unified:  Create a single resource group with no distinction between dev and non dev resources
    -l, --login     Request login with Azure CLI even if already logged in
                    Note that this may be required if you are not logged in with an id that allows you to create or manage 
                    resource group and service principals

END
)

exitWithMessageIfNoArgs $@ "$USAGE_MSG"

PARSED_ARGS=$(getopt -o hm:fl -l help,mode:,force,login -- "$@")
eval set -- "$PARSED_ARGS"

# intialize variable to defaults
DEPLOYMENT=default
FORCE=false
LOGIN=false

while true; do
    case $1 in
        -h|--help)
            echo "$USAGE_MSG"
            exit 0
            ;;
        -m|--mode)
            DEPLOYMENT_MODE=$2
            shift 2
            ;;
        # TODO: Remove force option
        -f|--force)
            FORCE=true
            shift 1
            ;;
        -l|--login)
            LOGIN=true
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

# move CONFIG_DIR variable to main .anarc file since it will be useful for other commands
CONFIG_DIR=$ROOT_DIR/config
# move following variables to infra command to avoid duplication in setup and destroy scripts
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

# Use the authenticated user account create the resource groups and service principals for those groups
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

# Create the resource group
# Check if resource group already exists
RESOURCE_GROUP_ID=$(az group list -o tsv --query "[?name == '$RESOURCE_GROUP_NAME'].id | [0]")                 
if [ -n "$RESOURCE_GROUP_ID" ]; then
    echo "Resource group already exists. Use either the --force option to ignore this or use 'ana infra destroy' to reset the environment."
    exit 1
fi
# Create the resource group if it does not exist
echo "Creating the resource group '$RESOURCE_GROUP_NAME'"
RESOURCE_GROUP_ID=$(az group create --location $RESOURCE_GROUP_LOCATION --resource-group $RESOURCE_GROUP_NAME -o tsv --query "id")
if [ $? -ne 0 ]; then
    echo "Failed to create the resource group"
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