#!/bin/sh


USAGE_MSG=$(cat <<-END

Usage: ana infra [options] <command>

Manage the deployment infrastructure of ANa

Options:
    -h, --help      Show this message
    -m, --mode      How the infrastructure should be set up. Valid modes are:
                    - default:  Create a resource group each for dev and non dev containing their respective resources
                    - shared:   Create a single resource group with both dev and non dev resources
                    - unified:  Create a single resource group with no distinction between dev and non dev resources
    -l, --login     Request login with Azure CLI even if already logged in
                    Note that this may be required if you are not logged in with an id that allows you to create or manage 
                    resource group and service principals
 
Commands:
    provision       Provision the ANa deployment infrastructure in Azure
                    Example: ana infra provision
    destroy         Coming soon...
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
            echo "Unrecognized option '$1'. See 'ana infra --help' for a list of valid options"
            exit 1
            ;;
    esac
done

# This script will then:
# 1. Create a service principal responsible for managing that subscription
# 2. Create the necessary resource groups (use the --dev-only flag to only create the dev resource group)

# Load the infra configuration
source $CLI_ROOT_DIR/infra/.env

# Only login if not already logged in or re-authentication is required
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

# using the authenticated user account create the resource groups and service principals for those groups
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
            -config $CLI_ROOT_DIR/infra/certs.cfg \
            -keyout $CLI_ROOT_DIR/infra/certs/key.pem \
            -out $CLI_ROOT_DIR/infra/certs/cert.pem &>/dev/null

if [ $? -eq 0 ]; then
    echo "Certificate generated successfully"
else
    # TODO: Add --debug flag 
    echo "An error occurred while generating the certificate. Enable --debug for more detail."
    # clean up any files that may have been created
fi

# create the pem file for use with azure
cat $CLI_ROOT_DIR/infra/certs/key.pem > $CLI_ROOT_DIR/infra/certs/azure.cert.pem 
cat $CLI_ROOT_DIR/infra/certs/cert.pem >> $CLI_ROOT_DIR/infra/certs/azure.cert.pem 

# create the service principal
az ad sp create-for-rbac --name ANaServicePrincipal \
                         --role contributor \
                         --scopes $RESOURCE_GROUP_ID \
                         --cert @$CLI_ROOT_DIR/infra/certs/azure.cert.pem