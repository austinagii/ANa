#!/usr/bin/env sh

CMD_SRC_PATH=$(dirname $(realpath $0))/cli/ana.sh
CMD_DEST_PATH=/usr/local/bin/ana

ANA_PATH=$(which ana)
if [ -z "$ANA_PATH" ]; then
  if [ -f $COMMAND_DEST_PATH ]; then
    ANA_PATH=$COMMAND_DEST_PATH
  fi
fi

if [ -n "$ANA_PATH" ]; then 
  if [ "$(realpath "$ANA_PATH")" == "$CMD_SRC_PATH" ]; then
    # Do nothing if the 'ana' command already exists on the executable path and is linked to the main ANa CLI script.
    echo "Command 'ana' already exists and is linked correctly"
    exit 0
  else 
    # Prompt the user to remove the existing 'ana' command.
    echo "Error: Conflicting command 'ana' already exists on PATH at '$ANA_PATH'"
    exit 1
  fi
fi

sudo -n ln -s $CMD_SRC_PATH $CMD_DEST_PATH &>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: Could not create and link the 'ana' command. Ensure that you are executing this script with 'sudo'" >&2
    exit 1
fi
echo "Command 'ana' linked successfully"
