# AWS

## Creating a VPC

VPC > Your VPCs > Create VPC

## Creating a Cluster

EK > Cluster > Create EKS cluster

## Client VPN endpoing

@see https://gist.github.com/monkut/16d79d98752039c0e36dcb0dbcb0a9b8

TOOLS
  create over private subnets only

QA/PROD
  enable the assign public ips for the public subnets
  create over private and public subnets
  security group add the tools security group all trafic

### Add new cluster

```bash
argocd login
argocd cluster add {context-already-added}
```
