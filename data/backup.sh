#!/bin/bash
namespace=kube-ops
for label in "postgresql" "redis" "gitlab"; do
  podName=$(kubectl get pods --field-selector=status.phase=Running -o=jsonpath="{.items[?(@.metadata.labels.name=='$label')].metadata.name}" -n $namespace)
  RG=$(az aks show --resource-group yourResourceGroup --name yourClusterName --query nodeResourceGroup -o tsv)
  snapshotName="snapshot-$podName-$(date +%Y%m%d%H%M%S)"
  diskID=$(kubectl get pod $podName -n $namespace -o json | jq '.spec.volumes[0].azureDisk.diskURI' -r)
  az snapshot create --resource-group $RG --name $snapshotName --source $diskID
done
