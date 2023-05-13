#!/bin/bash

# Configure the Amplify project for automatic deployments
function configure_amplify_deployments() {
  local app_id
  local domain_name
  local user_choice
  local env_name
  local amplify_service_role_arn='arn:aws:iam::774519591432:role/amplifyconsole-backend-role'

  # Get the domain name for the current repository
  domain_name="${domain_associations[$repo_index]}"

  # Check if the Amplify app exists
  app_id=$(get_app_id)

  # Generate a unique environment name conforming to the 10 char lowercase limit imposed by Amplify
  env_name=$(uuidgen | tr -dc 'a-z' | fold -w 9 | head -n 1)

  if [[ -z "$app_id" ]]; then
    # Initialize existing Amplify app
    amplify init --yes --envName "$env_name"

    echo "Amplify app '$name' finished initializing."

    # Get the new app ID after initializing
    app_id=$(get_app_id)

    # Stage and commit the changes
    check_command git add .
    check_command git commit -m "Automated setup (React/Amplify) commit"

    # Push the changes to the CodeCommit repository
    check_command git push origin master

    # Create and checkout 'dev' branch
    check_command git checkout -b dev

    # Push 'dev' branch to the repository
    check_command git push -u origin dev

    # Update Amplify app
    check_command aws amplify update-app --app-id "$app_id" \
      --name "$name" \
      --iam-service-role-arn "$amplify_service_role_arn" \
      --repository "https://git-codecommit.${region}.amazonaws.com/v1/repos/${name}" \
      --build-spec file://amplify.yml \
      --environment-variables '{"_LIVE_UPDATES": "[{\"name\":\"Amplify CLI\",\"pkg\":\"@aws-amplify/cli\",\"type\":\"npm\",\"version\":\"latest\"}]"}' \
      --no-cli-pager

    # Pull to sync updates
    if ! [ -f "./amplify/.config/local-env-info.json" ]; then
      echo "local-env-info.json does not exist. Pulling Amplify environment..."
      amplify pull --appId "$app_id" --envName "$env_name" --yes
    fi

    echo "Amplify app '$name' updated."
  fi

  # Check if the specified branches exist
  existing_branches=$(does_branch_exist "$app_id" "master" "dev")

  # Connect the branch
  if [[ $existing_branches == *"master"* ]]; then
    echo "Branch 'master' already exists in app '$name'. Skipping branch creation."
  else
    check_command aws amplify create-branch \
      --app-id "$app_id" \
      --branch-name master \
      --enable-auto-build \
      --framework 'React - Amplify' \
      --stage PRODUCTION \
      --enable-performance-mode \
      --no-cli-pager
  fi

  if [[ $existing_branches == *"dev"* ]]; then
    echo "Branch 'dev' already exists in app '$name'. Skipping branch creation."
  else
    check_command aws amplify create-branch \
      --app-id "$app_id" \
      --branch-name dev \
      --enable-auto-build \
      --framework 'React - Amplify' \
      --stage DEVELOPMENT \
      --enable-performance-mode \
      --no-cli-pager
  fi

  # Add a backend environment
  if does_environment_exist "$env_name"; then
    echo "Environment '$env_name' already exists in app '$name'. Skipping environment creation."
  else
    check_command aws amplify create-backend-environment \
      --app-id "$app_id" \
      --environment-name "$env_name"
  fi

  echo "Would you like to configure DNS for $name? Y/n"
  read -r user_choice

  if [[ "$user_choice" == "yes" || "$user_choice" == "y" || "$user_choice" == "Y" ]]; then
    # Run domain setup
    domain_setup
  else
    echo "Skipping DNS setup for $name."
  fi

  echo "Would you like to create webhooks for $name? Y/n"
  read -r user_choice

  if [[ "$user_choice" == "yes" || "$user_choice" == "y" || "$user_choice" == "Y" ]]; then
    # Run webhook setup
    create_webhook_if_not_exists "$app_id" "master" "build-master"
    create_webhook_if_not_exists "$app_id" "dev" "build-dev"

    # Trigger build
    run_webhooks "$app_id" "master"
    run_webhooks "$app_id" "dev"

  else
    echo "Skipping webhook setup for $name."
  fi

  # Push the changes to the CodeCommit repository
  check_command git push origin master
}