{{/*
File to define common variables that is used in multiple templates
*/}}

{{/*
Get AWS Account ID based on environment
*/}}
{{- define "app.awsAccountId" -}}
{{- if eq .Values.environment "qa" -}}
516268691093
{{- else if eq .Values.environment "prod" -}}
916509834689
{{- end -}}
{{- end -}}

{{/*
Get default certificate ARN based on environment
*/}}
{{- define "app.defaultCertificateArn" -}}
{{- if eq .Values.environment "qa" -}}
arn:aws:acm:us-east-2:516268691093:certificate/718b6860-c7c4-45dc-b96f-63a6b8e2402a
{{- else if eq .Values.environment "prod" -}}
arn:aws:acm:us-east-2:916509834689:certificate/8e8f5c91-4694-4d53-9b1d-f9d541b68654
{{- end -}}
{{- end -}}

{{/*
Get default WAFv2 ACL ARN based on environment
*/}}
{{- define "app.defaultWafv2AclArn" -}}
{{- if eq .Values.environment "prod" -}}
arn:aws:wafv2:us-east-2:916509834689:regional/webacl/production-web-acl/daa97d95-c424-420f-aed9-f9079bfae69c
{{- else -}}
{{- end -}}
{{- end -}}
