#!/usr/bin/env bash

# Add the main 'ana' script to the user's path
if which ana >/dev/null; then
    echo "Command 'ana' already exists on PATH at '$(which ana)'"
    while true; do
        echo "Would you like to delete it? [Y/n]"
        read RESPONSE
        case $RESPONSE in
            Y)
                sudo rm -f $(which ana)
                if [ $? -eq 0 ]; then
                    echo "File removed successfully"
                fi
                break
                ;;
            n)
                # Exit with an error code if the exisitng 'command' is not a symlink to the 'ana.sh' script
                if [ $(realpath $(which ana)) != "$(realpath $0)/cli/ana.sh" ]; then
                    echo "The existing 'ana' does not reference the ana script located in the CLI"
                    exit 1
                fi
                ;;
            *)
                echo "Not a valid option"
                ;;
        esac
    done
fi

# create a symlink in the user's bin to the ana command
sudo ln -s $(dirname $(realpath $0))/cli/ana.sh /usr/local/bin/ana