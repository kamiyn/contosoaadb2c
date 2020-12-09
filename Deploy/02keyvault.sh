#!/bin/sh
subscriptionId="c354e14c-1404-4331-a739-bd0f1f1dbcc1"
resourceGroupName="rg-contosocirclepay"
baseName="contosocirclepay"

# create name with convention
if [ -z "$AZRANDSUFFIX" ]; then
  echo please set AZRANDSUFFIX environment variable
  echo export AZRANDSUFFIX=abcd
  exit
fi
keyVaultName="kv-$baseName-${AZRANDSUFFIX}"
appserviceName="app-$baseName-${AZRANDSUFFIX}"

# do
az account set --subscription $subscriptionId

# https://docs.microsoft.com/ja-jp/azure/app-service/app-service-key-vault-references
# @Microsoft.KeyVault(SecretUri=https://$(cval))
# $1 : target AppConfig
# $2 : KeyVault Secret Name
# $3 : KeyVault Secret Value
useKeyVault () {
    cname=$1
    cnameKeyVault=$2
    secretval=$3
    cval=`az keyvault secret set --name $cnameKeyVault --vault-name $keyVaultName --value $secretval | jq -r .id`
    az webapp config appsettings set -g $resourceGroupName --name $appserviceName --settings "$cname=@Microsoft.KeyVault(SecretUri=$cval)"
}

# それぞれの値を実行時に変更する
useKeyVault "AzureAdB2C__Instance" "AzureAdB2C-Instance" `jq -r .AzureAdB2C.Instance < secrets.json`
useKeyVault "AzureAdB2C__ClientId" "AzureAdB2C-ClientId" `jq -r .AzureAdB2C.ClientId < secrets.json`
useKeyVault "AzureAdB2C__Domain"   "AzureAdB2C-Domain"   `jq -r .AzureAdB2C.Domain < secrets.json`
