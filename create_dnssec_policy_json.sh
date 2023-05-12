#!/bin/bash

# Create an amplify.yml file in the project directory if it doesn't exist
create_dnssec_policy_json() {
  local principal_arn
  local service_dns
  local source_account
  local source_arn
  local dnssec_policy

  principal_arn="arn:aws:iam::YOUR_PRINCIPAL_ID:root"
  service_dns="dnssec-route53.amazonaws.com"
  source_account="YOUR_SRC_ACCOUNT_NUMBER"
  source_arn="arn:aws:route53:::hostedzone/*"

  dnssec_policy=$(
    cat <<EOF
{
  "Version": "2012-10-17",
  "Id": "dnssec-policy",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "$principal_arn"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow Route 53 DNSSEC Service",
      "Effect": "Allow",
      "Principal": {
        "Service": "$service_dns"
      },
      "Action": [
        "kms:DescribeKey",
        "kms:GetPublicKey",
        "kms:Sign"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "$source_account"
        },
        "ArnLike": {
          "aws:SourceArn": "$source_arn"
        }
      }
    },
    {
      "Sid": "Allow Route 53 DNSSEC to CreateGrant",
      "Effect": "Allow",
      "Principal": {
        "Service": "$service_dns"
      },
      "Action": "kms:CreateGrant",
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
EOF
  )

  echo "$dnssec_policy"

}