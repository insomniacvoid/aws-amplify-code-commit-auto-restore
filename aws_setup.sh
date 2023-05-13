#!/bin/bash

# Main setup function
function main() {

  # Source DNS functionality
  source domain_setup.sh
  source create_dnssec_policy_json.sh
  source setup_dnssec.sh
  source request_certificate.sh
  source remove_domain_association.sh
  source add_and_verify_cname_record.sh
  source update_dns_settings.sh
  source get_hosted_zone_id.sh

  # Source core Amplify functionality
  source configure_amplify_deployments.sh
  source create_amplify_yml.sh
  source setup_amplify_cognito_auth.sh
  source amplify_setup_headless_auth.sh

  # Source helpers
  source check_command.sh
  source run_webhooks.sh
  source check_webhook_exists.sh
  source get_app_id.sh
  source does_branch_exist.sh
  source does_environment_exist.sh
  source does_react_app_exist.sh
  source create_webhook_if_not_exists.sh

  local description

  # Define the repository names and descriptions
  local repositories=(
    'idsystemsmarketing:Marketing repository'
    'idsystemsdocs:Documentation repository'
  )

  domain_associations=(
    'idsystemsdirectmarketing.com'
    'idsystemsdocs.link'
  )

  region='ap-southeast-2'

  # Ensure that there are equal numbers of repositories and domain associations
  if [ ${#repositories[@]} -ne ${#domain_associations[@]} ]; then
    echo "Error: The number of repositories and domain associations must be the same."
    exit 1
  fi

  # Present a menu to the user to select which apps they want to build
  echo "Please select the apps you want to build (select 'All' to build all apps):"
  select name_description in "${repositories[@]}" "All"; do
    # Stop if the user doesn't select a valid option
    [[ -n $name_description ]] || {
      echo "Invalid selection. Please try again."
      continue
    }

    if [ "$name_description" == "All" ]; then
      for repo_index in "${!repositories[@]}"; do
        name=$(echo "${repositories[$repo_index]}" | cut -d':' -f1)
        description=$(echo "${repositories[$repo_index]}" | cut -d':' -f2)
        build_app "$name" "$description" "$region"
      done
      break
    else
      # Extract the repository name and description
      name=$(echo "$name_description" | cut -d':' -f1)
      description=$(echo "$name_description" | cut -d':' -f2)

      # Now call your app build function for the selected app
      build_app "$name" "$description" "$region"
      break
    fi
  done
}

function build_app() {
  local name=$1
  local description=$2
  local region=$3

  if aws codecommit get-repository --repository-name "$name"; then
    echo "Repository '$name' already exists. Skipping creation."
  else
    # Create the repository
    if ! check_command aws codecommit create-repository \
      --repository-name "$name" \
      --repository-description "$description" \
      --region "$region" \
      --no-cli-pager; then
      echo "Failed to create repo, exiting"
      exit 1
    fi
  fi

  # Clone the repository
  check_command git clone ssh://git-codecommit."${region}".amazonaws.com/v1/repos/"$name"

  # Change directory to the CodeCommit repository
  cd "$name" || {
    echo "Error: Failed to change directory to '$name'"
    exit 1
  }

  # Check whether a React app already exists
  if does_react_app_exist; then
    echo "React app already exists in directory '$name'. Skipping creation."
  else
    # Create a new React app
    check_command npx create-react-app .

    # Create build script if needed
    create_amplify_yml
  fi

  # Configure Amplify deployments
  configure_amplify_deployments

  # Build cognito auth configuration & integrate with Amplify
  setup_amplify_cognito_auth

  # Go back to the parent directory
  cd ..

}

main "$@"