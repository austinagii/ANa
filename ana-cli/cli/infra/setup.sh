#!/bin/sh

load_feature_flags

USAGE_MSG=$(cat <<-END

Usage: ana infra setup [options]

Provision the Azure infrastructure required to run ANa
		
Options:
  -h, --help      Show this message
  -l, --login     Request login with Azure CLI even if already logged in. Note that this may be required
                  if you are not logged in with an id that allows you to create or manage resource groups
                  and service principals
  -s, --skip      Do not create resources if they already exist. Note that if these resources are not
                  configured properly specifying this option can lead to undefined behavior
END
)

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
LOGIN=1
SKIP_CREATED=1

while true; do
    case $1 in
        -h|--help)
            echo "$USAGE_MSG" 
            exit 0
            ;;
        -l|--login)
            LOGIN=0
            shift 1
            ;;
        -s|--skip)
            SKIP_CREATED=0
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

# Load the infrastructure config
source $INFRA_CONFIG_ROOT_DIR/azure.config

# Only login if not already logged in or --login flag is specified 
IS_ACCOUNT_LOGGED_IN=$(az account show &>/dev/null; echo $?)
if [ $IS_ACCOUNT_LOGGED_IN -ne 0 ] || [ $LOGIN -eq 0 ]; then
    az login &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to authenticate"
        exit 1
    fi
    echo "Authenticated successfully."
else
    echo "User already logged in."
fi
# Create the management group if it does not already exist.
echo "Checking for management group '$MANAGEMENT_GROUP_NAME'."
MANAGEMENT_GROUPS_EXISTS=$([ -n $(az account management-group list --query "[?name=='$MANAGEMENT_GROUP_NAME'].id" -o tsv) ]; echo $?)
if [ $MANAGEMENT_GROUPS_EXISTS -ne 0 ]; then
  echo "Management group '$MANAGEMENT_GROUP_NAME' could not be found. The group will be created."
  az account management-group create --name $MANAGEMENT_GROUPS_NAME &>/dev/null
  if [ $? -eq 0 ]; then
    echo "Management group '$MANAGEMENT_GROUP_NAME' was created successfully."
  else
    echo "Error: Failed to create management group '$MANAGEMENT_GROUP_NAME'."
  fi
else
  echo "Found management group '$MANAGEMENT_GROUP_NAME'." 
fi
exit 0

echo "Checking for resource group '$RESOURCE_GROUP_NAME'."
RESOURCE_GROUP_EXISTS=$([ -n $(az account management-group list --query "[?name=='$MANAGEMENT_GROUP_NAME'].id" -o tsv) ]; echo $?)
if [ $MANAGEMENT_GROUPS_EXISTS -ne 0 ]; then
  echo "Management group '$MANAGEMENT_GROUP_NAME' could not be found. The group will be created."
  az account management-group create --name $MANAGEMENT_GROUPS_NAME &>/dev/null
  if [ $? -eq 0 ]; then
    echo "Management group '$MANAGEMENT_GROUP_NAME' was created successfully."
  else
    echo "Error: Failed to create management group '$MANAGEMENT_GROUP_NAME'."
  fi
else
  echo "Found management group '$MANAGEMENT_GROUP_NAME'." 
fi
exit 0


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
    echo "Error: Resource group '$RESOURCE_GROUP_NAME' already exists." >&2
    echo "Use the '--skip' flag to continue without re-creating the resource group or use 'ana infra destroy' to reset"\
         "the environment." >&2
    exit 1
fi
echo "Creating the resource group '$RESOURCE_GROUP_NAME'"
RESOURCE_GROUP_ID=$(az group create --location $RESOURCE_GROUP_LOCATION --resource-group $RESOURCE_GROUP_NAME -o tsv --query "id")
if [ $? -ne 0 ]; then
    echo "Failed to create the resource group" >&2
    exit 1
fi

# Generate the certs for service principal authentication
# TODO: Ensure cert config exists before attempting to create certs
# Throw an error if the cert files exist and the --skip flag is not specified
if [ -f $CERT_ROOT_DIR/key.pem ] || [ -f $CERT_ROOT_DIR/cert.pem ] || [ -f $CERT_ROOT_DIR/azure.cert.pem ]; then
    if [[ $SKIP_CREATED == false ]]; then
        echo "Error: Certificates have already been generated." >&2
        echo "Use the '--skip' flag to continue without re-creating the certificates or use 'ana infra destroy' to reset"\
             "the environment." >&2
        exit 1
    fi
else
    echo "Generating certs now"
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
fi


# create the service principal
# TODO: Fix broken conditional
SERVICE_PRINCIPAL_NAME="ANaServicePrincipal"
echo "Creating service principal: '$SERVICE_PRINCIPAL_NAME'."
SERVICE_PRINCIPAL_ID=$(az ad sp list --all --query "[?displayName == '$SERVICE_PRINCIPAL_NAME'].id | [0]")
echo "Service Principal ID: '$SERVICE_PRINCIPAL_ID'"
if [ -n "$SERVICE_PRINCIPAL_ID" ]; then
    echo "Not null"
else
    echo "Null"
fi
echo "Should skip created: '$SKIP_CREATED'"

if [ -n "$SERVICE_PRINCIPAL_ID" ]; then
    echo 
    echo "Here"
    if [[ $SKIP_CREATED == 'false' ]]; then
        echo "Error: Service principal '$SERVICE_PRINCIPAL_NAME' already exists." 
        echo "Use the '--skip' flag to continue without re-creating the service principal or use 'ana infra destroy'"\
             "to reset the environment." 
        exit 1
    fi
else
    az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME \
                            --role contributor \
                            --scopes $RESOURCE_GROUP_ID \
                            --cert @$CERT_ROOT_DIR/azure.cert.pem
fi 

VM_ID="$(az vm list --resource-group $RESOURCE_GROUP_NAME --query "[?name=='$VM_NAME'].id" -o tsv)"
if [ -z $VM_ID ]; then 
  # Create the VM.
fi



