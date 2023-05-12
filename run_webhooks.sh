#!/bin/bash

# Run webhooks
run_webhooks() {
  local branch_name
  local app_id="$1"
  local branch_name="$2"
  local retries=5
  local delay=60

  # Build the specified branch
  until [ $retries -eq 0 ]; do
    output=$(aws amplify start-job \
      --app-id "$app_id" \
      --branch-name "$branch_name" \
      --job-type RELEASE \
      --no-cli-pager 2>&1)

    # Check if the command was successful
    if [ $? -eq 0 ]; then
      echo "$output"
      return 0
    fi

    # If the error was due to limit exceeded, wait and retry
    if echo "$output" | grep -q 'LimitExceededException'; then
      echo "Limit exceeded, retrying in $delay seconds..."
      sleep $delay
      ((retries--))
    else
      echo "$output"
      return 1
    fi
  done

  echo "Failed to start job after multiple attempts."
  return 1
}