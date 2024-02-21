#!/bin/bash
helm install prometheus stable/prometheus-operator --namespace kube-ops \
--set prometheusOperator.hostNetwork=true \
--set prometheus.service.type=ClusterIP \
--set grafana.service.type=ClusterIP \
--set grafana.service.port=3000 \
--set prometheus.prometheusSpec.externalUrl=https://uat-cn.loreal.wans/prometheus/ \
-f grafana.yaml
#--set grafana."grafana\.ini".server.root_url=https://uat-cn.loreal.wans/grafana
