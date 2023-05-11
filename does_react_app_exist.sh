#!/bin/bash

# Check if React app is already setup
does_react_app_exist() {
  if [ -f package.json ] && grep -q '"react-scripts":' package.json; then
    return 0
  else
    return 1
  fi
}