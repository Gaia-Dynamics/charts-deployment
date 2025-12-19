# Resource Chart

Helm chart for managing AWS resources via Crossplane. This chart provisions and manages S3 buckets, RDS databases, SQS queues, IAM roles, and Route53 DNS records for Kubernetes workloads.

## Overview

The resource chart uses Crossplane to provision AWS infrastructure declaratively. Resources are defined in Helm values and Crossplane handles the creation, updates, and lifecycle management of AWS resources.

Key features:
- Automatic secret management for RDS credentials
- IAM policy creation and IRSA integration
- Route53 DNS record management
- Environment-specific defaults (QA/Prod)
- Cross-account secret synchronization

## Installation

This chart is used as a dependency in your application's resource configuration:

```yaml
# Chart.yaml
apiVersion: v2
name: my-service
version: "0.0.1"
type: application

dependencies:
- name: resource
  version: "1.4.26"
  repository: https://gaia-dynamics.github.io/charts-deployment/
```

## Quick Start

Minimal configuration example:

```yaml
resource:
  resourceName: my-service-resources

  s3:
    buckets:
      - name: gaia-my-service-qa
        createPolicy: true
        attachToRoles:
          - my-service-qa

  rds:
    clusters:
      - name: my-service-db-qa

  iam:
    roles:
      - name: role-my-service
        namespace: my-namespace
        serviceAccountName: my-service
```

This creates:
- An S3 bucket with encryption and IAM policy
- A PostgreSQL Aurora cluster with auto-generated password
- A Kubernetes service account with IAM role for AWS access
- Secrets in AWS Secrets Manager for your application

## Resource Types

The chart supports the following AWS resource types:
- **S3 Buckets** - Object storage with encryption, versioning, lifecycle rules
- **RDS Aurora Clusters** - PostgreSQL and MySQL databases with auto-scaling
- **SQS Queues** - Message queues with dead letter queue support
- **IAM Roles** - IRSA roles for Kubernetes service accounts
- **Route53 DNS Records** - DNS management with routing policies

### S3 Buckets

Basic S3 bucket configuration:

```yaml
s3:
  buckets:
    - name: gaia-my-service-qa
      createPolicy: true          # Creates IAM policy for bucket access
      attachToRoles:              # Attach policy to IRSA roles
        - my-service-qa
```

**Defaults:**
- Private access (no public access)
- Server-side encryption enabled
- Versioning disabled
- No lifecycle rules

For advanced options (CORS, lifecycle rules, versioning, etc.), see the complete [values.yaml](values.yaml).

### RDS Aurora Clusters

Minimal RDS configuration:

```yaml
rds:
  clusters:
    - name: my-service-db-qa
```

This automatically configures:
- PostgreSQL 16.4 engine
- Auto-generated secure password
- Environment-specific VPC subnets
- Security group with EKS cluster access
- Connection secret pushed to AWS Secrets Manager

**Connection Secret Format:**

The chart automatically creates a secret at `{environment}/rds/{cluster-name}` in AWS Secrets Manager with:
- `POSTGRES_HOST` - Primary endpoint
- `POSTGRES_PORT` - Port (default 5432)
- `POSTGRES_USER` - Master username
- `POSTGRES_PASSWORD` - Auto-generated password
- `POSTGRES_DB` - Database name
- `POSTGRES_HOST_READ_ONLY` - Reader endpoint for read replicas

Reference this secret in your app configuration:

```yaml
app:
  env:
    secrets:
      - qa/rds/my-service-db-qa
```

**Customizing Secret Keys:**

```yaml
rds:
  clusters:
    - name: my-service-db-qa
      secretKeyNames:
        host: DB_HOST
        port: DB_PORT
        user: DB_USER
        password: DB_PASSWORD
        database: DB_NAME
```

**Production Configuration:**

For production databases, add:

```yaml
rds:
  clusters:
    - name: my-service-db-prod
      skipFinalSnapshot: false       # Create snapshot on deletion
      deletionProtection: true       # Prevent accidental deletion
      backupRetentionPeriod: 30      # Keep backups for 30 days
      instanceCount: 2               # Multi-AZ for high availability
```

