#!/bin/bash
RG=$(az aks show --resource-group yourResourceGroup --name yourClusterName --query nodeResourceGroup -o tsv)

diskName=mysql-origin
diskURI=$(az disk show --name $diskName --resource-group $RG --query id -o tsv)

diskName2=mysql-origin2
diskURI2=$(az disk show --name $diskName2 --resource-group $RG --query id -o tsv)

cat <<-EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: kube-ops
spec:
  selector:
    matchLabels:
      app: mysql
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql:5.7
        name: mysql
        imagePullPolicy: IfNotPresent
        args:
          - "--ignore-db-dir=lost+found"
          - "--datadir=/data/mysql"
        envFrom:
        - secretRef:
            name: mysql-secret
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
#        - name: data
#          mountPath: /var/lib/mysql
        - name: config
          mountPath: /etc/mysql/mysql.conf.d/my.cnf
          subPath: my.cnf
        - name: data2
          mountPath: /data
      volumes:
#      - name: data
#        persistentVolumeClaim:
#          claimName: pvc-mysql
      - name: data2
        azureDisk:
          kind: Managed
          diskName: $diskName2
          diskURI: $diskURI2
      - name: config
        configMap:
          name: mysql-config
---
#apiVersion: v1
#kind: PersistentVolume
#metadata:
#  name: pv-mysql
#  namespace: kube-ops
#spec:
#  accessModes:
#    - ReadWriteOnce
#  azureDisk:
#    kind: Managed
#    diskName: $diskName
#    diskURI: $diskURI
#  capacity:
#    storage: 500Gi
#  persistentVolumeReclaimPolicy: Retain
#  storageClassName: managed-premium
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-mysql
  namespace: kube-ops
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Gi
  volumeName: pv-mysql
  storageClassName: managed-premium
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: kube-ops
  labels:
    app: mysql
spec:
  ports:
  - port: 3306
    targetPort: 3306
  selector:
    app: mysql
  type: ClusterIP
EOF
