#!/bin/bash

# Setup CNAME record validation
add_and_verify_cname_record() {
  local propagation_check_count
  local propagation_check_limit
  local validation_record
  local cname_name
  local cname_value
  local existing_cname

  certificate_arn="$1"

  while [ -z "$validation_record" ] || [ "$validation_record" = "null" ]; do
    aws acm describe-certificate \
      --certificate-arn "$certificate_arn" \
      --output json >output.json
    validation_record=$(jq '.Certificate.DomainValidationOptions[0].ResourceRecord' output.json)
    echo "Waiting for ResourceRecord to be available..."
    sleep 10
  done

  cname_name=$(echo "$validation_record" | jq -r '.Name')
  cname_value=$(echo "$validation_record" | jq -r '.Value')

  # Get the hosted zone ID
  hosted_zone_id=$(get_hosted_zone_id)

  echo "Adding CNAME record to Route 53"

  # Add or update the CNAME record in Route 53
  aws route53 change-resource-record-sets \
    --hosted-zone-id "$hosted_zone_id" \
    --change-batch '{
      "Changes": [
        {
          "Action": "UPSERT",
          "ResourceRecordSet": {
            "Name": "'"$cname_name"'",
            "Type": "CNAME",
            "TTL": 300,
            "ResourceRecords": [
              {
                "Value": "'"$cname_value"'"
              }
            ]
          }
        }
      ]
    }'

  # Wait for the DNS change to propagate
  echo "Waiting for DNS change to propagate..."

  propagation_check_count=0
  propagation_check_limit=6

  while [ "$existing_cname" != "$cname_value" ] && [ $propagation_check_count -lt $propagation_check_limit ]; do
    sleep 10
    # Verify that the CNAME record exists in Route 53
    existing_cname=$(aws route53 list-resource-record-sets \
      --hosted-zone-id "$hosted_zone_id" \
      --query "ResourceRecordSets[?Name=='$cname_name'].ResourceRecords[0].Value" \
      --output text)

    ((propagation_check_count++))
  done

  if [ "$existing_cname" = "$cname_value" ]; then
    echo "CNAME record successfully added and verified."
  else
    echo "Error: CNAME record not found or incorrect value after waiting for propagation. Please check the record in Route 53 and try again."
    exit 1
  fi
}