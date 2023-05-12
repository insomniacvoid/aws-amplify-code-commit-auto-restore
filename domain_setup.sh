#!/bin/bash

# Run domain setup
domain_setup() {

setup_dnssec

  # Remove any existing domain associations
  remove_domain_association

  # Wait for the branch to become available
  echo "Waiting for the branch to become available..."
  sleep 30

  # Create the domain association with the root domain and 'dev' subdomain
  echo "Creating new domain association"

  check_command aws amplify create-domain-association \
    --app-id "$app_id" \
    --domain-name "$domain_name" \
    --sub-domain-settings '[{"prefix": "", "branchName": "master"}, {"prefix": "www", "branchName": "master"}, {"prefix": "dev", "branchName": "dev"}]' \
    --no-cli-pager

  # Request a new public SSL/TLS certificate
  certificate_arn=$(request_certificate)

  # Add and verify the CNAME record for domain ownership
  add_and_verify_cname_record "$certificate_arn"
}