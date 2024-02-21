#!/bin/bash
RG=$(az aks show --resource-group yourResourceGroup --name yourClusterName --query nodeResourceGroup -o tsv)
diskName=gitlab-origin
diskURI=$(az disk show --name $diskName --resource-group $RG --query id -o tsv)
cat <<-EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitlab
  namespace: kube-ops
  labels:
    name: gitlab
spec:
  replicas: 1
  selector:
    matchLabels:
      name: gitlab
  template:
    metadata:
      name: gitlab
      labels:
        name: gitlab
    spec:
      containers:
      - name: gitlab
        image: sameersbn/gitlab:11.8.1
        imagePullPolicy: IfNotPresent
        env:
        - name: TZ
          value: Asia/Shanghai
        - name: GITLAB_TIMEZONE
          value: Beijing
        - name: GITLAB_SECRETS_DB_KEY_BASE
          value: long-and-random-alpha-numeric-string
        - name: GITLAB_SECRETS_SECRET_KEY_BASE
          value: long-and-random-alpha-numeric-string
        - name: GITLAB_SECRETS_OTP_KEY_BASE
          value: long-and-random-alpha-numeric-string
        - name: GITLAB_ROOT_PASSWORD
          value: "1234qwer"
        - name: GITLAB_ROOT_EMAIL
          value: qracle@126.com
        - name: GITLAB_HOST
          value: uat-cn.xxxxx.wans
        - name: GITLAB_RELATIVE_URL_ROOT
          value: /gitlab
        - name: GITLAB_PORT
          value: "80"
        - name: GITLAB_SSH_PORT
          value: "22"
        - name: GITLAB_NOTIFY_ON_BROKEN_BUILDS
          value: "true"
        - name: GITLAB_NOTIFY_PUSHER
          value: "false"
        - name: GITLAB_BACKUP_SCHEDULE
          value: disable
        - name: GITLAB_BACKUP_TIME
          value: 01:00
        - name: DB_TYPE
          value: postgres
        - name: DB_HOST
          value: postgresql
        - name: DB_PORT
          value: "5432"
        - name: DB_USER
          value: deploy
        - name: DB_PASS
          value: passw0rd
        - name: DB_NAME
          value: gitlab
        - name: REDIS_HOST
          value: redis
        - name: REDIS_PORT
          value: "6379"
#        - name: GITLAB_HTTPS
#          value: "true"
#        - name: SSL_SELF_SIGNED
#          value: "true"
        ports:
        - name: http
          containerPort: 80
        - name: ssh
          containerPort: 22
        volumeMounts:
        - mountPath: /home/git/data
          name: data
#        - mountPath: /home/git/data
#          name: data2
#        livenessProbe:
#          httpGet:
#            path: /
#            port: 80
#          initialDelaySeconds: 180
#          timeoutSeconds: 5
#        readinessProbe:
#          httpGet:
#            path: /
#            port: 80
#          initialDelaySeconds: 5
#          timeoutSeconds: 1
      volumes:
      - name: data
        azureDisk:
          kind: Managed
          diskName: $diskName
          diskURI: $diskURI
#      - name: data2
#        persistentVolumeClaim:
#          claimName: pvc-gitlab
---
#apiVersion: v1
#kind: PersistentVolumeClaim
#metadata:
#  name: pvc-gitlab
#  namespace: kube-ops
#spec:
#  accessModes:
#    - ReadWriteOnce
#  resources:
#    requests:
#      storage: 50Gi
#  volumeName: pv-gitlab
#  storageClassName: managed-csi
---
#apiVersion: v1
#kind: PersistentVolume
#metadata:
#  name: pv-gitlab
#spec:
#  capacity:
#    storage: 50Gi
#  accessModes:
#    - ReadWriteOnce
#  persistentVolumeReclaimPolicy: Retain
#  storageClassName: managed-csi
#  csi:
#    driver: disk.csi.azure.com
#    readOnly: false
#    volumeHandle: $diskURI
#    volumeAttributes:
#      fsType: ext4
EOF
