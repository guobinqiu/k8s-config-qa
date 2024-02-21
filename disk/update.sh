#!/bin/bash
RG=$(az aks show --resource-group couponResourceGroup --name stagingAKSCluster --query nodeResourceGroup -o tsv)
diskName=$1
size=$2
diskURI=$(az disk update \
  --resource-group $RG \
  --name $diskName \
  --size-gb $size \
  --query id --output tsv \
  --sku Premium_LRS)
