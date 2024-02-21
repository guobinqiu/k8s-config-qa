#!/bin/bash
RG=$(az aks show --resource-group yourResourceGroup --name yourClusterName --query nodeResourceGroup -o tsv)
ip=$($ az network public-ip show --resource-group $RG --name $1 --query ipAddress --output tsv)
echo $ip
