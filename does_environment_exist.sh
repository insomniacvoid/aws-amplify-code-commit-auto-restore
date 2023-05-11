#!/bin/bash

# Check if a environment exists
does_environment_exist() {
  local existing_environment
  local environment_name=$1

  existing_environment=$(aws amplify list-backend-environments \
    --app-id "$app_id" \
    --query "backendEnvironments[?environmentName=='$environment_name'].environmentName" \
    --output text)

  if [ -n "$existing_environment" ]; then
    echo ""
  else
    echo "$existing_environment"
  fi
}