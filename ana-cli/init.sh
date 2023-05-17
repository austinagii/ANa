#!/usr/bin/env bash

# Get the path to the 'ana' command if present on the executable path
ANA_PATH=$(which ana)
ANA_CLI_SCRIPT_PATH=$(dirname $(realpath $0))/cli/ana.sh

if [ -n $ANA_PATH ] && [ "$(realpath "$ANA_PATH")" == "$ANA_CLI_SCRIPT_PATH" ]; then
    # Do nothing if the 'ana' command already exists on the executable path and is linked to the main ANa CLI script.
    echo "Command 'ana' already exists and is linked correctly"
else
    # Prompt the user to remove the existing 'ana' command if it is not linked to the main ANa CLI script.
    if [ -n $ANA_PATH ]; then
        echo "Command 'ana' already exists on PATH at '$ANA_PATH' but is not linked to the main ANa CLI script"
        while true; do
            echo "Would you like to delete the existing command and re-link it? (Y/n)"
            read RESPONSE
            case $RESPONSE in
                Y)
                    rm -f $ANA_PATH &>/dev/null
                    if [ $? -eq 0 ]; then
                        echo "Existing command removed successfully"
                    else
                        echo "Failed to remove the existing command. Ensure that you are executing this script with"\
                                "'sudo'" >/dev/stderr
                        exit 1
                    fi
                    break
                    ;;
                n)
                    exit 1
                    ;;
                *)
                    ;;
            esac
        done
    fi

    # Add the 'ana' command if it does not already exist on the executable path. 
    sudo -n ln -s $ANA_CLI_SCRIPT_PATH /usr/local/bin/ana &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Could not create and link the 'ana' command. Ensure that you are executing this script with"\
                "'sudo'" >/dev/stderr
        exit 1
    fi
fi



