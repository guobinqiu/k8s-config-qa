SUBNET_ID=$(az network vnet subnet show --resource-group EC2QDLRG01 --vnet-name EC2QDLVN01 --name EC2QDLAPPSN02 --query id -o tsv)

az vm create \
    --resource-group couponResourceGroup \
    --name couponVM \
    --image UbuntuLTS \
    --admin-username azureuser \
    --generate-ssh-keys \
    --subnet $SUBNET_ID