### SQS Queues

Basic queue configuration:

```yaml
sqs:
  queues:
    - name: gaia-my-service-queue-qa
      createPolicy: true
      attachToRoles:
        - my-service-qa
```

**Defaults:**
- 30 second visibility timeout
- 4 day message retention
- SSE encryption enabled
- Standard queue (not FIFO)

### IAM Roles (IRSA)

Create IAM roles for Kubernetes service accounts:

```yaml
iam:
  roles:
    - name: role-my-service
      namespace: my-namespace
      serviceAccountName: my-service
      policies:
        - arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

This creates an IAM role with OIDC trust policy for the specified service account. The app chart automatically annotates the service account with the role ARN.

**Naming Convention:** Roles are named as `{name}-{environment}` (e.g., `role-my-service-qa`).

**Attaching Custom Policies:**

When you create S3 buckets or SQS queues with `createPolicy: true` and `attachToRoles`, the chart automatically creates and attaches IAM policies for those resources.

### Route53 DNS Records

Create DNS records in Route53 hosted zones:

```yaml
route53:
  records:
    - name: api-dns-record
      recordName: api.example.com
      type: A
      ttl: 300
      zoneId: Z1234567890ABC
      records:
        - "192.0.2.1"
```

**Record Types Supported:** A, AAAA, CNAME, MX, TXT, NS, SRV, PTR, CAA, and more.

**Zone Reference Methods:**

You can specify the hosted zone in three ways:

1. **Direct Zone ID:**
   ```yaml
   zoneId: Z1234567890ABC
   ```

2. **Reference to Crossplane HostedZone:**
   ```yaml
   zoneIdRef: my-hosted-zone
   ```

3. **Selector by labels:**
   ```yaml
   zoneIdSelector:
     app.kubernetes.io/name: my-zone
   ```

**Common Record Examples:**

CNAME Record:
```yaml
- name: www-cname
  recordName: www.example.com
  type: CNAME
  ttl: 300
  zoneId: Z1234567890ABC
  records:
    - "example.com"
```

MX Record:
```yaml
- name: mail-mx
  recordName: example.com
  type: MX
  ttl: 300
  zoneId: Z1234567890ABC
  records:
    - "10 mail1.example.com"
    - "20 mail2.example.com"
```

TXT Record:
```yaml
- name: spf-txt
  recordName: example.com
  type: TXT
  ttl: 300
  zoneId: Z1234567890ABC
  records:
    - '"v=spf1 include:_spf.example.com ~all"'
```

**Alias Records:**

For AWS resources like ALB, CloudFront, or S3:

```yaml
- name: alb-alias
  recordName: app.example.com
  type: A
  zoneId: Z1234567890ABC
  alias:
    name: my-alb-123456.us-east-2.elb.amazonaws.com
    zoneId: Z3AADJGX6KTTL2  # ELB zone ID (region-specific)
    evaluateTargetHealth: true
```

**Advanced Routing Policies:**

The chart supports all Route53 routing policies:

- **Weighted Routing** - Distribute traffic across multiple resources
- **Latency-based Routing** - Route to lowest latency endpoint
- **Geolocation Routing** - Route based on user location
- **Failover Routing** - Active-passive failover
- **Multi-value Answer** - Return multiple IP addresses

See [values.yaml](values.yaml) for complete examples of each routing policy.

## Global Configuration

Global values are typically set by ArgoCD based on the environment:

```yaml
global:
  environment: qa              # Environment name
  accountId: "516268691093"    # AWS account ID
  region: us-east-2            # AWS region
  providerConfig: default-qa   # Crossplane provider config
  deletionPolicy: Delete       # Delete or Orphan
  namespace: crossplane-system # Namespace for Crossplane resources
```

These values are automatically configured per environment and rarely need to be changed.

## Advanced Configuration

### Multiple Resources

You can define multiple resources of the same type:

```yaml
rds:
  clusters:
    - name: my-service-db-qa
    - name: my-service-analytics-db-qa
      instanceClass: db.r6g.xlarge

