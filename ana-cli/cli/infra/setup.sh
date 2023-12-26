#!/bin/sh

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
SHORT_OPTIONS=hls
LONG_OPTIONS=help,login,skip
# TODO: Do not use getopt error message
PARSED_ARGS=$(getopt -n "setup" -o $SHORT_OPTIONS -l $LONG_OPTIONS -- "$@")
eval set -- "$PARSED_ARGS"

# intialize option variables to default values
LOGIN=1

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

# Only login if not already logged in, the current logged in user is not the required user
# or the 'login' flag is specified 
echo "Checking logged in user"
LOGGED_IN_USER=$(az account show --query "user.name" | tr -d \")
if [ $? -ne 0 ] || [ "$LOGGED_IN_USER" != "$USER_NAME" ] || [ $LOGIN == 0 ]; then 
  echo "Authenticating as user '$USER_NAME'"
  az login &>/dev/null
  if [ $? -ne 0 ]; then
      echo "Error: failed to authenticate as user '$USER_NAME'"
      exit 1
  fi
  echo "Authenticated successfully."
else 
  echo "User '$USER_NAME' is logged in"
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

# Ensure the provided subscription exists and add it to the management group.
SUBSCRIPTION_ID=$(az account list --query "[?name == '$SUBSCRIPTION_NAME'].id" -o tsv)
if [ -z $SUBSCRIPTION_ID ]; then 
    echo "Error: Subscription '$SUBSCRIPTION_NAME' could not be found or does not exist" >&2
    echo "Ensure that the subscription has been created before executing this script or run this command with the '--login' option to force a refresh" >&2
    exit 1;
fi


# Does the service principal already exist?


# Generate the certs for service principal authentication
# TODO: Ensure cert config exists before attempting to create certs
# Throw an error if the cert files exist and the --skip flag is not specified
if [ ! -f $CERT_ROOT_DIR/cert.pem ]; then
  rm -f $CERT_ROOT_DIR/*  # Clean up any stray certs to avoid conflicts.

  echo "Generating certs now"
  openssl req -x509 -new -newkey rsa:2048 -nodes \
              -config $SECURITY_CONFIG_ROOT_DIR/certs.cfg \
              -keyout $CERT_ROOT_DIR/key.pem \
              -out $CERT_ROOT_DIR/cert.pem &>/dev/null

  if [ $? -eq 0 ]; then
    echo "Certificates generated successfully"
  else
    # TODO: Add --debug flag.
    echo "An error occurred while generating the certificate. Enable --debug for more detail."
    # TODO: Clean up any files that may have been created.
    exit 1
  fi
else
  echo "Certificates found"
fi


# create the service principal
# TODO: Fix broken conditional
echo "Creating service principal: '$SERVICE_PRINCIPAL_NAME'."
SERVICE_PRINCIPAL_ID=$(az ad sp list --all --query "[?displayName == '$SERVICE_PRINCIPAL_NAME'].id | [0]")

if [ -z "$SERVICE_PRINCIPAL_ID" ]; then
    az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME \
                            --role contributor \
                            --scopes $RESOURCE_GROUP_ID \
                            --cert @$CERT_ROOT_DIR/cert.pem
else
  echo "Service principal '$SERVICE_PRINCIPAL_NAME' already exists." 
fi 

az login 

# Switch to the subscription.
az account set --subscription $SUBSCRIPTION_ID
if [ $? -ne 0 ]; then
    echo "Could not switch to provided subscription."
    exit 1
fi
echo "Switched to subscription '$SUBSCRIPTION_NAME'"

# Create the resource group if one does not already exist
RESOURCE_GROUP_EXISTS=$([ -n $(az group list -o tsv --query "[?name == '$RESOURCE_GROUP_NAME'].id") ]; echo $?)                 
# Exit with an error if we are not skipping created resources
if [ $RESOURCE_GROUP_EXISTS -ne 0 ]; then
  echo "Creating the resource group '$RESOURCE_GROUP_NAME'"
  RESOURCE_GROUP_ID=$(az group create --location $RESOURCE_GROUP_LOCATION --resource-group $RESOURCE_GROUP_NAME -o tsv --query "id")
  if [ $? -ne 0 ]; then
    echo "Failed to create the resource group" >&2
    exit 1
  fi
else
  echo "Found resource group '$RESOURCE_GROUP_NAME'." >&2
fi


# Create the VM.
VM_ID="$(az vm list --resource-group $RESOURCE_GROUP_NAME --query "[?name=='$VM_NAME'].id" -o tsv)"
if [ -z $VM_ID ]; then 
  # capture the output
  az vm create --name "ANa-Dev-VM" --resource-group "senti-lab_group" \
               --image "Ubuntu2204" --size "Standard_NC4as_T4_v3" \
               --security "Standard" --zone 1 --computer-name "ana-dev-vm" \
               --generate-ssh-keys \
               --location "eastus"  --nsg "ANa-NSG" --nsg-rule "SSH" \
               --ssh-key-name "ANa-dev-ssh-keys" \
               --vnet-name "ana-dev-vnet" --subnet "ana-dev-default-subnet" \
               --public-ip-address "ana-dev-ip" --public-ip-address-allocation "dynamic" \
               --public-ip-address-dns-name "ana-dev" --data-disk-sizes-gb 64 \
fi

ssh -o StrictHostKeyChecking=no -i $ssh_key_location $username@$vm_ip_address




