#!/bin/bash
RG=$(az aks show --resource-group couponResourceGroup --name stagingAKSCluster --query nodeResourceGroup -o tsv)
diskName=gitlab-origin
az disk update \
  --resource-group $RG \
  --name $diskName \
  --size-gb 5 \
  --query id --output tsv \
  --sku Premium_LRS
