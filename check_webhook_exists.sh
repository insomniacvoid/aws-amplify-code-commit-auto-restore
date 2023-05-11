#!/bin/bash

# Check if a webhook for the given branch already exists
check_webhook_exists() {
  local existing_webhook
  local app_id="$1"
  local branch_name="$2"

  existing_webhook=$(aws amplify list-webhooks \
    --app-id "$app_id" \
    --query "webhooks[?branchName=='$branch_name'].branchName" \
    --output text)
  if [ "$existing_webhook" = "$branch_name" ]; then
    return 0
  else
    return 1
  fi
}