# Helm Chart Documentation for "app"

This documentation provides an overview of how to configure the `values.yaml` file for the Helm chart "app."

Below are all the configurable values for the chart templates.

[**Current Version:**](https://github.com/Gaia-Dynamics/charts-deployment/releases/latest) v1.10.0

## Values Overview

The `values.yaml` file is where you define the configuration options for the chart.

This file includes application-specific configurations, resource settings, environment variables, scaling options, and more.

```yaml
app:

  # General Configuration
  name: app-name                              # Name of the application (used in resources)
  type: deployment                            # Either deployment or cronjob (default: deployment)
  environment: qa                             # Environment of the application (e.g., qa, prod)
  schedule: "*/5 * * * *"                     # Cron schedule for the CronJob (Optional)
  suspended: false                            # Set to true to suspend the deployment (replicas: 0)

  # Image Configuration
  image:                                      # Image object
    registry: registry                        # Docker registry
    name: image-name                          # Image name
    tag: latest                               # Image tag
    pullPolicy: IfNotPresent                  # Image pull policy (e.g., Always, IfNotPresent)
    command: yarn                             # Command to run in the container (Optional)
    args:                                     # Arguments to pass to the command (Optional)
      - "--arg1"                              # Arg1 (Optional)

  # Hook Configuration (for Jobs in specific stages)
  hooks:                                      # Hooks Array of object (Optional)
    - name: pre-sync-job                      # Name of the hook
      stage: PreSync                          # Type of stage
      image:                                  # Image
        registry: my-registry                 # Registry of the image
        name: my-job-image                    # Image name
        tag: latest                           # Image tag
      command: "run.sh"                       # Command to run in the container (Optional)
      args:                                   # Arguments to pass to the command (Optional)
        - "--option1"                         # Arg1 (Optional)
      deletionPolicy: HookSucceeded           # DeletionPolicy. Default: HookSucceeded

  # Environment Variables (ConfigMap for public, Secrets for private)
  env:                                        # Env Object (Optional)
    public:                                   # Public Env vars Object
      DATABASE_URL: "db-url"                  # Env var Key <-> Value
      SECRET_KEY: "secret-key"                # Env var Key <-> Value
    secrets:                                  # Array of AWS Secrets Manager keys (Optional)
      - "[ENV]/[APP_NAME]"                    # Primary secret (e.g., "qa/platform-api")
      - "[ENV]/rds/[DB_NAME]"                 # Additional secret (e.g., "qa/rds/platform-db")
      # Each secret creates a separate ExternalSecret resource
      # All secrets are merged into the pod's environment variables

  # ConfigMaps (for file-based configuration)
  configMaps:                                 # ConfigMaps Array of objects (Optional)
    - name: nginx-config                      # (Required) Name of the ConfigMap
      mountPath: /etc/nginx/conf.d            # (Required) Path where to mount the ConfigMap
      subPath: ""                             # (Optional) Specific file to mount from ConfigMap
      readOnly: true                          # (Optional, default: false) Mount as read-only
      defaultMode: 0644                       # (Optional) File permissions in octal
      data:                                   # (Required) ConfigMap data as key-value pairs
        default.conf: |                       # File name and content
          server {
            listen 80;
            server_name _;
            location / {
              return 200 "OK";
            }
          }
        custom.conf: |                        # Another file
          # Custom configuration here

  livenessProbe:                              # Liveness Probe Object
    enabled: true                             # Enable the liveness probe
    httpPath: /health                         # HTTP path for liveness check
    httpPort: 80                              # HTTP Port for liveness check
    initialDelaySeconds: 30                   # Initial delay in seconds
    periodSeconds: 10                         # Time in beetwen of a test
    successThreshold: 1                       # Threshold for success
    timeoutSeconds: 3                         # Time out limit in seconds
    failureThreshold: 3                       # Threshold for failure

  readinessProbe:                             # Readiness Probe Object
    enabled: true                             # Enable the readiness probe
    httpPath: /readiness                      # HTTP path for readiness check
    httpPort: 80                              # HTTP Port for liveness check
    initialDelaySeconds: 30                   # Initial delay in seconds
    periodSeconds: 10                         # Time in beetwen of a test
    successThreshold: 1                       # Threshold for success
    timeoutSeconds: 3                         # Time out limit in seconds
    failureThreshold: 3                       # Threshold for failure

  resources:                                  # Resource requests and limits for the Deployment
    requests:                                 # Resources for initialize the app Object
      memory: "512Mi"                         # Memory
      cpu: "500m"                             # CPU
    limits:                                   # Limit of resources of the app Object
      memory: "1Gi"                           # Memory
      cpu: "1"                                # CPU

  # Horizontal Pod Autoscaling Configuration
  autoscaling:                                # Autoscaling Object
    enabled: true                             # Enable HorizontalPodAutoscaler
    minReplicas: 1                            # Minimum number of replicas
    maxReplicas: 5                            # Maximum number of replicas
    targetCPUUtilizationPercentage: 80        # Target CPU utilization
    targetMemoryUtilizationPercentage: 70     # Target memory utilization

    # Scale Up Behavior Configuration
    scaleUpStabilizationWindowSeconds: 120    # How long to wait before scaling up again (default: 120)
    scaleUpPods: 4                            # Maximum number of pods to add in one scaling event (default: 4)
    scaleUpPeriodSeconds: 60                  # How frequently to check if scaling up is needed (default: 60)

    # Scale Down Behavior Configuration
    scaleDownStabilizationWindowSeconds: 600  # How long to wait before scaling down again (default: 600)
    scaleDownPods: 2                          # Maximum number of pods to remove in one scaling event (default: 2)
    scaleDownPeriodSeconds: 120               # How frequently to check if scaling down is needed (default: 120)

  # Pod Scheduling Configuration

  # Workload Profile (Recommended - Simplified Scheduling)
  workload:                                   # Workload profile configuration (Optional)
    profile: compute-intensive                # Workload type: "standard", "compute-intensive", "memory-intensive"
    size: large                              # Resource tier: "small", "medium", "large", "xlarge"
    # Profiles automatically configure tolerations and affinity based on workload type:
    # - standard: General web apps, APIs (no special scheduling requirements)
    # - compute-intensive: AI/ML workloads (tolerates compute nodes, prefers large tier)
    # - memory-intensive: Memory hungry apps (tolerates memory nodes, prefers large tier)
    #
    # Size determines node tier preference:
    # - small/medium: Standard nodes
    # - large/xlarge: Prefers large tier nodes with more resources

  # Legacy Scheduling Configuration (Advanced - Direct Kubernetes Configuration)
  # Note: Workload profiles are ignored when these are specified

  # Tolerations Configuration
  tolerations:                                # Pod tolerations configuration (Optional)
    - key: "workload-type"                    # Taint key to tolerate
      operator: "Equal"                       # Operator (Equal, Exists)
      value: "compute-intensive"              # Taint value to tolerate
      effect: "NoSchedule"                    # Taint effect (NoSchedule, PreferNoSchedule, NoExecute)
    # Tolerations allow pods to be scheduled on nodes with matching taints
    # Useful for dedicated node groups (e.g., compute-intensive, GPU nodes)

  # Node Selector Configuration
  nodeSelector:                               # Node selector configuration (Optional)
    workload-type: "compute-intensive"        # Label key-value pairs for node selection
    instance-type: "c5.2xlarge"              # Additional node labels for targeting
    # NodeSelector ensures pods are only scheduled on nodes with ALL specified labels
    # Provides strict node targeting based on node labels

  # Node Affinity Configuration
  nodeAffinity:                               # Node affinity configuration (Optional)
    key: tier                                 # Label key to match on nodes
    value: large                              # Label value to match on nodes
    # When configured, pods will prefer to be scheduled on nodes with the specified label
    # Uses preferredDuringSchedulingIgnoredDuringExecution - pods can still run on other nodes if needed

  # Ingress Configuration
  ingress:                                    # Ingress array of objects (Optional)
    - domain: example.com                     # (Required) Domain name for ingress
      targetPort: 80                          # (Required) Service target port (usually the port where the app listens on)
      paths:                                  # (Required) Paths configuration
        - path: "/"                          # (Required) Path for ingress
          pathType: "Prefix"                  # (Optional, default: "Prefix") Path Type
          serviceName: *app.name              # (Optional, defaults to app.name) Target service name

  # ALB Configuration
  alb:
    scope: internal                           # (Required) Possible values: internal, internet-facing
    certificateArn: "arn:aws:acm:us-east-2:971422706275:certificate/d40f8a67-f864-49a0-800e-bb37ad38d9b9"  # (Optional) ACM certificate ARN - auto-inferred from environment if not specified
    wafv2AclArn: "arn:aws:wafv2:us-east-2:916509834689:regional/webacl/production-web-acl/daa97d95-c424-420f-aed9-f9079bfae69c"  # (Optional) WAFv2 Web ACL ARN for security protection - auto-inferred for prod environment if not specified
    idleTimeoutSeconds: 60                    # (Optional, default: "60") Connection idle timeout in seconds
    healthcheckInterval: "10"                 # (Optional, default: "10") Health check interval in seconds
    healthcheckPath:                          # (Optional, default: "/") Location of the health check endpoint
    healthcheckTimeout: "5"                   # (Optional, default: "5") Health check timeout in seconds
    healthyThreshold: "2"                     # (Optional, default: "2") Healthy threshold count
    unhealthyThreshold: "2"                   # (Optional, default: "2") Unhealthy threshold count
    successCodes: "200"                        # (Optional, default: "200") Success response codes for health checks

  # Service Configuration (Exposing Ports)
  service:                                    # Service object (Optional)
    ports:                                    # Array key
      - 80                                    # Ports to expose for the Service

  # Linkerd Service Mesh Configuration
  linkerd:                                    # Linkerd configuration (Optional)
    enabled: true                             # Enable Linkerd sidecar injection
    # When enabled, automatically injects Linkerd proxy sidecar into pods
    # Provides automatic mTLS, observability metrics, and traffic management
    # Metrics available: request rates, latencies, success rates, and more
```
