#!/bin/bash
kubectl -n kube-ops get secret $(kubectl -n kube-ops get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"