# Install ingress controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-controller ingress-nginx/ingress-nginx
```

# Apply the ingress

```bash
kubectl apply -f ingress.yml
```

# Fixing the too many redirects error

Edit the config map
```bash
kubectl edit configmap argocd-cmd-params-cm -n argocd -o yaml
```

Add this:
```yaml
data:
  server.insecure: "true"
```

Then restart the deployment
```
kubectl rollout restart deployment argocd-server -n argocd
```
