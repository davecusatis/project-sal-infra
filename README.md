# Kubernetes cluster setup script

## Prerequisites
* kops
* awscli
* a domain you own
* `kops` iam user with the following permissions
    - AmazonEC2FullAccess
    - AmazonRoute53FullAccess
    - AmazonS3FullAccess
    - IAMFullAccess
    - AmazonVPCFullAccess

## Steps
1. Get the name server records for your parent domain, and copy them into the values in subdomain.json
    ```
    ID=$(uuidgen) && aws route53 create-hosted-zone --name subdomain.example.com --caller-reference $ID \ | jq .DelegationSet.NameServers
    ```
    * Note don't forget to change `subdomain.example.com in the above
2. rename the subdomain you wish to create in subdomain.json
3. change the values of `DOMAIN`, `PREFIX` and `STATE_STORE_BUCKET` in create_cluster.sh to be your values.
