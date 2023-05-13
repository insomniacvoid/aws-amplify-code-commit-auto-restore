#!/bin/bash

# Define a function to check if a command succeeds or not
check_command() {
  if ! "$@"; then
    echo "Error: Failed to execute command: $*"
    exit 1
  else
    echo "$(echo "$*" | awk '{print $1, $2, $3}' ) : passed error check"
  fi
}