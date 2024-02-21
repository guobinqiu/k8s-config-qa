#!/bin/bash
RG=$(az aks show --resource-group yourResourceGroup --name yourClusterName --query nodeResourceGroup -o tsv)
ip=$(az network public-ip create --resource-group $RG --name $1 \
--sku Standard \
--allocation-method static \
--query publicIp.ipAddress -o tsv)
echo $ip
