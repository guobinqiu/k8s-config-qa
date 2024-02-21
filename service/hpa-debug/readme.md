# Test

### Watch

```bash
kubectl get hpa
kubectl get deployment php-apache
```

### Run presure test

```bash
kubectl port-forward php-apache-7f56dc9fcc-s4csc 8090:80
while true; do wget -q -O- http://localhost:8090/; done
```

