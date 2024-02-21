#!/bin/bash
kubectl exec -n kube-ops -it redis-cluster-0 -- redis-cli --cluster create --cluster-replicas 1 \
$(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 {end}' -n kube-ops)

#check
#kubectl exec -n kube-ops -it redis-cluster-0 -- redis-cli cluster info


#https://faun.pub/fix-redis-cluster-on-kubernetes-cluster-failure-due-to-ip-change-on-pod-restart-97afe2f042ab
