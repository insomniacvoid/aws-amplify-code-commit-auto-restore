#!/bin/bash

amplify_setup_headless_auth() {
  local config="$1"
  echo "$config"
amplify add auth --headless --configure < "$config"
}