#!/bin/bash
echo $(kubectl exec -it deploy/jenkins -n kube-ops -- cat /var/jenkins_home/secrets/initialAdminPassword)
