curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo list
helm repo add stable                   https://charts.helm.sh/stable
helm repo add incubator                https://charts.helm.sh/incubator
helm repo add bitnami                  https://charts.bitnami.com/bitnami
helm repo add gitlab                   https://charts.gitlab.io/
helm repo add ingress-nginx            https://kubernetes.github.io/ingress-nginx
helm repo add azure-marketplace	       https://marketplace.azurecr.io/helm/v1/repo
helm repo add jetstack                 https://charts.jetstack.io
helm repo add haproxytech              https://haproxytech.github.io/helm-charts
helm repo add haproxy-ingress          https://haproxy-ingress.github.io/charts
helm repo update
helm repo list
