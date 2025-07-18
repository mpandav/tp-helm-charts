{{/*
Copyright © 2025. Cloud Software Group, Inc.
This file is subject to the license terms contained
in the license file that is distributed with this file.
*/}}

{{/* from community chart */}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prometheus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create labels for prometheus
*/}}
{{- define "prometheus.common.matchLabels" -}}
app.kubernetes.io/name: {{ include "prometheus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create unified labels for prometheus components
*/}}
{{- define "prometheus.common.metaLabels" -}}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ include "prometheus.chart" . }}
app.kubernetes.io/part-of: {{ include "prometheus.name" . }}
{{- with .Values.commonMetaLabels}}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "prometheus.server.labels" -}}
{{ include "prometheus.server.matchLabels" . }}
{{ include "prometheus.common.metaLabels" . }}
{{- end -}}

{{- define "prometheus.server.matchLabels" -}}
app.kubernetes.io/component: {{ .Values.server.name }}
{{ include "prometheus.common.matchLabels" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.fullname" -}}
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
Create a fully qualified ClusterRole name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.clusterRoleName" -}}
{{- if .Values.server.clusterRoleNameOverride -}}
{{ .Values.server.clusterRoleNameOverride | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{ include "prometheus.server.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified alertmanager name for communicating and check to ensure that `alertmanager` exists before trying to use it with the user via NOTES.txt
*/}}
{{- define "prometheus.alertmanager.fullname" -}}
{{- if .Subcharts.alertmanager -}}
{{- template "alertmanager.fullname" .Subcharts.alertmanager -}}
{{- else -}}
{{- "alertmanager not found" -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified Prometheus server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get KubeVersion removing pre-release information.
*/}}
{{- define "prometheus.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.Version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "prometheus.deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "prometheus.networkPolicy.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "prometheus.podDisruptionBudget.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1" }}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for rbac.
*/}}
{{- define "rbac.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" }}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19.x" (include "prometheus.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "ingress.supportsIngressClassName" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "prometheus.kubeVersion" .))) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "prometheus.kubeVersion" .))) -}}
{{- end -}}

{{/*
Create the name of the service account to use for the server component
*/}}
{{- define "prometheus.serviceAccountName.server" -}}
{{- if .Values.serviceAccounts.server.create -}}
    {{ default (include "prometheus.server.fullname" .) .Values.serviceAccounts.server.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.server.name }}
{{- end -}}
{{- end -}}

{{/*
Define the prometheus.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "prometheus.namespace" -}}
  {{- default .Release.Namespace .Values.forceNamespace -}}
{{- end }}

{{/*
Define template prometheus.namespaces producing a list of namespaces to monitor
*/}}
{{- define "prometheus.namespaces" -}}
{{- $namespaces := list }}
{{- if and .Values.rbac.create .Values.server.useExistingClusterRoleName }}
  {{- if .Values.server.namespaces -}}
    {{- range $ns := join "," .Values.server.namespaces | split "," }}
      {{- $namespaces = append $namespaces (tpl $ns $) }}
    {{- end -}}
  {{- end -}}
  {{- if .Values.server.releaseNamespace -}}
    {{- $namespaces = append $namespaces (include "prometheus.namespace" .) }}
  {{- end -}}
{{- end -}}
{{ mustToJson $namespaces }}
{{- end -}}

{{/*
Define prometheus.server.remoteWrite producing a list of remoteWrite configurations with URL templating
*/}}
{{- define "prometheus.server.remoteWrite" -}}
{{- $remoteWrites := list }}
{{- range $remoteWrite := .Values.server.remoteWrite }}
  {{- $remoteWrites = tpl $remoteWrite.url $ | set $remoteWrite "url" | append $remoteWrites }}
{{- end -}}
{{ toYaml $remoteWrites }}
{{- end -}}

{{/*
Define prometheus.server.remoteRead producing a list of remoteRead configurations with URL templating
*/}}
{{- define "prometheus.server.remoteRead" -}}
{{- $remoteReads := list }}
{{- range $remoteRead := .Values.server.remoteRead }}
  {{- $remoteReads = tpl $remoteRead.url $ | set $remoteRead "url" | append $remoteReads }}
{{- end -}}
{{ toYaml $remoteReads }}
{{- end -}}

