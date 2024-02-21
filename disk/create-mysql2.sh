#!/bin/bash
RG=$(az aks show --resource-group couponResourceGroup --name stagingAKSCluster --query nodeResourceGroup -o tsv)
diskName=mysql-origin2
az disk create \
  --resource-group $RG \
  --name $diskName \
  --size-gb 500 \
  --query id --output tsv \
  --sku Premium_LRS
