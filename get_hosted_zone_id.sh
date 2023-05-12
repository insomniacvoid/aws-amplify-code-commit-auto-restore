#!/bin/bash

# Handle hosted zone retrieval
get_hosted_zone_id() {
  hosted_zone_id=$(aws route53 list-hosted-zones-by-name \
    --dns-name "$domain_name" \
    --max-items 1 \
    --query 'HostedZones[0].Id' \
    --output text)

  echo "$hosted_zone_id"
}