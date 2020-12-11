#!/bin/sh
if [ -z "$AZDEPLOY_SUBSCRIPTIONID" -o  -z "$AZDEPLOY_RESOURCEGROUPNAME" ]; then
  echo please set subscriptionId environment variable
  exit
fi

az keyvault create --location $AZDEPLOY_LOCATION --name $AZDEPLOY_KEYVAULTNAME --resource-group $AZDEPLOY_RESOURCEGROUPNAME

az appservice plan create --location $AZDEPLOY_LOCATION -g $AZDEPLOY_RESOURCEGROUPNAME -n $AZDEPLOY_APPSERVICEPLANNAME --sku P1V3
az appservice plan update -g $AZDEPLOY_RESOURCEGROUPNAME -n $AZDEPLOY_APPSERVICEPLANNAME --sku S1

az webapp create -g $AZDEPLOY_RESOURCEGROUPNAME -p $AZDEPLOY_APPSERVICEPLANNAME -n $AZDEPLOY_APPSERVICENAME

az webapp update --name $AZDEPLOY_APPSERVICENAME \
                 --client-affinity-enabled false \
                 --https-only true \
                 --verbose

az webapp config set --name $AZDEPLOY_APPSERVICENAME \
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

az webapp config appsettings set --name $AZDEPLOY_APPSERVICENAME --settings @appsettings.json

# keyvault
principalId=`az webapp identity assign --name $AZDEPLOY_APPSERVICENAME --resource-group $AZDEPLOY_RESOURCEGROUPNAME -o tsv --query principalId`
az keyvault set-policy --name $AZDEPLOY_KEYVAULTNAME --resource-group $AZDEPLOY_KEYVAULTGROUP \
                       --object-id $principalId \
                       --secret-permissions Get List \
                       --verbose

cval=`az monitor app-insights component create --app $AZDEPLOY_APPSERVICENAME --location $AZDEPLOY_LOCATION --kind web -g $AZDEPLOY_RESOURCEGROUPNAME --application-type web --query connectionString -o tsv`
az webapp config appsettings set -g $AZDEPLOY_RESOURCEGROUPNAME --name $AZDEPLOY_APPSERVICENAME --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=$cval"
