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

az aks nodepool list --cluster-name yourClusterName --resource-group yourResourceGroup

az aks nodepool add \
    --cluster-name yourClusterName \
    --resource-group yourResourceGroup \
    --name systempool \
    --node-count 1 \
    --node-taints CriticalAddonsOnly=true:NoSchedule \
    --mode system

az aks nodepool scale \
    --name systempool \
    --cluster-name yourClusterName \
    --resource-group yourResourceGroup \
    --node-count 3

az aks nodepool add \
    --name nodepoolapp \
    --resource-group yourResourceGroup \
    --cluster-name yourClusterName \
    --node-vm-size Standard_D16s_v3 \
    --node-count 1 \
    --mode user
