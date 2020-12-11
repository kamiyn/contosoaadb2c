#!/bin/sh
baseName=`jq -r .baseName < secrets.json`
randsuffix=`jq -r .randsuffix < secrets.json`

if [ -z "$baseName" -o -z "$randsuffix" ]; then
  echo 'please set secrets.json'
  echo example: source ./00config.sh
  exit
fi

export AZDEPLOY_SUBSCRIPTIONID=`jq -r .subscriptionId < secrets.json`
export AZDEPLOY_LOCATION=`jq -r .location < secrets.json`

export AZDEPLOY_RESOURCEGROUPNAME="rg-${baseName}"
export AZDEPLOY_KEYVAULTNAME="kv-${baseName}-${randsuffix}"
export AZDEPLOY_KEYVAULTGROUP=$AZDEPLOY_RESOURCEGROUPNAME
export AZDEPLOY_APPSERVICEPLANNAME="plan-${baseName}-${randsuffix}"
export AZDEPLOY_APPSERVICENAME="app-${baseName}-${randsuffix}"
export AZDEPLOY_APPLICATIONINSIGHTSNAME="appi-${baseName}-${randsuffix}"

if [ ${#AZDEPLOY_KEYVAULTNAME} -ge 24 ]; then
  echo 'set AZDEPLOY_KEYVAULTNAME length <= 24'
  exit
fi

# do
az account set --subscription $AZDEPLOY_SUBSCRIPTIONID
if [ `az group exists -g $AZDEPLOY_RESOURCEGROUPNAME` = 'false' ]; then
  az group create --location $AZDEPLOY_LOCATION -g $AZDEPLOY_RESOURCEGROUPNAME
fi
az configure --defaults group=$AZDEPLOY_RESOURCEGROUPNAME location=$AZDEPLOY_LOCATION

echo az account show --query '[id,name]'
az account show --query '[id,name]'
echo az configure
az configure -l
env | fgrep AZDEPLOY
