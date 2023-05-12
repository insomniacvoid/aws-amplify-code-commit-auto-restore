
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