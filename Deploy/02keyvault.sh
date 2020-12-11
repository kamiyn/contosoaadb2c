#!/bin/sh
if [ -z "$AZDEPLOY_SUBSCRIPTIONID" -o  -z "$AZDEPLOY_RESOURCEGROUPNAME" ]; then
  echo please set subscriptionId environment variable
  exit
fi

# after Configure AzureB2C, 
# update variables AzureAdB2C section in secrets.json
# and run this script

# https://docs.microsoft.com/ja-jp/azure/app-service/app-service-key-vault-references
# @Microsoft.KeyVault(SecretUri=https://$(cval))
# $1 : target AppConfig
# $2 : KeyVault Secret Name
# $3 : KeyVault Secret Value
useKeyVault () {
    cname=$1
    cnameKeyVault=$2
    secretval=$3
    cval=`az keyvault secret set --name $cnameKeyVault --vault-name $AZDEPLOY_KEYVAULTNAME --value $secretval --query id -o tsv`
    az webapp config appsettings set -g $AZDEPLOY_RESOURCEGROUPNAME --name $AZDEPLOY_APPSERVICENAME --settings "$cname=@Microsoft.KeyVault(SecretUri=$cval)"
}

# それぞれの値を実行時に変更する
useKeyVault "AzureAdB2C__Instance" "AzureAdB2C-Instance" `jq -r .AzureAdB2C.Instance < secrets.json`
useKeyVault "AzureAdB2C__ClientId" "AzureAdB2C-ClientId" `jq -r .AzureAdB2C.ClientId < secrets.json`
useKeyVault "AzureAdB2C__Domain"   "AzureAdB2C-Domain"   `jq -r .AzureAdB2C.Domain < secrets.json`
