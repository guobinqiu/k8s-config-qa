#!/bin/bash
snapshotName=$1
diskName="$snapshotName-$(date +%Y%m%d%H%M%S)"
RG=$(az aks show --resource-group couponResourceGroup --name stagingAKSCluster --query nodeResourceGroup -o tsv)
az disk create --resource-group $RG --name $diskName --source $snapshotName
diskID=$(az disk show --resource-group $RG --name $diskName --query id -o tsv)
cat <<-EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: postgresql
  namespace: kube-ops
spec:
  containers:
  - name: postgresql
    image: sameersbn/postgresql:10
    imagePullPolicy: IfNotPresent
    ports:
    - name: postgres
      containerPort: 5432
    volumeMounts:
    - mountPath: /var/lib/postgresql
      name: data
    livenessProbe:
      exec:
        command:
        - pg_isready
        - -h
        - localhost
        - -U
        - postgres
      initialDelaySeconds: 30
      timeoutSeconds: 5
    readinessProbe:
      exec:
        command:
        - pg_isready
        - -h
        - localhost
        - -U
        - postgres
      initialDelaySeconds: 5
      timeoutSeconds: 1
  volumes:
  - name: data
    azureDisk:
      kind: Managed
      diskName: $diskName
      diskURI: $diskID
EOF
