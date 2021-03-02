{{/*
Common labels
*/}}
{{- define "pong-crds.labels" -}}
app.kubernetes.io/name: pong-crds
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
