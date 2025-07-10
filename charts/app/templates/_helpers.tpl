{{/*
File to define common variables that is used in multiple templates
*/}}

{{/*
Get AWS Account ID based on environment
*/}}
{{- define "app.awsAccountId" -}}
{{- if eq .Values.app.environment "qa2" -}}
516268691093
{{- else -}}
971422706275
{{- end -}}
{{- end -}}

{{/*
Get default certificate ARN based on environment
*/}}
{{- define "app.defaultCertificateArn" -}}
{{- if eq .Values.app.environment "qa2" -}}
arn:aws:acm:us-east-2:516268691093:certificate/c54a25c9-7170-4ab6-b1b0-555891c6b0bf
{{- else if eq .Values.app.environment "prod" -}}
arn:aws:acm:us-east-2:971422706275:certificate/a56540e5-5573-4162-a494-f8135749a2c8
{{- else -}}
arn:aws:acm:us-east-2:971422706275:certificate/d40f8a67-f864-49a0-800e-bb37ad38d9b9
{{- end -}}
{{- end -}}
