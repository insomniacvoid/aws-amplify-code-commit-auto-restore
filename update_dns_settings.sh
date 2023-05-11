#!/bin/bash

# Retrieves DNS settings
update_dns_settings() {
  local dns_records

  # Get the DNS records from the created domain association
  dns_records=$(aws amplify get-domain-association \
    --app-id "$app_id" \
    --domain-name "$domain_name" \
    --query 'domainAssociation.domainAssociationRecords' \
    --output json)

  # Print the DNS records and instruct the user to update their DNS settings
  echo "Update the DNS settings for domain '$domain_name' with the following records:"
  echo "$dns_records"
  echo "Please note that DNS changes may take some time to propagate."
}