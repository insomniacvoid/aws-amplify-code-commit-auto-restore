#!/bin/bash

# Run webhooks
run_webhooks() {
  local branch_name

  local app_id="$1"
  local branch_name="$2"

  # Build the specified branch
  check_command aws amplify start-job \
    --app-id "$app_id" \
    --branch-name "$branch_name" \
    --job-type RELEASE \
    --no-cli-pager
}