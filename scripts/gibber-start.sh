#!/bin/bash

if [[ $VM_STATUS = "VM Stopped" ]] || [[ $VM_STATUS == "VM Deallocated" ]]; then
    echo "Starting VM..."
    az vm start -g $RESOURCE_GROUP -n $VM_NAME
fi