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

az aks nodepool list --cluster-name stagingAKSCluster --resource-group couponResourceGroup

az aks nodepool add \
    --cluster-name stagingAKSCluster \
    --resource-group couponResourceGroup \
    --name systempool \
    --node-count 1 \
    --node-taints CriticalAddonsOnly=true:NoSchedule \
    --mode system

az aks nodepool scale \
    --name systempool \
    --cluster-name stagingAKSCluster \
    --resource-group couponResourceGroup \
    --node-count 3

az aks nodepool add \
    --name nodepoolapp \
    --resource-group couponResourceGroup \
    --cluster-name stagingAKSCluster \
    --node-vm-size Standard_D16s_v3 \
    --node-count 1 \
    --mode user

az aks nodepool delete \
    --cluster-name stagingAKSCluster \
    --name nodepool1 \
    --resource-group couponResourceGroup
