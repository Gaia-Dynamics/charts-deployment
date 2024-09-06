# Automated Deploys

## Pull from private registry

### GCP

Add the docker registry credentials to the cluster

```bash
docker logout

cat ../reisraff-service-account.json | docker login -u _json_key --password-stdin us-central1-docker.pkg.dev

# it should be for all existing namespaces
export NAMESPACE=sid-frontend

kubectl create secret generic regcred -n $NAMESPACE \
    --from-file=.dockerconfigjson=/home/reisraff/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
```

### AWS

Adds the policy "AmazonEC2ContainerRegistryReadOnly" to the profile of the cluster's node group

## Finishing up

On argocd in the `Settings >> Repositories` add the repository of the `apps` and its credentials.

Create a "project" on argocd with the same name as [deployments/apps/application.yaml:22](https://github.com/Gaia-Dynamics/deployment/blob/main/deployments/apps/application.yaml#L22)

And this project have to have configured the sections: "SOURCE REPOSITORIES", "DESTINATIONS" and "CLUSTER RESOURCE ALLOW LIST" allowing this deployment.

@todo Try to make this "create project" thing gitops as well

Apply the kustomization of the deployer

```bash
kubectl apply -k apps/
```
