{{/*
Expand the name of the chart.
*/}}
{{- define "resource.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "resource.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "resource.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "resource.labels" -}}
helm.sh/chart: {{ include "resource.chart" . }}
{{ include "resource.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "resource.selectorLabels" -}}
app.kubernetes.io/name: {{ include "resource.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Get the AWS account ID based on environment
*/}}
{{- define "resource.accountId" -}}
{{- .Values.global.accountId }}
{{- end }}

{{/*
Get the AWS region
*/}}
{{- define "resource.region" -}}
{{- .Values.global.region | default "us-east-2" }}
{{- end }}

{{/*
Get the provider config name
*/}}
{{- define "resource.providerConfig" -}}
{{- .Values.global.providerConfig }}
{{- end }}