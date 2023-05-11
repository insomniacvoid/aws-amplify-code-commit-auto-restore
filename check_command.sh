#!/bin/bash

# Define a function to check if a command succeeds or not
check_command() {
  if ! "$@"; then
    echo "Error: Failed to execute command: $*"
    exit 1
  fi
}