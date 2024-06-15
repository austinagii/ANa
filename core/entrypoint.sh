#!/usr/bin/env bash 

cmd="pipenv shell"

if [ $# -gt 1 ]; then 
  cmd="$@"
fi

pipenv sync && $cmd
