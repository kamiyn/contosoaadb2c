#!/bin/sh
subscriptionId="c354e14c-1404-4331-a739-bd0f1f1dbcc1"
resourceGroupName="rg-contosocirclepay"
baseName="contosocirclepay"
Location="westus2"

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

cval=`az monitor app-insights component create --app $appserviceName --location $Location --kind web -g $resourceGroupName --application-type web | jq -r .connectionString`
az webapp config appsettings set -g $resourceGroupName --name $appserviceName --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=$cval"
