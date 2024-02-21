ip=$(az vm show --resource-group couponResourceGroup --name couponVM -d --query [publicIps] --output tsv)
ssh azureuser@$ip