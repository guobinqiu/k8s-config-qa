#!/bin/bash
RG=$(az aks show --resource-group couponResourceGroup --name stagingAKSCluster --query nodeResourceGroup -o tsv)
diskName=postgresql-origin
diskURI=$(az disk show --name $diskName --resource-group $RG --query id -o tsv)
cat <<-EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
  namespace: kube-ops
  labels:
    name: postgresql
spec:
  replicas: 1
  selector:
    matchLabels:
      name: postgresql
  template:
    metadata:
      name: postgresql
      labels:
        name: postgresql
    spec:
      containers:
      - name: postgresql
        image: sameersbn/postgresql:10
        imagePullPolicy: IfNotPresent
        env:
        - name: DB_USER
          value: deploy
        - name: DB_PASS
          value: passw0rd
        - name: DB_NAME
          value: gitlab,keycloak
        - name: DB_EXTENSION
          value: pg_trgm
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
          diskURI: $diskURI
---
apiVersion: v1
kind: Service
metadata:
  name: postgresql
  namespace: kube-ops
  labels:
    name: postgresql
spec:
  ports:
  - name: postgres
    port: 5432
    targetPort: postgres
  selector:
    name: postgresql
EOF
