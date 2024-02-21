#!/bin/bash
NS=kube-ops
helm uninstall gitlab-runner --namespace $NS
