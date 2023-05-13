## Quickstart

### This script assumes you have already configured Access Keys/AWS CLI and have the correct libraries installed.

chmod +x aws_setup.sh

./aws_setup.sh

### Rebuilding the project (no automatic code-cleanup)

rm -rf idsystems* ; ./aws_setup.sh

*Where idsystems** *etc. are the old project directories*

## Create DNSSEC policy (no chain of trust)

in *create_dnssec_policy_json.sh* update the following policy fields.
These will likely be the same for your particular user.

principal_arn="arn:aws:iam::YOUR_PRINCIPAL_ID:root"
source_account="YOUR_SRC_ACCOUNT_NUMBER"

principal_arn="arn:aws:iam::222222222222:root"
source_account="222222222222"

### *Reference Links*

#### *Amplify auth headless schema configuration:*

[1] https://docs.amplify.aws/cli/usage/headless/#optional-ide-setup-for-headless-development

[2] https://github.com/aws-amplify/amplify-cli/blob/main/packages/amplify-headless-interface/schemas/auth/2/AddAuthRequest.schema.json

[3] https://github.com/aws-amplify/amplify-cli/blob/main/packages/amplify-headless-interface/src/interface/auth/add.ts

### *Issues*

##### Missing config\local-env-info.json error (requires amplify pull)
[1] https://github.com/aws-amplify/amplify-cli/issues/11245