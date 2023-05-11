#!/bin/bash

# Create an amplify.yml file in the project directory if it doesn't exist
create_amplify_yml() {
  if [ -f "amplify.yml" ]; then
    echo "amplify.yml file already exists."
  else
    echo "Creating amplify.yml file."
    cat << EOL > amplify.yml
version: 1
backend:
  phases:
    build:
      commands:
        - '# Execute Amplify CLI with the helper script'
        - amplifyPush --simple
frontend:
  phases:
    preBuild:
      commands:
        - npm install --package-lock-only
        - npm ci
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: build
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
EOL
    git add amplify.yml
    git commit -m "Add amplify.yml file"
  fi
}