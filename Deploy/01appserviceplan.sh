#!/bin/sh
subscriptionId="c354e14c-1404-4331-a739-bd0f1f1dbcc1"
resourceGroupName="rg-contosocirclepay"
Location="westus2"
baseName="contosocirclepay"

# create name with convention
if [ -z "$AZRANDSUFFIX" ]; then
  echo please set AZRANDSUFFIX environment variable
  echo export AZRANDSUFFIX=abcd
  exit
fi
keyVaultName="kv-$baseName-${AZRANDSUFFIX}"
keyVaultGroup=$resourceGroupName
appservicePlanName="plan-$baseName-${AZRANDSUFFIX}"
appserviceName="app-$baseName-${AZRANDSUFFIX}"
applicationInsightsName="appi-$baseName-${AZRANDSUFFIX}"

# do
az account set --subscription $subscriptionId
az configure --defaults group=$resourceGroupName location=$Location

az keyvault create --location $Location --name $keyVaultName --resource-group $resourceGroupName

az appservice plan create --location $Location -g $resourceGroupName -n $appservicePlanName --sku P1V3
az webapp create -g $resourceGroupName -p $appservicePlanName -n $appserviceName

az webapp update --name $appserviceName \
                 --client-affinity-enabled false \
                 --https-only true \
                 --verbose

az webapp config set --name $appserviceName \
                     --always-on true \
                     --auto-heal-enabled true \
                     --ftps-state Disabled \
                     --http20-enabled true \
                     --min-tls-version 1.2 \
                     --net-framework-version 'v4.0'\
                     --php-version '' \
                     --python-version '' \
                     --remote-debugging-enabled false \
                     --use-32bit-worker-process true \
                     --web-sockets-enabled false \
                     --verbose

az webapp config appsettings set --name $appserviceName --settings @appsettings.json

# keyvault
principalId=`az webapp identity assign --name $appserviceName --resource-group $resourceGroupName -o tsv --query principalId`
az keyvault set-policy --name $keyVaultName --resource-group $keyVaultGroup \
                       --object-id $principalId \
                       --secret-permissions Get List \
                       --verbose
