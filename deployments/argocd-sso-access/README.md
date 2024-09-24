# Enabling sso

References:
- https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/google/
- https://dexidp.io/docs/connectors/google/
- https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/

Edit argocd-cm and add this on the data section:

```bash
kubectl edit cm argocd-cm -n argocd
```

```yml
data:
  url: https://argocd.tools.gaiadynamics.ai
  dex.config: |
    connectors:
    - config:
        issuer: https://accounts.google.com
        clientID: {{clientId}}
        clientSecret: {{clientSecret}}
      type: oidc
      id: google
      name: Google
```

Apply the configmap.yml

```bash
kubectl apply -f configmap.yml
```

Restart argocd deployments

```bash
kubectl rollout restart deployment argocd-dex-server -n argocd
kubectl rollout restart deployment argocd-server  -n argocd
```
