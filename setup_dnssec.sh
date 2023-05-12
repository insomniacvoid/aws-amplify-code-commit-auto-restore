#!/bin/bash

setup_dnssec() {
  local current_date
  local dnssec_status
  local response
  local key_id
  local caller_reference
  local key_arn
  local key_name
  local dnssec_policy
  local hosted_zone_id

  # Get hosted zone ID
  hosted_zone_id=$(get_hosted_zone_id)

  # Check if DNSSEC is already enabled
  dnssec_status=$(aws route53 get-dnssec --hosted-zone-id "$hosted_zone_id" | jq -r '.Status.ServeSignature')

  if [ "$dnssec_status" == "ENABLED" ] || [ "$dnssec_status" == "SIGNING" ]; then
    echo "DNSSEC is already enabled for hosted zone $hosted_zone_id. Skipping DNSSEC setup."
  else

    dnssec_policy=$(create_dnssec_policy_json)

    # Pull DNSSEC policy from json file
    dnssec_policy=$(echo "$dnssec_policy" | jq .)

    # Create a unique caller reference
    caller_reference="${domain_name}_$(date +%s)"

    # Get current date in the format YYMMDDhhmmss
    current_date=$(date +%y%m%d%H%M%S)

    # Generate a unique key name and replace the domain name dots with underscores
    key_name="KSK_${domain_name//./_}"

    # Create a new KMS key with the necessary key spec and usage
    response=$(aws --region us-east-1 kms create-key --description "KMS Key for $domain_name" --key-usage SIGN_VERIFY --customer-master-key-spec ECC_NIST_P256 --policy "$dnssec_policy" --no-paginate)

    key_id=$(echo "$response" | jq -r '.KeyMetadata.KeyId')
    key_arn=$(echo "$response" | jq -r '.KeyMetadata.Arn')

    # Re-use KSK name for key alias
    aws kms create-alias \
      --alias-name alias/"$key_name" \
      --target-key-id "$key_arn"

    # Create a Key Signing Key (KSK) with the new KMS key
    response=$(aws --region us-east-1 route53 create-key-signing-key --hosted-zone-id "$hosted_zone_id" --key-management-service-arn "$key_arn" --name "$key_name" --status ACTIVE --caller-reference "$caller_reference" --no-paginate)

    # Enable DNSSEC for the hosted zone
    aws route53 enable-hosted-zone-dnssec --hosted-zone-id "$hosted_zone_id" --no-paginate

  fi
}