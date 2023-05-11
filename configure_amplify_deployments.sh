#!/bin/bash

# Configure the Amplify project for automatic deployments
function configure_amplify_deployments() {

  local amplify_service_role_arn='arn:aws:iam::774519591432:role/amplifyconsole-backend-role'

  local app_id
  local domain_name

  # Get the domain name for the current repository
  domain_name="${domain_associations[$repo_index]}"

  # Check if the Amplify app exists
  app_id=$(get_app_id)

  if [[ -z "$app_id" ]]; then
    # Initialize existing Amplify app
    amplify init --yes

    echo "Amplify app '$name' finished initializing."

    # Get the new app ID after initializing
    app_id=$(get_app_id)

    # Stage and commit the changes
    check_command git add .
    check_command git commit -m "Initial setup (React/Amplify) commit"

    # Push the changes to the CodeCommit repository
    check_command git push origin master

    # Create and checkout 'dev' branch
    check_command git checkout -b dev

    # Push 'dev' branch to the repository
    check_command git push -u origin dev

    # Update Amplify app
    aws amplify update-app --app-id "$app_id" \
      --name "$name" \
      --iam-service-role-arn "$amplify_service_role_arn" \
      --repository "https://git-codecommit.${region}.amazonaws.com/v1/repos/${name}" \
      --build-spec file://amplify.yml \
      --environment-variables '{"_LIVE_UPDATES": "[{\"name\":\"Amplify CLI\",\"pkg\":\"@aws-amplify/cli\",\"type\":\"npm\",\"version\":\"latest\"}]"}' \
      --no-cli-pager

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
  if does_environment_exist "$app_id" "dev"; then
    echo "Environment 'dev' already exists in app '$name'. Skipping environment creation."
  else
    check_command aws amplify create-backend-environment \
      --app-id "$app_id" \
      --environment-name dev
  fi

  # Run domain setup
  domain_setup

  # Run webhook setup
  create_webhook_if_not_exists "$app_id" "master" "build-master"
  create_webhook_if_not_exists "$app_id" "dev" "build-dev"

  # Trigger build
  run_webhooks "$app_id" "master"
  run_webhooks "$app_id" "dev"

  # Push the changes to the CodeCommit repository
  check_command git push origin master
}