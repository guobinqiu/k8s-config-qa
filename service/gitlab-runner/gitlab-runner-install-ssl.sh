#!/bin/bash
NS=kube-ops
BASEDIR=$(dirname "$0")
kubectl create secret generic gitlab-domain-cert \
--from-file=gitlab.azk8s.cn.crt=$BASEDIR/../gitlab/certs/gitlab.crt \
--namespace $NS
helm install gitlab-runner gitlab/gitlab-runner -f $BASEDIR/values.ssl.yaml --namespace $NS
