#!/bin/bash

# Removes Amplify associated domain
remove_domain_association() {

  # Check if the domain association exists
  if aws amplify get-domain-association \
    --app-id "$app_id" \
    --domain-name "$domain_name" \
    --no-cli-pager \
    >/dev/null 2>&1; then

    echo "Removing domain association for '$domain_name' from app '$app_id'"

    aws amplify delete-domain-association \
      --app-id "$app_id" \
      --domain-name "$domain_name" \
      --no-cli-pager

    echo "Finished removing old domain association"
  else
    echo "Domain association for '$domain_name' not found in app '$app_id'"
  fi
}