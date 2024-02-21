#!/bin/bash
NS=kube-ops
BASEDIR=$(dirname "$0")
helm install gitlab-runner gitlab/gitlab-runner -f $BASEDIR/values.yaml --namespace $NS
