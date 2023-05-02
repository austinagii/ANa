#!/bin/bash

cd $CORE_ROOT_DIR

# TODO: Make the help message produced by this command consistent with other ana help messages
# TODO: Run ANa in non-debug mode by default when executing using this command 
pipenv run python -m core "$@"