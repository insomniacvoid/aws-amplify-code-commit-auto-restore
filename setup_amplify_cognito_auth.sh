#!/bin/bash

# Create Auth config for Amplify Auth integration
setup_amplify_cognito_auth() {
  local cognito_id_pool
  local auth_resource_name
  local amplify_auth_config

  cognito_id_pool="${name}_user_pool"
  auth_resource_name="${name}auth"

  amplify_auth_config=$(
    cat <<EOF
{
  "version": 2,
  "resourceName": "$auth_resource_name",
  "serviceConfiguration": {
    "serviceName": "Cognito",
    "includeIdentityPool": false,
    "userPoolConfiguration": {
      "signinMethod": "EMAIL",
      "requiredSignupAttributes": ["EMAIL"],
      "passwordPolicy": {
        "minimumLength": 25,
        "additionalConstraints": [
          "REQUIRE_LOWERCASE",
          "REQUIRE_UPPERCASE",
          "REQUIRE_DIGIT",
          "REQUIRE_SYMBOL"
        ]
      },
      "mfa": {
        "mode": "ON",
        "mfaTypes": ["TOTP"],
        "smsMessage": "Your verification code is {####}"
      },
      "userPoolName": "$cognito_id_pool",
      "autoVerifiedAttributes": [
        {
          "type": "EMAIL",
          "verificationMessage": "Please click the link below to verify your email: {####}",
          "verificationSubject": "Your verification link"
        }
      ]
    }
  }
}
EOF
  )

  echo "$amplify_auth_config" >auth_config.json

  if ! [ -f "./amplify/.config/local-env-info.json" ]; then
    echo "local-env-info.json does not exist. Pulling Amplify environment..."
    amplify pull --yes --env "$env_name"
  fi

  # Wait for auth_config.json to become available before generating auth
  amplify add auth --headless < <(jq -c . auth_config.json)

  # Push auth changes
  amplify push --yes

}