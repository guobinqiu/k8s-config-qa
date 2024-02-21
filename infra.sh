#!/bin/bash
#aks
az network vnet subnet create \
  --name yourSubnetName \
  --resource-group yourResourceGroup \
  --address-prefixes 10.162.66.240/28 \
  --vnet-name yourVNetName

SUBNET_ID=$(az network vnet subnet show --resource-group yourResourceGroup --vnet-name yourVNetName --name yourSubnetName --query id -o tsv)

az aks create \
    --resource-group yourResourceGroup \
    --name yourClusterName \
    --node-count 3 \
    --node-vm-size Standard_DS2_v2 \
    --network-plugin kubenet \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --pod-cidr 10.244.0.0/16 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id $SUBNET_ID \
    --service-principal *** \
    --client-secret ***

#acr
az acr create --resource-group yourResourceGroup --name stagingACR --sku Basic

#disk
RG=$(az aks show --resource-group yourResourceGroup --name yourClusterName --query nodeResourceGroup -o tsv)

#gitlab
diskName=gitlab-origin
az disk create \
  --resource-group $RG \
  --name $diskName \
  --size-gb 5 \
  --query id --output tsv \
  --sku Premium_LRS

#mysql
diskName=mysql-origin
az disk create \
  --resource-group $RG \
  --name $diskName \
  --size-gb 5 \
  --query id --output tsv \
  --sku Premium_LRS

#postgresql
diskName=postgresql-origin
az disk create \
  --resource-group $RG \
  --name $diskName \
  --size-gb 5 \
  --query id --output tsv \
  --sku Premium_LRS

#redis
diskName=redis-origin
az disk create \
  --resource-group $RG \
  --name $diskName \
  --size-gb 5 \
  --query id --output tsv \
  --sku Premium_LRS