az extension add --name aks-preview
az feature register --name EnableAzureDiskFileCSIDriver --namespace Microsoft.ContainerService --subscription d67a2f1d-59a1-417a-801d-a987246185b3

clusterName=tidbCluster
resourceGroup=yourResourceGroup

#install tidb cluster
az aks create \
    --resource-group ${resourceGroup} \
    --name ${clusterName} \
    --location chinaeast2 \
    --generate-ssh-keys \
    --vm-set-type VirtualMachineScaleSets \
    --load-balancer-sku standard \
    --node-count 1 \
    --aks-custom-headers EnableAzureDiskFileCSIDriver=true

#add pool nodes for tidb components
az aks nodepool add --name admin \
    --cluster-name ${clusterName} \
    --resource-group ${resourceGroup} \
    --aks-custom-headers EnableAzureDiskFileCSIDriver=true \
    --node-count 1 \
    --labels dedicated=admin

az aks nodepool add --name pd \
    --cluster-name ${clusterName} \
    --resource-group ${resourceGroup} \
    --node-vm-size Standard_F4s_v2 \
    --aks-custom-headers EnableAzureDiskFileCSIDriver=true \
    --node-count 3 \
    --labels dedicated=pd \
    --node-taints dedicated=pd:NoSchedule

az aks nodepool add --name tidb \
    --cluster-name ${clusterName} \
    --resource-group ${resourceGroup} \
    --node-vm-size Standard_F8s_v2 \
    --aks-custom-headers EnableAzureDiskFileCSIDriver=true \
    --node-count 2 \
    --labels dedicated=tidb \
    --node-taints dedicated=tidb:NoSchedule

az aks nodepool add --name tikv \
    --cluster-name ${clusterName} \
    --resource-group ${resourceGroup} \
    --node-vm-size Standard_E8s_v4 \
    --aks-custom-headers EnableAzureDiskFileCSIDriver=true \
    --node-count 3 \
    --labels dedicated=tikv \
    --node-taints dedicated=tikv:NoSchedule

az aks nodepool add --name tiflash \
    --cluster-name ${clusterName} \
    --resource-group ${resourceGroup} \
    --node-vm-size Standard_E8s_v4 \
    --aks-custom-headers EnableAzureDiskFileCSIDriver=true \
    --node-count 3 \
    --labels dedicated=tiflash \
    --node-taints dedicated=tiflash:NoSchedule

#az aks nodepool add --name ticdc \
#    --cluster-name ${clusterName} \
#    --resource-group ${resourceGroup} \
#    --node-vm-size Standard_E16s_v4 \
#    --aks-custom-headers EnableAzureDiskFileCSIDriver=true \
#    --node-count 3 \
#    --labels dedicated=ticdc \
#    --node-taints dedicated=ticdc:NoSchedule

az aks get-credentials --resource-group ${resourceGroup} --name ${clusterName}

#install tidb operator crds
kubectl apply -f crd.yaml

kubectl create namespace tidb-admin
kubectl create namespace tidb-cluster

#install tidb operator
helm repo add pingcap https://charts.pingcap.org/
#helm install --namespace tidb-admin tidb-operator pingcap/tidb-operator --version v1.2.4
helm install --namespace tidb-admin tidb-operator pingcap/tidb-operator --version v1.2.4 \
    --set operatorImage=registry.cn-beijing.aliyuncs.com/tidb/tidb-operator:v1.2.4 \
    --set tidbBackupManagerImage=registry.cn-beijing.aliyuncs.com/tidb/tidb-backup-manager:v1.2.4 \
    --set scheduler.kubeSchedulerImageName=registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler
#helm uninstall --namespace tidb-admin tidb-operator

#deploy tidb cluster
kubectl apply -f tidb-cluster.yaml -n tidb-cluster

#deploy tidb monitor
kubectl apply -f tidb-monitor.yaml -n tidb-cluster
