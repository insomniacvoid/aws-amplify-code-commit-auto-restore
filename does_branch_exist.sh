#!/bin/bash

# Check if the specified branches exist
does_branch_exist() {
  local branch_name
  local existing_branches
  local existing_branch
  local branch_names

  branch_names=("$@")
  existing_branches=""

  for branch_name in "${branch_names[@]}"; do
    existing_branch=$(aws amplify list-branches \
      --app-id "$app_id" \
      --query "branches[?branchName=='$branch_name'].branchName" \
      --output text)

    if [ -n "$existing_branch" ]; then
      existing_branches="${existing_branches}${existing_branch} "
    fi
  done

  echo "${existing_branches}"
}