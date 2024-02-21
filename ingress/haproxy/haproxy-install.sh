#!/bin/bash
BASEDIR=$(dirname "$0")
helm install haproxy-ingress haproxy-ingress/haproxy-ingress \
  -f $BASEDIR/haproxy-ingress-values.yaml \
  -f $BASEDIR/internal-ingress.yaml \
  --namespace kube-ops
