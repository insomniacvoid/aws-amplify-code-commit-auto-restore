#!/bin/bash

# Create a webhook if it doesn't exist
create_webhook_if_not_exists() {
  local app_id="$1"
  local branch_name="$2"
  local description="$3"

  if ! check_webhook_exists "$app_id" "$branch_name"; then
    check_command aws amplify create-webhook \
      --app-id "$app_id" \
      --branch-name "$branch_name" \
      --description "$description"
  else
    echo "Webhook for branch '$branch_name' already exists. Skipping creation."
  fi
}