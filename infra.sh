#!/bin/bash
#aks
az network vnet subnet create \
  --name EC2QDLAPPSN02 \
  --resource-group EC2QDLRG01 \
  --address-prefixes 10.162.66.240/28 \
  --vnet-name EC2QDLVN01

SUBNET_ID=$(az network vnet subnet show --resource-group EC2QDLRG01 --vnet-name EC2QDLVN01 --name EC2QDLAPPSN02 --query id -o tsv)

az aks create \
    --resource-group couponResourceGroup \
    --name stagingAKSCluster \
    --node-count 3 \
    --node-vm-size Standard_DS2_v2 \
    --network-plugin kubenet \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --pod-cidr 10.244.0.0/16 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id $SUBNET_ID \
    --service-principal 3f6090be-07d0-4ad1-b610-b6ef2bb5f090 \
    --client-secret 7e_NXvlUE61.3iLE5od4_z7LYSgHrI.z_Z

#acr
az acr create --resource-group couponResourceGroup --name stagingACR --sku Basic

#disk
RG=$(az aks show --resource-group couponResourceGroup --name stagingAKSCluster --query nodeResourceGroup -o tsv)

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

#vm
az vm create \
    --resource-group couponResourceGroup \
    --name couponVM \
    --image UbuntuLTS \
    --admin-username azureuser \
    --generate-ssh-keys \
    --subnet $SUBNET_ID
