# Helm Chart Documentation for "app"

This documentation provides an overview of how to configure the `values.yaml` file for the Helm chart "app."

Below are all the configurable values for the chart templates.

[**Current Version:**](https://github.com/Gaia-Dynamics/charts-deployment/releases/latest) v1.5.0

## Values Overview

The `values.yaml` file is where you define the configuration options for the chart.

This file includes application-specific configurations, resource settings, environment variables, scaling options, and more.

```yaml
app:

  # General Configuration
  name: app-name                              # Name of the application (used in resources)
  namespace: default                          # Namespace of the app
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

  # Environment Variables (ConfigMap for public, Secret for private)
  env:                                        # Env Object (Optional)
    public:                                   # Public Env vars Object
      DATABASE_URL: "db-url"                  # Env var Key <-> Value
      SECRET_KEY: "secret-key"                # Env var Key <-> Value
    secretName: "[ENV]/[APP_NAME]"            # AWS Secrets Manager key to extract all secrets from (Optional)

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
    certificateArn: "arn:aws:acm:us-east-2:971422706275:certificate/d40f8a67-f864-49a0-800e-bb37ad38d9b9"  # (Required) ACM certificate ARN
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
```
