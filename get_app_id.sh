#!/bin/bash

# Gets the app id of the Amplify project using the project name
get_app_id() {
  aws amplify list-apps \
    --query "apps[?name=='""$name""'].appId" \
    --output text | head -n 1
}