# https://medium.com/@seifeddinerajhi/from-http-to-https-enabling-https-only-kubernetes-ingress-with-cert-manager-ad2ff06e5b85
# https://cert-manager.io/docs/devops-tips/syncing-secrets-across-namespaces/
# https://cert-manager.io/docs/troubleshooting/

service/environment cluster
```
gcloud container clusters get-credentials $K_CLUSTER_NAME --zone=$ZONE
```

install cert-manager
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
```

install nginx
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-controller ingress-nginx/ingress-nginx
```

apply config
```
kubectl apply -f $WORKSPACE/shoppr/gcloud-tools/container/ssl-config/clusterissuer.yml
kubectl apply -f $WORKSPACE/shoppr/gcloud-tools/container/ssl-config/certificate.yml
kubectl apply -f $WORKSPACE/shoppr/gcloud-tools/container/ssl-config/reflector.yml
```

get services | external IP for DNS
```
kubectl get services
```