# External Secrets

Install [external-secrets.io](https://external-secrets.io/) with helm

```bash
helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace
```

### GCP

Create a secret of your service account

```bash
# @see this https://blog.container-solutions.com/tutorial-how-to-set-external-secrets-with-gcp-secret-manager
# if you dont have this "service_account.json" you have to create a service account with the minimum acess roles

kubectl create secret generic gcpsm-secret \
  -n external-secrets \
  --from-file=secret-access-credentials=/path/to/service_account.json
```
### AWS

Create a secret containing your credentials

```bash
# @see https://external-secrets.io/latest/introduction/getting-started/#create-a-secret-containing-your-aws-credentials
echo -n 'KEYID' > ./access-key
echo -n 'SECRETKEY' > ./secret-access-key
kubectl create secret generic awssm-secret --from-file=./access-key --from-file=./secret-access-key
```

### Create your Cluster Secret Store


Change the the variables in the `external-secrets-{gcp|aws}.yaml` and apply it to ks8

```bash
kubectl apply -f external-secrets-{gcp|aws}.yaml
```
