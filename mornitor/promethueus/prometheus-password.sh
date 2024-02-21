#!/bin/bash
#kubectl get secret -n kube-ops prometheus-grafana -o yaml
username=$(kubectl get secret -n kube-ops prometheus-grafana -o jsonpath="{.data.admin-user}" | base64 --decode)
password=$(kubectl get secret -n kube-ops prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
echo -e "$username\n$password"
