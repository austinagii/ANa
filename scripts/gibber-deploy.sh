SCRIPT_DIR=$(dirname $(realpath $0))
RESOURCE_GROUP="GibberResources"
VM_NAME="GibberHost"
VM_STATUS=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query powerState -o tsv)

# if [[ $VM_STATUS != "VM Running" ]]; then
#     exit 0
# else
#     echo "VM is running"
# fi

# the following command assumes that docker is already set up on the VM
# TODO: write a script to automatically provision and install docker on the VM
ssh -i $SCRIPT_DIR/../.env/security/gibber_key.pem austinagi@20.94.79.28 " \
    sudo docker container run -d --name gibber-api -p 8000:8000 --rm austinagi/gibber-api:0.1.1; \
    sudo docker container run -d --name gibber-ui -p 80:80 --rm austinagi/gibber-ui:0.0.2"