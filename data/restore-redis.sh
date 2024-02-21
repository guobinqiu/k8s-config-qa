#!/bin/bash
snapshotName=$1
diskName="$snapshotName-$(date +%Y%m%d%H%M%S)"
RG=$(az aks show --resource-group yourResourceGroup --name yourClusterName --query nodeResourceGroup -o tsv)
az disk create --resource-group $RG --name $diskName --source $snapshotName
diskID=$(az disk show --resource-group $RG --name $diskName --query id -o tsv)
cat <<-EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: kube-ops
  labels:
    name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      name: redis
  template:
    metadata:
      name: redis
      labels:
        name: redis
    spec:
      containers:
      - name: redis
        image: sameersbn/redis:4.0.9-3
        imagePullPolicy: IfNotPresent
        ports:
        - name: redis
          containerPort: 6379
        volumeMounts:
        - mountPath: /var/lib/redis
          name: data
        livenessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 30
          timeoutSeconds: 5
        readinessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          timeoutSeconds: 1
      volumes:
      - name: data
        azureDisk:
          kind: Managed
          diskName: $diskName
          diskURI: $diskURI
EOF