{{/* end community chart */}}
{{/* begin control plane additions */}}

{{/* Get control plane environment configuration value from a key. key = key name in configmap, default = If key not found or configmap does not exist then the return default  */}}
{{/* required = if this key is mandatory or not, Release = get cm namespace from inbuilt .Release object */}}
{{/* usage =  include "cp-env.get" (dict "key" "CP_SERVICE_ACCOUNT_NAME" "default" "control-plane-sa" "required" "true"  "Release" .Release )  */}}
{{- define "cp-env.get" }}
{{- $cm := ((include "cp-env" .)| fromYaml) }}
{{- if $cm }} {{- /* configmap exists */ -}}
  {{- if (hasKey $cm "data") }}
    {{- if (hasKey $cm.data .key) }}
      {{- $val := (get $cm.data .key) }}
      {{- $val }}
    {{- else -}} {{- /* key does not exists */ -}}
       {{- if eq .required "true" }}{{ fail (printf "%s missing key in configmap cp-env" .key)}}{{ else }}{{ .default }}{{ end }}
    {{- end -}}
  {{- else -}}{{- /* data key does not exists */ -}}
    {{- if eq .required "true" }}{{ fail (printf "data key missing in configmap cp-env")}}{{ else }}{{ .default }}{{ end }}
  {{- end }}
{{- else }} {{- /* configmap does not exists */ -}}
    {{- if eq .required "true" }}{{ fail (printf "missing configmap cp-env")}}{{ else }}{{ .default }}{{ end }}
{{- end }}
{{- end }}
{{/* Control plane environment configuration. This will have shared configuration used across control plane components. */}}
{{- define "cp-env" -}}
{{- $data := (lookup "v1" "ConfigMap" .Release.Namespace "cp-env") }}
{{- $data | toYaml }}
{{- end }}


{{/* Service account configured for control plane. fail if service account not exist */}}
{{- define "tp-cp-prometheus.service-account-name" }}
{{- if .Values.serviceAccount }}
  {{- .Values.serviceAccount }}
{{- else }}
  {{- include "cp-env.get" (dict "key" "CP_SERVICE_ACCOUNT_NAME" "default" "control-plane-sa" "required" "false"  "Release" .Release )}}
{{- end }}
{{- end }}

{{/* PVC configured for control plane. Fail if the pvc not exist */}}
{{- define "tp-cp-prometheus.pvc-name" }}
{{- if .Values.pvcName }}
  {{- .Values.pvcName }}
{{- else }}
{{- include "cp-env.get" (dict "key" "CP_PVC_NAME" "default" "control-plane-pvc" "required" "false"  "Release" .Release )}}
{{- end }}
{{- end }}

{{- define "tp-cp-prometheus.image.registry" }}
{{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY" "default" "csgprdusw2reposaas.jfrog.io" "required" "false" "Release" .Release )}}
{{- end }}


{{/* Image pull secret configured for control plane. default value empty */}}
{{- define "tp-cp-prometheus.container-registry.secret" }}
{{- include "cp-env.get" (dict "key" "CP_CONTAINER_REGISTRY_IMAGE_PULL_SECRET_NAME" "default" "" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane instance Id. default value local */}}
{{- define "tp-cp-prometheus.cp-instance-id" }}
  {{- include "cp-env.get" (dict "key" "CP_INSTANCE_ID" "default" "cp1" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane dns domain. default value local */}}
{{- define "tp-cp-prometheus.dns-domain" -}}
{{- include "cp-env.get" (dict "key" "CP_DNS_DOMAIN" "default" "local" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane provider */}}
{{- define "tp-cp-prometheus.cp-provider" -}}
{{- include "cp-env.get" (dict "key" "CP_PROVIDER" "default" "local" "required" "false"  "Release" .Release )}}
{{- end }}

{{/* Control plane OTEl service */}}
{{- define "tp-cp-prometheus.otelServiceName" -}}
{{- include "cp-env.get" (dict "key" "CP_OTEL_SERVICE" "default" "" "required" "false"  "Release" .Release )}}
{{- end }}
