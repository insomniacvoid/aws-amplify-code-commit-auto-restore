#!/bin/bash

# Main setup function
function main() {

  # Source DNS functionality
  source domain_setup.sh

  source request_certificate.sh

  source remove_domain_association.sh

  source add_and_verify_cname_record.sh

  source update_dns_settings.sh

  source get_hosted_zone_id.sh

  # Source core Amplify functionality
  source configure_amplify_deployments.sh

  source create_amplify_yml.sh

  # Source helpers
  source check_command.sh

  source run_webhooks.sh

  source check_webhook_exists.sh

  source get_app_id.sh

  source does_branch_exist.sh

  source does_environment_exist.sh

  source does_react_app_exist.sh

  source create_webhook_if_not_exists.sh

  local repositories

  # Define the repository names and descriptions
  repositories=(
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

  # Loop through the repositories
  for repo_index in "${!repositories[@]}"; do
    local description

    # Extract the repository name and description
    name=$(echo "${repositories[$repo_index]}" | cut -d':' -f1)
    description=$(echo "${repositories[$repo_index]}" | cut -d':' -f2)

    if aws codecommit get-repository --repository-name "$name" >/dev/null 2>&1; then
      echo "Repository '$name' already exists. Skipping creation."
    else
      # Create the repository
      if ! check_command aws codecommit create-repository \
        --repository-name "$name" \
        --repository-description "$description" \
        --region ap-southeast-2 \
        --no-cli-pager; then
        echo "Failed to create repo, exiting"
        exit 1
      fi
    fi

    # Clone the repository
    check_command git clone ssh://git-codecommit.${region}.amazonaws.com/v1/repos/"$name"

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

    # Go back to the parent directory
    cd ..

  done

}

main "$@"