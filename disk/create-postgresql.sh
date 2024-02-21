#!/bin/bash
RG=$(az aks show --resource-group yourResourceGroup --name yourClusterName --query nodeResourceGroup -o tsv)
diskName=postgresql-origin
az disk create \
  --resource-group $RG \
  --name $diskName \
  --size-gb 5 \
  --query id --output tsv \
  --sku Premium_LRS
