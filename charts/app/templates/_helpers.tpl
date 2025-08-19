{{/*
File to define common variables that is used in multiple templates
*/}}

{{/*
Get AWS Account ID based on environment
*/}}
{{- define "app.awsAccountId" -}}
{{- if eq .Values.environment "qa" -}}
516268691093
{{- else -}}
971422706275
{{- end -}}
{{- end -}}

{{/*
Get default certificate ARN based on environment
*/}}
{{- define "app.defaultCertificateArn" -}}
{{- if eq .Values.environment "qa" -}}
arn:aws:acm:us-east-2:516268691093:certificate/c54a25c9-7170-4ab6-b1b0-555891c6b0bf
{{- else if eq .Values.environment "prod" -}}
arn:aws:acm:us-east-2:971422706275:certificate/a56540e5-5573-4162-a494-f8135749a2c8
{{- else -}}
arn:aws:acm:us-east-2:971422706275:certificate/d40f8a67-f864-49a0-800e-bb37ad38d9b9
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
