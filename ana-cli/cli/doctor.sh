#!/usr/bin/env bash

LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

JQ_IS_INSTALLED=false
AZ_IS_INSTALLED=false

echo "ANa Doctor"

# Check whether the azure client is installed
if which jq >/dev/null; then
    echo -e "   $GREEN[\xE2\x9C\x94]$NC JQ JSON Processor"
    JQ_IS_INSTALLED=true
else
    echo -e "   $RED[\xE2\x9C\x97]$NC JQ JSON Processor"
fi

# Check whether the azure client is installed
if which az >/dev/null; then
    AZ_IS_INSTALLED=true
    echo -e "   $GREEN[\xE2\x9C\x94]$NC Azure CLI"
else
    echo -e "   $RED[\xE2\x9C\x97]$NC Azure CLI"
fi

# Exit with a successful status if all required tooling is installed
if $JQ_IS_INSTALLED && $AZ_IS_INSTALLED; then
    exit 0
else
    exit 1
fi