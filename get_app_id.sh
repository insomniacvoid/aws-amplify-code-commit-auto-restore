#!/bin/bash

# Gets the app id of the Amplify project using the project name
get_app_id() {
  local existing_app_id=""

  for app_id in $(aws amplify list-apps \
    --query "apps[?name=='""$name""'].appId" \
    --output text); do
    if [ -z "$existing_app_id" ]; then
      existing_app_id="$app_id"
      break
    fi
  done

  echo "$existing_app_id"
}