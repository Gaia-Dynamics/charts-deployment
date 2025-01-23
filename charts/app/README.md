# Helm Chart Documentation for "app"

This documentation provides an overview of how to configure the `values.yaml` file for the Helm chart "app."

Below are all the configurable values for the chart templates.

[**Current Version:**](https://github.com/Gaia-Dynamics/charts-deployment/releases/latest)

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
    private:                                  # Private Env vars Object
      ENV_NAME: SECERT_KEY_NAME               # Env var Key <-> Value

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

  # Ingress Configuration
  ingress:                                    # Ingress array of object (Optional)
    - domain: example.com                     # Domain
      targetPort: 80                          # Service target port
      paths:                                  # Paths
        - "/"                                 # First path

  # Service Configuration (Exposing Ports)
  service:                                    # Service object (Optional)
    ports:                                    # Array key
      - 80                                    # Ports to expose for the Service
```
