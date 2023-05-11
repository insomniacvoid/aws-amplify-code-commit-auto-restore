#!/bin/bash

# Request SSL certificate for domain
request_certificate() {

  # Check if certificate already exists for domain
  certificate_arn=$(aws acm list-certificates --certificate-statuses ISSUED \
    --query "CertificateSummaryList[?DomainName=='$domain_name'].CertificateArn" \
    --include keyTypes=EC_secp384r1 \
    --output text)

  if [ -n "$certificate_arn" ]; then
    echo "$certificate_arn"
  else
    # Request a new public SSL/TLS certificate
    certificate_arn=$(aws acm request-certificate \
      --domain-name "$domain_name" \
      --validation-method DNS \
      --key-algorithm EC_secp384r1 \
      --idempotency-token "$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)" \
      --options CertificateTransparencyLoggingPreference=DISABLED | jq -r '.CertificateArn')
    echo "$certificate_arn"
  fi

}