s3:
  buckets:
    - name: gaia-my-service-uploads-qa
    - name: gaia-my-service-archives-qa
      lifecycleRules:
        - id: archive-old-data
          status: Enabled
          transitions:
            - storageClass: GLACIER
              days: 90
```

### Custom Tags

Add custom tags to resources:

```yaml
resource:
  customTags:
    owner: backend-team
    cost-center: engineering
    project: gaia

s3:
  buckets:
    - name: gaia-my-service-qa
      tags:
        backup: "true"
        data-classification: internal
```

### RDS Advanced Features

For advanced RDS configuration including:
- Serverless v2 scaling
- Performance Insights
- Enhanced monitoring
- Custom parameter groups
- Read replicas (multiple instances)

See the [values.yaml](values.yaml) for complete options.

## How It Works

1. **Resource Creation**: Crossplane provisions AWS resources based on your configuration
2. **Secret Generation**: RDS passwords are auto-generated and stored in Crossplane secrets
3. **Secret Synchronization**: PushSecret resources copy credentials to AWS Secrets Manager
4. **Application Access**: Apps use ExternalSecret to pull credentials from Secrets Manager

This approach keeps secrets secure and never exposes them in Git or Kubernetes manifests.

## Environment Differences

### QA Environment

- Default deletion policy: `Delete` (resources removed when chart is uninstalled)
- RDS: `skipFinalSnapshot: true` (faster cleanup)
- Smaller instance sizes for cost optimization

### Production Environment

- Default deletion policy: `Orphan` (resources preserved on uninstall)
- RDS: `skipFinalSnapshot: false` (always create final snapshot)
- `deletionProtection: true` (prevent accidental deletion)
- Multi-AZ configurations for high availability
- Extended backup retention periods

## Monitoring Resources

AWS resources can be monitored through:
- [Grafana Dashboard](https://grafana.services.gaiadynamics.ai) - RDS metrics, S3 usage, SQS queue depth
- [ArgoCD Web Interface](https://argocd.services.gaiadynamics.ai) - Crossplane resource sync status

## Troubleshooting

### Resource Not Provisioning

Check ArgoCD for sync status of your resource application. Crossplane resources may take several minutes to provision, especially RDS clusters (10-15 minutes).

### Secret Not Available in Application

1. Verify the RDS cluster name matches your secret reference
2. Check that PushSecret is successfully syncing to AWS Secrets Manager
3. Ensure ExternalSecret in your app namespace is configured correctly

The secret path is: `{environment}/rds/{cluster-name}`

### IAM Permission Issues

Verify:
1. The IAM role is created and has the correct trust policy
2. Service account is annotated with the role ARN
3. Policies are attached to the role (check `attachToRoles` configuration)

## Best Practices

1. **Naming Convention**: Use format `{service-name}-{resource-type}-{environment}` for consistency
2. **Production Safety**: Always set `skipFinalSnapshot: false` and `deletionProtection: true` for production databases
3. **Secret References**: Use the auto-generated secrets rather than hardcoding credentials
4. **IAM Policies**: Create resource-specific policies with `createPolicy: true` instead of overly permissive policies
5. **Tags**: Always tag resources with owner and cost-center for accountability
6. **Backup Strategy**: Set appropriate `backupRetentionPeriod` based on your recovery requirements

## Complete Configuration Reference

For all available configuration options, see the [values.yaml](values.yaml) file which includes:
- All S3 bucket options (CORS, lifecycle, notifications, etc.)
- All RDS options (serverless, monitoring, parameters, etc.)
- All SQS options (FIFO, dead letter queues, etc.)
- IAM inline policies and custom configurations

## Additional Resources

- [Crossplane Documentation](https://docs.crossplane.io/)
- [AWS Provider Documentation](https://marketplace.upbound.io/providers/upbound/provider-aws/)
- [Application Setup Guide](../../../deployments/APPLICATION_SETUP_GUIDE.md)
