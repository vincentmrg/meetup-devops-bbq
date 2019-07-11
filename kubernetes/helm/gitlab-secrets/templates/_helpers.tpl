{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gitlab-secrets.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gitlab-secrets.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gitlab-secrets.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the registry storage's secret data.
*/}}
{{- define "registrySecret" }}
# Example configuration of registry `storage` secret
# Example for Google Cloud Storage
#   See https://docs.docker.com/registry/storage-drivers/gcs
#   See https://gitlab.com/charts/gitlab/tree/master/doc/charts/registry/#storage
#   See https://gitlab.com/charts/gitlab/blob/master/doc/advanced/external-object-storage
{{ printf "gcs:" }}
{{ printf "bucket: %s" .Values.registry.bucket | indent 2}}
{{ printf "# This should match the name provided to `extraKey` property." | indent 2 }}
{{ printf "keyFile: /etc/docker/registry/storage/%s" .Values.registry.keyFile | indent 2 }}
{{- end }}

{{/*
Create the storage connection secret data.
*/}}
{{- define "storageSecret" }}
{{ printf "provider: Google" }}
{{ printf "google_project: %s" .Values.storage.googleProject }}
{{ printf "google_client_email: %s" .Values.storage.googleClientEmail }}
{{ printf "google_json_key_string: |-" }}
{{ printf .Values.storage.storageServiceAccountKey | b64dec | indent 2}}
{{- end }}

{{/*
Create the s3cmd config secret data.
*/}}
{{- define "s3cmdSecret" }}
{{ printf "[default]" }}
 {{ printf "host_base = storage.googleapis.com" }}
 {{ printf "host_bucket = storage.googleapis.com" }}
 {{ printf "use_https = True" }}
 {{ printf "signature_v2 = True" }}
 {{ printf "# Access and secret key can be generated in the interoperability" }}
 {{ printf "# https://console.cloud.google.com/storage/settings" }}
 {{ printf "# See Docs: https://cloud.google.com/storage/docs/interoperability" }}
 {{ printf "access_key = %s" .Values.s3cmd.accessKey }}
 {{ printf "secret_key = %s" .Values.s3cmd.secretKey }}
 {{ printf "# Multipart needs to be disabled for GCS !" }}
 {{ printf "enable_multipart = False" }}
{{- end }}